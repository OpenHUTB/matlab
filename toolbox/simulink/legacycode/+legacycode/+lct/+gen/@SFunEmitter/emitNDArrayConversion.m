



function emitNDArrayConversion(this,codeWriter,funSpec,col2Row)



    if~this.LctSpecInfo.hasRowMajorNDArray
        return
    end


    funSpec.forEachArg(@(f,a)xformData(a.Data));

    function xformData(dataSpec)


        if dataSpec.isExprArg()||dataSpec.isDWork()||(dataSpec.CArrayND.DWorkIdx<1)
            return
        end


        if col2Row

            if~(dataSpec.isInput()||dataSpec.isParameter()||dataSpec.isDWork())
                return
            end
        else

            if~(dataSpec.isOutput()||dataSpec.isDWork())
                return
            end
        end


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'sfun');

        if col2Row
            orientStr='col to row';
        else
            orientStr='row to col';
        end
        codeWriter.wNewLine;
        codeWriter.wCmt('Convert ND Array from %s major orientation for %s',...
        orientStr,dataSpec.Identifier);


        dataType=this.LctSpecInfo.DataTypes.Items(dataSpec.DataTypeId);
        slMatStr=dataSpec.Identifier;
        if dataType.isAggregateType()
            slMatStr=apiInfo.CVarWBusName;
        end
        cMatStr=apiInfo.CVarWANDName;


        widthStr=apiInfo.Width;
        dimsStr=cell(1,numel(dataSpec.Dimensions));
        for ii=1:numel(dataSpec.Dimensions)
            dimsStr{ii}=apiInfo.Dims(ii-1);
        end
        transposeKernel(col2Row,dataSpec.DataTypeId,dataSpec.Width,dataSpec.IsComplex,...
        slMatStr,cMatStr,widthStr,dimsStr,dataSpec.CArrayND.MatInfo,0);
    end

    function transposeKernel(col2Row,dataTypeId,width,isCplx,slMatStr,cMatStr,widthStr,dimsStr,matInfo,level)




        dataType=this.LctSpecInfo.DataTypes.Items(dataTypeId);
        typeName=dataType.Name;

        if matInfo==0
            if level==0

                return
            end

            if isCplx
                typeName=this.LctSpecInfo.DataTypes.getComplexTypeName(dataType);
            end



            typeSize=sprintf('sizeof(%s)',typeName);
            if width>1
                typeSize=sprintf('%d*%s',width,typeSize);
            end
            if col2Row
                codeWriter.wLine('(void)memcpy(%s, %s, %s);',...
                cMatStr,slMatStr,typeSize);
            else
                codeWriter.wLine('(void)memcpy(%s, %s, %s);',...
                slMatStr,cMatStr,typeSize);
            end

        elseif matInfo==1

            if isCplx
                typeName=this.LctSpecInfo.DataTypes.getComplexTypeName(dataType);
            end
            transposeMatrix(col2Row,cMatStr,slMatStr,dimsStr,typeName,level);

        elseif matInfo==2


            busSLMatStr=slMatStr;
            busCMatStr=cMatStr;


            if numel(dimsStr)>=2

                codeWriter.wBlockStart();
                numOpenedBlocks=1;


                idxName=sprintf('__idx%d',level);
                dimsArrayName=sprintf('__dims%d',level);
                dimsArrayValues=cell(1,numel(dimsStr));
                loopCntNames=cell(1,numel(dimsStr));
                for ii=1:numel(dimsStr)
                    dimsArrayValues{ii}=sprintf('%s[%d]',dimsArrayName,ii-1);
                    loopCntNames{ii}=sprintf('%s_%d',idxName,ii);
                end


                codeWriter.wLine('int_T %s = 0;',idxName);
                codeWriter.wLine('int_T %s[%d];',dimsArrayName,numel(dimsStr));


                for ii=1:numel(dimsStr)
                    numOpenedBlocks=numOpenedBlocks+1;


                    codeWriter.wLine('int_T %s;',loopCntNames{ii});



                    if ii==1
                        for jj=1:numel(dimsStr)
                            codeWriter.wLine('%s = %s;',dimsArrayValues{jj},dimsStr{jj});
                        end
                    end

                    codeWriter.wBlockStart('for (%s = 0; %s < %s; ++%s)',...
                    loopCntNames{ii},loopCntNames{ii},dimsArrayValues{ii},loopCntNames{ii});
                end


                linIdx=legacycode.lct.gen.CodeEmitter.genSubscripts2Index(loopCntNames,dimsArrayValues);


                codeWriter.wLine('%s* __cMatPtr%d = &%s[%s++];',typeName,level,busCMatStr,idxName);
                codeWriter.wLine('%s* __slMatPtr%d = &%s[%s];',typeName,level,busSLMatStr,linIdx);

                busSLMatStr=sprintf('(*__slMatPtr%d)',level);
                busCMatStr=sprintf('(*__cMatPtr%d)',level);


                transposeBus(col2Row,dataTypeId,busSLMatStr,busCMatStr,level+1);


                for ii=1:numOpenedBlocks
                    codeWriter.wBlockEnd();
                end

            elseif width~=1

                codeWriter.wBlockStart();
                loopCnt=sprintf('__idx%d',level);
                codeWriter.wLine('int_T %s;',loopCnt);
                codeWriter.wBlockStart('for (%s = 0; %s < (%s); ++%s)',loopCnt,loopCnt,widthStr,loopCnt);
                busSLMatStr=sprintf('%s[%s]',busSLMatStr,loopCnt);
                busCMatStr=sprintf('%s[%s]',busCMatStr,loopCnt);


                transposeBus(col2Row,dataTypeId,busSLMatStr,busCMatStr,level+1);


                codeWriter.wBlockEnd();
                codeWriter.wBlockEnd();
            else

                if level==0
                    busSLMatStr=['(*',busSLMatStr,')'];
                    busCMatStr=['(*',busCMatStr,')'];
                end


                transposeBus(col2Row,dataTypeId,busSLMatStr,busCMatStr,level+1);
            end
        end
    end

    function transposeBus(col2Row,dataTypeId,slMatStr,cMatStr,level)


        dataType=this.LctSpecInfo.DataTypes.Items(dataTypeId);


        for jj=1:dataType.NumElements
            el=dataType.Elements(jj);


            matInfo=this.LctSpecInfo.getNDArrayMarshalingInfo(el.DataTypeId,el.Dimensions);


            eCMatStr=sprintf('%s.%s',cMatStr,el.Name);
            eFMatStr=sprintf('%s.%s',slMatStr,el.Name);
            widthStr=sprintf('%d',el.Width);
            dimsStr=repmat({''},1,numel(el.Dimensions));

            if matInfo==0



                optAddr='';
                if el.Width==1
                    optAddr='&';
                end
                eCMatStr=[optAddr,eCMatStr];%#ok<AGROW>
                eFMatStr=[optAddr,eFMatStr];%#ok<AGROW>

            else
                if el.NumDimensions>1
                    if el.IsComplex
                        dataTypeName=this.LctSpecInfo.DataTypes.getComplexTypeName(el.DataTypeId);
                    else

                        elType=this.LctSpecInfo.DataTypes.getTypeForDeclaration(el.DataTypeId);
                        dataTypeName=elType.Name;
                    end



                    eCMatStr=sprintf('((%s*)%s)',dataTypeName,eCMatStr);
                    eFMatStr=sprintf('((%s*)%s)',dataTypeName,eFMatStr);


                    for ii=1:numel(el.Dimensions)
                        dimsStr{ii}=sprintf('%d',el.Dimensions(ii));
                    end
                end
            end


            transposeKernel(col2Row,el.DataTypeId,el.Width,...
            el.IsComplex,eFMatStr,eCMatStr,...
            widthStr,dimsStr,matInfo,level)
        end
    end

    function transposeMatrix(col2Row,cMatStr,slMatStr,dimsStr,typeName,level)


        if nargin<6
            level=0;
        end


        codeWriter.wBlockStart();
        numOpenedBlocks=1;


        idxName=sprintf('__idx%d',level);
        dimsArrayName=sprintf('__dims%d',level);
        dimsArrayValues=cell(1,numel(dimsStr));
        loopCntNames=cell(1,numel(dimsStr));
        for ii=1:numel(dimsStr)
            dimsArrayValues{ii}=sprintf('%s[%d]',dimsArrayName,ii-1);
            loopCntNames{ii}=sprintf('%s_%d',idxName,ii);
        end


        codeWriter.wLine('int_T %s = 0;',idxName);
        codeWriter.wLine('int_T %s[%d];',dimsArrayName,numel(dimsStr));


        for ii=1:numel(dimsStr)
            numOpenedBlocks=numOpenedBlocks+1;


            codeWriter.wLine('int_T %s;',loopCntNames{ii});



            if ii==1
                for jj=1:numel(dimsStr)
                    codeWriter.wLine('%s = %s;',dimsArrayValues{jj},dimsStr{jj});
                end
            end
            codeWriter.wBlockStart('for (%s = 0; %s < %s; ++%s)',...
            loopCntNames{ii},loopCntNames{ii},dimsArrayValues{ii},loopCntNames{ii});
        end


        linIdx=legacycode.lct.gen.CodeEmitter.genSubscripts2Index(loopCntNames,dimsArrayValues);

        rowMatExpr=sprintf('&(%s)[%s++]',cMatStr,idxName);
        colMatExpr=sprintf('&(%s)[%s]',slMatStr,linIdx);


        if col2Row
            dstExpr=rowMatExpr;
            srcExpr=colMatExpr;
        else
            dstExpr=colMatExpr;
            srcExpr=rowMatExpr;
        end
        codeWriter.wLine('(void)memcpy(%s, %s, sizeof(%s));',dstExpr,srcExpr,typeName);


        for ii=1:numOpenedBlocks
            codeWriter.wBlockEnd();
        end

    end
end


