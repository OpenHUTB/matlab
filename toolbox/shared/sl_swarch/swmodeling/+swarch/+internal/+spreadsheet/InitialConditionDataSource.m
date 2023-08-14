classdef InitialConditionDataSource<handle




    properties(Constant)
        ComponentCol=getString(message('SoftwareArchitecture:ArchEditor:SoftwareComponentColumn'));
        PortCol=getString(message('SoftwareArchitecture:ArchEditor:PortColumn'));
        ICCol=getString(message('SoftwareArchitecture:ArchEditor:InitialConditionColumn'));
    end

    properties(Access=private)
pParentTab
pPort
    end

    methods
        function this=InitialConditionDataSource(parentTab,portObj)
            this.pParentTab=parentTab;
            this.pPort=portObj;
        end

        function portHdl=get(this)
            portHdl=this.pPort;
        end

        function propValue=getPropValue(this,propName)
            switch propName
            case this.ComponentCol
                propValue=this.pPort.getComponent().getName();
            case this.PortCol
                propValue=this.pPort.getName();
            case this.ICCol
                propValue=this.pPort.getInitialCondition();
            otherwise
                propValue={};
            end
        end

        function isValid=isValidProperty(~,~)
            isValid=true;
        end

        function isEditable=isEditableProperty(this,propName)
            isEditable=strcmp(this.ICCol,propName);
        end

        function setPropValue(this,propName,propValue)
            assert(strcmp(propName,this.ICCol));
            this.pPort.setInitialCondition(propValue);
        end

        function isAllowed=isDragAllowed(~)
            isAllowed=false;
        end

        function isAllowed=isDropAllowed(~)
            isAllowed=false;
        end
    end
end


