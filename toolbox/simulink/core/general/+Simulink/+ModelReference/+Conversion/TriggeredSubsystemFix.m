classdef TriggeredSubsystemFix<Simulink.ModelReference.Conversion.AutoFix
    properties(SetAccess=private,GetAccess=public)
Model
System
        TriggeredSystems=[]
ConversionData
        Results={};
    end

    properties(SetAccess=private,GetAccess=private)
SystemNames
    end

    properties(SetAccess=private,GetAccess=private)
        FixedPorts=[];
        PortWithMultipleFcnCallSignals=[]
    end

    properties(Constant,Access=private)
        AddLineOpts={'autorouting','on'};
        AddBlockOpts={'MakeNameUnique','on'};
    end

    methods(Access=public)
        function this=TriggeredSubsystemFix(params,rootSubsystem,ssNames)
            this.IsModifiedSystemInterface=false;




            this.System=rootSubsystem;
            this.SystemNames=ssNames;
            this.ConversionData=params;
        end


        function fix(this)
            this.update;

            isMarkedExpFcnMdl=false;
            if slfeature('ExecutionDomainExportFunction')>2&&...
                strcmp(get_param(this.Model,'IsExportFunctionModel'),'on')&&...
                numel(this.TriggeredSystems)>0
                isMarkedExpFcnMdl=true;


                set_param(this.Model,'IsExportFunctionModel','off');
            end

            for idx=1:numel(this.TriggeredSystems)
                subsys=this.TriggeredSystems(idx);
                ph=get_param(subsys,'PortHandles');


                srcBlk='';
                if slfeature('ExecutionDomainExportFunction')>2



                    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);
                    trigpHO=get_param(ph.Trigger,'Object');
                    actSrcP=trigpHO.getActualSrc;
                    srcBlk=get_param(actSrcP(1,1),'Parent');
                    while~isempty(srcBlk)&&...
                        strcmp(get_param(srcBlk,'BlockType'),'From')
                        gtBlkStruct=get_param(srcBlk,'GotoBlock');
                        gtBlk=gtBlkStruct.name;
                        curPortHs=get_param(gtBlk,'PortHandles');
                        curInPHO=get_param(curPortHs.Inport,'Object');
                        actSrcP=curInPHO.getActualSrc;
                        srcBlk=get_param(actSrcP(1,1),'Parent');
                    end
                    if~isempty(srcBlk)&&...
                        ~strcmp(get_param(srcBlk,'BlockType'),'Inport')
                        DAStudio.error('RTW:buildProcess:trigSysMustBeDrivenByInport',...
                        getfullname(subsys));
                    end
                    delete(sess);
                    if isempty(srcBlk)
                        continue;
                    end
                    srcBlk=get_param(srcBlk,'handle');
                else
                    aLine=get_param(ph.Trigger,'Line');
                    srcBlk=get_param(aLine,'SrcBlockHandle');
                end


                if~ishandle(srcBlk)
                    continue;
                end

                triggerPort=find_system(subsys,'SearchDepth',1,'IncludeCommented','off','LookUnderMasks','all','BlockType','TriggerPort');


                this.convertTriggerToFunctionCall(subsys,triggerPort,srcBlk);


                this.updateConfigsetParams;
            end

            if~isempty(this.PortWithMultipleFcnCallSignals)

            end


            if isMarkedExpFcnMdl&&...
                slfeature('ExecutionDomainExportFunction')>2
                set_param(this.Model,'IsExportFunctionModel','on');
            end
        end

        function results=getActionDescription(this)
            results=this.Results;
        end
    end

    methods(Access=private)
        function update(this)
            allSystems=this.ConversionData.ConversionParameters.Systems;
            aNewModel=this.ConversionData.ConversionParameters.ModelReferenceNames{this.System==allSystems};
            this.Model=get_param(aNewModel,'Handle');
            newTriggeredSubsys=strcat([aNewModel,'/'],this.SystemNames);
            this.TriggeredSystems=cellfun(@(ssName)get_param(ssName,'Handle'),...
            Simulink.ModelReference.Conversion.Utilities.cellify(newTriggeredSubsys));
        end

        function updateConfigsetParams(this)
            cs=getActiveConfigSet(this.Model);
            this.set_param(cs,'UnderspecifiedInitializationDetection','Simplified');
            this.set_param(cs,'InvalidFcnCallConnMsg','error');
            this.set_param(cs,'FcnCallInpInsideContextMsg','error');
            this.set_param(cs,'Solver','FixedStepDiscrete');
            this.set_param(cs,'SolverType','Fixed-step');
            this.set_param(cs,'SampleTimeConstraint','Unconstrained');
            this.set_param(cs,'EnableRefExpFcnMdlSchedulingChecks','off');

        end

        function set_param(this,cs,paramName,value)%#ok
            if~isa(cs,'Simulink.ConfigSetRef')
                set_param(cs,paramName,value);
            end
        end
    end

    methods(Static,Access=public)
        function convertTriggerToFunctionCall(subsys,triggerPort,srcBlk)
            srcBlkType=get(srcBlk,'BlockType');
            if strcmp(srcBlkType,'Inport')


                set_param(srcBlk,'OutDataTypeStr','Inherit: auto');
                set_param(srcBlk,'SampleTime','-1');
                set_param(srcBlk,'OutputFunctionCall','on');


                triggerBlk=find_system(subsys,'SearchDepth',1,'LookUnderMasks','all','BlockType','TriggerPort');
                set_param(triggerBlk,'TriggerType','function-call');
                set_param(triggerBlk,'StatesWhenEnabling','held');


                if strcmp(get_param(subsys,'RTWFcnNameOpts'),'User specified')
                    fcnName=get_param(subsys,'RTWFcnName');
                    set_param(subsys,'Name',fcnName);
                end


                set_param(subsys,'RTWFcnNameOpts','Auto');
                set_param(subsys,'RTWFcnName','');






                triggerPortTsType=get_param(triggerPort,'SampleTimeType');
                if strcmp(triggerPortTsType,'triggered')

                else
                    triggerPortTs=get_param(triggerPort,'SampleTime');
                    if~strcmp(triggerPortTs,'-1')
                        set_param(srcBlk,'SampleTime',triggerPortTs);
                    else
                        set_param(triggerPort,'SampleTimeType','triggered');
                    end
                end
            end
        end
    end
end
