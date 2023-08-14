classdef Targets<handle









    methods(Access=public)
        function this=Targets()
            tgs=slrealtime.Targets.getTargets();
            if isempty(tgs)
                if this.getInitializing()










                    return;
                end
                this.initialize();
                slrealtime.Targets.setTargets(this);
            else
                this=tgs;
            end
        end

        function tg=addTarget(this,varargin)
            TargetSettings=[];
            newTargetName='';

            if nargin==1





                targetNames=this.getTargetNames();
                while true
                    newTargetName=strcat(this.newTargetNamePrefix,...
                    num2str(this.newTargetNameSuffix));
                    if any(strcmp(targetNames,newTargetName))
                        this.newTargetNameSuffix=this.newTargetNameSuffix+1;
                        continue;
                    end
                    break;
                end

            elseif nargin==2












                newTargetName=convertStringsToChars(varargin{1});
                if~ischar(newTargetName)
                    TargetSettings=varargin{1};
                    if~isa(TargetSettings,'slrealtime.TargetSettings')
                        this.throwError('slrealtime:targets:invalidArgs');
                    end
                    newTargetName=TargetSettings.name;
                end
            else
                this.throwError('slrealtime:targets:invalidArgs');
            end

            if this.targetsMap.isKey(newTargetName)
                this.throwError('slrealtime:targets:targetExists',newTargetName);
            end

            if isempty(TargetSettings)
                TargetSettings=slrealtime.TargetSettings(newTargetName);
            end

            this.createTargetAndAddToTargetsMap(TargetSettings);

            tg=this.getTarget(newTargetName);

            this.MATLABSettingsUpdateTargets();

            notify(this,'AddedTarget',slrealtime.events.TargetAddedData(newTargetName));
        end

        function removeTarget(this,targetName)
            targetName=convertStringsToChars(targetName);
            if~ischar(targetName)
                this.throwError('slrealtime:targets:invalidArgs');
            end

            if~this.targetsMap.isKey(targetName)
                this.throwError('slrealtime:targets:targetDoesNotExist',targetName);
            end



            tg=this.targetsMap(targetName).target;
            if tg.isConnected()
                this.throwError('slrealtime:targets:targetMustBeDisconnected',targetName);
            end



            if this.targetsMap.length==1
                this.throwError('slrealtime:targets:cannotRemoveLastTarget',targetName);
            end



            this.targetsMap.remove(targetName);



            if strcmp(this.defaultTargetName,targetName)
                tgMapInfos=this.targetsMap.values;

                this.setDefaultTargetName(tgMapInfos{1}.target.TargetSettings.name);
            end

            this.MATLABSettingsUpdateTargets();
            this.MATLABSettingsUpdateDefaultTargetName();

            notify(this,'RemovedTarget',slrealtime.events.TargetRemovedData(targetName));
        end

        function target=getTarget(this,varargin)
            targetName='';
            if nargin==1
                targetName=this.defaultTargetName;
            elseif nargin==2
                targetName=convertStringsToChars(varargin{1});
                if~ischar(targetName)
                    this.throwError('slrealtime:targets:invalidArgs');
                end
            else
                this.throwError('slrealtime:targets:invalidArgs');
            end

            if slrealtime.internal.feature('InstrumentPanelSLNormalMode')&&...
                strcmp(targetName,slrealtime.ui.control.TargetSelector.SIMULINK_NORMAL_MODE)



                target=slrealtime.internal.NormalModeTarget.getInstance();
                return;
            end

            if~this.targetsMap.isKey(targetName)




                try
                    ipaddr=slrealtime.internal.validateIpAddress(targetName);
                catch
                    ipaddr=false;
                end
                if ipaddr
                    values=this.targetsMap.values;
                    idx=find(cellfun(@(x)strcmp(x.target.TargetSettings.address,targetName),values));
                    if~isempty(idx)&&length(idx)==1


                        target=values{idx}.target;
                        return;
                    end
                end

                this.throwError('slrealtime:targets:targetDoesNotExist',targetName);
            end

            target=this.targetsMap(targetName).target;
        end

        function defaultTargetName=getDefaultTargetName(this)
            defaultTargetName=this.defaultTargetName;
        end

        function setDefaultTargetName(this,defaultTargetName)
            defaultTargetName=convertStringsToChars(defaultTargetName);
            if~ischar(defaultTargetName)
                this.throwError('slrealtime:targets:invalidArgs');
            end

            if~this.targetsMap.isKey(defaultTargetName)
                this.throwError('slrealtime:targets:targetDoesNotExist',defaultTargetName);
            end

            if strcmp(this.defaultTargetName,defaultTargetName)
                return;
            end

            eventData=slrealtime.events.DefaultTargetData(...
            this.defaultTargetName,defaultTargetName);

            this.defaultTargetName=defaultTargetName;

            this.MATLABSettingsUpdateDefaultTargetName();

            notify(this,'DefaultTargetChanged',eventData);
        end

        function numTargets=getNumTargets(this)
            numTargets=this.targetsMap.length;
        end

        function targetNames=getTargetNames(this)
            tgMapInfos=this.targetsMap.values;
            targetNames=cellfun(@(tgMapInfo)tgMapInfo.target.TargetSettings.name,tgMapInfos,'UniformOutput',false);
        end

        function TargetSettings=getTargetSettings(this)
            tgMapInfos=this.targetsMap.values;
            TargetSettings=cellfun(@(tgMapInfo)tgMapInfo.target.TargetSettings,tgMapInfos);
        end
    end




    methods(Access=private)
        function delete(~)
        end

        function initialize(this)
            this.setInitializing(true);
            c=onCleanup(@()this.setInitializing(false));

            this.targetsMap=containers.Map('KeyType','char','ValueType','any');



            s=settings;
            try
                targetNames=s.slrealtime.targets.name.ActiveValue;
            catch
                targetNames=[];
            end
            if isempty(targetNames)

                name='TargetPC1';
                TargetSettings=slrealtime.TargetSettings(name);
                this.createTargetAndAddToTargetsMap(TargetSettings);
                this.defaultTargetName=name;

                this.MATLABSettingsUpdateTargets();
                this.MATLABSettingsUpdateDefaultTargetName();
            else
                for nTarget=1:length(targetNames)
                    TargetSettings=slrealtime.TargetSettings(...
                    targetNames{nTarget},...
                    s.slrealtime.targets.address.ActiveValue{nTarget},...
                    s.slrealtime.targets.sshPort.ActiveValue(nTarget),...
                    s.slrealtime.targets.xcpPort.ActiveValue(nTarget),...
                    s.slrealtime.targets.username.ActiveValue{nTarget},...
                    s.slrealtime.targets.userPassword.ActiveValue{nTarget},...
                    s.slrealtime.targets.rootPassword.ActiveValue{nTarget});
                    this.createTargetAndAddToTargetsMap(TargetSettings);
                end
                this.defaultTargetName=s.slrealtime.defaultTargetName.ActiveValue;
            end
        end

        function createTargetAndAddToTargetsMap(this,settings)
            tgsMapInfo=slrealtime.internal.TargetsMapInfo;

            tgsMapInfo.target=slrealtime.Target(settings);

            tgsMapInfo.renameListeners(end+1)=addlistener(settings,'name','PreSet',@this.targetRenamedCB);
            tgsMapInfo.renameListeners(end+1)=addlistener(settings,'name','PostSet',@this.targetRenamedCB);

            tgsMapInfo.settingsListeners(end+1)=addlistener(settings,'address','PostSet',@this.targetSettingsChangedCB);
            tgsMapInfo.settingsListeners(end+1)=addlistener(settings,'sshPort','PostSet',@this.targetSettingsChangedCB);
            tgsMapInfo.settingsListeners(end+1)=addlistener(settings,'xcpPort','PostSet',@this.targetSettingsChangedCB);
            tgsMapInfo.settingsListeners(end+1)=addlistener(settings,'username','PostSet',@this.targetSettingsChangedCB);
            tgsMapInfo.settingsListeners(end+1)=addlistener(settings,'userPassword','PostSet',@this.targetSettingsChangedCB);
            tgsMapInfo.settingsListeners(end+1)=addlistener(settings,'rootPassword','PostSet',@this.targetSettingsChangedCB);

            this.targetsMap(settings.name)=tgsMapInfo;
        end




        function targetRenamedCB(this,~,evnt)
            if strcmp(evnt.EventName,'PreSet')
                this.renameTargetOldName=evnt.AffectedObject.name;
            elseif strcmp(evnt.EventName,'PostSet')
                oldTargetName=this.renameTargetOldName;
                newTargetName=evnt.AffectedObject.name;


                assert(~this.targetsMap.isKey(newTargetName));

                this.targetsMap(newTargetName)=this.targetsMap(oldTargetName);
                this.targetsMap.remove(oldTargetName);

                this.MATLABSettingsUpdateTargets();





                if strcmp(this.defaultTargetName,oldTargetName)
                    this.defaultTargetName=newTargetName;
                    this.MATLABSettingsUpdateDefaultTargetName();
                end

                this.renameTargetOldName=[];

                notify(this,'TargetNameChanged',slrealtime.events.TargetNameData(oldTargetName,newTargetName));
            end
        end

        function targetSettingsChangedCB(this,~,~)
            this.MATLABSettingsUpdateTargets();
        end




        function MATLABSettingsUpdateDefaultTargetName(this)
            s=settings;
            s.slrealtime.defaultTargetName.PersonalValue=char(this.defaultTargetName);
        end

        function MATLABSettingsUpdateTargets(this)
            s=settings;
            tgMapInfos=this.targetsMap.values;
            s.slrealtime.targets.name.PersonalValue=cellfun(@(tgMapInfo)char(tgMapInfo.target.TargetSettings.name),tgMapInfos,'UniformOutput',false);
            s.slrealtime.targets.address.PersonalValue=cellfun(@(tgMapInfo)char(tgMapInfo.target.TargetSettings.address),tgMapInfos,'UniformOutput',false);
            s.slrealtime.targets.sshPort.PersonalValue=cellfun(@(tgMapInfo)tgMapInfo.target.TargetSettings.sshPort,tgMapInfos,'UniformOutput',true);
            s.slrealtime.targets.xcpPort.PersonalValue=cellfun(@(tgMapInfo)tgMapInfo.target.TargetSettings.xcpPort,tgMapInfos,'UniformOutput',true);
            s.slrealtime.targets.username.PersonalValue=cellfun(@(tgMapInfo)char(tgMapInfo.target.TargetSettings.username),tgMapInfos,'UniformOutput',false);
            s.slrealtime.targets.userPassword.PersonalValue=cellfun(@(tgMapInfo)char(tgMapInfo.target.TargetSettings.userPassword),tgMapInfos,'UniformOutput',false);
            s.slrealtime.targets.rootPassword.PersonalValue=cellfun(@(tgMapInfo)char(tgMapInfo.target.TargetSettings.rootPassword),tgMapInfos,'UniformOutput',false);
        end
    end

    properties(Access=private)
targetsMap
defaultTargetName

        newTargetNamePrefix='TargetPC'
        newTargetNameSuffix=1

        renameTargetOldName;
    end

    events
DefaultTargetChanged
AddedTarget
RemovedTarget
TargetNameChanged
    end




    methods(Access=public,Static,Hidden)
        function reset()
            tgs=slrealtime.Targets.getTargets();
            if~isempty(tgs)
                tgs.initialize();
            end
        end
    end




    methods(Access={?slrealtime.TargetSettings},Static)
        function initializing=getInitializing()
            initializing=slrealtime.Targets.manageInitializing('get');
        end
    end
    methods(Access=private,Static)
        function setInitializing(initializing)
            slrealtime.Targets.manageInitializing('set',initializing);
        end
        function varargout=manageInitializing(command,varargin)
            mlock;
            persistent theInitializing;
            switch(command)
            case 'get'
                varargout{1}=theInitializing;
            case 'set'
                theInitializing=varargin{1};
            otherwise
                assert(false);
            end
        end
    end

    methods(Access=private,Static)



        function exc=createExc(errId,varargin)
            msg=message(errId,varargin{:});
            exc=MException(errId,'%s',msg.getString());
        end
        function throwError(errId,varargin)
            throw(slrealtime.Targets.createExc(errId,varargin{:}));
        end
        function throwErrorAsCaller(errId,varargin)
            throwAsCaller(slrealtime.Targets.createExc(errId,varargin{:}));
        end




        function targets=getTargets()
            targets=slrealtime.Targets.manageTargets('get');
        end
        function setTargets(targets)
            slrealtime.Targets.manageTargets('set',targets);
        end
        function varargout=manageTargets(command,varargin)
            mlock;
            persistent theTargets;
            switch(command)
            case 'get'
                varargout{1}=theTargets;
            case 'set'
                theTargets=varargin{1};
            otherwise
                assert(false);
            end
        end
    end
end
