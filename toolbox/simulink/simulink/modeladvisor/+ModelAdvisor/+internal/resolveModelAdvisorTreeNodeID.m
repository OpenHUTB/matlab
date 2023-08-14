function newID=resolveModelAdvisorTreeNodeID(oldID)





    newID='';

    map={'Modeling Standards for MAAB','maab';
    'DO178B:MISRA-C:Group','do178';
    'MisraGuidelinesTaskGroup','misra_c'};

    if startsWith(oldID,'_SYSTEM_By Task_')
        oldID=oldID(17:end);
    end

    for n=1:size(map,1)
        if strcmp(oldID,map{n,1})
            newID=['_SYSTEM_By Task_',map{n,2}];
            break;
        end
    end
end

