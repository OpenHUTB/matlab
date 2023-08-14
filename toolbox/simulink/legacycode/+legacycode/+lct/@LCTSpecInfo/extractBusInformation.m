function extractBusInformation(this)













































































































    function keys=nFillBusInformation(keys,keyStr,dataType,offsetStr,pathStr,spPathInfo)





        dataTypeSizeIdx=find(strcmp(dataType.DTName,...
        this.DataTypes.BusInfo.DataTypeSizeTable));

        if isempty(dataTypeSizeIdx)

            this.DataTypes.BusInfo.BusDataTypesId(end+1)=dataType.Id;


            this.DataTypes.BusInfo.DataTypeSizeTable(end+1)={dataType.DTName};


            dataTypeSizeIdx=numel(this.DataTypes.BusInfo.DataTypeSizeTable);
        end



        spPathInfo(end).SizeIdx=dataTypeSizeIdx-1;

        for kk=1:dataType.NumElements

            eRecord=dataType.Elements(kk);
            eDataType=this.DataTypes.Items(eRecord.DataTypeId);


            plusStr='';
            if~isempty(offsetStr)
                plusStr=' + ';
            end


            eKeyStr=sprintf('%s.%s_%d_%s_%d_%d',...
            keyStr,eRecord.Name,kk,eDataType.DTName,eRecord.Width,eRecord.IsComplex==1);


            eOffsetStr=sprintf('%s%sssGetBusElementOffset(S, __%sId, %d)',...
            offsetStr,plusStr,dataType.DTName,kk-1);


            ePathStr=sprintf('%s.%s',pathStr,eRecord.Name);

            if eDataType.isAggregateType()

                eSpInfo=struct(...
                'Name',eRecord.Name,...
                'DataTypeName',eDataType.DTName,...
                'Width',eRecord.Width,...
                'SizeIdx',-1);
                ePathTokens=[spPathInfo,eSpInfo];


                keys=nFillBusInformation(keys,eKeyStr,eDataType,eOffsetStr,ePathStr,ePathTokens);

            else




                if(eDataType.IsEnum~=1&&(eDataType.Id~=eDataType.IdAliasedThruTo))||...
                    eDataType.IsFixedPoint
                    eDataTypeId=eDataType.StorageId;
                    eDataType=this.DataTypes.Items(eDataTypeId);
                end



                eDataTypeSizeIdx=find(strcmp(eDataType.DTName,...
                this.DataTypes.BusInfo.DataTypeSizeTable));

                if isempty(eDataTypeSizeIdx)

                    this.DataTypes.BusInfo.OtherDataTypesId(end+1)=eDataType.Id;


                    this.DataTypes.BusInfo.DataTypeSizeTable(end+1)={eDataType.DTName};


                    eDataTypeSizeIdx=numel(this.DataTypes.BusInfo.DataTypeSizeTable);
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



                if isempty(find(strcmp(eKeyStr,this.DataTypes.BusInfo.BusElementHashTable(:,1)),1))
                    hashTableSize=size(this.DataTypes.BusInfo.BusElementHashTable,1);
                    eAccessInfo=struct(...
                    'OffsetStr',eOffsetStr,...
                    'SizeStr',eSizeStr,...
                    'OffsetIdx',2*hashTableSize,...
                    'SizeIdx',2*hashTableSize+1,...
                    'PathStr',ePathStr,...
                    'PathInfo',ePathTokens...
                    );...
                    this.DataTypes.BusInfo.BusElementHashTable(end+1,1:2)={eKeyStr,eAccessInfo};
                end

            end
        end
    end

    function keys=nFillBusInformationForData(dataSpec)


        dataType=this.DataTypes.Items(dataSpec.DataTypeId);

        if dataType.isAggregateType()

            spInfo=struct(...
            'Name','',...
            'DataTypeName',dataType.DTName,...
            'Width',dataSpec.Width,...
            'SizeIdx',-1);



            keys=nFillBusInformation(...
            {},...
            dataType.DTName,...
            dataType,...
            '',...
            dataType.DTName,...
spInfo...
            );
        else
            keys=cell(0,1);
        end
    end


    this.forEachDataSetDataOnly(@(d)fillData(d));

    function fillData(data)
        data.BusInfo.Keys=nFillBusInformationForData(data);
    end

end


