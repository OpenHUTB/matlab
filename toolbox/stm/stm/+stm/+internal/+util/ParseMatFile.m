function signalMetadata=ParseMatFile(id,matFile,varargin)



    pub=true;
    if nargin==3
        pub=varargin{1};
    end

    mlock;
    persistent h;

    function helperPublishMessage(~,evt)



        if pub
            publish(evt.Total,evt.Current);
        end
        delete(h);
    end
    [~,fileName,~]=fileparts(matFile);


    function publish(total,current)
        virtualChannel=sprintf('BaselineCriteria/ParseMatFile/Progress/%d',id);
        currPercent=sprintf('%d',round((current/total)*100));
        payload=struct('Progress',currPercent,'FileName',[fileName,'.mat']);
        payloadStruct=struct('VirtualChannel',virtualChannel,'Payload',payload);
        message.publish('/stm/messaging',payloadStruct);
    end


    if~isempty(matFile)
        wParser=Simulink.sdi.Instance.engine.WksParser;
        parsers=wParser.parseMATFile(matFile);
        sdiParserUtil=stm.internal.util.SDIParser();
        h=addlistener(sdiParserUtil,'VariableLoadEvent',@(src,evt)helperPublishMessage(src,evt));
        signalMetadata=sdiParserUtil.getSignalMetadataFromSDIParsers(parsers,true);
    end

    if isempty(signalMetadata)
        error(message('stm:BaselineCriteria:UnsupportedFile'));
    end
end
