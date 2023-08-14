classdef PackageString<handle




    properties(Constant,Access=public)

        NameColHeader=DAStudio.message('Simulink:busEditor:PropElementName')
        DescriptionColHeader=DAStudio.message('Simulink:busEditor:PropDescription')
        DataTypeColHeader=DAStudio.message('Simulink:busEditor:PropDataType')
        TypeColHeader=DAStudio.message('Simulink:busEditor:PropType')
        ComplexityColHeader=DAStudio.message('Simulink:busEditor:PropComplexity')
        DimensionsColHeader=DAStudio.message('Simulink:busEditor:PropDimensions')
        DimensionsModeColHeader=DAStudio.message('Simulink:busEditor:PropDimensionsMode')
        MinColHeader=DAStudio.message('Simulink:busEditor:PropMin')
        MaxColHeader=DAStudio.message('Simulink:busEditor:PropMax')
        UnitColHeader=DAStudio.message('Simulink:busEditor:PropUnits')
        DefaultValueHeader='DefaultValue';


        NameProp='Name';
        DescriptionProp='Description';
        DataTypeProp='DataType';
        TypeProp='Type';
        BaseTypeProp='BaseType';
        StorageTypeProp='StorageType';
        ComplexityProp='Complexity';
        DimensionsProp='Dimensions';
        DimensionsModeProp='DimensionsMode';
        MinProp='Min';
        MaxProp='Max';
        UnitProp='Unit';
    end

    methods(Static,Access=public)
        function propName=getPropNameForColHeader(colHeader)
            import sl.interface.dictionaryApp.node.PackageString;
            colHeaderToPropNameMap=PackageString.getColHeaderToPropNameMap();
            if colHeaderToPropNameMap.isKey(colHeader)
                propName=colHeaderToPropNameMap(colHeader);
                propName=char(propName);
            else
                propName=colHeader;
            end
        end
    end

    methods(Static,Access=private)
        function map=getColHeaderToPropNameMap()
            import sl.interface.dictionaryApp.node.PackageString;
            persistent colHeaderToPropNameMap;
            if isempty(colHeaderToPropNameMap)
                colHeaderToPropNameMap=dictionary();
                colHeaderToPropNameMap(PackageString.NameColHeader)=...
                PackageString.NameProp;
                colHeaderToPropNameMap(PackageString.DescriptionColHeader)=...
                PackageString.DescriptionProp;
                colHeaderToPropNameMap(PackageString.DataTypeColHeader)=...
                PackageString.DataTypeProp;
                colHeaderToPropNameMap(PackageString.TypeColHeader)=...
                PackageString.TypeProp;
                colHeaderToPropNameMap(PackageString.ComplexityColHeader)=...
                PackageString.ComplexityProp;
                colHeaderToPropNameMap(PackageString.DimensionsColHeader)=...
                PackageString.DimensionsProp;
                colHeaderToPropNameMap(PackageString.DimensionsModeColHeader)=...
                PackageString.DimensionsModeProp;
                colHeaderToPropNameMap(PackageString.MinColHeader)=...
                PackageString.MinProp;
                colHeaderToPropNameMap(PackageString.MaxColHeader)=...
                PackageString.MaxProp;
                colHeaderToPropNameMap(PackageString.UnitColHeader)=...
                PackageString.UnitProp;
            end
            map=colHeaderToPropNameMap;
        end
    end
end
