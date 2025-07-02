#!/bin/bash

set -e

PROJECT_NAME="djtestbench"
APP_NAME="benchmark"
PYTHON_BIN="python3"

echo "📦 Creating virtual environment..."


echo "⬇️ Installing Django, Gunicorn, Granian..."
pip install --upgrade pip
pip install django gunicorn granian

echo "🚧 Creating Django project: $PROJECT_NAME"
django-admin startproject $PROJECT_NAME
cd $PROJECT_NAME

echo "🚀 Creating Django app: $APP_NAME"
python3 manage.py startapp $APP_NAME

# Add app to INSTALLED_APPS
sed -i "/INSTALLED_APPS = \[/ a\ \ \ \ '$APP_NAME'," $PROJECT_NAME/settings.py

# Add test view
cat > $APP_NAME/views.py <<EOF
from django.http import HttpResponse

def test_view(request):
    return HttpResponse("OK")
EOF

# Wire up URL
cat > $PROJECT_NAME/urls.py <<EOF
from django.contrib import admin
from django.urls import path
from $APP_NAME.views import test_view

urlpatterns = [
    path("admin/", admin.site.urls),
    path("", test_view),
]
EOF

echo "⚙️ Applying migrations..."
python3 manage.py migrate

echo "✅ Setup complete!"
echo ""
echo "📌 Run the servers with:"
echo "  Django dev server:   python manage.py runserver"
echo "  Gunicorn:            gunicorn $PROJECT_NAME.wsgi:application --bind 127.0.0.1:8000"
echo "  Granian (WSGI):      granian --interface wsgi $PROJECT_NAME.wsgi:application"
