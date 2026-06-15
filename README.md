# RoHunt

RoHunt este aplicația mea de licență, realizată în Flutter, prin care utilizatorii pot descoperi orașe turistice din România printr-un joc de tip treasure hunt.

Ideea aplicației este să transforme vizitarea unui oraș într-o experiență mai interactivă. Utilizatorul își creează un cont, răspunde la un quiz pentru recomandarea unui oraș, poate salva orașe favorite și poate începe un traseu turistic. În timpul traseului primește povești și indicii, iar pentru a trece mai departe trebuie să încarce sau să facă o fotografie la locația cerută.

În versiunea actuală, traseul complet implementat este pentru Iași. Aplicația include autentificare, profil de utilizator, poză de profil, mod deschis/întunecat, sistem de medalii, direcționare către locație prin aplicația de hărți și validarea fotografiilor cu un model MobileNetV2 rulat local prin TensorFlow Lite.

## Tehnologii folosite

- Flutter și Dart pentru aplicația mobilă;
- Firebase Authentication pentru creare cont, logare, verificare email și resetare parolă;
- Cloud Firestore pentru salvarea profilului, progresului și medaliilor;
- Shared Preferences pentru date simple salvate local, cum ar fi tema și orașele favorite;
- TensorFlow Lite și MobileNetV2 pentru compararea imaginilor;
- Image Picker pentru încărcarea pozelor din galerie sau realizarea lor cu camera;
- URL Launcher pentru deschiderea locațiilor în aplicația de hărți.

## Funcționalități principale

- creare cont și autentificare cu email și parolă;
- verificarea adresei de email;
- resetarea parolei;
- profil utilizator cu nume și poză de profil;
- quiz pentru recomandarea unui oraș;
- listă de orașe și orașe favorite;
- treasure hunt pentru Iași;
- indicii pentru fiecare locație;
- validarea pozelor încărcate de utilizator;
- medalie primită la finalizarea traseului;
- temă light/dark.

## Rulare proiect

Pentru rulare este necesar ca Flutter să fie instalat pe calculator.

Pași:

```bash
flutter pub get
flutter run
```

Aplicația este configurată pentru Firebase prin fișierul `firebase_options.dart`, generat cu FlutterFire CLI.

## Stadiu proiect

Momentan, aplicația este pregătită pentru prezentarea funcționalităților principale. Traseul complet este cel pentru Iași, iar celelalte orașe pot fi extinse ulterior prin adăugarea de obiective, povești, coordonate și imagini oficiale.