




function emitLocalsForNDMarshaling(this,codeWriter,funSpec,fromWrapper)



    if~this.LctSpecInfo.hasRowMajorNDArray
        return
    end

    if nargin<4
        fromWrapper=false;
    end

    funSpec.forEachArg(@(f,a)declData(a.Data));

    function declData(dataSpec)


        if dataSpec.isExprArg()||dataSpec.isDWork()||(dataSpec.CArrayND.DWorkIdx<1)
            return
        end


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'tlc');
        if dataSpec.IsComplex
            typeName=apiInfo.CplxTypeName;
        else
            typeName=apiInfo.TypeName;
        end



        if~fromWrapper
            codeWriter.wLine(sprintf('%%<%s>* %s = (%%<%s>*)%%<%s>;',...
            typeName,apiInfo.WANDName,...
            typeName,apiInfo.WAND));
        end





        if fromWrapper
            if~this.LctSpecInfo.DataTypes.isAggregateType(dataSpec.DataTypeId)
                codeWriter.wLine(sprintf('%%<%s>* %s = (%%<%s>*)%s;',...
                typeName,apiInfo.WBusName,...
                typeName,dataSpec.Identifier));
            end
        else
            codeWriter.wLine(sprintf('%%<%s>* %s = (%%<%s>*)%%<%s>;',...
            typeName,apiInfo.WBusName,...
            typeName,apiInfo.Ptr));
        end
    end
end
