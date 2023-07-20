




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


        emitBanner(dataSpec.Identifier);


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'tlc');


        codeWriter.wLine('%%assign dTypeId = %s',apiInfo.TypeId);

        if~dataSpec.IsComplex&&dataType.IsBus&&(dataSpec.Width==1)

            emitOldApi(dataSpec,dataType.DTName,apiInfo);
        else

            emitNewApi(dataSpec,dataType.DTName,apiInfo);
        end
    end

    function emitOldApi(dataSpec,typeName,apiInfo)
        if sl2User
            codeWriter.wLine('%%<SLibAssignSLStructToUserStruct(dTypeId, "(*(%s *)%s)", "(char *)%s", 0)>\n',...
            typeName,apiInfo.WBusName,dataSpec.Identifier);
        else
            codeWriter.wLine('%%<SLibAssignUserStructToSLStruct(dTypeId, "(char *)%s", "(*(%s *)%s)", 0)>',...
            dataSpec.Identifier,typeName,apiInfo.WBusName);
        end
    end

    function emitNewApi(dataSpec,typeName,apiInfo)
        if dataSpec.IsDynamicArray
            widthArg=sprintf('"%sDynamicArrayWidth"',dataSpec.Identifier);
            codeWriter.wLine('%assign optStar = ""');
        else
            codeWriter.wLine('%%assign width = %s',apiInfo.Width);
            widthArg='width';
            codeWriter.wLine('%assign optStar = ISEQUAL(width,1) ? "*" : ""');
        end
        codeWriter.wLine('%%assign isCmplx = %s',apiInfo.IsCplx);
        if sl2User
            codeWriter.wLine('%%<SLibAssignSLStructToUserStructND(dTypeId, %s, "(%%<optStar>(%s *)%s)", "(char *)%s", Matrix(1,1) [0], 0, isCmplx)>',...
            widthArg,typeName,apiInfo.WBusName,dataSpec.Identifier);
        else
            codeWriter.wLine('%%<SLibAssignUserStructToSLStructND(dTypeId, %s, "(char *)%s", "(%%<optStar>(%s *)%s)", Matrix(1,1) [0], 0, isCmplx)>',...
            widthArg,dataSpec.Identifier,typeName,apiInfo.WBusName);
        end
    end

    function emitBanner(id)
        codeWriter.wNewLine;
        if sl2User
            codeWriter.wLine('/* Assign the Simulink structure %s to user structure %sBUS */',id,id);
        else
            codeWriter.wLine('/* Assign the user structure %sBUS to the Simulink structure %s */',id,id);
        end
    end
end


