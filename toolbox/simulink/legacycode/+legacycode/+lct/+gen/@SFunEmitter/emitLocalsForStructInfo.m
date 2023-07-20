




function emitLocalsForStructInfo(this,codeWriter)


    if this.HasBusInfoToRegister
        codeWriter.wNewLine;
        codeWriter.wCmt('Access bus/struct information');

        dWorkOffset=this.LctSpecInfo.TotalNumDWorks;



        codeWriter.wLine('int32_T* __dtSizeInfo = (int32_T*) ssGetDWork(S, %d);',...
        dWorkOffset-2);
        codeWriter.wLine('int32_T* __dtBusInfo = (int32_T*) ssGetDWork(S, %d);',...
        dWorkOffset-1);
        codeWriter.wNewLine;
    end
