function url=ViewSDP(src,varargin)




















    p=inputParser;
    addRequired(p,'src');
    addParameter(p,'debug',false,@islogical);
    addParameter(p,'ModelToLink','');
    addParameter(p,'CreateAndSave','',@islogical);

    parse(p,src,varargin{:});
    coder.internal.CoderDataStaticAPI.checkOutERTLicense();

    v=[];%#ok<NASGU>
    ddName=src;
    sr=slroot;
    if sr.isValidSlObject(ddName)
        v=createModelDictionaryView(get_param(ddName,'handle'));
    elseif exist(ddName,'File')
        v=createDataDictionaryView(ddName);
    elseif isempty(ddName)
        v=createEmptyDictionaryView(p);
    else
        DAStudio.error('SimulinkCoderApp:core:DictionaryNotFound',ddName);
    end

    v.UseCEF=true;
    if~isempty(v)

        if p.Results.debug
            url=v.DebugURL;
        else
            url=v.URL;
        end

        v.DEBUG=p.Results.debug;
        if~v.DEBUG
            v.start;
        end
    end




end
function v=createModelDictionaryView(modelHandle)
    v=simulinkcoder.internal.app.DictionaryViewManager.instance.getView(modelHandle);
    if isempty(v)
        viewSource=simulinkcoder.internal.app.SDPModelDictionaryViewSource(modelHandle);
        v=simulinkcoder.internal.app.ViewHMIBrowserDialog(viewSource);
        viewSource.Channel='/coder/SDPView';
        viewSource.ClientID=hex2dec(v.ClientID);
        viewSource.subscribe;
        simulinkcoder.internal.app.DictionaryViewManager.instance.setView(modelHandle,v);
    end
end
function v=createEmptyDictionaryView(p)
    v=simulinkcoder.internal.app.DictionaryViewManager.instance.getView(-1);
    if isempty(v)
        viewSource=simulinkcoder.internal.app.NewDataDictionaryViewSource();
        viewSource.CreateAndSave=p.Results.CreateAndSave;
        v=simulinkcoder.internal.app.ViewHMIBrowserDialog(viewSource);
        viewSource.Channel='/coder/SDPView';
        viewSource.ClientID=hex2dec(v.ClientID);
        viewSource.subscribe;
        simulinkcoder.internal.app.DictionaryViewManager.instance.setView(-1,v);
    end

    v.ModelToLink=p.Results.ModelToLink;
end

function v=createDataDictionaryView(ddName)

    if coder.dictionary.exist(ddName)
        cdict=coder.dictionary.open(ddName);
        ddName=cdict.sourceDictionary.ID;
    end

    ddFilePath=which(ddName);
    if~isempty(ddFilePath)

        ddName=ddFilePath;
    end
    v=simulinkcoder.internal.app.DictionaryViewManager.instance.getView(ddName);
    if isempty(v)
        viewSource=simulinkcoder.internal.app.SDPDataDictionaryViewSource(ddName,false,[]);
        v=simulinkcoder.internal.app.ViewHMIBrowserDialog(viewSource);
        viewSource.Channel='/coder/SDPView';
        viewSource.ClientID=hex2dec(v.ClientID);
        viewSource.subscribe;
        simulinkcoder.internal.app.DictionaryViewManager.instance.setView(ddName,v);
    end
end


