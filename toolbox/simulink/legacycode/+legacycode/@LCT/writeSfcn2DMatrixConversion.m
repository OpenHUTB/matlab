function writeSfcn2DMatrixConversion(h,fid,infoStruct,fcnInfo,col2Row)%#ok<INUSL>





    if col2Row

        for ii=1:fcnInfo.RhsArgs.NumArgs
            thisArg=fcnInfo.RhsArgs.Arg(ii);
            if strcmp(thisArg.Type,'SizeArg')
                continue
            end

            thisData=legacycode.util.lct_pGetDataFromArg(infoStruct,thisArg);
            if thisData.CMatrix2D.DWorkId>0&&ismember(thisArg.Type,{'Input','Parameter'})
                nMarshallArgument(col2Row,thisData,thisArg.DataId-1,thisArg.Type);
            end
        end
    else

        if fcnInfo.LhsArgs.NumArgs==1
            thisArg=fcnInfo.LhsArgs.Arg(1);
            thisData=legacycode.util.lct_pGetDataFromArg(infoStruct,thisArg);

            if strcmpi(thisArg.Type,'Output')&&thisData.CMatrix2D.DWorkId>0
                nMarshallArgument(col2Row,thisData,thisArg.DataId,thisArg.Type);
            end
        end

        for ii=1:fcnInfo.RhsArgs.NumArgs
            thisArg=fcnInfo.RhsArgs.Arg(ii);
            if strcmp(thisArg.Type,'SizeArg')
                continue
            end

            thisData=legacycode.util.lct_pGetDataFromArg(infoStruct,thisArg);
            if strcmpi(thisArg.Type,'Output')&&thisData.CMatrix2D.DWorkId>0
                nMarshallArgument(col2Row,thisData,thisArg.DataId-1,thisArg.Type);
            end
        end

    end

    function nMarshallArgument(col2Row,thisData,dataId,dataKind)



        switch dataKind
        case 'Input'
            widthStr=sprintf('ssGetInputPortWidth(S, %d)',dataId);
            numRowStr=sprintf('ssGetInputPortDimensions(S, %d)[0]',dataId);
            numColStr=sprintf('ssGetInputPortDimensions(S, %d)[1]',dataId);

        case 'Parameter'
            widthStr=sprintf('mxGetNumberOfElements(ssGetSFcnParam(S, %d))',dataId);
            numRowStr=sprintf('mxGetDimensions(ssGetSFcnParam(S, %d))',dataId);
            numColStr=sprintf('mxGetDimensions(ssGetSFcnParam(S, %d))',dataId);

        case 'Output'
            widthStr=sprintf('ssGetOutputPortWidth(S, %d)',dataId);
            numRowStr=sprintf('ssGetOutputPortDimensions(S, %d)[0]',dataId);
            numColStr=sprintf('ssGetOutputPortDimensions(S, %d)[1]',dataId);
        otherwise

        end

        if col2Row
            orientStr='col to row';
        else
            orientStr='row to col';
        end
        fprintf(fid,'/*\n');
        fprintf(fid,' * Convert 2D Matrix from %s major orientation for %s\n',orientStr,thisData.Identifier);
        fprintf(fid,' */\n');

        thisDataType=infoStruct.DataTypes.DataType(thisData.DataTypeId);


        slMatStr=thisData.Identifier;
        if(thisDataType.IsBus==1||thisDataType.IsStruct==1)
            slMatStr=['__',slMatStr,'BUS'];
        end
        cMatStr=['__',thisData.Identifier,'M2D'];


        nConvert2DMatrix(col2Row,thisData.DataTypeId,thisData.Width,thisData.Dimensions,...
        slMatStr,cMatStr,widthStr,numRowStr,numColStr,thisData.CMatrix2D.MatInfo,0);

    end

    function nConvert2DMatrix(col2Row,dataTypeId,width,dims,slMatStr,cMatStr,widthStr,numRowStr,numColStr,matInfo,level)



        thisDataType=infoStruct.DataTypes.DataType(dataTypeId);

        if matInfo==0
            if level==0

                return
            end



            if col2Row
                fprintf(fid,'(void)memcpy(%s, %s, %d*sizeof(%s));',...
                cMatStr,slMatStr,width,thisDataType.Name);
            else
                fprintf(fid,'(void)memcpy(%s, %s, %d*sizeof(%s));',...
                slMatStr,cMatStr,width,thisDataType.Name);
            end

        elseif matInfo==1

            str=iGenerate2DMatrixConversionStr(col2Row,...
            cMatStr,slMatStr,numRowStr,numColStr,thisDataType.Name,level);
            fprintf(fid,'%s\n',str);

        elseif matInfo==2



            busSLMatStr=slMatStr;
            busCMatStr=cMatStr;


            origLevel=level;
            if numel(dims)==2


                fprintf(fid,'{\n');
                fprintf(fid,'    int_T __i%d, __j%d;\n',level,level);
                fprintf(fid,'    int_T __idx%d = 0;\n',level);
                fprintf(fid,'    for (__i%d = 0; __i%d < %s; ++__i%d) {\n',level,level,numRowStr,level);
                fprintf(fid,'        for (__j%d = 0; __j%d < %s; ++__j%d) {\n',level,level,numColStr,level);
                fprintf(fid,'            %s* __cMatPtr%d = &%s[__idx%d];\n',thisDataType.Name,level,busCMatStr,level);
                fprintf(fid,'            %s* __slMatPtr%d = &%s[__i%d + __j%d * %s];\n',thisDataType.Name,level,busSLMatStr,level,level,numRowStr);
                busSLMatStr=sprintf('(*__slMatPtr%d)',level);
                busCMatStr=sprintf('(*__cMatPtr%d)',level);
                level=level+1;

            elseif width~=1

                fprintf(fid,'{\n');
                fprintf(fid,'    int_T __i%d;\n',level);
                fprintf(fid,'    for(__i%d = 0; __i%d < %s; ++__i%d) {\n',level,level,widthStr,level);
                busSLMatStr=sprintf('%s[__i%d]',busSLMatStr,level);
                busCMatStr=sprintf('%s[__i%d]',busCMatStr,level);
                level=level+1;

            else

                if level==0
                    busSLMatStr=['(*',busSLMatStr,')'];
                    busCMatStr=['(*',busCMatStr,')'];
                end
            end


            nConvert2DMatrixForBus(col2Row,dataTypeId,busSLMatStr,busCMatStr,level);


            if width~=1
                if numel(dims)==2
                    fprintf(fid,'            ++__idx%d;\n',origLevel);
                    fprintf(fid,'        }\n');
                end
                fprintf(fid,'    }\n');
                fprintf(fid,'}\n');
            end
        end
    end

    function nConvert2DMatrixForBus(col2Row,dataTypeId,slMatStr,cMatStr,level)


        dataType=infoStruct.DataTypes.DataType(dataTypeId);


        for jj=1:dataType.NumElements
            el=dataType.Elements(jj);


            matInfo=legacycode.LCT.get2DMatrixMarshalingInfo(infoStruct,el.DataTypeId,el.Dimensions);


            eCMatStr=sprintf('%s.%s',cMatStr,el.Name);
            eFMatStr=sprintf('%s.%s',slMatStr,el.Name);
            widthStr=sprintf('%d',el.Width);
            numRowStr='';
            numColStr='';

            if matInfo==0



                optAddr='';
                if el.Width==1
                    optAddr='&';
                end
                eCMatStr=[optAddr,eCMatStr];%#ok<AGROW>
                eFMatStr=[optAddr,eFMatStr];%#ok<AGROW>

            else
                if el.NumDimensions>1

                    elType=infoStruct.DataTypes.DataType(el.DataTypeId);
                    if((elType.Id~=elType.IdAliasedThruTo)&&(elType.IdAliasedTo~=-1))

                        dataTypeName=elType.Name;
                    else

                        dType=infoStruct.DataTypes.DataType(elType.IdAliasedThruTo);
                        dataTypeName=dType.Name;
                    end



                    eCMatStr=sprintf('((%s*)%s)',dataTypeName,eCMatStr);
                    eFMatStr=sprintf('((%s*)%s)',dataTypeName,eFMatStr);


                    numRowStr=sprintf('%d',el.Dimensions(1));
                    numColStr=sprintf('%d',el.Dimensions(2));
                end
            end


            nConvert2DMatrix(col2Row,el.DataTypeId,...
            el.Width,el.Dimensions,eFMatStr,eCMatStr,...
            widthStr,numRowStr,numColStr,matInfo,level+1)
        end

    end

end


function str=iGenerate2DMatrixConversionStr(col2Row,cMatStr,slMatStr,numRowStr,numColStr,typeName,level)


    if nargin<6
        typeName='';
    end

    if nargin<7
        level=0;
    end


    str=sprintf('{\n');


    if~isempty(typeName)
        colMatStr=sprintf('__colMat%d',level);
        rowMatStr=sprintf('__rowMat%d',level);
        str=sprintf('%s    %s* %s = (%s*)%s;\n    %s* %s = (%s*)%s;\n',...
        str,typeName,colMatStr,typeName,slMatStr,typeName,rowMatStr,typeName,cMatStr);
        slMatStr=colMatStr;
        cMatStr=rowMatStr;
    end


    iStr=sprintf('__i%d',level);
    jStr=sprintf('__j%d',level);
    str=sprintf([...
    '%s',...
    '    int_T %s, %s;\n',...
    '    for (%s = 0; %s < %s; ++%s) {\n',...
'        for (%s = 0; %s < %s; ++%s) {\n'...
    ],str,iStr,jStr,iStr,iStr,numRowStr,iStr,jStr,jStr,numColStr,jStr);


    cMatUpdateStr=sprintf('*%s++',cMatStr);
    slMatUpdateStr=sprintf('%s[%s + %s * %s]',slMatStr,iStr,jStr,numRowStr);
    if col2Row
        lhsStr=cMatUpdateStr;
        rhsStr=slMatUpdateStr;
    else
        lhsStr=slMatUpdateStr;
        rhsStr=cMatUpdateStr;
    end
    str=sprintf('%s            %s = %s;\n',str,lhsStr,rhsStr);


    str=sprintf('%s        }\n    }\n}',str);

end
