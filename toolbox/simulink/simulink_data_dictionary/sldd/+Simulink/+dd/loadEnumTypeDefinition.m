function loadEnumTypeDefinition(enumClassName,fromSrc,fromEntryId)









    assert(ischar(enumClassName));
    assert(ischar(fromSrc));
    assert(isnumeric(fromEntryId));


    status=warning('off','SLDD:sldd:DuplicateEnumTypeDefsWithOneLoaded');
    cn=onCleanup(@()warning(status));


    fromSrcTmp=which(fromSrc);
    if~isempty(fromSrcTmp)
        fromSrc=fromSrcTmp;
    end

    [~,ddFile,ddExt]=fileparts(fromSrc);
    ddName=[ddFile,ddExt];

    try

        ddConnect=Simulink.dd.open(fromSrc);


        ei=ddConnect.getEntryInfo(fromEntryId);


        if~isa(ei.Value,'Simulink.data.dictionary.EnumTypeDefinition')
            errID='SLDD:sldd:enumNotLoadableAsEnumWithSrc';
            DAStudio.error(errID,enumClassName,ddName);
        end


        ddConnect.loadEnum(enumClassName);
    catch err
        if strcmp(err.identifier,'SLDD:sldd:EntryNotFound')
            errID='SLDD:sldd:EntryNotFoundInDD';
            DAStudio.error(errID,ddName);
        else
            rethrow(err);
        end
    end
end