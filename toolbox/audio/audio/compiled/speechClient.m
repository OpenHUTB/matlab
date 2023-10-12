function clientObj=speechClient(apiName,varargin)

    narginchk(1,Inf);
    apiName=validatestring(apiName,["Google","IBM","Microsoft","wav2vec2.0"],"speechClient","apiName");

    isCloudBasedAPI=ismember(apiName,["Google","IBM","Microsoft"]);

    if isCloudBasedAPI

        coder.internal.errorIf(~exist(apiName+"SpeechClient.p","file"),...
        'audio:speech2text:FilesNotFound');

        switch apiName
        case "Google"
            clientObj=GoogleSpeechClient.getClient();
        case "IBM"
            clientObj=IBMSpeechClient.getClient();
        case "Microsoft"
            clientObj=MicrosoftSpeechClient.getClient();
        end
        clientObj.clearOptions();
        clientObj.setOptions(varargin{:});

    else

        clientObj=Wav2VecSpeechClient(varargin{:});

    end

end