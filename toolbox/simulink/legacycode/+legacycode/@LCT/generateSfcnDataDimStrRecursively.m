function dimStr=generateSfcnDataDimStrRecursively(h,infoStruct,thisType,thisDataId,thisDim,defaultStr)













    thisData=infoStruct.([thisType,'s']).(thisType)(thisDataId);


    dimStr='';

    if thisData.Dimensions(thisDim)~=-1


        dimStr=sprintf('%d',thisData.Dimensions(thisDim));
    else

        thisDimInfo=thisData.DimsInfo.DimInfo(thisDim);


        if thisData.DimsInfo.HasInfo(thisDim)==1

            if strcmp(thisDimInfo.Type,'Parameter')&&thisDimInfo.DimRef==0


                dimStr=sprintf('mxGetScalar(ssGetSFcnParam(S, %d))',...
                thisDimInfo.DataId-1);
            else

                dimStr=h.generateSfcnDataDimStrRecursively(infoStruct,...
                thisDimInfo.Type,...
                thisDimInfo.DataId,...
                thisDimInfo.DimRef,...
                defaultStr);
            end
        else






            switch thisType
            case 'Parameter'
                if length(thisData.Dimensions)<2

                    dimStr=sprintf('mxGetNumberOfElements(ssGetSFcnParam(S, %d))',...
                    thisDataId-1);
                else

                    dimStr=sprintf('mxGetDimensions(ssGetSFcnParam(S, %d))[%d]',...
                    thisDataId-1,thisDim-1);
                end

            case 'Input'
                if strcmp(defaultStr,'init')


                    dimStr='DYNAMICALLY_SIZED';
                else

                    if thisDim==1
                        if length(thisData.Dimensions)<2

                            dimStr=sprintf('ssGetInputPortWidth(S, %d)',...
                            thisDataId-1);
                        else




                            isTrueDynSize=legacycode.util.lct_pIsTrueDynamicSize(infoStruct,thisData,thisDim);

                            if isTrueDynSize&&length(thisData.Dimensions)>2
                                dimStr=sprintf(' ((ssGetInputPortNumDimensions(S, %d) >= 1) ? ssGetInputPortDimensions(S, %d)[0] : %s)',...
                                thisDataId-1,thisDataId-1,defaultStr);
                            else
                                dimStr=sprintf('ssGetInputPortDimensions(S, %d)[0]',...
                                thisDataId-1);
                            end
                        end
                    else







                        isTrueDynSize=legacycode.util.lct_pIsTrueDynamicSize(infoStruct,thisData,thisDim);

                        if isTrueDynSize&&length(thisData.Dimensions)>2


                            dimStr=sprintf(' ((ssGetInputPortNumDimensions(S, %d) >= %d) ? ssGetInputPortDimensions(S, %d)[%d] : %s)',...
                            thisDataId-1,thisDim,thisDataId-1,thisDim-1,defaultStr);
                        else


                            dimStr=sprintf('ssGetInputPortDimensions(S, %d)[%d]',...
                            thisDataId-1,thisDim-1);
                        end
                    end
                end

            otherwise





            end
        end
    end
