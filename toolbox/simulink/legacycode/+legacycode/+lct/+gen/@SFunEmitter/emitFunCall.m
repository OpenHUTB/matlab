



function emitFunCall(this,codeWriter,funSpec)


    dataTypeTable=this.LctSpecInfo.DataTypes;


    lhs='';
    fcnName=funSpec.Name;
    argList={};


    funSpec.forEachArg(@(f,a)addArg(a));


    callStr=[fcnName,'(',strjoin(argList,', '),');'];
    if~isempty(lhs)
        callStr=[lhs,' = ',callStr];
    end

    codeWriter.wNewLine;
    codeWriter.wCmt('Call the legacy code function');
    codeWriter.wLine(callStr);

    function addArg(argSpec)

        dataSpec=argSpec.Data;
        dataType=dataTypeTable.Items(dataSpec.DataTypeId);
        argName=dataSpec.Identifier;


        ptrCastStr='';
        if~argSpec.PassedByValue
            if numel(dataSpec.Dimensions)>1&&false
                ptrCastStr=legacycode.lct.CodeEmitter.genPtrCastForNDArg(1,this.LctSpecInfo,dataSpec);
            end
        end


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'sfun');


        prefix='';
        if dataSpec.CArrayND.DWorkIdx>0

            argName=apiInfo.CVarWANDName;
            if argSpec.PassedByValue
                prefix='*';
            end

        elseif dataType.isAggregateType()

            argName=apiInfo.CVarWBusName;
            if argSpec.PassedByValue
                prefix='*';
            end

        else

            if argSpec.PassedByValue&&~dataSpec.isExprArg()
                prefix='*';
            end


            if dataSpec.isDWork()&&strcmp(dataType.DTName,'void')
                if~isempty(dataSpec.pwIdx)&&~argSpec.PassedByValue

                    prefix='&';
                else

                    prefix='';
                end
            end
        end

        argStr=sprintf('%s%s%s',prefix,ptrCastStr,argName);


        if argSpec.IsReturn
            lhs=argStr;
        else
            argList{end+1}=argStr;
        end
    end
end


