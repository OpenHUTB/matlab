function postProcessVarsFromDB(variableName,field,variableSize,sourceLocation,isStruct,identifierInformation)





    if(~isStruct)

        if(isempty(field))


            if(~isKey(identifierInformation,variableName))
                identifierInformation(variableName)=struct('Identifier',variableName,'Size',0,'Parent',"");
            end
            Information=identifierInformation(variableName);
        else


            if(~isKey(identifierInformation,field))
                identifierInformation(field)=struct('Identifier',field,'Size',0,'Parent',variableName);
            end
            Information=identifierInformation(field);
        end
        Information.Size=variableSize;
        if isfield(Information,'SourceLocation')
            Information.SourceLocation=[Information.SourceLocation,sourceLocation];
        else
            Information.SourceLocation=sourceLocation;
        end
        identifierInformation(Information.Identifier)=Information;%#ok<NASGU>
    end
end
