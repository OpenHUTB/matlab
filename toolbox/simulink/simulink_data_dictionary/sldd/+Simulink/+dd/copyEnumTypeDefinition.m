function copyEnumTypeDefinition(enumClassName,fromSrc,fromEntryId,toSrcs,toEntryIds)
















    assert(ischar(enumClassName));
    assert(ischar(fromSrc));
    assert(isnumeric(fromEntryId));
    assert(iscell(toSrcs));
    assert(isnumeric(toEntryIds));
    assert(length(toSrcs)==length(toEntryIds));
    assert(~strcmp(fromSrc,'memory'));


    status=warning('off','SLDD:sldd:DuplicateEnumTypeDefsWithOneLoaded');
    cn=onCleanup(@()warning(status));


    loc_checkIfDefInDD(fromSrc,fromEntryId,enumClassName,'error');
    fromSrc=which(fromSrc);
    frDD=Simulink.dd.open(fromSrc);
    entryInfo=frDD.getEntryInfo(fromEntryId);
    enumTypeDef=entryInfo.Value;
    assert(isa(enumTypeDef,'Simulink.data.dictionary.EnumTypeDefinition'));



    for i=1:length(toSrcs)
        if(loc_checkIfDefInDD(toSrcs{i},toEntryIds(i),enumClassName,'warning'))
            toSrc=which(toSrcs{i});
            toDD=Simulink.dd.open(toSrc);
            toDD.setEntry(toEntryIds(i),enumTypeDef);

            toDD.show;
            toDD.close;
        end
    end



    directDD=Simulink.dd.open(entryInfo.DataSource);
    directDD.loadEnum(enumClassName);
    directDD.close();
end





function throwWarningOrError(errType,errorID,args)
    switch(errType)
    case 'warning'
        msg=DAStudio.message(errorID,args{:});
        warning(errorID,msg);
    case 'error'
        DAStudio.error(errorID,args{:});
    otherwise
        assert(false,'''errType'' is not supported');
    end
end

function rst=loc_checkIfDefInDD(ddSpec,entryId,enumClassName,errType)




    rst=true;


    ddSpecTmp=which(ddSpec);
    if~isempty(ddSpecTmp)
        ddSpec=ddSpecTmp;
    end

    [~,ddFile,ddExt]=fileparts(ddSpec);
    ddName=[ddFile,ddExt];

    try
        ddConnect=Simulink.dd.open(ddSpec);

        ei=ddConnect.getEntryInfo(entryId);

        if~isa(ei.Value,'Simulink.data.dictionary.EnumTypeDefinition')
            rst=false;
            errID='SLDD:sldd:enumNotLoadableAsEnumWithSrc';
            throwWarningOrError(errType,errID,{enumClassName,ddName});
        end
        ddConnect.close();
    catch err
        if strcmp(err.identifier,'SLDD:sldd:EntryNotFound')
            rst=false;
            errID='SLDD:sldd:EntryNotFoundInDD';
            throwWarningOrError(errType,errID,{ddName});
        else
            rethrow(err);
        end
    end
end
