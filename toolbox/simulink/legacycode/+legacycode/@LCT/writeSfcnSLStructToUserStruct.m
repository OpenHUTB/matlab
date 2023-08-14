function writeSfcnSLStructToUserStruct(h,fid,infoStruct,fcnInfo)%#ok<INUSL>






    function nAssignSLStructToUserStruct(keys,srcStr,startSrcOffsetStr,startDstStr,startLevel)



        for jj=1:numel(keys)

            dataIdx=strmatch(keys{jj},infoStruct.DataTypes.BusInfo.BusElementHashTable(:,1),'exact');
            eAccessInfo=infoStruct.DataTypes.BusInfo.BusElementHashTable{dataIdx(1),2};

            level=startLevel;
            dstStr=startDstStr;
            srcOffsetStr=startSrcOffsetStr;

            if startLevel>0



                srcOffsetStr=sprintf(' + i0*__dtSizeInfo[%d]',eAccessInfo.PathInfo(1).SizeIdx);
            end

            for kk=2:numel(eAccessInfo.PathInfo)-1
                dstStr=sprintf('%s.%s',dstStr,eAccessInfo.PathInfo(kk).Name);
                if eAccessInfo.PathInfo(kk).Width~=1
                    dstStr=sprintf('((%s*)%s)[i%d]',eAccessInfo.PathInfo(kk).DataTypeName,dstStr,level);
                    srcOffsetStr=sprintf('%s + i%d*__dtSizeInfo[%d]',...
                    srcOffsetStr,level,eAccessInfo.PathInfo(kk).SizeIdx);
                    fprintf(fid,'{\n');
                    fprintf(fid,'    int_T i%d;\n',level);
                    fprintf(fid,'    for(i%d = 0; i%d < %d; i%d++) {\n',...
                    level,level,eAccessInfo.PathInfo(kk).Width,level);
                    level=level+1;
                end
            end

            if eAccessInfo.PathInfo(end).Width==1
                dstStr=sprintf('&%s',dstStr);
            end

            dstStr=sprintf('%s.%s\n',dstStr,eAccessInfo.PathInfo(end).Name);
            fprintf(fid,'(void) memcpy(%s, %s %s + __dtBusInfo[%d], __dtBusInfo[%d]);\n',...
            dstStr,srcStr,...
            srcOffsetStr,...
            eAccessInfo.OffsetIdx,...
            eAccessInfo.SizeIdx);

            for kk=2:numel(eAccessInfo.PathInfo)-1
                if eAccessInfo.PathInfo(kk).Width~=1
                    fprintf(fid,'}\n');
                    fprintf(fid,'}\n');
                end
            end
        end
    end

    function nMarshallInput(aData,aDataWidthAccessStr)
        fprintf(fid,'/*\n');
        fprintf(fid,' * Assign the Simulink Structure %s to the Legacy Structure __%sBUS\n',...
        aData.Identifier,aData.Identifier);
        fprintf(fid,' */\n');


        srcStr=aData.Identifier;
        srcOffsetStr='';
        level=0;
        if aData.Width==1
            dstStr=['__',srcStr,'BUS[0]'];
        else
            dstStr=['__',srcStr,'BUS[i0]'];
            level=1;
            fprintf(fid,'{\n');
            fprintf(fid,'    int_T i0;\n');
            fprintf(fid,'    for(i0 = 0; i0 < %s; i0++) {\n',aDataWidthAccessStr);
        end

        nAssignSLStructToUserStruct(...
        aData.BusInfo.Keys,...
        srcStr,...
        srcOffsetStr,...
        dstStr,...
level...
        );

        if aData.Width~=1
            fprintf(fid,'}\n');
            fprintf(fid,'}\n');
        end
        fprintf(fid,'\n');

    end



    for ii=1:fcnInfo.RhsArgs.NumArgs
        thisArg=fcnInfo.RhsArgs.Arg(ii);
        thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);

        if(thisDataType.IsBus==1||thisDataType.IsStruct==1)&&strcmp(thisArg.Type,'DWork')

            nMarshallInput(infoStruct.DWorks.DWork(thisArg.DataId),...
            sprintf('ssGetDWorkWidth(S, %d)',thisArg.DataId-1));
        end

        if(thisDataType.IsBus==1||thisDataType.IsStruct==1)&&strcmp(thisArg.Type,'Input')

            nMarshallInput(infoStruct.Inputs.Input(thisArg.DataId),...
            sprintf('ssGetInputPortWidth(S, %d)',thisArg.DataId-1));
        end

        if(thisDataType.IsBus==1||thisDataType.IsStruct==1)&&strcmp(thisArg.Type,'Parameter')

            nMarshallInput(infoStruct.Parameters.Parameter(thisArg.DataId),...
            sprintf('mxGetNumberOfElements(ssGetSFcnParam(S, %d))',thisArg.DataId-1));
        end
    end

end


