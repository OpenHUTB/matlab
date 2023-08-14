function result=isValidGroupType(value)




    customizationInGroups=coder.internal.asap2.getListOfCustomizationsInGrouping();
    value=convertStringsToChars(value);
    result=true;
    if(ischar(value))
        if~any(strcmp(value,customizationInGroups))
            DAStudio.error('Simulink:Harness:InvalidInputArgumentForHarnessCreation',strjoin(customizationInGroups,''', '''),value);
        end
    end
    if(iscellstr(value))
        for ii=1:numel(value)
            if~any(strcmp(value{ii},customizationInGroups))
                DAStudio.error('Simulink:Harness:InvalidInputArgumentForHarnessCreation',strjoin(customizationInGroups,''', '''),value{ii});
            end
        end
    end
end

