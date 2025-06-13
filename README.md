# Image Captioning API

This is a FastAPI-based image captioning backend using the ViT-GPT2 model.

## How to Deploy on Render

1. Push this folder to GitHub.
2. Go to [https://render.com](https://render.com) and create a new Web Service.
3. Connect to your GitHub repo.
4. Use the following start command:
   ```
   uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```
5. Test the endpoint at `/caption/` with an image file.
