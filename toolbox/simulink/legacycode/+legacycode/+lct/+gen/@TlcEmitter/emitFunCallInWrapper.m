



function emitFunCallInWrapper(this,codeWriter,funSpec)


    dataTypeTable=this.LctSpecInfo.DataTypes;


    lhs='';
    argList={};


    funSpec.forEachArg(@(f,a)addArg(a));


    callStr=[funSpec.Name,'(',strjoin(argList,', '),');'];
    if~isempty(lhs)
        callStr=[lhs,' = ',callStr];
    end
    codeWriter.wLine(callStr);

    function addArg(argSpec)

        dataSpec=argSpec.Data;
        dataType=dataTypeTable.Items(dataSpec.DataTypeId);
        argName=dataSpec.Identifier;


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'tlc');

        prefix='';
        if dataSpec.CArrayND.DWorkIdx>0


            if argSpec.PassedByValue
                prefix='*';
            end

            argName=sprintf('(%s *) %s',dataType.Name,apiInfo.WANDName);

        elseif dataType.isAggregateType()


            if argSpec.PassedByValue
                prefix='*';
            end

            argName=sprintf('(%s *) %s',dataType.Name,apiInfo.WBusName);
        else

            if dataType.isAliasType()||dataType.isEnumType()


                if argSpec.PassedByValue
                    prefix='*';
                end

                argName=sprintf('(%s *) %s',dataType.Name,argName);
            else

                if~dataSpec.isOutput()&&~dataSpec.isDWork()
                    optStar='';
                    if~argSpec.PassedByValue
                        optStar='*';
                    end


                    dtName=dataType.Name;
                    if dataTypeTable.isFakeAliasType(dataType)

                        rootDataType=dataTypeTable.getTypeForDeclaration(dataType);
                        dtName=rootDataType.Name;
                    end
                    if dataSpec.IsComplex


                        dtName=sprintf('c%s',dtName);
                    end
                    argName=sprintf('(%s%s)(%s)',dtName,optStar,argName);
                end
            end



            if argSpec.IsReturn
                prefix='*';
            end
        end


        ptrCastStr='';
        if~argSpec.PassedByValue
            if numel(dataSpec.Dimensions)>1&&false
                ptrCastStr=legacycode.lct.CodeEmitter.genPtrCastForNDArg(1,this.LctSpecInfo,dataSpec);
            end
        end

        argStr=sprintf('%s%s%s',ptrCastStr,prefix,argName);
        if argSpec.IsReturn
            lhs=argStr;
        else
            argList{end+1}=argStr;
        end
    end
end
