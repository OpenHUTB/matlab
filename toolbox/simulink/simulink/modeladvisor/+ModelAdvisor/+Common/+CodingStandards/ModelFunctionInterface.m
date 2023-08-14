
classdef ModelFunctionInterface<ModelAdvisor.Common.CodingStandards.Base

    methods(Access=public)

        function this=ModelFunctionInterface(system,messagePrefix)
            this@ModelAdvisor.Common.CodingStandards.Base(...
            system,messagePrefix);
            this.flaggedObjects=struct(...
            'uuid',{},...
            'Position',{},...
            'SLObjectName',{},...
            'SLObjectType',{},...
            'Category',{},...
            'ArgName',{},...
            'Qualifier',{},...
            'Recommended',{});
            this.validationMessage='';
        end

        function algorithm(this)





            active=get_param(this.rootSystem,...
            'ModelStepFunctionPrototypeControlCompliant');
            if strcmp(active,'off')
                this.localResultStatus=true;
                this.localResultStatusDetails='PassNoSpec';
                return;
            end





            functionSpecification=RTW.getFunctionSpecification(this.rootSystem);





            if isempty(functionSpecification)
                this.localResultStatus=true;
                this.localResultStatusDetails='PassNoSpec';
                return;
            end





            if isa(functionSpecification,'RTW.FcnDefault')
                this.localResultStatus=true;
                this.localResultStatusDetails='PassDefaultSpec';
                return;
            end





            if isa(functionSpecification,'RTW.ModelSpecificCPrototype')





                if functionSpecification.PreConfigFlag
                    [validationOk,this.validationMessage]=...
                    functionSpecification.runValidation('init');
                else
                    [validationOk,this.validationMessage]=...
                    functionSpecification.runValidation('postProp');
                end
                if~validationOk
                    this.localResultStatus=false;
                    this.localResultStatusDetails='WarnInvalidConf';
                    return;
                end





                Data=functionSpecification.syncWithModel();





                for i=1:numel(Data)
                    notOk=strcmp(Data(i).SLObjectType,'Inport')&&...
                    strcmp(Data(i).Category,'Pointer')&&...
                    strcmp(Data(i).Qualifier,'none');
                    if notOk
                        this.addFlaggedObject(Data(i));
                    end
                end

            end

            if this.getNumFlaggedObjects()==0
                this.localResultStatus=true;
                this.localResultStatusDetails='';
            else
                this.localResultStatus=false;
                this.localResultStatusDetails='';
            end

        end

        function report(this)

            resultTable=ModelAdvisor.FormatTemplate('TableTemplate');
            resultTable.setCheckText(this.getMessage('CheckText'));
            resultTable.setColTitles({...
            this.getMessage('ColTitle_Order'),...
            this.getMessage('ColTitle_PortName'),...
            this.getMessage('ColTitle_PortType'),...
            this.getMessage('ColTitle_Category'),...
            this.getMessage('ColTitle_ArgumentName'),...
            this.getMessage('ColTitle_Qualifier'),...
            this.getMessage('ColTitle_RecommendedQualifier')});
            resultTable.setSubBar(false);
            this.addReportObject(resultTable);

            earlyReturn=...
            this.localResultStatus==true&&...
            strcmp(this.localResultStatusDetails,'PassNoSpec');
            if earlyReturn
                resultTable.setSubResultStatus('Pass');
                resultTable.setSubResultStatusText(this.getMessage(...
                'TextPassNoSpec'));
                return;
            end

            earlyReturn=...
            this.localResultStatus==true&&...
            strcmp(this.localResultStatusDetails,'PassDefaultSpec');
            if earlyReturn
                resultTable.setSubResultStatus('Pass');
                resultTable.setSubResultStatusText(this.getMessage(...
                'TextPassDefaultSpec'));
                return;
            end

            earlyReturn=...
            this.localResultStatus==false&&...
            strcmp(this.localResultStatusDetails,'WarnInvalidConf');
            if earlyReturn
                resultTable.setSubResultStatus('Warn');
                resultTable.setSubResultStatusText([this.getMessage(...
                'TextWarnInvalidConf'),...
                ' ',...
                this.getValidationMessage()]);
                resultTable.setRecAction(this.getMessage(...
                'RecommendedActionInvalidConf'));
                return;
            end

            for i=1:this.getNumFlaggedObjects()
                flaggedObject=this.getFlaggedObjects(i);
                row={...
                num2str(flaggedObject.Position),...
                flaggedObject.SLObjectName,...
                flaggedObject.SLObjectType,...
                flaggedObject.Category,...
                flaggedObject.ArgName,...
                flaggedObject.Qualifier,...
                flaggedObject.Recommended};
                resultTable.addRow(row);
            end

            if this.localResultStatus
                resultTable.setSubResultStatus('Pass');
                resultTable.setSubResultStatusText(this.getMessage(...
                'TextPass'));
            else
                resultTable.setSubResultStatus('Warn');
                resultTable.setSubResultStatusText(this.getMessage(...
                'TextWarn'));
                resultTable.setRecAction(this.getMessage(...
                'RecommendedAction'));
            end

        end

        function message=getValidationMessage(this)
            message=this.validationMessage;
        end

    end

    properties(Access=protected)
        validationMessage;
    end

    methods(Access=protected)

        function addFlaggedObject(this,Data)
            this.flaggedObjects(end+1)=struct(...
            'uuid','',...
            'Position',Data.Position,...
            'SLObjectName',Data.SLObjectName,...
            'SLObjectType',Data.SLObjectType,...
            'Category',Data.Category,...
            'ArgName',Data.ArgName,...
            'Qualifier',Data.Qualifier,...
            'Recommended','const *');
        end

    end

end

