



classdef(Abstract)View<handle
    properties
URL
    end

    properties(Hidden=true)
DebugURL
ClientID

HelpArgs
Title
        UseCEF=false
        UseWebkit=true
        DEBUG=false
Dlg
ViewSource
        ModelToLink=[]

hSourceCloseListener
hSlddFileSelected
hDeActivateListener
hMemSecPackageChangeListener
        PostNameChangeId=''
    end

    properties(Constant,Hidden)
        AppPath='/toolbox/coder/simulinkcoder_app/ui/web/MainView/'
        LaunchTypes={'default','system','returnurl'}
    end

    methods
        function obj=View(viewSource)
            simulinkcoder.internal.app.initialize();
            obj.ViewSource=viewSource;
            obj.hSourceCloseListener=addlistener(obj.ViewSource,'HandleBeingDestroyed',@obj.onSourceBeingDestroyed);
            obj.ClientID=generateClientID();

            connector.ensureServiceOn;
            args=struct('modelName',obj.ViewSource.CoderDataSourceName,'clientId',obj.ClientID);
            if isa(obj.ViewSource,'simulinkcoder.internal.app.SDPViewSource')
                args.isLocalDict=obj.ViewSource.isLocalDict;
                if isa(obj.ViewSource,'simulinkcoder.internal.app.NewDataDictionaryViewSource')
                    args.showSetup='true';
                    obj.hSlddFileSelected=addlistener(obj.ViewSource,'SlddFileSelected',@obj.onSlddFileSelected);
                    if obj.ViewSource.CreateAndSave
                        args.CreateOnly='true';
                    else
                        args.CreateOnly='false';
                    end
                else

                    args.CreateOnly='false';
                    args.showSetup='false';
                end
                if isa(obj.ViewSource,'simulinkcoder.internal.app.SDPDataDictionaryViewSource')
                    if coder.dictionary.exist(obj.ViewSource.DataDictionaryFileName)
                        args.CDictExist='true';
                    else
                        args.CDictExist='false';
                    end
                end
                obj.DebugURL=buildURL('/toolbox/coder/simulinkcoder_app/sdp/web/SDPView/','sdp-debug.html','args',args);
                obj.URL=buildURL('/toolbox/coder/simulinkcoder_app/sdp/web/SDPView/','sdp.html','args',args);

                if~isa(obj.ViewSource,'simulinkcoder.internal.app.NewDataDictionaryViewSource')




                    simulinkcoder.internal.app.registerClientModelAssociation(hex2dec(obj.ClientID),viewSource.getClientAssociationHandle);
                end
                obj.ViewSource.createListener(hex2dec(obj.ClientID));
                obj.Title=obj.getDialogTitle;
                return;
            end
            if isa(obj.ViewSource,'simulinkcoder.internal.app.DataDictionaryViewSource')||...
                isa(obj.ViewSource,'simulinkcoder.internal.app.ModelDictionaryViewSource')
                args.isDataModel='true';
                if simulinkcoder.internal.app.showImplementationTab
                    args.hasImplTab='true';
                else
                    args.hasImplTab='false';
                end

                if slfeature('TimingServicesInCodeGen')||coderdictionary.data.feature.getFeature('SDPUI')
                    args.hasSDP='true';
                else
                    args.hasSDP='false';
                end
                if isa(obj.ViewSource,'simulinkcoder.internal.app.DataDictionaryViewSource')
                    args.configDefaults='true';
                else
                    args.configDefaults='false';
                end
                if isa(obj.ViewSource,'simulinkcoder.internal.app.ModelDictionaryViewSource')
                    args.isLocalDict='true';
                else
                    args.isLocalDict='false';
                end

                if simulinkcoder.internal.app.FeatureChecker.isUsageFeatureOn
                    args.usageOn='true';
                else
                    args.usageOn='false';
                end
            end
            if~isa(obj.ViewSource,'simulinkcoder.internal.app.DefaultMappingViewSource')
                obj.DebugURL=buildURL(obj.AppPath,'coderApp_debug.html','args',args);
                obj.URL=buildURL(obj.AppPath,'coderApp.html','args',args);





                simulinkcoder.internal.app.registerClientModelAssociation(hex2dec(obj.ClientID),viewSource.getClientAssociationHandle);
                obj.ViewSource.createListener(hex2dec(obj.ClientID));
                obj.Title=obj.getDialogTitle;
            else
                obj.ViewSource.Channel=sprintf('/DefaultMapping/%s',obj.ClientID);
                obj.ViewSource.ClientID=obj.ClientID;
                obj.ViewSource.subscribe;
                args.channel=obj.ViewSource.Channel;
                obj.DebugURL=buildURL(obj.AppPath,'defaultMapping_debug.html','args',args);
                obj.URL=buildURL(obj.AppPath,'defaultMapping.html','args',args);
            end
        end
        function onSourceBeingDestroyed(obj,~,~,~)
            obj.closeDialog;
        end
        function onSlddFileSelected(obj,~,evtData)
            try
                if exist(evtData.FileName,'file')
                    [fpath,name,ext]=fileparts(evtData.FileName);
                    origPath=addpath(fpath);
                    cleanupPath=onCleanup(@()path(origPath));
                    if~isempty(obj.ModelToLink)
                        if isa(obj.ModelToLink,'function_handle')
                            obj.ModelToLink([name,ext]);
                        else
                            set_param(obj.ModelToLink,'EmbeddedCoderDictionary',[name,ext]);
                        end
                    end
                    if obj.ViewSource.CreateAndSave
                        dd1=Simulink.dd.open(evtData.FileName);
                        dd1.explore;
                        dd1.saveChanges
                    end
                end
            catch me
                disp(me.message);
            end
        end
        function closeDialog(obj)
            simulinkcoder.internal.app.removeClientModelAssociation(hex2dec(obj.ClientID));
            if~isempty(obj.Dlg)
                obj.Dlg.delete;
            end
        end
        function delete(obj)


            obj.closeDialog;
            delete(obj.ViewSource);
        end
        function out=getDialogTitle(obj)
            srcHandle=obj.ViewSource.getClientAssociationHandle;
            if isa(srcHandle,'Simulink.ConfigSetDialogController')
                cs=obj.ViewSource.getConfigSet;
                newName=cs.get_param('Name');
                msg=message('SimulinkCoderApp:ui:CoderAppTitle',newName).getString;






                if~isempty(obj.ViewSource.ModelHandle)&&isa(getActiveConfigSet(obj.ViewSource.ModelHandle),'Simulink.ConfigSetRef')
                    msg=[msg,' (',message('SimulinkCoderApp:ui:CoderAppTitleShared').getString,')'];
                end
                out=msg;
            else
                srcSpec=simulinkcoder.internal.app.getCodeDefinitionsSource(hex2dec(obj.ClientID));
                if~isempty(srcSpec)
                    out=message('SimulinkCoderApp:ui:CoderAppTitle',srcSpec).getString;
                else
                    out=message('SimulinkCoderApp:sdp:ConfigureSelectorDialogTitle').getString;
                end
            end
        end
        function setTitle(obj,title)
            obj.Title=title;
            if~isempty(obj.Dlg)
                obj.Dlg.setTitle(obj.Title);
            end
        end
        function start(~)
            simulinkcoder.internal.app.AppInit.getInstance.initializeSubscribers;
        end

        function onBrowserClose(obj,size)
            obj.ViewSource.onBrowserClose(size);
        end
        function ret=getGemoetry(obj)
            if isa(obj.ViewSource,'simulinkcoder.internal.app.NewDataDictionaryViewSource')
                ret=simulinkcoder.internal.app.View.getDefaultGeometry();
            else
                ret=simulinkcoder.internal.app.View.getSetGeometry();
            end
        end
    end

    methods(Hidden,Static)
        function result=getDefaultGeometry()
            result=[100,100,1100,600];
        end

        function result=getSetGeometry(windowPos)
            persistent windowGeometry;
            if nargin>0
                windowGeometry=windowPos;
                return;
            end
            if~isempty(windowGeometry)
                result=windowGeometry;
            else
                result=simulinkcoder.internal.app.View.getDefaultGeometry();
            end
        end
    end
end

function id=generateClientID()
    rng('shuffle');
    id=sprintf('%08x',uint32(rand*intmax('uint32')));
end

function q=buildQueryString(argStruct)
    q='';
    argCount=0;
    fldNames=fieldnames(argStruct);
    if~isempty(fldNames)
        for i=1:length(fldNames)
            if argCount==0
                prefix='?';
            else
                prefix='&';
            end
            val=argStruct.(fldNames{i});
            if isnumeric(val)
                val=num2str(val);
            end
            q=[q,prefix,fldNames{i},'=',val];%#ok
            argCount=argCount+1;
        end
    end
end

function url=buildURL(path,page,varargin)
    p=inputParser;
    addRequired(p,'path');
    addRequired(p,'page');
    addOptional(p,'args',struct(),@isstruct);
    parse(p,path,page,varargin{:});

    url=[path,page];
    if~isempty(p.Results.args)
        url=[url,buildQueryString(p.Results.args)];
    end
    url=connector.getUrl(url);
end





