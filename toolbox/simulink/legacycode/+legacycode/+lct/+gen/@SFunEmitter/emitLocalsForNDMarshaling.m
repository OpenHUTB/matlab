




function emitLocalsForNDMarshaling(this,codeWriter,funSpec)



    if~this.LctSpecInfo.hasRowMajorNDArray
        return
    end


    stmts={};
    funSpec.forEachArg(@(f,a)declData(a.Data));


    if~isempty(stmts)
        codeWriter.wNewLine;
        codeWriter.wCmt('Locally declared variable(s) for ND Row Major Array');
        cellfun(@(aLine)codeWriter.wLine(aLine),stmts);
    end

    function declData(dataSpec)


        if dataSpec.isExprArg()||dataSpec.isDWork()||(dataSpec.CArrayND.DWorkIdx<1)
            return
        end


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'sfun');
        dataType=this.LctSpecInfo.DataTypes.Items(dataSpec.DataTypeId);
        if dataSpec.IsComplex
            typeName=this.LctSpecInfo.DataTypes.getComplexTypeName(dataType);
        else
            typeName=dataType.Name;
        end

        stmts{end+1}=sprintf('%s* %s = (%s*) %s;',...
        typeName,apiInfo.CVarWANDName,typeName,apiInfo.WAND);
    end
end


