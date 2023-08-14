classdef BlockInterfaceParser






    methods
        function inputTypes=getInputTypes(this,blockObject)
            portDataTypes=blockObject.CompiledPortDataTypes;
            inputTypes=getTypeList(this,portDataTypes.Inport,blockObject);
        end

        function outputTypes=getOutputTypes(this,blockObject)
            portDataTypes=blockObject.CompiledPortDataTypes;
            outputTypes=getTypeList(this,portDataTypes.Outport,blockObject);
        end
    end

    methods(Access=private)
        function typeList=getTypeList(~,typeStringList,blockObject)
            typeList=Simulink.NumericType.empty;
            nList=numel(typeStringList);
            for ii=1:nList
                typeString=typeStringList{ii};
                parsedContainer=parseDataType(typeString,blockObject);
                typeList=[typeList,parsedContainer.ResolvedType];%#ok<AGROW>
            end
        end
    end
end