function writeSfcnUserStructToSLStruct(h,fid,infoStruct,fcnInfo)%#ok<INUSL>






    function nAssignUserStructToSLStruct(keys,startSrcStr,dstStr,startDstOffsetStr,startLevel)



        for jj=1:numel(keys)

            dataIdx=strmatch(keys{jj},infoStruct.DataTypes.BusInfo.BusElementHashTable(:,1),'exact');
            eAccessInfo=infoStruct.DataTypes.BusInfo.BusElementHashTable{dataIdx(1),2};

            level=startLevel;
            srcStr=startSrcStr;
            dstOffsetStr=startDstOffsetStr;

            if startLevel>0



                dstOffsetStr=sprintf(' + i0*__dtSizeInfo[%d]',eAccessInfo.PathInfo(1).SizeIdx);
            end

            for kk=2:numel(eAccessInfo.PathInfo)-1
                srcStr=sprintf('%s.%s',srcStr,eAccessInfo.PathInfo(kk).Name);
                if eAccessInfo.PathInfo(kk).Width~=1
                    srcStr=sprintf('((%s*)%s)[i%d]',eAccessInfo.PathInfo(kk).DataTypeName,srcStr,level);
                    dstOffsetStr=sprintf('%s + i%d*__dtSizeInfo[%d]',...
                    dstOffsetStr,level,eAccessInfo.PathInfo(kk).SizeIdx);
                    fprintf(fid,'{\n');
                    fprintf(fid,'    int_T i%d;\n',level);
                    fprintf(fid,'    for(i%d = 0; i%d < %d; i%d++) {\n',...
                    level,level,eAccessInfo.PathInfo(kk).Width,level);
                    level=level+1;
                end
            end

            if eAccessInfo.PathInfo(end).Width==1
                srcStr=sprintf('&%s',srcStr);
            end

            srcStr=sprintf('%s.%s\n',srcStr,eAccessInfo.PathInfo(end).Name);
            fprintf(fid,'(void) memcpy(%s %s + __dtBusInfo[%d], %s,  __dtBusInfo[%d]);\n',...
            dstStr,dstOffsetStr,eAccessInfo.OffsetIdx,...
            srcStr,...
            eAccessInfo.SizeIdx);

            for kk=2:numel(eAccessInfo.PathInfo)-1
                if eAccessInfo.PathInfo(kk).Width~=1
                    fprintf(fid,'}\n');
                    fprintf(fid,'}\n');
                end
            end
        end
    end

    function nMarshallOutput(aData,aDataWidthAccessStr)
        fprintf(fid,'/*\n');
        fprintf(fid,' * Assign the Legacy Structure __%sBUS to the Simulink Structure %s\n',...
        aData.Identifier,aData.Identifier);
        fprintf(fid,' */\n');


        dstStr=aData.Identifier;
        dstOffsetStr='';

        level=0;
        if aData.Width==1
            srcStr=['__',dstStr,'BUS[0]'];
        else
            srcStr=['__',dstStr,'BUS[i0]'];
            level=1;
            fprintf(fid,'{\n');
            fprintf(fid,'    int_T i0;\n');
            fprintf(fid,'    for(i0 = 0; i0 < %s; i0++) {\n',aDataWidthAccessStr);
        end

        nAssignUserStructToSLStruct(...
        aData.BusInfo.Keys,...
        srcStr,...
        dstStr,...
        dstOffsetStr,...
level...
        );

        if aData.Width~=1
            fprintf(fid,'}\n');
            fprintf(fid,'}\n');
        end
        fprintf(fid,'\n');

    end

    if fcnInfo.LhsArgs.NumArgs==1
        thisArg=fcnInfo.LhsArgs.Arg(1);
        thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);

        if(thisDataType.IsBus==1||thisDataType.IsStruct==1)

            nMarshallOutput(infoStruct.Outputs.Output(thisArg.DataId),...
            sprintf('ssGetOutputPortWidth(S, %d)',thisArg.DataId-1));
        end
    end

    for ii=1:fcnInfo.RhsArgs.NumArgs
        thisArg=fcnInfo.RhsArgs.Arg(ii);
        thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);

        if(thisDataType.IsBus==1||thisDataType.IsStruct==1)&&strcmp(thisArg.Type,'Output')
            nMarshallOutput(infoStruct.Outputs.Output(thisArg.DataId),...
            sprintf('ssGetOutputPortWidth(S, %d)',thisArg.DataId-1));
        end

        if(thisDataType.IsBus==1||thisDataType.IsStruct==1)&&strcmp(thisArg.Type,'DWork')
            nMarshallOutput(infoStruct.DWorks.DWork(thisArg.DataId),...
            sprintf('ssGetDWorkWidth(S, %d)',thisArg.DataId-1));
        end

    end

end


