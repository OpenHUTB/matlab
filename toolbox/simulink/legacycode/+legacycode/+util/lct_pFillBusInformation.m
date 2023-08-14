function infoStruct=lct_pFillBusInformation(infoStruct)













































































































    function keys=nFillBusInformation(keys,keyStr,dataType,offsetStr,pathStr,spPathInfo)





        dataTypeSizeIdx=find(strcmp(dataType.DTName,...
        infoStruct.DataTypes.BusInfo.DataTypeSizeTable));

        if isempty(dataTypeSizeIdx)

            infoStruct.DataTypes.BusInfo.BusDataTypesId(end+1)=dataType.Id;


            infoStruct.DataTypes.BusInfo.DataTypeSizeTable(end+1)={dataType.DTName};


            dataTypeSizeIdx=numel(infoStruct.DataTypes.BusInfo.DataTypeSizeTable);
        end



        spPathInfo(end).SizeIdx=dataTypeSizeIdx-1;

        for kk=1:dataType.NumElements

            eRecord=dataType.Elements(kk);
            eDataType=infoStruct.DataTypes.DataType(eRecord.DataTypeId);


            plusStr='';
            if~isempty(offsetStr)
                plusStr=' + ';
            end


            eKeyStr=sprintf('%s.%s_%d_%s_%d_%d',...
            keyStr,eRecord.Name,kk,eDataType.DTName,eRecord.Width,eRecord.IsComplex==1);


            eOffsetStr=sprintf('%s%sssGetBusElementOffset(S, __%sId, %d)',...
            offsetStr,plusStr,dataType.DTName,kk-1);


            ePathStr=sprintf('%s.%s',pathStr,eRecord.Name);

            if eDataType.IsBus==1||eDataType.IsStruct==1

                eSpInfo=struct(...
                'Name',eRecord.Name,...
                'DataTypeName',eDataType.DTName,...
                'Width',eRecord.Width,...
                'SizeIdx',-1);
                ePathTokens=[spPathInfo,eSpInfo];


                keys=nFillBusInformation(keys,eKeyStr,eDataType,eOffsetStr,ePathStr,ePathTokens);

            else




                if eDataType.IsEnum~=1&&(eDataType.Id~=eDataType.IdAliasedThruTo)
                    eDataTypeId=eDataType.StorageId;
                    eDataType=infoStruct.DataTypes.DataType(eDataTypeId);
                end



                eDataTypeSizeIdx=find(strcmp(eDataType.DTName,...
                infoStruct.DataTypes.BusInfo.DataTypeSizeTable));

                if isempty(eDataTypeSizeIdx)

                    infoStruct.DataTypes.BusInfo.OtherDataTypesId(end+1)=eDataType.Id;


                    infoStruct.DataTypes.BusInfo.DataTypeSizeTable(end+1)={eDataType.DTName};


                    eDataTypeSizeIdx=numel(infoStruct.DataTypes.BusInfo.DataTypeSizeTable);
                end


                eWidth=eRecord.Width;
                if eRecord.IsComplex==1
                    eWidth=eWidth*2;
                end
                if eWidth==1
                    eWidthStr='';
                else
                    eWidthStr=sprintf('%d*',eWidth);
                end
                eSizeStr=sprintf('%s__dtSizeInfo[%d]',eWidthStr,eDataTypeSizeIdx-1);



                if isempty(find(strcmp(eKeyStr,keys),1))
                    keys(end+1,1)={eKeyStr};%#ok<AGROW>
                end


                eSpInfo=struct(...
                'Name',eRecord.Name,...
                'DataTypeName',eDataType.DTName,...
                'Width',eRecord.Width,...
                'SizeIdx',eDataTypeSizeIdx-1);

                ePathTokens=[spPathInfo,eSpInfo];



                if isempty(find(strcmp(eKeyStr,infoStruct.DataTypes.BusInfo.BusElementHashTable(:,1)),1))
                    hashTableSize=size(infoStruct.DataTypes.BusInfo.BusElementHashTable,1);
                    eAccessInfo=struct(...
                    'OffsetStr',eOffsetStr,...
                    'SizeStr',eSizeStr,...
                    'OffsetIdx',2*hashTableSize,...
                    'SizeIdx',2*hashTableSize+1,...
                    'PathStr',ePathStr,...
                    'PathInfo',ePathTokens...
                    );...
                    infoStruct.DataTypes.BusInfo.BusElementHashTable(end+1,1:2)={eKeyStr,eAccessInfo};
                end

            end
        end
    end

    function keys=nFillBusInformationForData(thisData)


        thisDataType=infoStruct.DataTypes.DataType(thisData.DataTypeId);

        if thisDataType.IsBus==1||thisDataType.IsStruct==1

            spInfo=struct(...
            'Name','',...
            'DataTypeName',thisDataType.DTName,...
            'Width',thisData.Width,...
            'SizeIdx',-1);



            keys=nFillBusInformation(...
            {},...
            thisDataType.DTName,...
            thisDataType,...
            '',...
            thisDataType.DTName,...
spInfo...
            );
        else
            keys=cell(0,1);
        end
    end

    for ii=1:infoStruct.Inputs.Num
        infoStruct.Inputs.Input(ii).BusInfo.Keys=...
        nFillBusInformationForData(infoStruct.Inputs.Input(ii));
    end

    for ii=1:infoStruct.Parameters.Num
        infoStruct.Parameters.Parameter(ii).BusInfo.Keys=...
        nFillBusInformationForData(infoStruct.Parameters.Parameter(ii));
    end

    for ii=1:infoStruct.Outputs.Num
        infoStruct.Outputs.Output(ii).BusInfo.Keys=...
        nFillBusInformationForData(infoStruct.Outputs.Output(ii));
    end

    for ii=1:infoStruct.DWorks.Num
        infoStruct.DWorks.DWork(ii).BusInfo.Keys=...
        nFillBusInformationForData(infoStruct.DWorks.DWork(ii));
    end

end

