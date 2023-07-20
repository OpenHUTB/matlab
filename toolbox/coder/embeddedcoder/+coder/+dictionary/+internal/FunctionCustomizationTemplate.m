classdef FunctionCustomizationTemplate<coder.dictionary.internal.CoderDataEntry




    methods(Static)


        function allprops=getAllProps(~)
            if(slfeature('EnableFileControlForSimulinkFcns')>0)
                allprops={'Name','Description','DataSource','FunctionName','MemorySection','HeaderFile','DefinitionFile'};
            else
                allprops={'Name','Description','DataSource','FunctionName','MemorySection'};
            end
        end
        function allowedVals=getAllowedPropVals(~,~)
            allowedVals='';
        end


        function out=isValidPropertyForSection(propName,entry)
            props=coder.dictionary.internal.FunctionCustomizationTemplate.getAllProps(entry);
            out=any(ismember(props,propName));
        end

        function setProp(entry,name,value)
            import coder.dictionary.internal.FunctionCustomizationTemplate.*;
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            if strcmp(name,'MemorySection')


                if ischar(value)
                    if strcmp(value,'None')
                        value=coderdictionary.data.MemorySection.empty;
                    else
                        value=hlp.findEntry(entry.owner,'MemorySection',value);
                        if isempty(value)
                            DAStudio.error('SimulinkCoderApp:data:CannotResolveNamedEntry',value);
                        end
                    end
                elseif isa(value,'coder.dictionary.Entry')
                    value=value.sourceEntry;
                else
                    DAStudio.error('SimulinkCoderApp:data:InvalidValue',value,name);
                end
            end
            hlp.setProp(entry,name,value);
        end


        function checkValidProperty(entry,propName,~)
            import coder.dictionary.internal.FunctionCustomizationTemplate.*;
            checkValidPropertyForSection(propName,entry);
        end


        function checkValidPropertyForSection(propName,entry)
            if~coder.dictionary.internal.FunctionCustomizationTemplate.isValidPropertyForSection(propName,entry)
                DAStudio.error('SimulinkCoderApp:data:InvalidPropertyName',propName);
            end
        end
    end
end


