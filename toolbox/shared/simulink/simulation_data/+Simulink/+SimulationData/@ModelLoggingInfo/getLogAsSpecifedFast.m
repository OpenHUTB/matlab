


function bRet=getLogAsSpecifedFast(this,blk)



    this.assertSizeOfLogAsSpecifiedMatch();
    assert(~strcmp(blk,this.model_));


    bRet=false;
    checkBlkPath=true;
    try
        thisBlkSSID=Simulink.ID.getSID(blk);
        if any(strcmp(this.logAsSpecifiedByModelsSSIDs_,thisBlkSSID))
            bRet=true;
            checkBlkPath=false;
        end
    catch me %#ok

    end

    if(checkBlkPath)
        if any(strcmp(this.logAsSpecifiedByModels_,blk))
            bRet=true;
        end
    end
end
