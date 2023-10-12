function tableOut=speech2text(connection,y,fs,varargin)
    invalidSpeechClient=isempty(connection)||~isvalid(connection)||...
    (~isa(connection,"BaseSpeechClient")&&~isa(connection,"Wav2VecSpeechClient"));
    coder.internal.errorIf(invalidSpeechClient,...
    "audio:speech2text:InvalidClient");

    if isa(connection,"Wav2VecSpeechClient")

        narginchk(3,3)
        tableOut=connection.transcribe(y,fs);

    else

        timeOut=10;

        if~isempty(varargin)
            validatestring(varargin{1},"HTTPTimeOut");
            timeOut=varargin{2};
        end

        connection.isSpeechToText=true;


        tableOut=connection.speechToText(y,fs,timeOut);
    end

end