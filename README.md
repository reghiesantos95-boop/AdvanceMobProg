# santos_advmobprog

## Lab Activity 2: Discussion

This activity uses a simple model-service-screen design pattern to render men's fashion data from an API endpoint. The `Product` model in `lib/models/product_model.dart` defines the shape of each product returned by DummyJSON, including nested values such as dimensions, reviews, metadata, images, and pricing details. This keeps JSON parsing separate from the UI so the screens can work with clear Dart objects.

The `ProductService` in `lib/services/product_service.dart` is responsible for communicating with the API endpoint. It requests data from `https://dummyjson.com/products`, decodes the JSON response, converts each item into a `Product` object, and keeps only men's fashion categories such as shirts, shoes, and watches. If the request fails, the service throws an exception that the screen can display to the user.

The screens in `lib/screens` render the data and handle user interaction. `ProductScreen` calls the service through a `FutureBuilder`, shows loading and error states, displays the products in a grid, and includes Enhancement 1 by filtering the product list with a search bar. Enhancement 2 is implemented by opening `ProductDetailScreen` when a card is tapped, showing a larger image and full product details. Enhancement 3 is implemented in `SettingsScreen`, where the dark/light mode switch is moved away from the home screen.

The `ThemeProvider` in `lib/providers/theme_provider.dart` demonstrates app state management with Provider. It stores the current theme mode, notifies listeners when the mode changes, and lets `main.dart` rebuild `MaterialApp` with the correct light or dark theme. This separates app-wide state from temporary screen state, making the code easier to maintain.

Overall, the design pattern separates responsibilities: models describe data, services fetch data, providers manage shared state, widgets handle reusable UI, and screens compose everything into the final user interface.
