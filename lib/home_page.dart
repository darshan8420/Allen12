import 'package:allen12/feature_box.dart';
import 'package:allen12/openai_service.dart';
import 'package:allen12/themes.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';


class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedImage;
  String? generatedContent;
  int start = 200;
  int delay = 200; 

  @override
  void initState(){
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: const Text('AppBar')),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Themes.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/images/virtualAssistant.png')),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            // chat bubble
            FadeInRight(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                  top: 30,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Themes.borderColor,
                  ),
                  borderRadius: BorderRadius.circular(20).copyWith(
                    topLeft: Radius.zero,
                  ),
                ),
                child: Text(
                  generatedContent == null ? 'Good Morning, what task can I do for you?' : generatedContent!,
                  style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Themes.mainFontColor,
                    fontSize: generatedContent == null ? 25 : 18,
                  ),
                ),
              ),
            ),
            if(generatedImage != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImage!),
                ),
            ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImage == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(
                    top: 10,
                    left: 22
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        'Here are a few features',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Cera Pro',
                        color: Themes.mainFontColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // features list
            Visibility(
              visible: generatedContent == null && generatedImage == null,
              child: Column(
                children: [
                    SlideInLeft(
                      delay: Duration(milliseconds: start),
                      child: const FeatureBox(
                        color: Themes.firstSuggestionBoxColor,
                        headerText: 'ChatGPT',
                        descriptionText: 'A smarter way to stay organized and informed with ChatGPT',
                      ),
                    ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const FeatureBox(
                      color: Themes.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptionText: 'Get inspired and stay creative with your personal assistant powered by Dall-E',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + 2 * delay),
                    child: const FeatureBox(
                      color: Themes.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptionText: 'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3 * delay),
        child: FloatingActionButton(
          backgroundColor: Themes.firstSuggestionBoxColor,
          onPressed: () async {
              if(await speechToText.hasPermission && speechToText.isNotListening) {
                await startListening();
              }else if(speechToText.isListening){
                final speech = await openAIService.isArtPromptAPI(lastWords);
                if(speech.contains("https")){
                  generatedImage = speech;
                  generatedContent = null;
                  setState(() {});
                } else {
                  generatedImage = null;
                  generatedContent = speech;
                  setState(() {});
                }
                await systemSpeak(speech);
                await stopListening();
              }else {
                initSpeechToText();
              }
          },
          child: Icon(
              speechToText.isListening ? Icons.stop : Icons.mic,
          ),
        ),
      ),
    );
  }
}
