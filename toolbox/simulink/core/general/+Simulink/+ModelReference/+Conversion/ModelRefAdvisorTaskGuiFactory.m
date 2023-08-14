




classdef ModelRefAdvisorTaskGuiFactory<handle
    properties(Access=private)
FunctionHandleMap
    end


    properties(Constant)
        DefaultSystemName='';
        DefaultDataFileName='data.mat'
        HelpMapFile=fullfile(docroot,'toolbox','simulink','helptargets.map');
    end


    methods(Access=public)
        function this=ModelRefAdvisorTaskGuiFactory()
            this.init;
        end


        function create(this,supportedIds)
            mdladvRoot=ModelAdvisor.Root;
            mainGroup=this.get(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorMainGroupId);


            this.addSupportedTask(mdladvRoot,mainGroup,supportedIds,...
            Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorInputParametersId);

            this.addSupportedTask(mdladvRoot,mainGroup,supportedIds,...
            Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorModelConfigurationsId);

            this.addSupportedTask(mdladvRoot,mainGroup,supportedIds,...
            Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorSubsystemInterfaceId);

            this.addSupportedTask(mdladvRoot,mainGroup,supportedIds,...
            Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorSubsystemContentId);

            this.addSupportedTask(mdladvRoot,mainGroup,supportedIds,Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorCompleteConversionId);
            mdladvRoot.register(mainGroup);
        end


        function item=get(this,id)
            assert(this.FunctionHandleMap.isKey(id),'Unrecognized task ID: %s',id);
            fhandle=this.FunctionHandleMap(id);
            item=fhandle(id);
        end
    end


    methods(Access=private)
        function addTask(this,mdladvRoot,parent,taskId)
            task=this.get(taskId);
            mdladvRoot.register(task);
            parent.addTask(task);
        end


        function addSupportedTask(this,mdladvRoot,parent,supportedIds,taskId)
            if any(strcmp(supportedIds,taskId))
                this.addTask(mdladvRoot,parent,taskId);
            end
        end


        function item=createMainGroup(this,taskId)
            item=this.createGenericProcedure(taskId,Simulink.ModelReference.Conversion.ModelRefAdvisorTaskGuiFactory.DefaultSystemName,...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorMainGroupAnalysis',...
            Simulink.ModelReference.Conversion.ModelRefAdvisorTaskGuiFactory.DefaultSystemName));
            item.CustomObject=this.createMainGroupCustomObject;


            maxCol=11;
            item.InputParametersLayoutGrid=[6,maxCol];
            item.setInputParametersCallbackFcn(@Simulink.ModelReference.Conversion.AdvisorCallbacks.inputParametersCallbackFcn);

            checkSimulationResults=false;
            stopTime=Simulink.SDIInterface.DefaultStopTime;
            absError=Simulink.SDIInterface.DefaultAbsoluteTolerance;
            relError=Simulink.SDIInterface.DefaultRelativeTolerance;

            inputParams={...
            Simulink.ModelReference.Conversion.ModelRefAdvisorCheckGuiFactory.createGenericInputParameter(...
            DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogNewModelName'),...
            'string','',DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogNewModelNameDesc'),[1,1],[1,maxCol],true),...
            Simulink.ModelReference.Conversion.ModelRefAdvisorCheckGuiFactory.createGenericInputParameter(...
            DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogDataFileName'),'string',...
            Simulink.ModelReference.Conversion.ModelRefAdvisorTaskGuiFactory.DefaultDataFileName,...
            DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogDataFileNameDesc'),...
            [2,2],[1,maxCol],true),...
            Simulink.ModelReference.Conversion.ModelRefAdvisorCheckGuiFactory.createGenericInputParameter(...
            DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogAutoFix'),...
            'bool',false,DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogAutoFixDesc'),[3,3],[1,maxCol],true),...
            Simulink.ModelReference.Conversion.ModelRefAdvisorCheckGuiFactory.createGenericInputParameter(...
            DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogReplaceSubsystem'),...
            'bool',true,DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogReplaceSubsystemDesc'),[4,4],[1,5],true),...
            Simulink.ModelReference.Conversion.ModelRefAdvisorCheckGuiFactory.createGenericInputParameter(...
            DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogCopyCodeMappings'),...
            'bool',false,DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogCopyCodeMappingsDesc'),[4,4],[6,maxCol],true),...
            Simulink.ModelReference.Conversion.ModelRefAdvisorCheckGuiFactory.createCombobox(...
            DAStudio.message('Simulink:modelReferenceAdvisor:SimulationMode'),...
            Simulink.ModelReference.Conversion.StringMapForGui.Keys,...
            DAStudio.message('Simulink:modelReferenceAdvisor:SimulationModeDesc'),[5,5],[1,maxCol],true),...
            Simulink.ModelReference.Conversion.ModelRefAdvisorCheckGuiFactory.createGenericInputParameter(...
            DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogCheckSimulationResults'),...
            'bool',checkSimulationResults,...
            DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogCheckSimulationResultsDesc'),[6,6],[1,maxCol],true),...
            Simulink.ModelReference.Conversion.ModelRefAdvisorCheckGuiFactory.createGenericInputParameter(...
            DAStudio.message('Simulink:modelReferenceAdvisor:StopTime'),...
            'string',num2str(stopTime),DAStudio.message('SimulinkPerformanceAdvisor:advisor:StopTimeTip'),...
            [7,7],[1,3],checkSimulationResults),...
            Simulink.ModelReference.Conversion.ModelRefAdvisorCheckGuiFactory.createGenericInputParameter(...
            DAStudio.message('Simulink:modelReferenceAdvisor:AbsoluteTolerance'),...
            'string',num2str(absError),DAStudio.message('Simulink:modelReferenceAdvisor:AbsoluteToleranceDesc'),...
            [7,7],[5,7],checkSimulationResults),...
            Simulink.ModelReference.Conversion.ModelRefAdvisorCheckGuiFactory.createGenericInputParameter(...
            DAStudio.message('Simulink:modelReferenceAdvisor:RelativeTolerance'),...
            'string',num2str(relError),DAStudio.message('Simulink:modelReferenceAdvisor:RelativeToleranceDesc'),...
            [7,7],[9,maxCol],checkSimulationResults),...
            };

            item.setInputParameters(inputParams);


            item.HelpMethod='helpview';
            item.HelpArgs={Simulink.ModelReference.Conversion.ModelRefAdvisorTaskGuiFactory.HelpMapFile,'susbys_to_model_ref'};

            Simulink.ModelReference.Conversion.AdvisorCallbacks.inputParametersCallbackFcn(item);
        end


        function item=createInputParametersTask(this,taskId)
            item=this.createGenericTask(taskId,DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorInputParametersItem'),'');
        end


        function item=createModelConfigurationsTask(this,taskId)
            item=this.createGenericTask(taskId,DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorModelConfigurationsItem'),'');
        end


        function item=createCompleteConversionTask(this,taskId)
            item=this.createGenericTask(taskId,...
            [...
            DAStudio.message('Simulink:tools:PrefixForCompileCheck'),' ',...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorCompleteConversionItem')],...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorCompleteConversionAnalysis'));
        end


        function item=createSubsystemInterfaceTask(this,taskId)
            item=this.createGenericTask(taskId,...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorSubsystemInterfaceItem'),...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorSubsystemInterfaceAnalysis'));
        end


        function item=createSubsystemContentTask(this,taskId)
            item=this.createGenericTask(taskId,...
            [...
            DAStudio.message('Simulink:tools:PrefixForCompileCheck'),' ',...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorSubsystemContentItem')],...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorSubsystemContentAnalysis'));
        end


        function init(this)
            this.FunctionHandleMap=containers.Map;
            this.FunctionHandleMap(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorMainGroupId)=@this.createMainGroup;
            this.FunctionHandleMap(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorInputParametersId)=...
            @this.createInputParametersTask;
            this.FunctionHandleMap(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorModelConfigurationsId)=...
            @this.createModelConfigurationsTask;
            this.FunctionHandleMap(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorSubsystemInterfaceId)=...
            @this.createSubsystemInterfaceTask;
            this.FunctionHandleMap(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorSubsystemContentId)=...
            @this.createSubsystemContentTask;
            this.FunctionHandleMap(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorCompleteConversionId)=...
            @this.createCompleteConversionTask;
        end
    end


    methods(Static,Access=private)
        function taskItem=createGenericTask(taskId,displayName,description)
            taskItem=ModelAdvisor.Task(taskId);
            taskItem.DisplayName=displayName;
            taskItem.Description=description;
            taskItem.setCheck(taskId);
            taskItem.EnableReset=true;
            taskItem.Value=false;
            taskItem.CSHParameters.MapKey='mdlrefadvisor';
            taskItem.CSHParameters.TopicID=taskId;
        end


        function taskItem=createGenericProcedure(taskId,displayName,description)
            taskItem=ModelAdvisor.Procedure(taskId);
            taskItem.DisplayName=displayName;
            taskItem.Description=description;
        end


        function obj=createMainGroupCustomObject()
            obj=ModelAdvisor.Customization;
            obj.GUITitle=DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorName');
            obj.GUICloseCallback={'Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.cleanup'};


            obj.MenuHelp.Text=DAStudio.message('Simulink:modelReferenceAdvisor:RootHelp');
            obj.MenuHelp.Callback=['helpview(','''',Simulink.ModelReference.Conversion.ModelRefAdvisorTaskGuiFactory.HelpMapFile,''',',...
            '''susbys_to_model_ref'');'];
            obj.MenuAbout.Text=DAStudio.message('Simulink:tools:MAAboutSimulink');
            obj.MenuAbout.Callback='daabout(''simulink'');';


            obj.LoadRestorePointCallback={'Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.restore'};


            obj.MenuSettings.Visible=false;


            obj.GUIReportTabName=DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorName');
            obj.ReportPageTitleCallback=...
            {'DAStudio.message','string','Simulink:modelReferenceAdvisor:PerformReportFor','string','''%<SystemName>''','token'};
            obj.ReportTitle=DAStudio.message('Simulink:modelReferenceAdvisor:ReportTitle');
        end
    end
end
