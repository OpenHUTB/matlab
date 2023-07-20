




function emitLocalsForStructMarshaling(this,codeWriter,funSpec)


    funSpec.forEachArg(@(f,a)declData(a.Data));

    function declData(dataSpec)

        dataType=this.LctSpecInfo.DataTypes.Items(dataSpec.DataTypeId);
        if~dataType.isAggregateType()
            return
        end


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'sfun');
        dataType=this.LctSpecInfo.DataTypes.Items(dataSpec.DataTypeId);

        codeWriter.wLine('%s* %s = (%s*) %s;',...
        dataType.Name,apiInfo.CVarWBusName,dataType.Name,apiInfo.WBus);
    end
end


