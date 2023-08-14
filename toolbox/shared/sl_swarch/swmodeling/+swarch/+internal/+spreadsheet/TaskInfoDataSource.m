classdef TaskInfoDataSource<handle




    properties(Constant)
        TaskNameCol=getString(message('SoftwareArchitecture:ArchEditor:TaskNameColumn'));
        PeriodCol=getString(message('SoftwareArchitecture:ArchEditor:PeriodColumn'));
        NumFunctionsCol=getString(message('SoftwareArchitecture:ArchEditor:NumFunctionsColumn'));
    end
    properties(Access=private)
        pTask;
        pParent;
    end

    methods
        function this=TaskInfoDataSource(parentTab,taskObj)
            this.pParent=parentTab;
            this.pTask=taskObj;
        end

        function taskHdl=get(this)
            taskHdl=this.pTask;
        end

        function propValue=getPropValue(this,propName)
            switch propName
            case this.TaskNameCol
                propValue=this.pTask.taskName;
            case this.NumFunctionsCol
                propValue=num2str(this.pTask.functions.Size);
            case this.PeriodCol
                propValue=num2str(this.pTask.period);
            otherwise




                propValue={};
            end
        end

        function isValid=isValidProperty(~,~)
            isValid=true;
        end

        function isEditable=isEditableProperty(this,propName)
            isEditable=strcmp(this.TaskNameCol,propName)||...
            strcmp(this.PeriodCol,propName);
        end

        function setPropValue(this,propName,propValue)
            switch propName
            case this.TaskNameCol
                this.pTask.taskName=propValue;
            case this.PeriodCol
                this.pTask.period=str2double(propValue);
            end
        end

        function schema=getPropertySchema(this)
            schema=swarch.internal.propertyinspector.TaskSchema(...
            this.pParent.getSpreadsheet().getStudio(),this.pTask);
        end

        function isAllowed=isDragAllowed(~)
            isAllowed=false;
        end

        function isAllowed=isDropAllowed(~)
            isAllowed=false;
        end
    end
end
