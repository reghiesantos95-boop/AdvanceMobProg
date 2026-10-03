# santos_advmobprog

## Lab Activity 2: Discussion

This activity uses a simple model-service-screen design pattern to render men's fashion data from an API endpoint. The `Product` model in `lib/models/product_model.dart` defines the shape of each product returned by DummyJSON, including nested values such as dimensions, reviews, metadata, images, and pricing details. This keeps JSON parsing separate from the UI so the screens can work with clear Dart objects.

The `ProductService` in `lib/services/product_service.dart` is responsible for communicating with the API endpoint. It requests data from `https://dummyjson.com/products`, decodes the JSON response, converts each item into a `Product` object, and keeps only men's fashion categories such as shirts, shoes, and watches. If the request fails, the service throws an exception that the screen can display to the user.

The screens in `lib/screens` render the data and handle user interaction. `ProductScreen` calls the service through a `FutureBuilder`, shows loading and error states, displays the products in a grid, and includes Enhancement 1 by filtering the product list with a search bar. Enhancement 2 is implemented by opening `ProductDetailScreen` when a card is tapped, showing a larger image and full product details. Enhancement 3 is implemented in `SettingsScreen`, where the dark/light mode switch is moved away from the home screen.

The `ThemeProvider` in `lib/providers/theme_provider.dart` demonstrates app state management with Provider. It stores the current theme mode, notifies listeners when the mode changes, and lets `main.dart` rebuild `MaterialApp` with the correct light or dark theme. This separates app-wide state from temporary screen state, making the code easier to maintain.

Overall, the design pattern separates responsibilities: models describe data, services fetch data, providers manage shared state, widgets handle reusable UI, and screens compose everything into the final user interface.

## Lab Activity 4: Authentication API

Lab 4 is connected in this same project so the shop, cart, and profile all use DummyJSON. After splash loading, the app restores a saved session from `shared_preferences` or opens the sign-in screen. `UserService` authenticates against DummyJSON (`/auth/login` or `/user/login`), then loads the full user profile from `/users/{id}`. `AuthProvider` keeps that user in memory and on disk.

The Profile tab renders the saved user model instead of placeholder text. The Cart tab uses the authenticated user id to call `/carts/user/{id}`, and add-to-cart sends `/carts/add` for that same user. Signing out clears the saved session and returns to sign in.

## Lab Activity 5: DummyJSON and Firebase Authentication

This store keeps its product catalog, product details, cart, search, and existing
shop interface while extending the same authentication layer with account
management. DummyJSON remains the practice API: it authenticates the supplied
username and password, then simulates account creation, updates, password
changes, and deletion. The app persists the resulting session with
`shared_preferences` and uses the DummyJSON user id to load the matching cart.

Firebase Authentication is available alongside DummyJSON for real email/password
accounts. The sign-in and sign-up screens let the user choose an account source.
Firebase creates durable user accounts, manages secure tokens, and requires a
recent password reauthentication before a password change or account deletion.
Firebase users intentionally do not request a DummyJSON cart because their
Firebase uid is unrelated to a DummyJSON user id; the existing product and cart
UI remains available for items added during that session.

`UserService` handles the DummyJSON HTTP calls, `FirebaseAuthService` handles
Firebase user operations, and `AuthProvider` exposes one consistent session state
to the shop UI. Profile provides username and password controls, while Settings
provides logout and delete-account controls. This separation keeps product,
cart, and authentication responsibilities independent and makes the app easier
to extend.
