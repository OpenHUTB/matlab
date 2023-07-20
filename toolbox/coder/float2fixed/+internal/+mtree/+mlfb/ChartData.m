




classdef ChartData<handle
    properties
Name
Scope
PIRType
    end

    methods
        function this=ChartData(name,type,scope)
            this.Name=name;
            this.PIRType=type;
            this.Scope=internal.mtree.mlfb.Scope(scope);
        end

        function val=isInput(this)
            val=isequal(this.Scope,internal.mtree.mlfb.Scope.INPUT);
        end

        function val=isOutput(this)
            val=isequal(this.Scope,internal.mtree.mlfb.Scope.OUTPUT);
        end

        function val=isParameter(this)
            val=isequal(this.Scope,internal.mtree.mlfb.Scope.PARAMETER);
        end

        function val=isBusType(this)
            val=this.PIRType.isRecordType;
        end
    end
end
