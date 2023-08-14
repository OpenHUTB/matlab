classdef FunctionPlaformMapping<Simulink.interface.dictionary.internal.PlatformMapping





    properties(Constant,Access=private)
        PlatformKind=sl.interface.dict.mapping.PlatformMappingKind.FunctionPlatform;
    end

    properties(Access=private)
        PlatformName;
    end

    methods
        function this=FunctionPlaformMapping(platformName,interfaceDictAPI)
            this@Simulink.interface.dictionary.internal.PlatformMapping(interfaceDictAPI);
            this.PlatformName=platformName;
        end

        function setPlatformProperty(this,stereotypeableObj,varargin)%#ok<INUSD>


            assert(false,'this operation is not supported yet!');
        end

        function propValue=getPlatformProperty(this,stereotypeableObj,propName)%#ok<INUSD>
            propValue=[];
            assert(false,'this operation is not supported yet!');
        end

        function[propNames,propValues]=getPlatformProperties(this,stereotypeableObj)%#ok<INUSD>


            propNames=[];
            propValues=[];
            assert(false,'this operation is not supported yet!');
        end
    end


    methods(Hidden)
        function platformKind=getPlatformKind(this)
            platformKind=char(this.PlatformKind);
        end
    end
end


