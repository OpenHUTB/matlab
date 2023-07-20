




function emitStructConversion(this,codeWriter,funSpec,sl2User)


    dataTypeTable=this.LctSpecInfo.DataTypes;


    funSpec.forEachArg(@(f,a)xformData(a.Data));

    function xformData(dataSpec)

        dataType=dataTypeTable.Items(dataSpec.DataTypeId);
        if~dataType.isAggregateType()
            return
        end


        if sl2User

            if~(dataSpec.isInput()||dataSpec.isParameter()||dataSpec.isDWork())
                return
            end
        else

            if~(dataSpec.isOutput()||dataSpec.isDWork())
                return
            end
        end


        nMarshallData(dataSpec)
    end

    function nMarshallData(dataSpec)

        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'sfun');


        level=0;
        idxStart='0';
        if dataSpec.Width~=1
            level=1;
            idxStart='i0';
        end


        slStruct=dataSpec.Identifier;
        userStruct=sprintf('%s[%s]',apiInfo.CVarWBusName,idxStart);

        codeWriter.wNewLine;
        if sl2User
            codeWriter.wCmt('Assign the Simulink structure %s to user structure %s',...
            dataSpec.Identifier,apiInfo.CVarWBusName);
        else
            codeWriter.wCmt('Assign the user structure %s to the Simulink structure %s',...
            apiInfo.CVarWBusName,dataSpec.Identifier);
        end


        if level==1
            codeWriter.wBlockStart();
            codeWriter.wLine('int_T i0;');
            codeWriter.wLine('int_T width0 = %s;',apiInfo.Width);
            codeWriter.wBlockStart('for (i0 = 0; i0 < width0; i0++)');
        end


        nMarshalKernel(...
        dataSpec.BusInfo.Keys,...
        level,...
        slStruct,...
userStruct...
        );


        if level==1
            codeWriter.wBlockEnd();
            codeWriter.wBlockEnd();
        end
    end

    function nMarshalKernel(keys,startLevel,slStruct,userStruct)
        for jj=1:numel(keys)

            dataIdx=find(strcmp(keys{jj},dataTypeTable.BusInfo.BusElementHashTable(:,1)));
            eAccessInfo=dataTypeTable.BusInfo.BusElementHashTable{dataIdx(1),2};


            if sl2User
                memcpySrc=slStruct;
                memcpyDst=userStruct;
            else
                memcpySrc=userStruct;
                memcpyDst=slStruct;
            end




            offset='';
            if startLevel>0
                offset=sprintf('+ i0*__dtSizeInfo[%d] ',eAccessInfo.PathInfo(1).SizeIdx);
            end


            level=startLevel;
            for kk=2:numel(eAccessInfo.PathInfo)-1

                if sl2User
                    memcpyDst=sprintf('%s.%s',memcpyDst,eAccessInfo.PathInfo(kk).Name);
                else
                    memcpySrc=sprintf('%s.%s',memcpySrc,eAccessInfo.PathInfo(kk).Name);
                end


                if eAccessInfo.PathInfo(kk).Width~=1

                    codeWriter.wBlockStart();
                    codeWriter.wLine('int_T i%d;',level);
                    codeWriter.wLine('int_T width%d = %d;',level,eAccessInfo.PathInfo(kk).Width);
                    codeWriter.wBlockStart('for (i%d = 0; i%d < width%d; i%d++)',level,level,level,level);


                    offset=sprintf('%s+ i%d*__dtSizeInfo[%d] ',...
                    offset,level,eAccessInfo.PathInfo(kk).SizeIdx);


                    if sl2User
                        memcpyDst=sprintf('((%s*)%s)[i%d]',eAccessInfo.PathInfo(kk).DataTypeName,memcpyDst,level);
                    else
                        memcpySrc=sprintf('((%s*)%s)[i%d]',eAccessInfo.PathInfo(kk).DataTypeName,memcpySrc,level);
                    end


                    level=level+1;
                end
            end


            if eAccessInfo.PathInfo(end).Width==1
                if sl2User
                    memcpyDst=sprintf('&%s',memcpyDst);
                else
                    memcpySrc=sprintf('&%s',memcpySrc);
                end
            end


            if sl2User
                memcpySrc=sprintf('%s %s+  __dtBusInfo[%d]',memcpySrc,offset,eAccessInfo.OffsetIdx);
                memcpyDst=sprintf('%s.%s',memcpyDst,eAccessInfo.PathInfo(end).Name);
            else
                memcpySrc=sprintf('%s.%s',memcpySrc,eAccessInfo.PathInfo(end).Name);
                memcpyDst=sprintf('%s %s+  __dtBusInfo[%d]',memcpyDst,offset,eAccessInfo.OffsetIdx);
            end


            codeWriter.wLine('(void) memcpy(%s, %s,  __dtBusInfo[%d]);',...
            memcpyDst,memcpySrc,eAccessInfo.SizeIdx);


            for kk=1:level-startLevel
                codeWriter.wBlockEnd();
                codeWriter.wBlockEnd();
            end
        end
    end
end


