classdef(Sealed)OptimizationNumeric<optim.problemdef.OptimizationExpression









    properties(Hidden,SetAccess=private,GetAccess=public)
        OptimizationNumericVersion=2;
    end

    methods

        function obj=OptimizationNumeric(Value)



            obj=obj@optim.problemdef.OptimizationExpression([]);

            if isa(Value,'optim.problemdef.OptimizationNumeric')
                obj=Value;
                return
            end

            if~(isnumeric(Value)||islogical(Value))
                throwAsCaller(MException(message('MATLAB:invalidConversion','optim.problemdef.OptimizationExpression',class(Value))));
            end

            if~(islogical(Value)||isa(Value,'double'))
                error(message('shared_adlib:OptimizationNumeric:NonDoubleArgument'));
            end

            if(~isreal(Value))
                error(message('shared_adlib:OptimizationNumeric:InvalidComplex'));
            end

            if any(isinf(Value))
                error(message('shared_adlib:OptimizationNumeric:InvalidInf'));
            end

            if any(isnan(Value))
                error(message('shared_adlib:OptimizationNumeric:InvalidNaN'));
            end

            createNumeric(obj.OptimExprImpl,Value);
        end

        function val=isnumeric(~)
            val=true;
        end




        function eout=cat(dim,varargin)



            function val=Numeric2Num(num)
                if isa(num,'optim.problemdef.OptimizationNumeric')
                    val=evaluate(num.OptimExprImpl,struct);
                else
                    val=num;
                end
            end


            parsedInput=cellfun(@Numeric2Num,varargin,'UniformOutput',false);

            eout=cat(dim,parsedInput{:});

            if~isa(eout,'optim.problemdef.OptimizationExpression')
                eout=optim.problemdef.OptimizationNumeric(eout);
            end
        end

    end

    methods(Hidden,Access=protected)
        function obj=reloadv1tov2(obj,nin)
            obj=reloadv1tov2@optim.problemdef.OptimizationExpression(obj,nin);
        end
    end

    methods(Static)
        function obj=loadobj(nin)
            if nin.OptimizationNumericVersion==1
                obj=optim.problemdef.OptimizationNumeric([]);
                obj=reloadv1tov2(obj,nin);
            else
                obj=nin;
            end
        end
    end


end
