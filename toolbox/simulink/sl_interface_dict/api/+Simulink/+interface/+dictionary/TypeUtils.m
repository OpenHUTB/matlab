classdef(Hidden)TypeUtils





    methods(Static)
        function datatypeName=stripPrefix(typeStr)
            datatypeName=regexprep(typeStr,'\s*((Enum)\s*:|(Bus)\s*:|(ValueType)\s*:|?)\s*','','ignorecase');
        end

        function res=isBus(typeStr)
            res=startsWith(typeStr,'Bus:');
        end

        function res=isValueType(typeStr)
            res=startsWith(typeStr,'ValueType:');
        end

        function setBusElementPropVal(dictName,busName,elemName,propName,propVal)
            isModelContext=false;
            systemcomposer.BusObjectManager.SetInterfaceElementProperty(dictName,...
            isModelContext,busName,elemName,propName,propVal);
        end

        function busElmObj=getBusElementObj(dictName,busName,elemName)
            busElmObj=[];
            dd=Simulink.data.dictionary.open(dictName);
            designSection=getSection(dd,'Design Data');
            entry=getEntry(designSection,busName,'DataSource',dictName);
            elements=entry.getValue().Elements;
            for i=1:length(elements)
                if strcmp(elemName,elements(i).Name)
                    busElmObj=elements(i);
                    return;
                end
            end
        end

        function propVal=getBusElementPropVal(dictName,busName,elemName,propName)
            busElmObj=Simulink.interface.dictionary.TypeUtils.getBusElementObj(dictName,busName,elemName);
            propVal=busElmObj.(propName);
            if~ischar(propVal)
                propVal=mat2str(propVal);
            end
        end
    end
end


