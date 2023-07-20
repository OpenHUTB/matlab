




classdef FunctionHandle<internal.mtree.Type

    properties(Access=public)
        Name(1,:)char
    end

    methods(Access=public)

        function this=FunctionHandle(name)
            this=this@internal.mtree.Type([1,1]);

            assert(nargin>0,'missing function name for function handle')

            this.Name=name;
        end

        function name=getMLName(this)
            name=this.Name;
        end

        function type=toSlName(~)%#ok<STOUT>
            error('function handle does not have a Simulink name')
        end

        function doesit=supportsExampleValues(~)
            doesit=true;
        end

    end

    methods(Access=protected)

        function type=toScalarPIRType(this)%#ok<STOUT>
            error(['cannot convert function handle type ',this.Name,' to PIR type'])
        end

        function exVal=getExampleValueScalar(this)
            exVal=eval(this.getExampleValueStringScalar);
        end

        function exStr=getExampleValueStringScalar(this)
            exStr=['@',this.Name];
        end

        function res=isTypeEqualScalar(this,other)
            if~isa(other,'internal.mtree.type.FunctionHandle')
                res=false;
            else
                res=strcmp(this.getMLName,other.getMLName);
            end
        end

    end

end
