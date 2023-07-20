classdef(Abstract)ModuleGenerationBase<dynamicprops










    properties(Constant,Hidden)

        ModuleGenerationChoices={'on','off'};
        ModuleGenerationDefault=true;
        ModuleGenerationMapKeyName='TrimmableProcessorProperties';
        BlockGenerationName='BlockGeneration';
        ModuleGenerationName='ModuleGeneration';
    end





    methods
        function setDynamicProp(obj,val,propName)
            val=validateModuleGenerationProperty(obj,val,propName);
            obj.(propName)=val;
        end

        function value=getDynamicProp(obj,propName)
            value=convertLogicalToString(obj,obj.(propName));
        end
    end


    methods(Hidden)

        function outVal=convertLogicalToString(~,inVal)

            if inVal
                outVal='on';
            else
                outVal='off';
            end
        end

        function val=validateModuleGenerationProperty(obj,val,valName)




            if~islogical(val)
                dnnfpga.config.validateStringPropertyValue(val,valName,...
                obj.ModuleGenerationChoices,obj.ModuleGenerationChoices{1})

                if strcmpi(val,'on')
                    val=true;
                else
                    val=false;
                end
            end
        end

    end

end

