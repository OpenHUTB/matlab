function emitRegisterGlobalDataStoreInfo(this,codeWriter)





    if~this.LctSpecInfo.GlobalIO.HasDSMs

        return;
    end

    numDataStores=numel(this.LctSpecInfo.GlobalIO.DataStores);

    codeWriter.wNewLine;
    codeWriter.wCmt('Register global data store memories');
    codeWriter.wBlockStart();
    codeWriter.wLine('boolean_T success;');
    codeWriter.wLine('ssSetNumDataStores(S, %d);',numDataStores);

    for kDSM=1:numDataStores
        dsmName=this.LctSpecInfo.GlobalIO.DataStores(kDSM).WorkspaceName;
        if this.LctSpecInfo.GlobalIO.DataStores(kDSM).IsReadOnly
            strReadWrite='SS_READER_ONLY';
        else
            strReadWrite='SS_READER_AND_WRITER';
        end
        codeWriter.wLine('ssRegisterGlobalDataStoreFromName(S, %d, "%s", %s, %s, %s);',...
        kDSM-1,dsmName,strReadWrite,'false','&success');
    end

    codeWriter.wLine('if (!success) return;');
    codeWriter.wBlockEnd();

end