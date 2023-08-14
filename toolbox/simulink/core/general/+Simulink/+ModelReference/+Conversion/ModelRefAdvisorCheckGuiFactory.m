




classdef ModelRefAdvisorCheckGuiFactory<handle
    properties(Access=private)
FunctionHandleMap
    end


    properties(Constant)
        AdvisorName=DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorName');
        ActionDescriptionMessage=DAStudio.message('Simulink:modelReferenceAdvisor:DefaultActionDescription',...
        DAStudio.message('Simulink:modelReferenceAdvisor:FixButtonLabel'),...
        DAStudio.message('Simulink:tools:MAContinue'),...
        DAStudio.message('Simulink:tools:MARunThisTask'));
    end



    methods(Access=public)
        function this=ModelRefAdvisorCheckGuiFactory()
            this.init;
        end


        function create(this,checkIds)
            mdladvRoot=ModelAdvisor.Root;
            numberOfChecks=length(checkIds);
            for idx=1:numberOfChecks
                checkId=checkIds{idx};
                checkItem=this.get(checkId);
                mdladvRoot.register(checkItem,this.AdvisorName);
            end
        end


        function item=get(this,checkId)
            assert(this.FunctionHandleMap.isKey(checkId),'Unrecognized check ID: %s',checkId);
            fhandle=this.FunctionHandleMap(checkId);
            item=fhandle(checkId);
        end
    end



    methods(Access=private)
        function init(this)
            this.FunctionHandleMap=containers.Map;
            this.FunctionHandleMap(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorInputParametersId)=...
            @this.createInputParametersCheck;

            this.FunctionHandleMap(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorModelConfigurationsId)=...
            @this.createModelConfigurationsCheck;

            this.FunctionHandleMap(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorSubsystemInterfaceId)=...
            @this.createSubsystemInterface;

            this.FunctionHandleMap(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorSubsystemContentId)=...
            @this.createSubsystemContent;

            this.FunctionHandleMap(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorCompleteConversionId)=...
            @this.createCompleteConversion;
        end


        function checkItem=createInputParametersCheck(this,checkId)
            checkItem=this.createGenericCheck(checkId,...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorInputParametersItem'),...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorInputParametersAnalysis',...
            Simulink.ModelReference.Conversion.ModelRefAdvisorTaskGuiFactory.DefaultSystemName));
            checkItem.setCallbackFcn(@Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.runCheck,'None','StyleOne');
        end


        function checkItem=createModelConfigurationsCheck(this,checkId)
            checkItem=this.createGenericCheck(checkId,...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorModelConfigurationsItem'),...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorModelConfigurationsAnalysis'));
            checkItem.setCallbackFcn(@Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.runCheck,'None','StyleOne');
            fixAction=this.createDefaultAction(@Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.runFix,...
            DAStudio.message('Simulink:modelReferenceAdvisor:FixButtonLabel'),...
            this.ActionDescriptionMessage);
            checkItem.setAction(fixAction);
        end


        function checkItem=createCompleteConversion(this,checkId)
            checkItem=this.createGenericCheck(checkId,...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorCompleteConversionItem'),...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorCompleteConversionAnalysis'));
            checkItem.setCallbackFcn(@Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.runCheck,'None','StyleOne');
        end


        function checkItem=createSubsystemInterface(this,checkId)
            checkItem=this.createGenericCheck(checkId,...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorSubsystemInterfaceItem'),...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorSubsystemInterfaceAnalysis'));
            checkItem.setCallbackFcn(@Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.runCheck,'None','StyleOne');
            fixAction=this.createDefaultAction(@Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.runFix,...
            DAStudio.message('Simulink:modelReferenceAdvisor:FixButtonLabel'),...
            this.ActionDescriptionMessage);
            checkItem.setAction(fixAction);
        end


        function checkItem=createSubsystemContent(this,checkId)
            checkItem=this.createGenericCheck(checkId,...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorSubsystemContentItem'),...
            DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorSubsystemContentAnalysis'));
            checkItem.setCallbackFcn(@Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.runCheck,'None','StyleOne');
            fixAction=this.createDefaultAction(@Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.runFix,...
            DAStudio.message('Simulink:modelReferenceAdvisor:FixButtonLabel'),...
            this.ActionDescriptionMessage);
            checkItem.setAction(fixAction);
        end
    end


    methods(Static,Access=public)
        function checkItem=createGenericCheck(checkId,title,titleTips)
            checkItem=ModelAdvisor.Check(checkId);
            checkItem.Title=title;
            checkItem.TitleTips=titleTips;
        end


        function inputParam=createGenericInputParameter(name,type,value,description,rowSpan,colSpan,isEnable)
            inputParam=ModelAdvisor.InputParameter;
            inputParam.Name=name;
            inputParam.Type=type;
            inputParam.Enable=isEnable;
            inputParam.Value=value;
            inputParam.Description=description;
            inputParam.setRowSpan(rowSpan);
            inputParam.setColSpan(colSpan);
        end


        function inputParam=createCombobox(name,entries,description,rowSpan,colSpan,isEnable)
            inputParam=ModelAdvisor.InputParameter;
            inputParam.Name=name;
            inputParam.Type='Enum';
            inputParam.Entries=entries;
            inputParam.Description=description;
            inputParam.setRowSpan(rowSpan);
            inputParam.setColSpan(colSpan);
            inputParam.Enable=isEnable;
        end


        function action=createDefaultAction(callBackFcn,actionName,actionDescription)
            action=ModelAdvisor.Action;
            action.setCallbackFcn(callBackFcn);
            action.Name=actionName;
            action.Description=actionDescription;
        end
    end
end
