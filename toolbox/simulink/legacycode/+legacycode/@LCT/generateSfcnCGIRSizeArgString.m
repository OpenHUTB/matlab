function str=generateSfcnCGIRSizeArgString(h,infoStruct,thisArg)%#ok<INUSL>







    dataKind=thisArg.DimsInfo.DimInfo.Type;
    dataId=thisArg.DimsInfo.DimInfo.DataId;
    dataDim=thisArg.DimsInfo.DimInfo.DimRef;


    str=iGetDataDimStrRecursively(infoStruct,dataKind,dataId,dataDim);


    function dimStr=iGetDataDimStrRecursively(infoStruct,thisType,thisDataId,thisDim)










        thisData=infoStruct.([thisType,'s']).(thisType)(thisDataId);


        dimStr='';

        if thisData.Dimensions(thisDim)~=-1


            dimStr=sprintf('%d',thisData.Dimensions(thisDim));
        else

            thisDimInfo=thisData.DimsInfo.DimInfo(thisDim);


            if thisData.DimsInfo.HasInfo(thisDim)==1

                if strcmp(thisDimInfo.Type,'Parameter')&&thisDimInfo.DimRef==0


                    dimStr=sprintf('mxGetScalar(ssGetSFcnParam(getSimStruct(), %d))',...
                    thisDimInfo.DataId-1);
                else

                    dimStr=iGetDataDimStrRecursively(infoStruct,...
                    thisDimInfo.Type,...
                    thisDimInfo.DataId,...
                    thisDimInfo.DimRef);
                end

            else






                switch thisType
                case 'Parameter'
                    if length(thisData.Dimensions)<2

                        dimStr=sprintf('mxGetNumberOfElements(ssGetSFcnParam(getSimStruct(), %d))',...
                        thisDataId-1);
                    else

                        dimStr=sprintf('mxGetDimensions(ssGetSFcnParam(getSimStruct(), %d))[%d]',...
                        thisDataId-1,thisDim-1);
                    end

                case 'Input'
                    if thisDim==1
                        if length(thisData.Dimensions)<2

                            dimStr=sprintf('ssGetInputPortWidth(getSimStruct(), %d)',...
                            thisDataId-1);
                        else

                            dimStr=sprintf('ssGetInputPortDimensionSize(getSimStruct(), %d, 0)',...
                            thisDataId-1);
                        end
                    else
                        dimStr=sprintf('ssGetInputPortDimensionSize(getSimStruct(), %d, %d)',...
                        thisDataId-1,thisDim-1);
                    end

                otherwise




                end
            end
        end
