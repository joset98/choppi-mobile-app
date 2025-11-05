# Choppi Mobile App

A Flutter-based mobile application for the Choppi e-commerce platform, providing a seamless shopping experience with store browsing, product discovery, and cart management.

## Features

- **User Authentication**: Login and registration with JWT token management
- **Store Management**: Browse available stores and view store details
- **Product Catalog**: Explore products with pagination and search functionality
- **Shopping Cart**: Add, remove, and manage cart items with price calculation
- **Cart Quotes**: Real-time pricing calculation via backend API
- **Offline Persistence**: Local storage for cart and authentication state

## Architecture

### Project Structure

```
lib/
├── main.dart              # Application entry point
├── router.dart            # Navigation routing
├── models/                # Data models
│   ├── cart_item.dart     # Cart item model
│   ├── product.dart       # Product model
│   ├── store.dart         # Store model
├── providers/             # State management providers
│   ├── auth_provider.dart     # Authentication state
│   ├── cart_provider.dart     # Shopping cart state
│   ├── product_provider.dart  # Product data
│   └── store_provider.dart    # Store data
├── screens/               # UI screens
│   ├── login_screen.dart
│   ├── stores_screen.dart
│   ├── store_detail_screen.dart
│   ├── product_detail_screen.dart
│   └── cart_screen.dart
└── widgets/               # Reusable UI components
    └── cart_item_widget.dart
```

### State Management

The app uses the Provider pattern for state management:
- **AuthProvider**: Manages user authentication state and API calls
- **StoreProvider**: Handles store data fetching and caching
- **CartProvider**: Manages shopping cart items and persistence
- **ProductProvider**: Fetches and manages product data

### API Integration

The app communicates with the Choppi Core Backend API:

- **Authentication**: JWT-based auth via `/auth/login` and `/auth/register`
- **Stores**: CRUD operations via `/stores` endpoints
- **Products**: Product catalog via `/products` endpoints
- **Cart**: Quote calculation via `/cart/quote`

All API calls include proper error handling and loading states.

## Getting Started

### Prerequisites

- Flutter SDK (version 3.0 or higher)
- Dart SDK (version 3.0 or higher)
- Choppi Core Backend running

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd choppi-app-mobile/choppi_mob
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   # For web (recommended for testing)
   flutter run -d chrome

   # For mobile emulator
   flutter run
   ```

### Backend Setup

Ensure the Choppi Core Backend is running:

```bash
cd choppi-core-back
npm install
npm start
```

The backend should be accessible at `http://localhost:4000` with Swagger docs at `http://localhost:4000/api` in local dev.

## Development

### Adding New Features

1. **Update Models**: Add new data models in `lib/models/`
2. **Create Providers**: Implement state management in `lib/providers/`
3. **Build UI**: Create screens in `lib/screens/`
4. **Update Routing**: Add routes in `lib/router.dart`

### API Integration

When adding new API endpoints:

1. Define API constants in the relevant provider
2. Implement HTTP methods with proper error handling
3. Update loading and error states
4. Test both success and failure scenarios

### Testing

Run tests with:
```bash
flutter test
```

For integration testing with the backend, ensure the API is running and accessible.

## Environment Configuration

The app uses environment variables for configuration:

- Create a `.env` file in the root directory
- Set `API_BASE_URL` to your backend URL (defaults to `http://localhost:4000` if not set)

Example `.env` file:
```
API_BASE_URL=http://localhost:4000
```

## Dependencies

Key packages used:

- `http`: HTTP client for API communication
- `shared_preferences`: Local data persistence
- `provider`: State management
- `go_router`: Navigation and routing
- `flutter_dotenv`: Environment variable management

## API Documentation

For detailed API documentation, visit the Swagger UI at `http://localhost:4000/api` when the backend is running in local.

## Contributing

1. Follow Flutter best practices
2. Use meaningful commit messages
3. Update documentation for new features
4. Test on multiple platforms (web, mobile)

## Troubleshooting

### Common Issues

- **API Connection Failed**: Ensure backend is running on port 4000 in local
- **Build Errors**: Run `flutter clean` and `flutter pub get`
- **Permission Errors**: Check CORS settings in backend

### Debug Mode

Use Flutter DevTools for debugging:
- Access via terminal output URL when running in debug mode
- Inspect network requests and state changes
- Monitor performance metrics

## License

This project is part of the Choppi e-commerce platform.
