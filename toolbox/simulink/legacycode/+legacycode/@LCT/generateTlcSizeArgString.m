function str=generateTlcSizeArgString(h,infoStruct,thisArg)%#ok<INUSL>







    dataKind=thisArg.DimsInfo.DimInfo.Type;
    dataId=thisArg.DimsInfo.DimInfo.DataId;
    dataDim=thisArg.DimsInfo.DimInfo.DimRef;


    str=iGetDataDimStrRecursively(infoStruct,dataKind,dataId,dataDim);


    function dimStr=iGetDataDimStrRecursively(infoStruct,thisType,thisDataId,thisDim)










        thisData=infoStruct.([thisType,'s']).(thisType)(thisDataId);


        dimStr='';

        if thisData.Dimensions(thisDim)~=-1


            dimStr=sprintf('CAST("Number", %d)',thisData.Dimensions(thisDim));
        else

            thisDimInfo=thisData.DimsInfo.DimInfo(thisDim);


            if thisData.DimsInfo.HasInfo(thisDim)==1

                if strcmp(thisDimInfo.Type,'Parameter')&&thisDimInfo.DimRef==0


                    dimStr=sprintf('LibBlockParameter(p%d, "", "", 0)',...
                    thisDimInfo.DataId);
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

                        dimStr=sprintf('LibBlockParameterWidth(p%d)',...
                        thisDataId);
                    else

                        dimStr=sprintf('LibBlockParameterDimensions(p%d)[%d]',...
                        thisDataId,thisDim-1);
                    end

                case 'Input'
                    if thisDim==1
                        if length(thisData.Dimensions)<2

                            dimStr=sprintf('LibBlockInputSignalWidth(%d)',...
                            thisDataId-1);
                        else

                            dimStr=sprintf('LibBlockInputSignalDimensions(%d)[0]',...
                            thisDataId-1);
                        end
                    else
                        dimStr=sprintf('LibBlockInputSignalDimensions(%d)[%d]',...
                        thisDataId-1,thisDim-1);
                    end

                otherwise




                end
            end
        end
