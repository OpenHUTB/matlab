function isValid=nesl_isvalidcomponentblock(hBlock)





    isValid=false;%#ok
    compName=simscape.getBlockComponent(hBlock);
    if~strcmp(get_param(hBlock,'LinkStatus'),'none')
        isValid=false;
    elseif lIsTimestampCurrent(hBlock,compName)


        isValid=true;
    else


        nesl_isvalidsimscapecomponent=nesl_private('nesl_isvalidsimscapecomponent');
        isValid=nesl_isvalidsimscapecomponent(compName);
    end

end

function result=lIsTimestampCurrent(hBlock,theComponent)



    result=false;
    blockTimeStamp=...
    simscape.engine.sli.internal.getblocktimestamp(hBlock);
    if~isempty(blockTimeStamp)
        componentTimeStamp=...
        simscape.engine.sli.internal.getfiletimestamp(...
        which(theComponent));
        result=strcmp(blockTimeStamp,componentTimeStamp);
    end

end


