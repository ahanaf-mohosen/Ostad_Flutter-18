# REST API CRUD Operation

A Flutter application implementing complete CRUD (Create, Read, Update, Delete) operations using a REST API.

## Features

- **Product Management**: View, add, edit, and delete products.
- **REST API Integration**: Uses the `http` package for network communication.
- **Form Validation**: Ensures data integrity when adding or editing products.
- **Pull-to-Refresh**: Refresh the product list with a simple gesture.
- **Responsive UI**: Clean and intuitive interface with loading indicators and snackbars for feedback.

## API Details

- **Base URL**: `https://crud-api-ostad-live.onrender.com/api/v1`
- **Endpoints**:
  - `GET /ReadProduct`: Fetch all products.
  - `POST /CreateProduct`: Create a new product.
  - `POST /UpdateProduct/:id`: Update an existing product.
  - `GET /DeleteProduct/:id`: Delete a product.

## App Screenshots

### 1. Product List
![Product List](images/1.png)

### 2. Add New Product
![Add Product](images/5.png)

### 4. Edit Product
![Edit Product](images/3.png)

### 5. Delete Product
![Success](images/4.png)

## Getting Started

To run this project locally:

1. Clone the repository.
2. Navigate to the project directory.
3. Run `flutter pub get` to install dependencies.
4. Run `flutter run` to launch the app on your device or emulator.

