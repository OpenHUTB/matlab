classdef SLRTComponent<matlab.ui.componentcontainer.ComponentContainer




    properties(Access=protected,Abstract,Transient)




tgEventsTriggeringUpdateGUI
    end

    methods(Access=public,Hidden,Abstract)



updateGUI



disableControlForInvalidTarget
    end

    properties(Access=protected,Transient,NonCopyable)













        firstUpdate=true;




        tgEventListenersTriggeringUpdateGUI=[]








        tgListenerCreate=[]
        tgListenerDestroy=[]








UpdateButton
    end

    methods(Access=protected)
        function updateGUIWrapper(this,varargin)
            args=varargin{:};
            try
                this.updateGUI(args);
            catch ME



                if~strcmp(ME.identifier,'MATLAB:class:InvalidHandle')
                    rethrow(ME);
                end
            end
        end
    end



    properties(Dependent,GetAccess=private)
TargetSource
    end
    methods
        function set.TargetSource(this,value)
            this.initTarget(value);
        end
    end

    properties(SetAccess=private,GetAccess=protected,Transient,NonCopyable)



        GetTargetNameFcnH=[]



        TargetSelectorObj=[]
    end
    methods
        function value=get.GetTargetNameFcnH(this)
            if isempty(this.GetTargetNameFcnH)

                this.initTarget([]);
            end
            value=this.GetTargetNameFcnH;
        end
    end

    properties(Access=private,Transient,NonCopyable)



        TargetChangedListener=[]




        DefaultTargetChangedListener=[]



        TargetNameChangedListener=[]







        ConnectedListener=[]
        DisconnectedListener=[]






        ProgressDlg=[]
    end



    events
GUIUpdated
    end



    methods(Access=protected)
        function initTarget(this,targetSelectorOrName)
            function name=getDefaultTargetName()
                tgs=slrealtime.Targets;
                name=tgs.getDefaultTargetName();
            end

            tgs=slrealtime.Targets;
            if isempty(this.TargetNameChangedListener)
                this.TargetNameChangedListener=...
                listener(tgs,...
                'TargetNameChanged',...
                @(src,evnt)this.updateGUIWrapper([]));
            end

            if isempty(targetSelectorOrName)



                this.TargetSelectorObj=[];
                this.GetTargetNameFcnH=@()getDefaultTargetName();

                if isempty(this.DefaultTargetChangedListener)
                    this.DefaultTargetChangedListener=...
                    listener(tgs,...
                    'DefaultTargetChanged',...
                    @(src,evnt)this.targetSelectionChanged());
                end

            elseif isa(targetSelectorOrName,'slrealtime.ui.control.TargetSelector')



                if~isscalar(targetSelectorOrName)
                    slrealtime.internal.throw.Error('slrealtime:appdesigner:InitInvalidArg');
                end
                this.TargetSelectorObj=targetSelectorOrName;
                this.GetTargetNameFcnH=@()this.TargetSelectorObj.TargetName;

                if~isempty(this.DefaultTargetChangedListener)
                    delete(this.DefaultTargetChangedListener);
                    this.DefaultTargetChangedListener=[];
                end
            else



                if iscell(targetSelectorOrName)
                    slrealtime.internal.throw.Error('slrealtime:appdesigner:InitInvalidArg');
                elseif~isscalar(targetSelectorOrName)&&isstring(targetSelectorOrName(1))
                    slrealtime.internal.throw.Error('slrealtime:appdesigner:InitInvalidArg');
                else
                    targetSelectorOrName=convertStringsToChars(targetSelectorOrName);
                    if~ischar(targetSelectorOrName)
                        slrealtime.internal.throw.Error('slrealtime:appdesigner:InitInvalidArg');
                    end
                end
                this.TargetSelectorObj=[];
                this.GetTargetNameFcnH=@()targetSelectorOrName;

                if~isempty(this.DefaultTargetChangedListener)
                    delete(this.DefaultTargetChangedListener);
                    this.DefaultTargetChangedListener=[];
                end
            end

            if~isempty(this.TargetSelectorObj)
                this.TargetChangedListener=...
                listener(this.TargetSelectorObj,...
                'TargetSelectionChanged',...
                @(src,evnt)this.targetSelectionChanged());
            end



            this.targetSelectionChanged();
        end
    end




    methods(Access=public,Hidden)
        function targetSelectionChanged(this)


            if isempty(this.tgEventListenersTriggeringUpdateGUI)
                this.tgEventListenersTriggeringUpdateGUI=...
                containers.Map('KeyType','char','ValueType','any');
            else
                listeners=this.tgEventListenersTriggeringUpdateGUI.values;
                cellfun(@(x)delete(x),listeners);
                this.tgEventListenersTriggeringUpdateGUI.remove(this.tgEventListenersTriggeringUpdateGUI.keys);
            end
            if~isempty(this.tgListenerCreate)||~isempty(this.tgListenerDestroy)
                delete(this.ConnectedListener);
                delete(this.DisconnectedListener);
                this.tgListenerDestroy();
            end

            if(this.isDeployedWithDefaultTarget())
                this.disableControlForInvalidTarget();
                return;
            end



            tg=this.tgGetTargetObject();
            if isempty(tg)
                msg=message('slrealtime:appdesigner:InvalidTargetName',this.GetTargetNameFcnH());
                this.uialert(MException('slrealtime:appdesigner:InvalidTargetName',msg.getString()));
                this.disableControlForInvalidTarget();
                return;
            end




            if this.isDesignTime(),return;end



            for i=1:length(this.tgEventsTriggeringUpdateGUI)
                evnt=this.tgEventsTriggeringUpdateGUI{i};
                this.tgEventListenersTriggeringUpdateGUI(evnt)=...
                listener(tg,evnt,@(src,evnt)this.updateGUIWrapper(evnt));
            end
            if~isempty(this.tgListenerCreate)||~isempty(this.tgListenerDestroy)
                this.ConnectedListener=listener(tg,'Connected',...
                @(src,evnt)this.tgListenerCreate());
                this.DisconnectedListener=listener(tg,'Disconnected',...
                @(src,evnt)this.tgListenerDestroy());
                if tg.isConnected()
                    this.tgListenerCreate();
                end
            end



            this.updateGUIWrapper([]);
        end
    end




    methods(Access=protected)
        function val=isSimulinkNormalMode(this,varargin)
            if~slrealtime.internal.feature('InstrumentPanelSLNormalMode')
                val=false;
                return;
            end

            if~isempty(varargin)
                targetName=varargin{1};
            else
                targetName=this.GetTargetNameFcnH();
            end

            val=strcmp(targetName,...
            slrealtime.ui.control.TargetSelector.SIMULINK_NORMAL_MODE);
        end
    end




    methods(Access=protected)
        function openProgressDlg(this,msg,title)
            this.ProgressDlg=uiprogressdlg(...
            ancestor(this.Parent,'figure'),...
            'Indeterminate','on',...
            'Message',msg,...
            'Title',title);
        end

        function closeProgressDlg(this)
            try
                if~isempty(this.ProgressDlg)
                    drawnow nocallbacks;
                    delete(this.ProgressDlg);
                    this.ProgressDlg=[];
                end
            catch ME



                if~strcmp(ME.identifier,'MATLAB:class:InvalidHandle')
                    rethrow(ME);
                end
            end
        end
    end




    methods(Access=protected)
        function uialert(this,ME,varargin)
            function fixItCB(e)
                function updateComplete()
                    if this.UpdateButton.Completed
                        delete(this.UpdateButton);
                        this.UpdateButton=[];
                    end
                end
                if e.SelectedOptionIndex==2
                    tg=this.tgGetTargetObject();
                    if isempty(tg),return;end
                    this.UpdateButton=slrealtime.ui.control.UpdateButton(fig,'Visible','off');
                    addlistener(this.UpdateButton,'Completed','PostSet',@(o,e)updateComplete());
                    this.UpdateButton.buttonPushed();
                end
            end

            fig=ancestor(this.Parent,'figure');
            if strcmp(fig.Visible,'off')
                return;
            end

            targetName=this.GetTargetNameFcnH();

            errorTitle=message('slrealtime:appdesigner:TargetErrorTitle');

            if~isempty(ME.cause)&&strcmp(ME.cause{1}.identifier,'slrealtime:target:versionMismatch')



                errorMsg=message('slrealtime:appdesigner:TargetError',...
                targetName,...
                message('slrealtime:appdesigner:VersionMismatch').getString);

                fixItMsg=message('slrealtime:appdesigner:FixIt').getString();
                uiconfirm(...
                fig,...
                errorMsg.getString(),...
                errorTitle.getString(),...
                'Icon','error',...
                'Options',{getString(message('MATLAB:uitools:uidialogs:OK')),fixItMsg},...
                'DefaultOption',fixItMsg,varargin{:},...
                'CloseFcn',@(o,e)fixItCB(e));
            else
                errorMsg=message('slrealtime:appdesigner:TargetError',...
                targetName,...
                slrealtime.internal.replaceHyperlinks(ME.message));

                uialert(...
                fig,...
                errorMsg.getString(),...
                errorTitle.getString(),varargin{:});
            end
        end

        function uiwarning(this,msg)
            fig=ancestor(this.Parent,'figure');
            if strcmp(fig.Visible,'off')
                return;
            end

            warningTitle=message('slrealtime:appdesigner:TargetWarningTitle');

            uialert(...
            fig,...
            msg,warningTitle.getString(),...
            'Icon','warning','Modal',true);
        end
    end




    methods(Access=protected)
        function val=isDesignTime(this)





            val=false;
            if isprop(ancestor(this,'figure'),'DesignTimeProperties')
                val=true;
            end
        end
    end




    methods(Access=protected)





        function tg=tgGetTargetObject(this,varargin)
            tg=[];

            if~isempty(varargin)
                targetName=varargin{1};
            else
                targetName=this.GetTargetNameFcnH();
            end

            try
                tg=slrealtime(targetName);
            catch
                delete(this.ProgressDlg);
                this.ProgressDlg=[];
            end
        end

    end




    methods(Access=public)
        function delete(this)
            delete(this.TargetChangedListener);
            delete(this.DefaultTargetChangedListener);
            delete(this.TargetNameChangedListener);
            delete(this.ConnectedListener);
            delete(this.DisconnectedListener);

            delete(this.ProgressDlg);

            if~isempty(this.tgEventListenersTriggeringUpdateGUI)
                listeners=this.tgEventListenersTriggeringUpdateGUI.values;
                cellfun(@(x)delete(x),listeners);
            end

            this.tgListenerDestroy();
        end
    end




    methods
        function set.GetTargetNameFcnH(this,value)
            validateattributes(value,{'function_handle'},{'scalar'});
            this.GetTargetNameFcnH=value;
        end

        function set.TargetSelectorObj(this,value)
            if~isempty(value)
                validateattributes(value,{'slrealtime.ui.control.TargetSelector'},{'scalar'});
            end
            this.TargetSelectorObj=value;
        end
    end




    methods(Static)
        function blockpath=checkAndFormatBlockPath(blockpath)











            if iscell(blockpath)
                blockpath=cellfun(@convertStringsToChars,blockpath,'UniformOutput',false);
                if any(cellfun(@isempty,blockpath))||~all(cellfun(@ischar,blockpath))
                    slrealtime.internal.throw.Error('slrealtime:appdesigner:InvalidBlockPath');
                end
            elseif length(blockpath)>1&&isstring(blockpath(1))
                blockpath=arrayfun(@convertStringsToChars,blockpath,'UniformOutput',false);
                if any(cellfun(@isempty,blockpath))||~all(cellfun(@ischar,blockpath))
                    slrealtime.internal.throw.Error('slrealtime:appdesigner:InvalidBlockPath');
                end
            else
                blockpath=convertStringsToChars(blockpath);
                if~ischar(blockpath)
                    slrealtime.internal.throw.Error('slrealtime:appdesigner:InvalidBlockPath');
                end
            end
        end

        function blockPathStr=blockPathToDisplay(blockpath)




            if iscell(blockpath)
                blockPathStr=blockpath{1};
                for i=2:length(blockpath)
                    blockPathStr=strcat(blockPathStr,'/',extractAfter(blockpath{i},'/'));
                end
            else
                blockPathStr=blockpath;
            end
        end

        function validateImageFile(propertyName,propertyValue)






            [~,file,ext]=fileparts(propertyValue);
            fileNameWithExtension=[file,ext];



            if~isempty(propertyValue)&&...
                (isa(propertyValue,'char')||isa(propertyValue,'string'))&&...
                ~exist(fileNameWithExtension,'file')
                throwAsCaller(MException(message('MATLAB:appdesigner:appdesigner:fileNotFoundOnMatlabPathWithSuggestion',propertyName)));
            end



            if~isempty(propertyValue)
                try
                    matlab.ui.internal.IconUtils.validateIcon(fileNameWithExtension);
                catch
                    throwAsCaller(MException(message('MATLAB:ui:components:invalidIconFormat',...
                    'png, jpg, jpeg, gif, svg')));
                end
            end
        end



        function val=isDeployedWithDefaultTarget()
            targets=slrealtime.Targets;

            if(isdeployed&&...
                targets.getNumTargets==1&&...
                isequal(targets.getDefaultTargetName,'Enter_IP_Address_Here')&&...
                isempty(targets.getTargetSettings.address))
                val=true;
            else
                val=false;
            end
        end
    end




    methods(Access=public,Hidden)
        function out=getForTesting(this,prop)



            narginchk(2,2);

            if~ischar(prop)&&~isStringScalar(prop)
                slrealtime.internal.throw.Error('slrealtime:appdesigner:InvalidPropertyName');
            end

            if~contains(prop,'.')
                if isprop(this,prop)
                    out=this.(prop);
                else
                    slrealtime.internal.throw.Error('slrealtime:appdesigner:NotTargetProperty',prop,class(this));
                end
            else
                props=split(prop,'.');
                numProps=length(props);
                obj=this;
                for i=1:(numProps-1)
                    obj=obj.(char(props(i)));
                end

                if isprop(obj,char(props(numProps)))||...
                    any(strcmp(fieldnames(obj),char(props(numProps))))
                    out=obj.(char(props(numProps)));
                else
                    slrealtime.internal.throw.Error('slrealtime:appdesigner:NotTargetProperty',class(obj));
                end
            end
        end
    end
end
