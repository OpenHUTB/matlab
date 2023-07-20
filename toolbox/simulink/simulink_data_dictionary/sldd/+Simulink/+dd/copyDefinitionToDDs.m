function copyDefinitionToDDs(fromDD,fromEntryId,toDDs,toEntryIds,entryName)











    assert(ischar(fromDD));
    assert(isnumeric(fromEntryId));
    assert(iscell(toDDs));
    assert(isnumeric(toEntryIds));
    assert(length(toDDs)==length(toEntryIds));
    assert(ischar(entryName));

    bws='base workspace';
    fromBWS=strcmp(fromDD,bws);
    if(fromBWS)
        msg=loc_checkIfVarInBWS(entryName);
        if~isempty(msg)
            error(msg);
        end
        entryValue=evalin('base',entryName);
    else
        msg=loc_checkIfEntryInDD(fromDD,fromEntryId);
        if~isempty(msg)
            error(msg);
        end
        frDD=Simulink.dd.open(fromDD);
        entryValue=frDD.getEntry(fromEntryId);
    end

    for i=1:length(toDDs)
        if(strcmp(toDDs{i},bws))
            msg=loc_checkIfVarInBWS(entryName);
            if isempty(msg)
                assignin('base',entryName,entryValue);
            else
                warning('SLDD:sldd:VarNotInBWS',msg);
            end
        else
            msg=loc_checkIfEntryInDD(toDDs{i},toEntryIds(i));
            if isempty(msg)
                toDD=Simulink.dd.open(toDDs{i});
                toDD.setEntry(toEntryIds(i),entryValue);

                toDD.show;
                toDD.close;
            else
                warning('SLDD:sldd:EntryNotFoundInDD',msg);
            end
        end
    end

    if(~fromBWS)
        frDD.close;
    end
end

function msg=loc_checkIfVarInBWS(varName)
    msg='';
    if~(evalin('base',['exist(''',varName,''')']))
        msg=DAStudio.message('SLDD:sldd:VarNotInBWS',varName);
    end
end

function msg=loc_checkIfEntryInDD(ddSpec,entryId)
    msg='';
    try
        ddConnect=Simulink.dd.open(ddSpec);
        ddConnect.getEntryInfo(entryId);
        ddConnect.close();
    catch err
        if strcmp(err.identifier,'SLDD:sldd:EntryNotFound')
            [~,ddName,ddExt]=fileparts(ddSpec);
            msg=DAStudio.message('SLDD:sldd:EntryNotFoundInDD',[ddName,ddExt]);
        else
            msg=err.message;
        end
    end
end