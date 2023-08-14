function symbolInfo=ec_get_datasym(package,classIndex,csc,memorySection,mpt_symbol_mapping)









    matches=strcmp(mpt_symbol_mapping.packageList,package);
    pIndex=find(matches,1);

    if isempty(pIndex)==0
        matches=strcmp(mpt_symbol_mapping.package{pIndex}.class{classIndex}.CSCNames,csc);
        cscIndex=find(matches,1);
        if isempty(cscIndex)==0
            matches=strcmp(mpt_symbol_mapping.package{pIndex}.memorySectionList{classIndex},memorySection);
            memSIndex=find(matches,1);
            if isempty(memSIndex)==0
                symbolInfo=mpt_symbol_mapping.package{pIndex}.class{classIndex}.csc{cscIndex}.memorySection{memSIndex};

            else
                symbolInfo=mpt_symbol_mapping.package{pIndex}.class{classIndex}.csc{cscIndex}.default;
            end
            index=strcmp(mpt_symbol_mapping.symbolList,'Define');
            symbolInfo.defineIndex=find(index,1);
            symbolInfo.defineSym='Define';
            return;
        else
            symbolInfo=default_mapping(mpt_symbol_mapping);
        end
    else
        symbolInfo=default_mapping(mpt_symbol_mapping);
    end

    function symbolInfo=default_mapping(mpt_symbol_mapping)


        symbolInfo.name='Unknown';
        symbolInfo.globalDefSym='Definitions';
        symbolInfo.globalDecSym='Declarations';
        symbolInfo.fileScopeSym='Definitions';
        index=strcmp(mpt_symbol_mapping.symbolList,'Definitions');
        symbolInfo.globalDefSymIndex=find(index,1);
        index=strcmp(mpt_symbol_mapping.symbolList,'Declarations');
        symbolInfo.globalDecSymIndex=find(index,1);
        index=strcmp(mpt_symbol_mapping.symbolList,'Definitions');
        symbolInfo.fileScopeSymIndex=find(index,1);
        index=strcmp(mpt_symbol_mapping.symbolList,'Define');
        symbolInfo.defineIndex=find(index,1);
        symbolInfo.defineSym='Define';

