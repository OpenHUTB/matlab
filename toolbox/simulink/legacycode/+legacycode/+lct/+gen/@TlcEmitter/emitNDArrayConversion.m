



function emitNDArrayConversion(this,codeWriter,funSpec,col2Row,skipCast)

    if nargin<5
        skipCast=false;
    end



    if~this.LctSpecInfo.hasRowMajorNDArray
        return
    end


    if col2Row
        dirStr='TLC_TRUE';
    else
        dirStr='TLC_FALSE';
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


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'tlc');

        if skipCast
            slMatPtrStr=apiInfo.WBusName;
            cMatPtrStr=apiInfo.WANDName;
        else


            if dataSpec.IsComplex
                typeName=apiInfo.CplxTypeName;
            else
                typeName=apiInfo.TypeName;
            end
            slMatPtrStr=sprintf('((%%<%s>*) %s)',typeName,apiInfo.WBusName);
            cMatPtrStr=sprintf('((%%<%s>*) %s)',typeName,apiInfo.WANDName);
        end


        codeWriter.wNewLine;
        codeWriter.wLine('%%<SLibMarshalNDArray(%s, %s, %s, %s, "%s", "%s", %d, %s, 0)>',...
        dirStr,apiInfo.TypeId,apiInfo.Width,apiInfo.Dims,...
        cMatPtrStr,slMatPtrStr,dataSpec.CArrayND.MatInfo,...
        apiInfo.IsCplx);
    end
end


