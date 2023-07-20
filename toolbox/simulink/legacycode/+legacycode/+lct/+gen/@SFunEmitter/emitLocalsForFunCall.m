




function emitLocalsForFunCall(this,codeWriter,funSpec)

    hasArg=funSpec.LhsArgs.Numel>0||funSpec.RhsArgs.Numel>0;
    if hasArg
        codeWriter.wNewLine;
        codeWriter.wCmt('Get access to Parameter/Input/Output/DWork data');
    else
        return
    end


    funSpec.forEachArg(@(f,a)declData(a.Data));

    if hasArg
        codeWriter.wNewLine;
    end

    function declData(dataSpec)

        dataType=this.LctSpecInfo.DataTypes.Items(dataSpec.DataTypeId);


        if dataSpec.isExprArg()

            exprStr=legacycode.lct.gen.ExprSFunEmitter.emitExprArg(this.LctSpecInfo,dataSpec,'0');


            dataType=this.LctSpecInfo.DataTypes.getTypeForDeclaration(dataType);

            codeWriter.wLine('%s %s = (%s) (%s);',...
            dataType.Name,dataSpec.Identifier,dataType.Name,exprStr);
            return
        end


        if dataType.isAggregateType()

            dataTypeName='char';
        elseif dataSpec.isDWork()&&~isempty(dataSpec.pwIdx)

            dataTypeName='void';
        else

            dataType=this.LctSpecInfo.DataTypes.getTypeForDeclaration(dataType);
            dataTypeName=dataType.Name;
        end


        if dataSpec.IsComplex
            dataTypeName=sprintf('c%s',dataTypeName);
        end


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'sfun');
        codeWriter.wLine('%s* %s = (%s*) %s;',...
        dataTypeName,dataSpec.Identifier,dataTypeName,apiInfo.Ptr);
    end
end


