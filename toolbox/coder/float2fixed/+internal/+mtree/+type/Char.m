




classdef Char<internal.mtree.Type

    methods(Access=public)

        function this=Char(dimensions)
            this=this@internal.mtree.Type(dimensions);
        end

        function name=getMLName(~)
            name='char';
        end

        function type=toSlName(~)%#ok<STOUT>
            error('char type does not have a Simulink name')
        end

        function doesit=supportsExampleValues(~)
            doesit=true;
        end

    end

    methods(Access=protected)

        function type=toScalarPIRType(~)%#ok<STOUT>
            error('char type does not have a PIR type')
        end

        function exVal=getExampleValueScalar(this)
            exVal=eval(this.getExampleValueStringScalar);
        end

        function exStr=getExampleValueStringScalar(~)
            exStr='''a''';
        end

        function res=isTypeEqualScalar(~,other)
            res=isa(other,'internal.mtree.type.Char');
        end

    end

end
