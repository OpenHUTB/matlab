function[url,view]=start(src,varargin)
















































    p=inputParser;
    addRequired(p,'src');
    addParameter(p,'debug',false,@islogical);


    addParameter(p,'useModelDictionary',false,@islogical);
    addParameter(p,'useSharedDictionary',false,@islogical);

    addParameter(p,'useWebkit',false,@islogical);
    addParameter(p,'useCEF',true,@islogical);
    addParameter(p,'launchType','default',@(x)~isempty(strcmp(x,simulinkcoder.internal.app.View.LaunchTypes)));
    parse(p,src,varargin{:});
    coder.internal.CoderDataStaticAPI.checkOutERTLicense();

    sr=slroot;
    isAttachedToModel=false;
    modelHandle=[];


    if sr.isValidSlObject(src)
        modelHandle=get_param(src,'handle');
        hlp=coder.internal.CoderDataStaticAPI.getHelper;
        ddConn=hlp.openDD(modelHandle);

        if exist(ddConn.owner.ID,'file')
            [~,~,fext]=fileparts(ddConn.owner.ID);
            if strcmpi(fext,'.sldd')

            end
        end
    end
    if sr.isValidSlObject(src)
        modelHandle=src;
        isAttachedToModel=true;

        src=get_param(modelHandle,'handle');
    end

    if sr.isValidSlObject(src)


        ertTarget=hSafeGetParam(src,'IsERTTarget');
        if strcmp(ertTarget,'off')
            name=get_param(src,'Name');
            DAStudio.error('SimulinkCoderApp:ui:ModelNotERTTarget',name);
        end
    end
    v=[];%#ok<NASGU>
    if sr.isValidSlObject(src)
        src=get_param(src,'Handle');
        v=createModelDictionaryView(src,p.Results.launchType);
    else
        ddName=src;
        if~exist(ddName,'File')
            DAStudio.error('SimulinkCoderApp:core:DictionaryNotFound',ddName);
        end
        v=createDictionaryView(ddName,p.Results.launchType,isAttachedToModel,modelHandle);
    end
    if~isempty(v)
        if strcmp(p.Results.launchType,'returnurl')
            if p.Results.debug
                url=v.DebugURL;
            else
                url=v.URL;
            end
            view=v;
        else
            url=[];
            view=[];
        end

        v.DEBUG=p.Results.debug;
        v.UseCEF=p.Results.useCEF;
        v.UseWebkit=p.Results.useWebkit;

        v.start;
    end



    coder.internal.CoderDataStaticAPI.updateDictionariesInClosureIfPackageChanged(src);
end

function value=hSafeGetParam(sourceHandle,paramName)
    if isa(sourceHandle,'Simulink.ConfigSet')
        value=get_param(sourceHandle,paramName);
    else
        cs=getActiveConfigSet(sourceHandle);
        if isa(cs,'Simulink.ConfigSetRef')
            cs=cs.getRefConfigSet();
        end
        value=get_param(cs,paramName);
    end
end

function v=createModelDictionaryView(modelHandle,launchType)
    v=simulinkcoder.internal.app.DictionaryViewManager.instance.getView(modelHandle);
    if isempty(v)||~v.isvalid||strcmp(launchType,'returnurl')
        viewSource=simulinkcoder.internal.app.ModelDictionaryViewSource(modelHandle);
        v=createView(viewSource,launchType);
        viewSource.view=v;
        simulinkcoder.internal.app.DictionaryViewManager.instance.setView(modelHandle,v);
    end
end
function v=createDictionaryView(ddName,launchType,isAttachedToModel,modelHandle)

    if coder.dictionary.exist(ddName)
        cdict=coder.dictionary.open(ddName);
        ddName=cdict.sourceDictionary.ID;
    end

    ddFilePath=which(ddName);
    if~isempty(ddFilePath)

        ddName=ddFilePath;
    end
    v=simulinkcoder.internal.app.DictionaryViewManager.instance.getView(ddName);
    if isempty(v)||strcmp(launchType,'returnurl')
        if coderdictionary.data.feature.getFeature('SDPUI')
            viewSource=simulinkcoder.internal.app.SDPDataDictionaryViewSource(ddName,false,[]);
            v=simulinkcoder.internal.app.ViewHMIBrowserDialog(viewSource);
            viewSource.Channel='/coder/SDPView';
            viewSource.ClientID=hex2dec(v.ClientID);
            viewSource.subscribe;
        else
            viewSource=simulinkcoder.internal.app.DataDictionaryViewSource(ddName,isAttachedToModel,modelHandle);
            v=createView(viewSource,launchType);


            viewSource.DefaultMappingViewSource=simulinkcoder.internal.app.DefaultMappingViewSource(ddName,isAttachedToModel,modelHandle);
            viewSource.DefaultMappingViewSource.Channel='/coder/coderApp/defaultMapping';
            viewSource.DefaultMappingViewSource.ClientID=hex2dec(v.ClientID);
            viewSource.DefaultMappingViewSource.subscribe;
            if slfeature('TimingServicesInCodeGen')
                viewSource.RTEViewSource=simulinkcoder.internal.app.RTEViewSource(ddName,isAttachedToModel,modelHandle);
                viewSource.RTEViewSource.Channel='/coder/coderApp/SDP';
                viewSource.RTEViewSource.ClientID=hex2dec(v.ClientID);
                viewSource.RTEViewSource.subscribe;
            end
        end

        simulinkcoder.internal.app.DictionaryViewManager.instance.setView(ddName,v);
    end
end
function v=createDefaultMappingView(ddName,launchType,isAttachedToModel,modelHandle)
    v=simulinkcoder.internal.app.DictionaryViewManager.instance.getView(ddName);
    if isempty(v)||strcmp(launchType,'returnurl')
        viewSource=simulinkcoder.internal.app.DefaultMappingViewSource(ddName,isAttachedToModel,modelHandle);
        v=createView(viewSource,launchType);
        simulinkcoder.internal.app.DictionaryViewManager.instance.setView(ddName,v);
    end
end
function v=createView(sourceHandle,launchType)
    switch launchType
    case 'webkit'
        v=simulinkcoder.internal.app.ViewWebkitBrowserDialog(sourceHandle);
    case{'default','cef'}
        v=simulinkcoder.internal.app.ViewHMIBrowserDialog(sourceHandle);
    case 'system'
        v=simulinkcoder.internal.app.ViewSystemBrowser(sourceHandle);
    case 'returnurl'
        v=simulinkcoder.internal.app.ViewURL(sourceHandle);
    end
end


