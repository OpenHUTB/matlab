classdef AlgorithmParameter


    properties(Hidden,Constant,Abstract,GetAccess=public)


        AliasNames;
        AliasValues;
        DefaultValue;
    end

    properties(Abstract,Constant,GetAccess=public)




        Name;
        Options;
        Primary;
    end

    properties(SetAccess=public,GetAccess=public)

Value
    end

    methods
        function obj=AlgorithmParameter()
            obj.Value=obj.DefaultValue;
        end

        function out=setAP(obj,value)
            if(strcmpi(class(value),class(obj)))
                out=value;
            else
                obj.Value=value;
                out=obj;
            end
        end

        function obj=set.Value(obj,val)







            obj.Value=coder.algorithm.parameter.validateValue(obj,val);
        end

        function same=isValueDefault(obj)

            same=false;


            if isequal(sort(obj.DefaultValue),sort(obj.Value))

                same=true;
            end

        end

    end

end
