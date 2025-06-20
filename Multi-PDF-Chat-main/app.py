from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
from backend.pdf_processor import get_pdf_text, get_text_chunks
from backend.vector_store import get_vector_store
from backend.qa_handler import handle_user_query

load_dotenv()

app = Flask(__name__)
CORS(app)

# Route for PDF upload and processing
@app.route('/process-pdf', methods=['POST'])
def process_pdf():
    if 'pdfs' not in request.files:
        return jsonify({'error': 'No PDF files uploaded'}), 400

    pdf_files = request.files.getlist('pdfs')
    
    ## Debug Testing
    print(f"Received {len(pdf_files)} file(s):")
    for file in pdf_files:
        print(f" - {file.filename}")
    
    try:
        raw_text = get_pdf_text(pdf_files)
        print(raw_text)
        chunks = get_text_chunks(raw_text)
        
        print(f"🔍 Total chunks: {len(chunks)}")
        for i, chunk in enumerate(chunks):
            print(f"\n🧩 Chunk {i+1}:\n{chunk[:300]}...") 
        
        get_vector_store(chunks)
        return jsonify({'message': 'PDFs processed and indexed successfully!'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Route for user query
@app.route('/ask', methods=['POST'])
def ask_question():
    try:
        data = request.get_json()
        query = data.get('query', '')
        if not query:
            return jsonify({'error': 'No query provided'}), 400

        response = handle_user_query(query)
        return jsonify({'response': response}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0',debug=True, port=5000)
