classdef IRTInfoDataSource<swarch.internal.spreadsheet.FunctionInfoDataSource




    properties(Constant)
        FunctionTypeCol=getString(message('SoftwareArchitecture:ArchEditor:FunctionTypeColumn'));
        InitializeType=getString(message('SoftwareArchitecture:ArchEditor:InitializeType'));
        ResetType=getString(message('SoftwareArchitecture:ArchEditor:ResetType'));
        TerminateType=getString(message('SoftwareArchitecture:ArchEditor:TerminateType'));
    end

    methods(Access=protected)
        function propVal=getSubclassPropAllowedValues(this,propName)
            switch propName
            case this.FunctionTypeCol
                propVal={this.InitializeType,this.ResetType,this.TerminateType};
            otherwise
                propVal={};
            end
        end

        function propValue=getSubclassPropValue(this,propName)
            import systemcomposer.architecture.model.swarch.FunctionType

            switch propName
            case this.FunctionTypeCol
                switch this.pFunction.type
                case FunctionType.Initialize
                    propValue=this.InitializeType;
                case FunctionType.Reset
                    propValue=this.ResetType;
                case FunctionType.Terminate
                    propValue=this.TerminateType;
                end
            otherwise
                propValue={};
            end
        end

        function setSubclassPropValue(this,propName,propValue)
            import systemcomposer.architecture.model.swarch.FunctionType;

            if strcmpi(propName,this.FunctionTypeCol)
                switch propValue
                case this.InitializeType
                    this.pFunction.type=FunctionType.Initialize;
                case this.ResetType
                    this.pFunction.type=FunctionType.Reset;
                case this.TerminateType
                    this.pFunction.type=FunctionType.Terminate;
                end
            end
        end
    end

    methods
        function isAllowed=isDragAllowed(~)
            isAllowed=false;
        end

        function isAllowed=isDropAllowed(~)
            isAllowed=false;
        end
    end
end