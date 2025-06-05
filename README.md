# Aura

Aura je lična Flutter aplikacija namenjena praćenju epileptičnih napada i prikupljanju zdravstvenih podataka preko Health Connect/Samsung Health servisa. Aplikacija je prvenstveno razvijena u svrhu testiranja i ličnog monitoringa.

## Glavne funkcionalnosti

- **Evidencija napada** – na početnom ekranu mogu se zabeležiti napadi tri jačine (Blag, Umeren, Težak) ili unos leka *Frisium*. Uz svaki događaj pamti se okolnost i trajanje, a moguće je sačuvati i zbir zdravstvenih podataka (koraci, puls, temperatura, kalorije, saturacija, san, težina, visina, BMI).
- **Istorija događaja** – prikazuje listu svih zabeleženih događaja sa mogućnošću brisanja. Svaki događaj se prikazuje karticom koja sadrži sve relevantne informacije i opciono detalje iz Health Connect‑a.
- **Podešavanja** – omogućavaju uključivanje *test moda* (prikaz trećeg taba za testiranje) i unos ličnih podataka poput visine korisnika. Koristi se `Provider` za upravljanje stanjem.
- **Test ekran** – služi za pregled i ručno osvežavanje svih dostupnih zdravstvenih podataka sa uređaja. Ovaj ekran je namenjen samo kada je uključen test mod.
- **Dozvole i Health Connect** – aplikacija pri pokretanju traži sve potrebne sistemske dozvole (kamera, lokacija, notifikacije, aktivnosti...) i, ukoliko postoji, pristup Health Connect/Samsung Health podacima.

## Pokretanje aplikacije

1. Instalirati [Flutter](https://flutter.dev/) i potrebne platformske alate (Android Studio/Xcode).
2. U korenskom direktorijumu projekta pokrenuti:
   ```bash
   flutter pub get
   flutter run
   ```
3. Na Android uređajima biće neophodno omogućiti pristup Health Connect podacima kako bi se prikazale sve metrike.

Aplikacija je namenjena lokalnom razvoju i nije predviđena za javnu distribuciju.
