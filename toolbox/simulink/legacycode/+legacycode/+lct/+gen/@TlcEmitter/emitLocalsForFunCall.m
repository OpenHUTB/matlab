




function emitLocalsForFunCall(this,codeWriter,funSpec,isBlockOutputSignal)

    if nargin<4
        isBlockOutputSignal=false;
    end


    funSpec.forEachArg(@(f,a)declArg(a));

    function declArg(argSpec)


        if isBlockOutputSignal&&argSpec.IsReturn
            return
        end


        dataSpec=argSpec.Data;


        if dataSpec.isExprArg()

            exprStr=legacycode.lct.gen.ExprTlcEmitter.emitExprArg(this.LctSpecInfo,dataSpec);
            if contains(exprStr,"%<")

                exprStr=sprintf('"%s"',exprStr);
            end
            codeWriter.wLine(sprintf('%%assign %s_val = %s',dataSpec.Identifier,exprStr));
            return
        end


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'tlc');
        if argSpec.PassedByValue
            codeWriter.wLine(sprintf('%%assign %s_val = %s',dataSpec.Identifier,apiInfo.Val));
        else
            codeWriter.wLine(sprintf('%%assign %s_ptr = %s',dataSpec.Identifier,apiInfo.Ptr));
        end
    end
end
