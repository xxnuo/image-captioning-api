from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from pydantic import BaseModel
from transformers import BlipProcessor, BlipForConditionalGeneration
from PIL import Image
from io import BytesIO
import requests
import torch

app = FastAPI()

processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-large")
model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-large")

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model.to(device)

def load_image_from_bytes(file_bytes):
    try:
        return Image.open(BytesIO(file_bytes)).convert("RGB")
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid image file: {e}")

@app.post("/caption")
async def generate_caption(
    image: UploadFile = File(None)
):
    if image:
        image_data = await image.read()
        img = load_image_from_bytes(image_data)
    else:
        raise HTTPException(status_code=400, detail="No image file or URL provided.")

    inputs = processor(images=img, return_tensors="pt").to(device)
    out = model.generate(**inputs, min_new_tokens=32, max_new_tokens=4096)
    caption = processor.decode(out[0], skip_special_tokens=True)

    return {"caption": caption}