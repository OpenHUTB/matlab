function maskSignednessAutoFlag=maskSignednessAuto(h,blkObj,pathItem)%#ok






    if(strcmp(pathItem,'Product output')||strcmp(pathItem,'Accumulator'))

        maskSignednessAutoFlag=true;
    elseif strcmp(pathItem,'Output')
        maskSignednessAutoFlag=strcmp(blkObj.outputSignedness,'Auto');
    else
        maskSignednessAutoFlag=false;
    end

