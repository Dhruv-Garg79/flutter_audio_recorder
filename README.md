# Audio recorder and player

The inspiration for UI is whatsapp voice notes.

Architecture:
MVVM architecture is used with stacked library.

Folder structure:
1. app - setup code for router and service locator
2. models - data wrapper classes
3. screens
    1. view files - main screen UI
    2. viewmodel files - contains logic or business logic of app
    3. widgets folder - contains individual UI components which make up view. this is done for readability and performance. so that only required components are rebuild.
4. theme - contains styling and dimensions related code
5. utils - helper classes


