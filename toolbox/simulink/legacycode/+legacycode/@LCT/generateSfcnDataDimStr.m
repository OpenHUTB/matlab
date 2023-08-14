function str=generateSfcnDataDimStr(h,infoStruct,thisType,thisDataId,defaultStr)






    thisData=infoStruct.([thisType,'s']).(thisType)(thisDataId);


    str=cell(length(thisData.Dimensions),1);


    for ii=1:length(thisData.Dimensions)
        dimStr=h.generateSfcnDataDimStrRecursively(infoStruct,thisType,thisDataId,ii,defaultStr);
        str{ii,1}=dimStr;
    end
