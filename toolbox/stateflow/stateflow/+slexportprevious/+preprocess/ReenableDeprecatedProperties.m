



function ReenableDeprecatedProperties(obj)

    machine=getStateflowMachine(obj);

    if isempty(machine)
        return;
    end


    if isR2018bOrEarlier(obj.ver)

        try
            createdAsOldFormat=get_param(obj.modelName,'Created');






            t=datetime(createdAsOldFormat,'InputFormat','eee MMM dd HH:mm:ss y','Locale','en_US');
        catch

            t=datetime;
        end
        createdTime=datestr(t,'dd-mmm-yyyy HH:MM:SS');
        obj.appendRule(getCreatedSaveAsRules(createdTime));


        isLibrary=sf('get',machine.Id,'.isLibrary');
        obj.appendRule(getIsLibrarySaveAsRules(isLibrary));
    end
end

function newRule=getCreatedSaveAsRules(createdTime)
    newRule=sprintf('<Stateflow<machine<sfVersion:insertsibpair created "%s">>>',createdTime);
end

function newRule=getIsLibrarySaveAsRules(isLibrary)
    newRule=sprintf('<Stateflow<machine<sfVersion:insertsibpair isLibrary %d>>>',isLibrary);
end
