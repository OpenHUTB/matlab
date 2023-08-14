function[visStat,value]=getOutputFunctionCallStatus(blkObject,data)




    visStat=false;

    if nargin<2
        data=blkObject.UserData;
    end

    myData=data;
    value=myData.OFC;

    if~strcmp(blkObject.BlockType,'VariantSource')
        return;
    end

    visStat=true;

end