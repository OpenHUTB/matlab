function simscapeResultsCB(cbinfo)



    modelHandle=simscape.internal.sl_toolstrip.getModelHandle(cbinfo);




    blkHdl=simscape.internal.sl_toolstrip.getSelectedBlock(cbinfo);
    if isempty(blkHdl)





        blkHdl=modelHandle;
    end
    [log,logName]=simscape.logging.sli.internal.getModelLog(modelHandle);
    if(~isempty(blkHdl)&&~isempty(log))








        simscape.logging.internal.exploreForSlToolstrip(log,blkHdl,logName);
    end

end