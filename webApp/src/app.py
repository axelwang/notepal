import os
import streamlit as st
from openai import OpenAI


### Setup OPENAI client
OPENAI_API_KEY = st.secrets["openai"]["api_key"]
openai = OpenAI(api_key=OPENAI_API_KEY)

### Inputs
# System prompt for the meeting companion
system_prompt = """You are a helpful assistant that provides key points and, if applicable, action items and/or suggestions 
                   based on provided transcript of a meeting. Keep the output brief and do not use
                   complete sentences. Provide response in markdown. Use markdown heading level 1 for key points and action items and/or suggestions. """
                   
# correction prompt
correction_prompt = """You are a helpful assistant. Your task is to correct any spelling discrepancies in the transcribed text using common sense.
                   Make sure the following are spelled correctly: ChatGPT, Google Colab, YC.  Only add necessary punctuation such as periods, commas, and capitalization,
                   and use only the context provided.
                  """
                  

### Functions
# Transcribe the audio file using openAI whisper
def transcribe_audio_whisper(audio_file):
  """
  Use OpenAI's whisper model to transcribe audito to text.
  """
  audio= open(audio_file, "rb")

  transcription = openai.audio.transcriptions.create(
  model="whisper-1",
  file=audio,
  response_format="text"
  )

  return transcription

# Message that needs to be passed to GPT 4o mini API for summarization...
def message(transcribed_text):
    user_prompt = f"""The transcript is as follows: \n
                      {transcribed_text}"""
    return [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": user_prompt}
    ]
    
def generate_corrected_transcript(temperature, correction_prompt, transcription):
    response = openai.chat.completions.create(
        model="gpt-4o-mini",
        temperature=temperature,
        messages=[
            {
                "role": "system",
                "content": correction_prompt
            },
            {
                "role": "user",
                "content": transcription
            }
        ]
    )
    return response.choices[0].message.content



def summarize(audio_file,customized_correction=False):

    # First check if this meeting has been transcribed
    # If Yes, read the file
    transcription_file = "./"+audio_file.split(".")[1]+".txt"
    if os.path.exists(transcription_file):
      transcription = open(transcription_file,"r").read()
    # If No, transcribe
    else:
      transcription = transcribe_audio_whisper(audio_file)
      if customized_correction:
        transcription = generate_corrected_transcript(0,correction_prompt,transcription)
      # save transcription for RAG, if not already present
      with open("./"+audio_file.split(".")[1]+".txt","a") as file:
        file.write(transcription)

    # Create summaries
    response = openai.chat.completions.create(
        model = "gpt-4o-mini",
        messages = message(transcription)
    )

    return  response.choices[0].message.content, transcription

### Main
def main():
    st.title("Teammate AI demo")

    ### File upload
    uploaded_file = st.file_uploader("Choose an audio file", type=["mp3"])
    
    if uploaded_file is not None:
        ### Save the uploaded file
        audio_file = os.path.join("./data",uploaded_file.name)
        with open(audio_file,"wb") as f:
            f.write(uploaded_file.getbuffer())
        
        ### Recognize and summarize the audio
        st.header("Meeting Summary")
        output,transcription = summarize(audio_file)
        ### show key points and action items side by side
        col1, col2 = st.columns(2)
        with col1:
            st.markdown("###"+output.split("#")[1])
        with col2:
            st.markdown("###"+output.split("#")[2])
            
            
        #####################################    
        ### Ask questions
        st.header("Ask about details")
        # Set a default model
        if "openai_model" not in st.session_state:
            st.session_state["openai_model"] = "gpt-4o-mini"
            
        # Initialize chat history
        if "messages" not in st.session_state:
            # Add system prompt and meeting details
            follow_up_prompt = """You are an helpful assistant that answers questions based on
                         the text in the Assistant role."""
            st.session_state.messages = [
            {"role": "system", "content": follow_up_prompt},
            {"role": "assistant", "content": transcription}
            ]
        
        # Display chat messages from history on app rerun
        # for message in st.session_state.messages:
        #     with st.chat_message(message["role"]):
        #         st.markdown(message["content"])
                
        for message in st.session_state.messages:
            if message["role"] == "user":
                with st.chat_message("user"):
                    st.markdown(message["content"])
            elif message["role"] == "assistant" and message != st.session_state.messages[1]:
                with st.chat_message("assistant"):
                    st.markdown(message["content"])
                
        # Accept user input
        if prompt := st.chat_input("Any questions about the meeting? I was there!"):
            
            # Add user message to chat history
            st.session_state.messages.append({"role": "user", "content": prompt})
            # Display user message in chat message container
            with st.chat_message("user"):
                st.markdown(prompt)
                
            # Display assistant/AI (streamlit) response in chat message container
            with st.chat_message("assistant"):
                stream = openai.chat.completions.create(
                    model=st.session_state["openai_model"],
                    messages=[
                        {"role": m["role"], "content": m["content"]}
                        for m in st.session_state.messages
                    ],
                    stream=True,
                )
                response = st.write_stream(stream)
            st.session_state.messages.append({"role": "assistant", "content": response})
            
        
        
if __name__ == "__main__":
    main()
        
        
        




