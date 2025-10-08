[Distributing Windows apps - Docs](https://docs.flutter.dev/platform-integration/windows/building#msix-packaging)

- If you haven't already, download the OpenSSL toolkit to generate your certificates.
- Go to where you installed OpenSSL, for example, C:\Program Files\OpenSSL-Win64\bin.
- Set an environment variable so that you can access OpenSSL from anywhere:
  `"C:\Program Files\OpenSSL-Win64\bin"`

1. ✅ openssl genrsa -out timedplayerkey.key 2048
    - Generate a private key as follows:

2. ✅ openssl req -new -key timedplayerkey.key -out timedplayercsr.csr -config "C:\Program Files\OpenSSL-Win64\bin\openssl.cfg"
   - Generate a certificate signing request (CSR) file using the private key:
   * Country Name: `QA`
   * State or Province Name: `Doha`
   * Locality Name: `Doha`
   * Organization Name: `Open Softwares`
   * Organizational Unit Name: `Timed Player`
   * Common Name: `Lazarus Muya`
   * Email Address: []
   * challenge password []: `TimedPlayer`
   * optional company name: `Open Softwares`

3. ✅ openssl x509 -in timedplayercsr.csr -out timedplayercert.crt -req -signkey timedplayerkey.key -days 10000
   - Generate the signed certificate (CRT) file using the private key and CSR file


4. [] openssl pkcs12 -export -out TIMEDPLAYERCERTPFX.pfx -inkey timedplayerkey.key -in timedplayercert.crt
   - Generate the .pfx file using the private key and CRT file
   * Pasword: `TimedPlayer`

5. Import-PfxCertificate -FilePath .\TIMEDPLAYERCERTPFX.pfx -CertStoreLocation "Cert:\LocalMachine\Root"
- Install the .pfx certificate first on the local machine in Certificate store as Trusted Root Certification Authorities before installing the app.

    - This command might fail and so use below to fix that:
        * $pwd = ConvertTo-SecureString -String "TimedPlayer" -Force -AsPlainText
        * Import-PfxCertificate -FilePath "C:\Users\dev\Documents\projects\flutter\timed_app\TIMEDPLAYERCERTPFX.pfx" -CertStoreLocation "Cert:\LocalMachine\Root" -Password $pwd

6. signtool sign /f "C:\Users\dev\Documents\projects\flutter\timed_app\TIMEDPLAYERCERTPFX.pfx" /p "TimedPlayer" /fd SHA256 /tr http://timestamp.digicert.com /td SHA256 "C:\Users\dev\Documents\projects\flutter\timed_app\build\windows\x64\runner\Release\TimedPlayer.exe"
- Sign the app