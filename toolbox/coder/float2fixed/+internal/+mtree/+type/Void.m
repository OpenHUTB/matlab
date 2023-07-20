






classdef Void<internal.mtree.Type

    methods(Access=public)

        function this=Void
            this=this@internal.mtree.Type([]);
        end

        function getMLName(~)
            error('no MATLAB name exists for void type')
        end

        function toSlName(~)
            error('no SL name exists for void type')
        end

        function doesit=supportsExampleValues(~)
            doesit=false;
        end

    end

    methods(Access=protected)

        function type=toScalarPIRType(~)%#ok<STOUT>
            error('cannot convert void type to PIR type')
        end

        function exVal=getExampleValueScalar(~)%#ok<STOUT>
            error('Cannot get an example value of a void type');
        end

        function exStr=getExampleValueStringScalar(~)%#ok<STOUT>
            error('Cannot get an example string of a void type');
        end

        function res=isTypeEqualScalar(~,~)

            res=false;
        end

    end

end
