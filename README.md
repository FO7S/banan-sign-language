# 👐 Banan (بنان) | AI-Powered Sign Language Learning for Kids

**"Teaching hands to speak and hearts to listen."**

Banan (Arabic for "Fingerprints/Fingertips") is an innovative educational mobile application designed to bridge the communication gap for deaf and hard-of-hearing children using Artificial Intelligence. Inspired by the Quranic verse: *"Yes, We are able to perfectly restore his very fingertips"* [75:4], this project turns fingertips into a powerful tool for expression and learning.

---

## 🌟 The Vision
Banan aims to empower deaf children by translating their signs into text and speech, while simultaneously teaching hearing children the beauty of sign language through an interactive, gamified experience.

## 🧠 Core AI Features
* **Sign-to-Text (Real-time):** Recognizes 32 Arabic sign language categories using a trained `MobileNetV2` model.
* **Voice-to-Sign (Visual Dictionary):** Converts spoken words into a sequence of animated sign language images.
* **Sentence Construction:** A smart module that buffers individual signs to form complete, meaningful sentences.
* **Intelligent Feedback:** Real-time visual cues to help children correct their hand gestures.

## 📱 Application Flow & Screens
The app offers two personalized paths: **"I Sign & Learn"** (for Deaf children) and **"I Speak & Learn"** (for Hearing children).

1.  **Alphabet Arena (الحروف):** Learn individual Arabic letters and test them via the camera.
2.  **Words Garden (الكلمات):** Practice spelling full words sign by sign.
3.  **Challenge Zone (التحديات):** A gamified space with timed challenges, stars, and leaderboards.
4.  **Echo:** Speech-to-Sign module where the app visualizes spoken words into signs.
5.  **Tell:** Sign-to-Text module where the child signs a full sentence, and the AI writes it down.

## 🛠 Tech Stack
* **Frontend:** [Flutter / React Native] - *UI inspired by "Learning App for Kids" (Figma).*
* **Deep Learning:** TensorFlow Lite, Keras, MobileNetV2.
* **Dataset:** Over 54,000 images of Arabic Sign Language (ArSL).
* **NLP:** Speech-to-Text APIs for the "Echo" module.

## 📁 Project Structure
```bash
├── assets/             # Icons, 3D Hand Models, and UI Graphics
├── lib/                # Flutter source code
│   ├── screens/        # The 5 Main Modules
│   ├── models/         # TFLite Model integration
│   └── widgets/        # Custom UI components (Cards, Buttons)
├── models/             # Pre-trained .tflite files
└── README.md
