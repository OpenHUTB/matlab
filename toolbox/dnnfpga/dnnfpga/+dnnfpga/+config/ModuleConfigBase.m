classdef(Abstract)ModuleConfigBase<dnnfpga.config.PropertyListBase...
    &dnnfpga.config.ModuleGenerationBase




    properties(Access=public)




    end

    properties(Hidden,Dependent)

    end

    properties(GetAccess=public,SetAccess=protected)



        ModuleID='';

    end

    methods
        function obj=ModuleConfigBase(moduleID)


            obj.ModuleID=moduleID;
            obj.addprop(obj.ModuleGenerationName);
            obj.ModuleGeneration=obj.ModuleGenerationDefault;

            obj.Properties('TopLevelProperties')={};
            obj.Properties(obj.ModuleGenerationMapKeyName)={'ModuleGeneration'};
        end

        function validateModuleConfig(obj)%#ok<MANU>



        end

        function validateTrimmableProcessorProperties(obj)




            moduleProperties=obj.Properties(obj.ModuleGenerationMapKeyName);
            customModuleID=dnnfpga.config.CustomLayerModuleConfig.DefaultModuleID;
            for idy=1:numel(moduleProperties)
                moduleProperty=moduleProperties{idy};
                if contains(moduleProperty,'ModuleGeneration')||strcmpi(obj.ModuleID,customModuleID)




                    continue;
                end
                if~contains(moduleProperty,'BlockGeneration')


                    errorStrCat=sprintf('Property name "%s" of the "%s" module does not follow the rule (Block name + %s) e.g: "LRNBlockGeneration".',...
                    moduleProperty,obj.ModuleID,obj.BlockGenerationName);
                    error(errorStrCat);
                end
            end
        end
    end


    methods(Hidden)

        function disp(obj,varargin)



            obj.dispHeading(sprintf('Processing Module "%s"',obj.ModuleID));


            obj.dispProperties(obj.ModuleGenerationMapKeyName,true);


            obj.dispProperties('TopLevelProperties');

        end

    end

end

