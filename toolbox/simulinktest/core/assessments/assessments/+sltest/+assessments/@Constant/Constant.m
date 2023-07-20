


classdef(Sealed)Constant<sltest.assessments.Expression
    properties(SetAccess=immutable)
value
    end

    methods
        function self=Constant(c)
            validateattributes(c,{'numeric','logical','embedded.fi'},{'scalar'});
            self.value=c;
            self=self.initializeInternal();


            self.internal.setMetadata('originalData',self.value);
        end

        function res=children(~)
            res={};
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            if isstruct(self.value)
                data=self.value.Values;
            else
                data=self.value;
            end
            enumTypeName='';
            if(isenum(data))
                [data,enumTypeName]=sltest.assessments.Expression.castEnumData(data);
            end

            internal=sltest.assessments.internal.expression.constant(data,enumTypeName);
        end
    end
end
