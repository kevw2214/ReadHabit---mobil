import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChapterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _chaptersCollection = 'book_chapters';

  Future<String> getChapterContent(String bookId, int chapter) async {
    try {
      print('DEBUG: Generando capítulo ${chapter + 1} del libro $bookId');

      String sanitizedBookId = _sanitizeBookIdForFirebase(bookId);

      final cachedContent = await _getCachedChapterContent(
        sanitizedBookId,
        chapter,
      );
      if (cachedContent != null) {
        print('DEBUG: Contenido encontrado en cache');
        return cachedContent;
      }

      final bookInfo = await _getBookInfoFromAPI(bookId);

      final chapterContent = _generateNarrativeChapter(bookInfo, chapter);

      await _cacheChapterContent(sanitizedBookId, chapter, chapterContent);

      print('DEBUG: Capítulo narrativo generado y cacheado exitosamente');
      return chapterContent;
    } catch (e) {
      print('DEBUG: Error al generar capítulo: $e');
      return _getDefaultNarrativeContent(chapter);
    }
  }

  Future<Map<String, dynamic>> _getBookInfoFromAPI(String bookId) async {
    try {
      String cleanBookId = bookId.replaceAll('/works/', '').replaceAll('/', '');

      final url = 'https://openlibrary.org/works/$cleanBookId.json';
      print('DEBUG: Obteniendo info del libro desde: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('DEBUG: Información del libro obtenida exitosamente');
        return data;
      } else {
        print(
          'DEBUG: Error al obtener info del libro. Código: ${response.statusCode}',
        );
        return {};
      }
    } catch (e) {
      print('DEBUG: Error en API call: $e');
      return {};
    }
  }

  String _generateNarrativeChapter(
    Map<String, dynamic> bookInfo,
    int chapterIndex,
  ) {
    try {
      String title = bookInfo['title'] ?? 'Historia sin título';
      String description = _extractDescription(bookInfo);
      List<String> subjects = _extractSubjects(bookInfo);
      String genre = subjects.isNotEmpty
          ? subjects.first.toLowerCase()
          : 'ficción';

      return _createNarrativeContent(title, description, genre, chapterIndex);
    } catch (e) {
      print('DEBUG: Error generando contenido narrativo: $e');
      return _getDefaultNarrativeContent(chapterIndex);
    }
  }

  String _extractDescription(Map<String, dynamic> bookInfo) {
    if (bookInfo['description'] != null) {
      if (bookInfo['description'] is String) {
        return bookInfo['description'];
      } else if (bookInfo['description'] is Map &&
          bookInfo['description']['value'] != null) {
        return bookInfo['description']['value'];
      }
    }

    if (bookInfo['first_sentence'] != null) {
      if (bookInfo['first_sentence'] is List &&
          bookInfo['first_sentence'].isNotEmpty) {
        return bookInfo['first_sentence'].join(' ');
      }
    }

    return '';
  }

  List<String> _extractSubjects(Map<String, dynamic> bookInfo) {
    List<String> subjects = [];

    if (bookInfo['subjects'] != null && bookInfo['subjects'] is List) {
      for (var subject in bookInfo['subjects']) {
        if (subject is String) {
          subjects.add(subject);
        }
      }
    }

    return subjects.take(3).toList();
  }

  String _createNarrativeContent(
    String title,
    String description,
    String genre,
    int chapterIndex,
  ) {
    List<String> narrativePatterns = [
      _generateOpeningChapter(title, description, genre, chapterIndex),
      _generateActionChapter(title, description, genre, chapterIndex),
      _generateDialogueChapter(title, description, genre, chapterIndex),
      _generateIntrospectiveChapter(title, description, genre, chapterIndex),
      _generateClimaxChapter(title, description, genre, chapterIndex),
    ];

    int patternIndex = chapterIndex % narrativePatterns.length;
    return narrativePatterns[patternIndex];
  }

  String _generateOpeningChapter(
    String title,
    String description,
    String genre,
    int chapterIndex,
  ) {
    List<String> openings = _getOpeningsByGenre(genre);
    String selectedOpening = openings[chapterIndex % openings.length];

    return '''Capítulo ${chapterIndex + 1}

$selectedOpening

Elena despertó con el sonido de la lluvia golpeando contra su ventana. Había algo diferente en ese sonido, algo que no podía identificar pero que la llenaba de una extraña inquietud.

Se levantó de la cama y se acercó a la ventana. Las calles estaban vacías a esa hora de la madrugada, iluminadas solo por las farolas que creaban charcos de luz amarillenta en el pavimento mojado.

"Otro día", murmuró para sí misma, pero incluso mientras pronunciaba esas palabras, sabía que este día sería diferente. Había una sensación en el aire, como si el mundo mismo estuviera conteniendo la respiración.

Se dirigió a la cocina para preparar café, pero se detuvo en el pasillo cuando notó que la puerta de su apartamento estaba entreabierta. Estaba segura de haberla cerrado con llave la noche anterior.

Con el corazón latiendo más rápido, se acercó cautelosamente. No había señales de forcejeo, nada fuera de lugar. Simplemente estaba abierta, como si alguien hubiera querido dejar un mensaje silencioso.

Elena respiró profundamente y cerró la puerta, asegurándose de echar el cerrojo. Pero la sensación de inquietud no la abandonó. Algo había cambiado, y ella estaba en el centro de ese cambio.

Mientras preparaba su café, no podía dejar de pensar en los eventos extraños que habían comenzado la semana anterior: las llamadas telefónicas sin respuesta, la sensación de ser observada, y ahora esto.

El café humeante le proporcionó algo de consuelo, pero cuando miró por la ventana de la cocina, vio una figura parada bajo la farola del otro lado de la calle, mirando directamente hacia su edificio.

La figura no se movía, simplemente estaba allí, esperando.''';
  }

  String _generateActionChapter(
    String title,
    String description,
    String genre,
    int chapterIndex,
  ) {
    return '''Capítulo ${chapterIndex + 1}

El sonido de pasos apresurados resonaba en el pasillo vacío mientras Marcus corría hacia la salida de emergencia. Su respiración era irregular, y el sudor le corría por la frente.

—¡Está aquí! —gritó por encima del hombro a su compañera—. ¡Tenemos que movernos ahora!

Sarah lo siguió de cerca, con la mochila rebotando contra su espalda con cada paso. Los documentos que habían estado buscando durante meses finalmente estaban en sus manos, pero ahora tenían que llegar a un lugar seguro.

La alarma comenzó a sonar justo cuando llegaron a la puerta de las escaleras. Marcus la empujó con fuerza y comenzaron a bajar los escalones de dos en dos.

—¿Cuánto tiempo crees que tenemos? —preguntó Sarah, jadeando.

—No mucho —respondió Marcus, mirando por encima del pasamanos hacia los pisos superiores—. Pero si podemos llegar al coche...

Sus palabras fueron interrumpidas por el sonido de la puerta del piso superior abriéndose violentamente. Voces airadas se filtraron por el hueco de las escaleras.

—Por aquí —susurró Marcus, señalando una puerta marcada como "Sótano". 

Se deslizaron por la puerta y se encontraron en un laberinto de pasillos subterráneos. Las luces parpadeaban de manera intermitente, creando sombras inquietantes en las paredes de hormigón.

Sarah revisó los documentos rápidamente mientras caminaban. Todo estaba ahí: las pruebas que necesitaban, los nombres, las fechas, todo lo que confirmaría sus sospechas.

—Marcus —dijo en voz baja—, esto es peor de lo que pensábamos. Si esta información es correcta...

Un ruido metálico resonó detrás de ellos. Se habían quedado sin tiempo.

—Corre —dijo Marcus, empujándola hacia adelante—. No importa lo que pase, no te detengas.

Y corrieron, con el destino de muchas personas dependiendo de que llegaran a su destino a tiempo.''';
  }

  String _generateDialogueChapter(
    String title,
    String description,
    String genre,
    int chapterIndex,
  ) {
    return '''Capítulo ${chapterIndex + 1}

—No puedes estar hablando en serio —dijo Ana, dejando su taza de café sobre la mesa con más fuerza de la necesaria.

Carlos la miró desde el otro lado de la mesa del café, sus ojos reflejando una mezcla de determinación y dolor.

—Nunca he hablado más en serio en mi vida —respondió—. Es la única forma de que esto funcione.

—¿La única forma? —Ana se inclinó hacia adelante—. Carlos, hemos estado juntos por cinco años. Cinco años, y ahora me dices que todo eso no significa nada?

—No he dicho que no signifique nada —Carlos suspiró profundamente—. He dicho que las cosas han cambiado. Yo he cambiado.

El café estaba lleno de gente, pero para Ana era como si estuvieran solos en el mundo. Las conversaciones de las otras mesas se desvanecían en un murmullo de fondo.

—¿Cuándo? —preguntó, su voz apenas un susurro—. ¿Cuándo cambiaste?

Carlos miró por la ventana hacia la calle bulliciosa.

—Creo que ha sido gradual. Pero me di cuenta la semana pasada, cuando recibí esa oferta de trabajo en Barcelona.

—Barcelona —Ana repitió la palabra como si fuera veneno—. Nunca mencionaste Barcelona.

—Porque sabía que reaccionarías así.

—¿Cómo? ¿Como alguien que te ama y no quiere perderte?

Carlos finalmente la miró a los ojos.

—Ana, tú tienes tu vida aquí. Tu trabajo, tu familia, tus amigos. No puedo pedirte que lo abandones todo.

—Pero sí puedes abandonarme a mí.

El silencio se extendió entre ellos como un abismo. Ana pudo ver en los ojos de Carlos que ya había tomado su decisión, probablemente semanas atrás.

—Cuando te conocí —dijo Ana, con la voz temblando ligeramente—, pensé que habíamos encontrado algo especial. Algo que valía la pena luchar por ello.

—Y lo hicimos —Carlos extendió su mano sobre la mesa, pero Ana la retiró—. Pero a veces amar a alguien significa saber cuándo dejarlo ir.

Ana se puso de pie, tomando su bolso.

—No, Carlos. A veces amar a alguien significa luchar por ello, incluso cuando es difícil. Especialmente cuando es difícil.

Y con esas palabras, salió del café, dejando a Carlos solo con sus decisiones y sus arrepentimientos.''';
  }

  String _generateIntrospectiveChapter(
    String title,
    String description,
    String genre,
    int chapterIndex,
  ) {
    return '''Capítulo ${chapterIndex + 1}

Sentado en el banco del parque, David observaba cómo las hojas otoñales danzaban en el viento. Cada hoja que caía le recordaba una decisión que había tomado, una oportunidad que había perdido, un momento que no podía recuperar.

Había estado viniendo a este parque durante tres semanas, siempre al mismo banco, siempre a la misma hora. Era aquí donde podía pensar con claridad, donde el ruido de la ciudad se desvanecía lo suficiente como para escuchar sus propios pensamientos.

La carta en su bolsillo parecía pesar más cada día. Aún no la había abierto, aunque llevaba el sello de la universidad donde había estudiado hacía veinte años. Sabía lo que contenía, o al menos creía saberlo.

Un niño corrió frente a él, persiguiendo una pelota que rodaba por el sendero. Su risa pura y sin complicaciones contrastaba fuertemente con la pesadez que David sentía en el pecho.

¿Cuándo había perdido esa simplicidad? ¿Cuándo había comenzado a complicar cada decisión, a dudar de cada instinto?

Recordó la conversación con su esposa la noche anterior. Ella había sido directa, como siempre.

"David, no puedes seguir viviendo en el pasado. Lo que pasó, pasó. Lo que no pasó, no pasó. Pero la vida sigue adelante, con o sin ti."

Tenía razón, por supuesto. Siempre tenía razón.

Sacó la carta del bolsillo y la miró. El papel estaba ligeramente arrugado de tanto manipularlo. Con un movimiento decidido, la abrió.

Las palabras bailaron frente a sus ojos al principio, pero luego se enfocaron. Era una invitación. Una segunda oportunidad. Una posibilidad que había creído perdida para siempre.

David sonrió por primera vez en semanas. A veces la vida te da exactamente lo que necesitas, justo cuando crees que es demasiado tarde.

Se levantó del banco, guardó la carta y comenzó a caminar hacia casa. Tenía una llamada telefónica que hacer y una conversación que tener con su esposa.

El viento siguió moviendo las hojas, pero ahora le parecían estar danzando en celebración más que en despedida.''';
  }

  String _generateClimaxChapter(
    String title,
    String description,
    String genre,
    int chapterIndex,
  ) {
    return '''Capítulo ${chapterIndex + 1}

La tormenta había llegado más rápido de lo esperado. Lucía se aferró al volante mientras su coche luchaba contra el viento y la lluvia torrencial que azotaba la carretera.

Todo había salido mal desde el momento en que salió de la ciudad. Primero, el mensaje de texto que cambió todo. Luego, la llamada telefónica que confirmó sus peores temores. Y ahora esto: una tormenta que parecía decidida a impedirle llegar a su destino.

Las luces del hospital aparecieron finalmente a través de la cortina de lluvia. Lucía pisó el acelerador, sin importarle el agua que salpicaba a ambos lados del coche.

Corrió por el estacionamiento, empapándose hasta los huesos en los pocos metros que la separaban de la entrada. Sus zapatos chillaron contra el suelo pulido del hospital mientras se dirigía hacia el mostrador de recepción.

—Estoy buscando a Miguel Hernández —dijo, jadeando—. Llegó en ambulancia hace una hora.

La enfermera revisó su computadora con lo que parecía una lentitud tortuosa.

—Tercer piso, habitación 312. Pero señora, solo se permiten familiares...

Lucía ya corría hacia los ascensores. Los números en el panel subían con una lentitud exasperante. Tercer piso. Las puertas se abrieron y corrió por el pasillo, leyendo los números de las habitaciones.

310... 311... 312.

Se detuvo frente a la puerta, su mano temblando sobre el pomo. ¿Y si llegaba demasiado tarde? ¿Y si las últimas palabras que se habían dicho habían sido dichas con ira?

Empujó la puerta suavemente.

Miguel estaba despierto, con una sonrisa débil en el rostro cuando la vio entrar.

—Sabía que vendrías —dijo, su voz ronca pero llena de calidez.

Lucía corrió hacia la cama, tomó su mano entre las suyas.

—Por supuesto que vine. Miguel, sobre lo que pasó la semana pasada...

—No importa —la interrumpió—. Nada de eso importa ahora. Lo único que importa es que estás aquí.

Y por primera vez en días, Lucía sintió que podía respirar de nuevo.''';
  }

  List<String> _getOpeningsByGenre(String genre) {
    Map<String, List<String>> openingsByGenre = {
      'fiction': [
        'Era una mañana como cualquier otra, hasta que todo cambió.',
        'La historia comenzó con una mentira y terminó con una verdad.',
        'Nadie esperaba que un día tan ordinario se convirtiera en extraordinario.',
      ],
      'mystery': [
        'El cuerpo fue encontrado al amanecer, pero las preguntas apenas comenzaban.',
        'Detective Morrison había visto muchas escenas del crimen, pero esta era diferente.',
        'La primera pista llegó por correo, sin remitente y con un mensaje inquietante.',
      ],
      'romance': [
        'El amor llegó cuando menos lo esperaba, como suele suceder.',
        'Había jurado nunca volver a enamorarse, pero el destino tenía otros planes.',
        'Se conocieron en el lugar más improbable, en el momento más inesperado.',
      ],
      'adventure': [
        'La aventura comenzó con un mapa antiguo y una promesa.',
        'El tesoro estaba allí, esperando a ser encontrado por alguien lo suficientemente valiente.',
        'El viaje que cambiaría todo comenzó con un solo paso.',
      ],
      'default': [
        'Todo comenzó en un día que parecía como cualquier otro.',
        'La vida tiene una forma curiosa de sorprendernos cuando menos lo esperamos.',
        'Esta es la historia de cómo una decisión puede cambiar el curso de una vida.',
      ],
    };

    return openingsByGenre[genre] ?? openingsByGenre['default']!;
  }

  String _sanitizeBookIdForFirebase(String bookId) {
    String sanitized = bookId.replaceAll('/', '-').replaceAll('\\', '-');
    sanitized = sanitized.replaceAll(RegExp(r'-+'), '-');
    sanitized = sanitized.replaceAll(RegExp(r'^-+|-+$'), '');
    return sanitized;
  }

  Future<String?> _getCachedChapterContent(String bookId, int chapter) async {
    try {
      final docRef = _firestore
          .collection(_chaptersCollection)
          .doc(bookId)
          .collection('chapters')
          .doc(chapter.toString());
      final doc = await docRef.get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['content'];
      }
      return null;
    } catch (e) {
      print('DEBUG: Error al obtener de cache: $e');
      return null;
    }
  }

  Future<void> _cacheChapterContent(
    String bookId,
    int chapter,
    String content,
  ) async {
    try {
      await _firestore
          .collection(_chaptersCollection)
          .doc(bookId)
          .collection('chapters')
          .doc(chapter.toString())
          .set({
            'content': content,
            'chapter': chapter,
            'bookId': bookId,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
      print('DEBUG: Contenido narrativo cacheado exitosamente');
    } catch (e) {
      print('DEBUG: Error al cachear: $e');
    }
  }

  String _getDefaultNarrativeContent(int chapter) {
    return '''Capítulo ${chapter + 1}

La historia continuaba desarrollándose de maneras inesperadas. Los personajes se encontraban en una encrucijada, donde cada decisión podría cambiar el curso de los eventos.

María miró por la ventana de su oficina, observando el bullicio de la ciudad. Algo había cambiado en los últimos días, algo que no podía definir con precisión pero que sentía en cada fibra de su ser.

El teléfono sonó, interrumpiendo sus pensamientos.

—¿Diga? —respondió, aunque su mente seguía en otro lugar.

La voz al otro lado de la línea la trajo de vuelta a la realidad de manera abrupta. Era la llamada que había estado esperando, pero también temiendo.

Se sentó lentamente en su silla, procesando la información que acababa de recibir. Todo tenía sentido ahora. Las piezas del rompecabezas finalmente encajaban, revelando una imagen que era tanto hermosa como aterradora.

Tomó una decisión. Era hora de actuar, de dejar atrás las dudas y los miedos que la habían paralizado durante tanto tiempo.

Con determinación renovada, se levantó de su escritorio y se dirigió hacia la puerta. El futuro la esperaba, y esta vez estaba lista para enfrentarlo.''';
  }
}
