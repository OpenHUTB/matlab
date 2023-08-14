function ec_set_datasym(info)












    mpt_symbol_mapping=rtwprivate('rtwattic','AtticData','mpt_symbol_mapping');
    matches=strcmp(mpt_symbol_mapping.packageList,info.packageName);
    pIndex=find(matches,1);
    if isempty(pIndex)==0
        matches=strcmp(mpt_symbol_mapping.package{pIndex}.class{info.classIndex}.CSCNames,info.className);
        cscIndex=find(matches,1);
        if isempty(cscIndex)==0
            matches=strcmp(mpt_symbol_mapping.package{pIndex}.memorySectionList{info.classIndex},info.memorySectionName);
            memSIndex=find(matches,1);
            if isempty(memSIndex)==0
                minfo=[];
                minfo.globalDefSym=info.globalDefSym;
                index=strcmp(mpt_symbol_mapping.symbolList,minfo.globalDefSym);
                minfo.globalDefSymIndex=find(index,1);

                minfo.globalDecSym=info.globalDecSym;
                index=strcmp(mpt_symbol_mapping.symbolList,minfo.globalDecSym);
                minfo.globalDecSymIndex=find(index,1);

                minfo.fileScopeSym=info.fileScopeSym;
                index=strcmp(mpt_symbol_mapping.symbolList,minfo.fileScopeSym);
                minfo.fileScopeSymIndex=find(index,1);

                mpt_symbol_mapping.package{pIndex}.class{info.classIndex}.csc{cscIndex}.memorySection{memSIndex}=minfo;
                return;
            end
        end
    end
    rtwprivate('rtwattic','AtticData','mpt_symbol_mapping',mpt_symbol_mapping);

