


function ssId=getSSID(this,blkOrMdl)



    ssId='';
    if~strcmp(blkOrMdl,this.model_)
        try
            ssId=Simulink.ID.getSID(blkOrMdl);
        catch me %#ok
            ssId='';
        end
    end
end
