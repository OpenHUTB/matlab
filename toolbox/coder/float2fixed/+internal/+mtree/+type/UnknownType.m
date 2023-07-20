




classdef UnknownType<internal.mtree.Type

    properties(Access=public)
        Name(1,:)char
    end

    methods(Access=public)

        function this=UnknownType(name,dimensions)
            if nargin<2
                dimensions=[];
            end

            this=this@internal.mtree.Type(dimensions);

            if nargin<1
                name='unknown';
            end

            this.Name=name;
        end

        function name=getMLName(this)
            name=this.Name;
        end

        function type=toSlName(~)

            type='Inherit';
        end

        function doesit=supportsExampleValues(~)
            doesit=false;
        end

    end

    methods(Access=protected)

        function type=toScalarPIRType(this)%#ok<STOUT>
            error(['cannot convert unknown type ',this.Name,' to PIR type'])
        end

        function exVal=getExampleValueScalar(~)%#ok<STOUT>
            error('Cannot get an example value of an unknown type');
        end

        function exStr=getExampleValueStringScalar(~)%#ok<STOUT>
            error('Cannot get an example string of an unknown type');
        end

        function res=isTypeEqualScalar(~,~)

            res=false;
        end

    end

end
