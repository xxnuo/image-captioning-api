from fastapi import FastAPI, UploadFile, File
from PIL import Image
import io
import torch
from transformers import VisionEncoderDecoderModel, ViTImageProcessor, AutoTokenizer

# Load model and processor
model = VisionEncoderDecoderModel.from_pretrained("nlpconnect/vit-gpt2-image-captioning")
processor = ViTImageProcessor.from_pretrained("nlpconnect/vit-gpt2-image-captioning")
tokenizer = AutoTokenizer.from_pretrained("nlpconnect/vit-gpt2-image-captioning")

# Select device
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model.to(device)

# FastAPI app
app = FastAPI()

@app.post("/caption/")
async def caption_image(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        image = Image.open(io.BytesIO(contents)).convert("RGB")
        inputs = processor(images=image, return_tensors="pt").to(device)
        output_ids = model.generate(**inputs)
        caption = tokenizer.decode(output_ids[0], skip_special_tokens=True)
        return {"caption": caption}
    except Exception as e:
        return {"error": str(e)}