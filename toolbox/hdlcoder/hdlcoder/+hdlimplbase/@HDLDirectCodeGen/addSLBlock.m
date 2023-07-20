function blkName=addSLBlock(this,hC,blkType,blkNameWithPath,makeNameUnique,skipSampleTime)



    if nargin<6
        skipSampleTime=false;
    end

    if nargin<5
        makeNameUnique=true;
    end

    if makeNameUnique
        slHandle=add_block(blkType,blkNameWithPath,'MakeNameUnique','on');
        name=get_param(slHandle,'Name');
        name=strrep(name,'/','//');
        hC.Name=name;
    else
        slHandle=add_block(blkType,blkNameWithPath);
    end
    hC.setGMHandle(slHandle);

    if~skipSampleTime
        try
            this.setBlockSampleTime(hC,slHandle);
        catch
        end
    end

    if(slHandle>0)
        blkName=getfullname(slHandle);
        blkName=hdlfixblockname(blkName);
    else
        blkName=blkNameWithPath;
    end
end
