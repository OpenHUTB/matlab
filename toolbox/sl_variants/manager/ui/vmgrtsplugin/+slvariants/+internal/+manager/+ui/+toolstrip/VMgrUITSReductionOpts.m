classdef(Hidden,Sealed)VMgrUITSReductionOpts<handle




    properties(Hidden)

        ReductionMode(1,:)char='';

        CompileMode(1,:)char='sim';

        ExcludeFiles(1,:)cell={};

        OutputFolder(1,:)char='';

        PreserveSignalAttributes(1,1)logical=true;

        GenerateDetailedSummary(1,1)logical=false;

        OpenReducedModel(1,1)logical=true;

        ModelSuffix(1,:)char='_r';
    end

    methods(Hidden)

        function obj=VMgrUITSReductionOpts()
        end

        function reduceModel(obj,modelH)
            oc1=onCleanup(@()obj.resetUI(modelH));

            modelName=getfullname(modelH);

            switch obj.ReductionMode
            case 'Simulink:VariantManagerUI:VariantReducerConfigRadiobuttonText'

                selectedConfigs=slvariants.internal.manager.ui.config.getSelectedConfigs(modelH);
                configPVArgs={'NamedConfigurations',selectedConfigs};
            case 'Simulink:VariantManagerUI:VariantReducerCtrlvarRadiobuttonText'

                configPVArgs=slvariants.internal.manager.ui.vargrps.getVariableGroupsPVArgs(modelH);
            otherwise

                configPVArgs={};
            end

            pvArgs=[configPVArgs,{'CompileMode',obj.CompileMode}];

            if slfeature('VRedExcludeFiles')>0
                pvArgs=[pvArgs,{'ExcludeFiles',obj.ExcludeFiles}];
            end

            pvArgs=[pvArgs,...
            {'PreserveSignalAttributes',obj.PreserveSignalAttributes,...
            'GenerateSummary',obj.GenerateDetailedSummary,...
            'ModelSuffix',obj.ModelSuffix,...
            'OutputFolder',obj.OutputFolder,...
            'CalledFromUI',true}];
            try
                [success,errorMsg,warnings,reducerCommand,reducedModelFullName]=...
                Simulink.VariantManager.reduceModel(modelName,pvArgs{:});
            catch exep
                sldiagviewer.reportError(exep);
                return;
            end

            if~isempty(reducerCommand)
                commandPrefix=MException(message('Simulink:VariantManagerUI:VariantReducerCommandrowPrefix'));
                sldiagviewer.reportInfo(commandPrefix);
                sldiagviewer.reportInfo(reducerCommand);
            end

            for warnItr=1:numel(warnings)
                actWarn=warnings{warnItr};
                sldiagviewer.reportWarning(actWarn);
            end

            if~isempty(errorMsg)
                sldiagviewer.reportError(errorMsg);
                return;
            end

            if~success
                return;
            end

            succMsg=MException(message('Simulink:VariantManagerUI:VariantReducerSuccessMessageWithoutCDCmd',reducedModelFullName));
            sldiagviewer.reportInfo(succMsg);


            if obj.OpenReducedModel
                calledFromUI=true;
                Simulink.variant.reducer.utils.cdAndOpenReducedModel(reducedModelFullName,calledFromUI);
            end
        end

        function obj=setOutputFolder(obj,modelHandle)
            fileName=get_param(modelHandle,'FileName');
            [dir,~,~]=fileparts(fileName);
            obj.OutputFolder=[dir,filesep,message('Simulink:VariantManagerUI:VariantReducerFoldernameSuffix').getString()];
        end

    end

    methods(Access=private)
        function resetUI(~,~)





        end
    end


end


