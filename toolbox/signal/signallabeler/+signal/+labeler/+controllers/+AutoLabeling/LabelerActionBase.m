classdef LabelerActionBase<handle




    properties(Hidden)
        Engine;
        Model;
        LabelerSettings;
        ParentLabelDefinitionID;
        LabelDefinitionID;


        NeedCleanUp;
    end
    methods(Hidden,Abstract)


        y=getFunctionHandle(this);

    end

    methods(Access=private)

        function[successFlag,exceptionKeyword,info]=addAutomatedLabelInstanceImpl(this,memberIDs,signalInfos,cleanUpHandle)




            this.NeedCleanUp=true;
            finishup=onCleanup(@()cleanUpHandle());


            labelerSettingsArguments=this.getLabelerSettingsArguments();
            functionHandle=this.getFunctionHandle();
            labelDefintionIDs=this.getLabelDefintionIDs();
            runTimeLimits=this.getRunTimeLimits();
            [successFlag,exceptionKeyword,info]=this.validateSignalType(memberIDs,signalInfos);
            if successFlag
                [successFlag,exceptionKeyword,info]=this.Model.addAutomatedLabelInstance(...
                memberIDs,signalInfos,labelDefintionIDs,functionHandle,labelerSettingsArguments,runTimeLimits);
            end


            this.NeedCleanUp=false;
        end
    end

    methods(Hidden)

        function this=LabelerActionBase(model,setupData)

            this.Engine=Simulink.sdi.Instance.engine;
            this.Model=model;
            this.updateSetting(setupData);
        end

        function[successFlag,exceptionKeyword,info]=addAutomatedLabelInstance(this,memberIDs,signalInfos,cleanUpHandle)
            [successFlag,exceptionKeyword,info]=addAutomatedLabelInstanceImpl(this,memberIDs,signalInfos,cleanUpHandle);
        end



        function updateSetting(this,setupData)
            this.LabelerSettings=setupData.lablerInfo.settings;
            this.LabelDefinitionID=setupData.labelDefintionsData.LabelDefinitionID;
            this.ParentLabelDefinitionID=setupData.labelDefintionsData.ParentLabelDefinitionID;
        end

        function[successFlag,exceptionKeyword,info]=validateSignalType(...
            this,memberIDs,signalInfos)%#ok<INUSD>


            successFlag=true;
            exceptionKeyword='';
            info=struct('succesFlag',successFlag);
        end

        function nameValuePairCellArray=getLabelerSettingsArguments(~)
            nameValuePairCellArray={};
        end

        function y=getLabelDefintionIDs(this)
            if~strcmp(this.ParentLabelDefinitionID,'')
                y=[string(this.ParentLabelDefinitionID),string(this.LabelDefinitionID)];
            else
                y=string([this.LabelDefinitionID]);
            end
        end

        function y=getRunTimeLimits(this)
            y=[];
            if isfield(this.LabelerSettings,'RunTimeLimits')
                y=this.LabelerSettings.RunTimeLimits;
            end
        end
    end
end

