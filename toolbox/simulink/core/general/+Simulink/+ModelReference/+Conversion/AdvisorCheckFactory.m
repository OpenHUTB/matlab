




classdef AdvisorCheckFactory<handle
    properties(SetAccess=private,GetAccess=private)
Model
        ModelName=''
        Systems=''
SIDs
        ModelReferenceNames=''
        DataFileName=''

        ReplaceSubsystem=true
        CopyCodeMappings=false
        UseAutoFix=false
        CheckSimulationResults=false
        SimulationModes={}

        ShowConversionReport=true;
StopTime
RelativeTolerance
AbsoluteTolerance

        CheckList={}


        FailedCheckId='';
        HasFailed=false;


        FixResults={}
CheckResults
        Logger=[]
ModelReferenceAdvisor
FunctionHandleMap
StringMapForGui
        ConversionData=[];
    end


    properties(Transient,SetAccess=private,GetAccess=public)
        SubsystemConversion=[]
SystemNames
    end


    methods(Access=public)
        function this=AdvisorCheckFactory(mdladvObj,subsys)
            this.Model=bdroot(subsys(1));
            this.ModelName=get_param(this.Model,'Name');
            this.Systems=subsys;
            this.SIDs=arrayfun(@(ss)Simulink.ID.getSID(ss),subsys,'UniformOutput',false);
            this.ModelReferenceAdvisor=mdladvObj;
            this.init;

            this.StringMapForGui=Simulink.ModelReference.Conversion.StringMapForGui;
            this.CheckResults=[];
        end


        function item=runCheck(this,checkId)
            assert(this.FunctionHandleMap.isKey(checkId),'Unrecognized check ID: %s',checkId);
            fhandle=this.FunctionHandleMap(checkId);
            item=fhandle(checkId);
        end


        function runFixes(this)
            this.SubsystemConversion.runFixes;
            this.FixResults=this.ConversionData.Logger.getFixResults;


            this.ConversionData.clearFixQueues;
        end


        function terminate(this)
            if~isempty(this.SubsystemConversion)
                this.SubsystemConversion.runCheck(DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorTerminateId'));
            end
        end


        function results=getFixResults(this)
            results=this.FixResults;
        end


        function clearCheckResults(this)
            this.FixResults={};
        end
    end


    methods(Access=private)
        function init(this)
            this.FunctionHandleMap=containers.Map;

            this.FunctionHandleMap(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorInputParametersId)=@this.checkInputParameters;
            this.FunctionHandleMap(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorModelConfigurationsId)=@this.runGenericCheck;
            this.FunctionHandleMap(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorSubsystemInterfaceId)=@this.runGenericCheck;
            this.FunctionHandleMap(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorSubsystemContentId)=@this.runGenericCheck;
            this.FunctionHandleMap(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorCompleteConversionId)=@this.runGenericCheck;

            this.CheckList={...
            Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorModelConfigurationsId,...
            Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorSubsystemInterfaceId,...
            Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorSubsystemContentId,...
            Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorCompleteConversionId};
        end


        function setInternalStates(this,hasFailed,checkId)
            this.HasFailed=hasFailed;
            this.FailedCheckId=checkId;
        end


        function resetInternalStates(this)
            this.setInternalStates(false,'');
        end


        function results=checkInputParameters(this,~)
            try
                this.processInputParameters;


                backupName=[DAStudio.message('Simulink:modelReferenceAdvisor:BackupName'),' ',datestr(now)];
                subsys=this.ModelReferenceAdvisor.SystemName;
                backupDescription=DAStudio.message('Simulink:modelReferenceAdvisor:BackupDescription',bdroot(subsys),subsys);
                this.ModelReferenceAdvisor.saveRestorePoint(backupName,backupDescription);


                this.createSubsystemConversionObject;
            catch me
                this.CheckResults=me;
                needCleanup=false;
                this.processFailedCheck(needCleanup);
            end


            results=this.processResultForModelAdvisor;
        end


        function runPreviousChecks(this,checkId)
            currentCheckIdx=find(strcmp(this.CheckList,checkId));
            if~isempty(currentCheckIdx)
                if isempty(this.SubsystemConversion)



                    this.checkInputParameters;
                else
                    this.SubsystemConversion.reset;
                end


                currentCheckIdx=currentCheckIdx-1;
                for idx=1:currentCheckIdx
                    this.SubsystemConversion.runCheck(this.CheckList{idx});
                end
            end
        end


        function run(this,checkId)






            if~isempty(this.FailedCheckId)||isempty(this.SubsystemConversion)


                this.resetInternalStates;
                this.runPreviousChecks(checkId);
            end

            this.SubsystemConversion.runCheck(checkId);
        end


        function exec(this,checkId)
            try
                this.run(checkId);
            catch me
                this.terminate;
                if this.hasFix&&this.UseAutoFix
                    this.setInternalStates(true,checkId);

                    this.runFixes;

                    this.run(checkId);
                else
                    throw(me);
                end
            end
        end


        function results=processResultForModelAdvisor(this)
            messageBeautifier=Simulink.ModelReference.Conversion.MessageBeautifier;
            results=ModelAdvisor.Paragraph;
            results.setCollapsibleMode('none');
            lineBreak=ModelAdvisor.LineBreak;

            if isempty(this.CheckResults)
                results.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:modelReferenceAdvisor:CheckPassed'),{'bold','pass'}));


                this.processPassedCheck;
            else

                results.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:modelReferenceAdvisor:CheckFailed'),{'bold','fail'}));
                results.addItem(lineBreak);
                results.addItem(ModelAdvisor.Text(messageBeautifier.emitExceptionHTML(this.CheckResults)));


                this.CheckResults=[];


                needCleanup=true;
                this.processFailedCheck(needCleanup);
            end

            if~isempty(this.SubsystemConversion)


                if this.HasFailed&&~this.SubsystemConversion.getIsSuccess()
                    arrayfun(@(subsys)this.Logger.addInfo(...
                    message('Simulink:modelReferenceAdvisor:FailedConversionMessage',...
                    this.ConversionData.beautifySubsystemName(subsys),...
                    Simulink.ModelReference.Conversion.MessageBeautifier.createRestoreHyperLink(...
                    DAStudio.message('Simulink:modelReferenceAdvisor:RestoreOriginalModel')))),this.Systems);
                end


                if this.Logger.hasWarning
                    results.addItem(lineBreak);
                    results.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:modelReferenceAdvisor:CheckWarn'),{'bold','warn'}));
                    results.addItem(ModelAdvisor.Text(messageBeautifier.getHTMLTextFromMessages(this.Logger.getWarning),{'warn'}));
                    this.Logger.clearWarning;
                end


                if~isempty(this.FixResults)
                    results.addItem(lineBreak);
                    results.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:modelReferenceAdvisor:AutoFixDescription'),{'bold','pass'}));
                    results.addItem(ModelAdvisor.Text(messageBeautifier.getHTMLTextFromMessages(this.FixResults)));
                    this.FixResults={};
                end


                if this.Logger.hasInfo
                    results.addItem(lineBreak);
                    results.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:modelReferenceAdvisor:ConversionInfo'),{'bold'}));
                    results.addItem(ModelAdvisor.Text(messageBeautifier.getHTMLTextFromMessages(this.Logger.getInfo)));
                    this.Logger.clearInfo;
                end
            end
        end


        function results=runGenericCheck(this,checkId)
            try
                if~any(Simulink.ModelReference.Conversion.Utilities.isSubsystem(this.Systems))

                    modelBlocks=this.SubsystemConversion.ConversionData.ModelBlocks;
                    this.Logger.addWarning(message('Simulink:modelReferenceAdvisor:ConversionIsCompleted',getfullname(modelBlocks(1))));
                else
                    this.exec(checkId);
                end
            catch me
                this.CheckResults=me;
                this.setInternalStates(true,checkId);
            end


            results=this.processResultForModelAdvisor;
        end


        function processInputParameters(this)
            parentGroup=this.ModelReferenceAdvisor.getTaskObj(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorMainGroupId);
            params=parentGroup.getInputParameters;


            this.ModelReferenceNames=Simulink.ModelReference.Conversion.Utilities.cellify(...
            params{Simulink.ModelReference.Conversion.GuiParameters.NewModel}.Value);
            dataAccessor=Simulink.data.DataAccessor.createForExternalData(this.ModelName);
            cellfun(@(modelName)...
            Simulink.ModelReference.Conversion.ConversionParameters.validateModelReferenceName(modelName,dataAccessor),this.ModelReferenceNames);
            this.DataFileName=params{Simulink.ModelReference.Conversion.GuiParameters.DataFile}.Value;
            this.ReplaceSubsystem=params{Simulink.ModelReference.Conversion.GuiParameters.ReplaceSubsystem}.Value;
            this.CopyCodeMappings=params{Simulink.ModelReference.Conversion.GuiParameters.CopyCodeMappings}.Value;
            this.UseAutoFix=params{Simulink.ModelReference.Conversion.GuiParameters.AutoFix}.Value;
            this.CheckSimulationResults=params{Simulink.ModelReference.Conversion.GuiParameters.CheckSimulationResults}.Value;
            if this.CheckSimulationResults
                stopTimeExpression=params{Simulink.ModelReference.Conversion.GuiParameters.StopTime}.Value;
                this.StopTime=Simulink.SDIInterface.calculateStopTime(parentGroup.MAObj.ModelName,stopTimeExpression);
                this.AbsoluteTolerance=str2double(params{Simulink.ModelReference.Conversion.GuiParameters.AbsoluteTolerance}.Value);
                this.RelativeTolerance=str2double(params{Simulink.ModelReference.Conversion.GuiParameters.RelativeTolerance}.Value);
            end
            this.SimulationModes=this.StringMapForGui.get(params{Simulink.ModelReference.Conversion.GuiParameters.SimulationMode}.Value);
        end


        function createSubsystemConversionObject(this)
            inputArguments={};



            this.updateSystemHandles;

            inputArguments{end+1}=this.Systems;
            inputArguments{end+1}=this.ModelReferenceNames;

            inputArguments{end+1}='DataFileName';
            inputArguments{end+1}=this.DataFileName;


            if this.ReplaceSubsystem
                inputArguments{end+1}='ReplaceSubsystem';
                inputArguments{end+1}=true;
            end


            if this.CopyCodeMappings
                inputArguments{end+1}='CopyCodeMappings';
                inputArguments{end+1}=true;
            end



            if this.UseAutoFix
                inputArguments{end+1}='AutoFix';
                inputArguments{end+1}=true;
            end


            if this.CheckSimulationResults
                inputArguments{end+1}='CheckSimulationResults';
                inputArguments{end+1}=true;
                inputArguments{end+1}='AbsoluteTolerance';
                inputArguments{end+1}=this.AbsoluteTolerance;
                inputArguments{end+1}='RelativeTolerance';
                inputArguments{end+1}=this.RelativeTolerance;
                inputArguments{end+1}='StopTime';
                inputArguments{end+1}=this.StopTime;
            end

            inputArguments{end+1}='SimulationModes';
            inputArguments{end+1}={this.SimulationModes};


            inputArguments{end+1}='UseConversionAdvisor';
            inputArguments{end+1}=true;


            this.SubsystemConversion=Simulink.ModelReference.Conversion.SubsystemConversion(inputArguments{:});
            this.ConversionData=this.SubsystemConversion.ConversionData;
            this.Logger=this.SubsystemConversion.Logger;
            this.SystemNames=this.SubsystemConversion.ConversionParameters.SystemNames;
        end


        function cleanUp(this)
            this.terminate;
        end


        function processFailedCheck(this,needCleanup)
            this.ModelReferenceAdvisor.setCheckResultStatus(false);



            if isempty(this.SubsystemConversion)
                actionEnable=false;
            else
                actionEnable=this.hasFix;
            end

            this.ModelReferenceAdvisor.setActionEnable(actionEnable);
            this.ModelReferenceAdvisor.setCheckErrorSeverity(true);
            if needCleanup
                this.cleanUp;
            end
        end


        function processPassedCheck(this)
            if this.Logger.hasWarning
                this.ModelReferenceAdvisor.setCheckResultStatus(false);
                this.ModelReferenceAdvisor.setActionEnable(false);
                this.ModelReferenceAdvisor.setCheckErrorSeverity(0);
            else
                this.ModelReferenceAdvisor.setCheckResultStatus(true);
                this.ModelReferenceAdvisor.setActionEnable(false);
            end
        end


        function status=hasFix(this)
            if~isempty(this.ConversionData)
                status=this.SubsystemConversion.hasFix;
            else
                status=false;
            end
        end


        function updateSystemHandles(this)
            if~all(ishandle(this.Systems))
                if all(cellfun(@(sid)Simulink.ID.isValid(sid),this.SIDs))
                    this.Systems=cellfun(@(sid)Simulink.ID.getHandle(sid),this.SIDs);
                else

                    this.Systems=cellfun(@(ss)get_param(ss,'Handle'),this.SystemNames);
                end
            end
        end
    end
end


