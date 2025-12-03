# Build and Run Script for Event Management System

Write-Host "Checking for Flutter SDK..."
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    Write-Host "Flutter SDK found." -ForegroundColor Green
    
    Write-Host "Getting dependencies..." -ForegroundColor Cyan
    flutter pub get
    
    if ($?) {
        Write-Host "Dependencies installed successfully." -ForegroundColor Green
        
        Write-Host "Running build_runner..." -ForegroundColor Cyan
        flutter pub run build_runner build --delete-conflicting-outputs
        
        if ($?) {
            Write-Host "Build runner completed successfully." -ForegroundColor Green
            Write-Host "Running the app..." -ForegroundColor Cyan
            flutter run --android-skip-build-dependency-validation
        }
        else {
            Write-Host "Build runner failed. Please check the errors above." -ForegroundColor Red
            exit 1
        }
        
    }
    else {
        Write-Host "Failed to get dependencies. Please check your internet connection or pubspec.yaml." -ForegroundColor Red
    }
}
else {
    Write-Host "Error: Flutter SDK not found in PATH." -ForegroundColor Red
    Write-Host "Please ensure Flutter is installed and added to your system PATH."
    Write-Host "Visit https://flutter.dev/docs/get-started/install/windows for instructions."
}
