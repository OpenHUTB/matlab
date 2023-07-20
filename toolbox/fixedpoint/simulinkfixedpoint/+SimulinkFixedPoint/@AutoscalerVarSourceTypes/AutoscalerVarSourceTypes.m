classdef AutoscalerVarSourceTypes<uint8







    enumeration
        Unknown(0)
        Base(1)
        Model(2)
        DataDictionary(3)
        Mask(4)
    end
    methods(Static)

        function enumType=convertToEnumSourceType(sourceTypeStr)


            switch sourceTypeStr
            case{'base workspace','base'}
                enumType=...
                SimulinkFixedPoint.AutoscalerVarSourceTypes.Base;
            case{'model workspace','model'}
                enumType=...
                SimulinkFixedPoint.AutoscalerVarSourceTypes.Model;
            case 'data dictionary'
                enumType=...
                SimulinkFixedPoint.AutoscalerVarSourceTypes.DataDictionary;
            case 'mask workspace'
                enumType=...
                SimulinkFixedPoint.AutoscalerVarSourceTypes.Mask;
            otherwise
                enumType=...
                SimulinkFixedPoint.AutoscalerVarSourceTypes.Unknown;

            end
        end

        function str=enum2string(enumType)


            switch enumType
            case SimulinkFixedPoint.AutoscalerVarSourceTypes.Base
                str='base workspace';
            case SimulinkFixedPoint.AutoscalerVarSourceTypes.Model
                str='model workspace';
            case SimulinkFixedPoint.AutoscalerVarSourceTypes.DataDictionary
                str='data dictionary';
            case SimulinkFixedPoint.AutoscalerVarSourceTypes.Mask
                str='mask workspace';
            otherwise
                str='unknown workspace';
            end
        end

    end
end


