classdef EnumDataDictionaryBuilder<autosar.simulink.enum.EnumAbstractBuilder




    properties(Access=private)
        Dictionary;
    end

    methods(Access=public)

        function this=EnumDataDictionaryBuilder(dictionaryFile)
            this.Dictionary=Simulink.data.dictionary.open(dictionaryFile);
        end



        function addEnumeration(this,name,...
            literalNames,literalValues,...
            defaultValue,storageType,...
            addClassNameToEnumNames,description,...
            headerFile,dataScope)

            enumTypeDefinition=Simulink.data.dictionary.EnumTypeDefinition;
            enumTypeDefinition.clearEnumerals();

            for el=1:numel(literalNames)
                enumTypeDefinition.appendEnumeral(char(literalNames(el)),literalValues(el),'');
            end

            if~isempty(defaultValue)
                enumTypeDefinition.DefaultValue=defaultValue;
            end

            enumTypeDefinition.AddClassNameToEnumNames=addClassNameToEnumNames;
            enumTypeDefinition.DataScope=dataScope;
            enumTypeDefinition.Description=description;
            enumTypeDefinition.HeaderFile=headerFile;
            enumTypeDefinition.StorageType=storageType;


            dictDdSection=this.Dictionary.getSection('Design Data');
            enumName=name;

            if dictDdSection.exist(enumName)
                oldEntry=dictDdSection.getEntry(enumName);
                oldEnumTypeDefinition=oldEntry.getValue();
                if autosar.simulink.enum.EnumDataDictionaryBuilder.areEnumTypeDefinitionsConsistent(...
                    oldEnumTypeDefinition,enumTypeDefinition)


                else
                    oldEntry.setValue(enumTypeDefinition);
                end
            else
                dictDdSection.addEntry(enumName,enumTypeDefinition);
            end
        end
    end

    methods(Static,Access=private)

        function tf=areEnumTypeDefinitionsConsistent(enumTypeDef1,enumTypeDef2)
            if(~isa(enumTypeDef1,'Simulink.data.dictionary.EnumTypeDefinition')||...
                ~isa(enumTypeDef2,'Simulink.data.dictionary.EnumTypeDefinition'))


                tf=false;
                return;
            end


            props=enumTypeDef1.getPossibleProperties();
            for i=1:length(props)
                prop=props{i};
                if~i_isPropEquivalent(prop,enumTypeDef1,enumTypeDef1)
                    tf=false;
                    return;
                end
            end


            enumerals1=enumTypeDef1.Enumerals;
            enumerals2=enumTypeDef2.Enumerals;
            if length(enumerals1)~=length(enumerals2)
                tf=false;
                return;
            end


            for i=1:length(enumerals1)
                enumeral1=enumerals1(i);
                enumeral2=enumerals2(i);
                if~isequal(enumeral1,enumeral2)
                    tf=false;
                    return;
                end
            end


            tf=true;
        end
    end
end

function ret=i_isPropEquivalent(prop,enumTypeDef1,enumTypeDef2)


    ret=false;

    if isequal(enumTypeDef1.(prop),enumTypeDef2.(prop))
        ret=true;
        return;
    end



    if strcmp(prop,'StorageType')&&...
        (strcmp(enumTypeDef1.StorageType,'')&&strcmp(enumTypeDef2.StorageType,'int32')||...
        strcmp(enumTypeDef1.StorageType,'int32')&&strcmp(enumTypeDef2.StorageType,''))
        ret=true;
        return;
    end

end


