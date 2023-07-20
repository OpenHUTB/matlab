function session=sldvCreateSession(model,block,opts,showUI,initCovData,client,blockPathObj)



















    if nargin<7
        blockPathObj=[];
    end

    if nargin<6
        client=Sldv.SessionClient.DVCommandLine;
    end

    modelH=get_param(model,'Handle');
    blockH=get_param(block,'Handle');

    try
        session=Sldv.Session(modelH,blockH,opts,showUI,initCovData,client,blockPathObj);
    catch MEx %#ok<NASGU> 
        session=[];
    end
end
