
classdef Argument
    properties
        name='';
        mappedFrom={};
        mergedWith={};
        dataTypeString='';
        qualifier=coder.parser.Qualifier.None;
        passBy=coder.parser.PassByEnum.Value;
        dimensionString='';
    end
    methods
        function aStr=preview(obj)
            spaceStr='';
            if~isempty(obj.qualifier)
                spaceStr=' ';
            end
            aStr=[obj.qualifier,spaceStr];
            spaceStr='';
            if~isempty(obj.dataTypeString)
                spaceStr=' ';
            end
            aStr=[aStr,obj.dataTypeString,spaceStr,obj.name];
        end
    end
end
