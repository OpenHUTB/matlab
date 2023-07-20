




function localDecls=emitLocalsForWrapperFunCall(this,codeWriter,funSpec)


    localDecls={};


    funSpec.forEachArg(@(f,a)declArg(a));

    function declArg(argSpec)

        dataSpec=argSpec.Data;
        dataType=this.LctSpecInfo.DataTypes.Items(dataSpec.DataTypeId);


        if dataSpec.isExprArg()

            exprStr=legacycode.lct.gen.ExprTlcEmitter.emitExprArg(this.LctSpecInfo,dataSpec);
            if contains(exprStr,"%<")

                exprStr=sprintf('"%s"',exprStr);
            end
            codeWriter.wLine(sprintf('%%assign %s_val = %s',dataSpec.Identifier,exprStr));

            if dataType.isAliasType()




                dataType=this.LctSpecInfo.DataTypes.getBottomAliasedType(dataType);
                localDecls{end+1}=sprintf('%s %s_val = %%<%s_val>;',...
                dataType.Name,dataSpec.Identifier,dataSpec.Identifier);
            end
            return
        end


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'tlc');




        addrTaken=true;

        if dataType.isAggregateType()


            codeWriter.wLine(sprintf('%%assign %s_ptr = %s',dataSpec.Identifier,apiInfo.Ptr));
            codeWriter.wLine(sprintf('%%assign %s_ptr = %s',apiInfo.WBusName,apiInfo.WBus));

        elseif dataType.isAliasType()||dataType.isEnumType()
            if dataSpec.isParameter()&&argSpec.PassedByValue



                codeWriter.wLine(sprintf('%%assign %s_val = %s',dataSpec.Identifier,apiInfo.Val));




                baseType=this.LctSpecInfo.DataTypes.Items(dataType.IdAliasedThruTo);
                if baseType.isAggregateType()



                    localDecls{end+1}=sprintf(...
                    '%%<%s> %s_val = %%<%s_val>;',apiInfo.TypeName,...
                    dataSpec.Identifier,dataSpec.Identifier);
                else



                    localDecls{end+1}=sprintf(...
                    '%s %s_val = (%s)%%<%s_val>;',baseType.NativeType,...
                    dataSpec.Identifier,baseType.NativeType,dataSpec.Identifier);
                end

                addrTaken=false;

            else

                codeWriter.wLine(sprintf('%%assign %s_ptr = %s',dataSpec.Identifier,apiInfo.Ptr));
            end
        else
            if~argSpec.PassedByValue||argSpec.IsReturn



                codeWriter.wLine(sprintf('%%assign %s_ptr = %s',dataSpec.Identifier,apiInfo.Ptr));
            else


                codeWriter.wLine(sprintf('%%assign %s_val = %s',dataSpec.Identifier,apiInfo.Val));
                addrTaken=false;
            end
        end


        if dataSpec.CArrayND.DWorkIdx>0

            codeWriter.wLine(sprintf('%%assign %s_ptr = %s',apiInfo.WANDName,apiInfo.WAND));




            if addrTaken==false
                codeWriter.wLine(sprintf('%%assign %s_ptr = %s',dataSpec.Identifier,apiInfo.Ptr));
            end
        end
    end
end


