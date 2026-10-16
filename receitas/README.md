# Caderno de Receitas — Aula 06

Aplicativo Flutter de livro de receitas com consumo de API REST, operações CRUD, Splash animada, pesquisa, imagens, navegação inferior e temas claro/escuro conforme o sistema.

## Como executar

O ZIP contém o código-fonte, não os arquivos gerados automaticamente pelo Flutter. É necessário ter Flutter e Android SDK instalados.

1. Abra um terminal na pasta extraída.
2. Execute `flutter create --platforms=android .` para gerar os arquivos padrão Android que não estão no ZIP.
3. Execute `flutter pub get`.
4. Execute `flutter run` com o celular ou emulador conectado.
5. Para gerar o APK: `flutter build apk --release`.
6. Copie `build/app/outputs/flutter-apk/app-release.apk` para `assets/app-release.apk` antes de enviar ao GitHub.

## API

A URL base configurada é `https://receitasapi-b-2025.vercel.app`.
As rotas REST foram assumidas como `/receitas` e `/receitas/:id`, com POST/PUT/DELETE.
**Importante:** não foi possível verificar a documentação/resposta real da API neste ambiente. Confira as rotas e os nomes dos campos antes da entrega. Ajuste `lib/services/receita_service.dart` e `lib/models/receita.dart` se necessário.

## Tecnologias

Flutter, Dart, http, intl, shared_preferences.

## Observação

O APK não está incluído porque este ambiente não possui o SDK Flutter para compilar e testar o aplicativo.
