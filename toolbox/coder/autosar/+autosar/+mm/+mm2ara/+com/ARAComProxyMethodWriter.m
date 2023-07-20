function ARAComProxyMethodWriter(codeWriter,intfName,proxyMethodList,...
    methodSerializerFilePath,modelName)





    autosar.mm.mm2ara.com.RtpsProxyMethodSerializerWriter(methodSerializerFilePath,...
    intfName,proxyMethodList,modelName);


    codeWriter.wBlockStart('namespace methods');
    for ii=1:numel(proxyMethodList)
        m3iMthd=proxyMethodList{ii};


        [argTypeStr,argInvokeStr,argSignatureStr,retTypesEmpty,retTypesArr,retArgNames]=...
        GetOperatorMethodConfig(m3iMthd,modelName);


        codeWriter.wBlockStart(['class ',m3iMthd.Name]);


        codeWriter.wLine('public:');



        if m3iMthd.FireAndForget||retTypesEmpty

            codeWriter.wLine(['std::shared_ptr<ara::com::ProxyFireForgetMethodMiddlewareBase<'...
            ,argTypeStr,'>> mPrxMthd;']);
        else
            codeWriter.wBlockStart('struct Output');
            for jj=1:numel(retTypesArr)
                codeWriter.wLine([retTypesArr{jj},' ',retArgNames{jj},';']);
            end
            codeWriter.wBlockEnd();
            codeWriter.wLine(';');

            codeWriter.wLine(['std::shared_ptr<ara::com::ProxyRequestResponseMethodMiddlewareBase<'...
            ,autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(...
            [m3iMthd.Name,'::Output'],', ',argTypeStr),'>> mPrxMthd;']);
        end




        dynType=['proxy_io::',intfName,'_',m3iMthd.Name,'_mthd_t'];

        codeWriter.wBlockStart([m3iMthd.Name,'(ara::com::ServiceHandleType handle): mPrxMthd(nullptr)']);
        if m3iMthd.FireAndForget||retTypesEmpty
            codeWriter.wLine(['mPrxMthd.reset(ara::com::MethodFactory::CreateProxyFireForgetMethod'...
            ,'<',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(...
            dynType,', ',argTypeStr),'>(handle));']);
        else
            codeWriter.wLine(['mPrxMthd.reset(ara::com::MethodFactory::CreateProxyRequestResponseMethod'...
            ,'<',m3iMthd.Name,'::Output, ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(...
            dynType,', ',argTypeStr),'>(handle));']);
        end
        codeWriter.wBlockEnd();


        codeWriter.wBlockStart(['~',m3iMthd.Name,'()']);
        codeWriter.wLine('mPrxMthd.reset();');
        codeWriter.wBlockEnd();



        if m3iMthd.FireAndForget||retTypesEmpty
            codeWriter.wBlockStart(['void operator() (',argSignatureStr,')']);
            codeWriter.wBlockStart('if (mPrxMthd)');
            codeWriter.wLine(['mPrxMthd->SendPayload(',argInvokeStr,');']);
            codeWriter.wBlockMiddle('else');
        else
            codeWriter.wBlockStart(['ara::core::Future<',m3iMthd.Name,'::Output> operator() (',argSignatureStr,')']);
            codeWriter.wBlockStart('if (mPrxMthd)');
            codeWriter.wLine(['return mPrxMthd->SendPayload(',argInvokeStr,');']);
            codeWriter.wBlockMiddle('else');
            codeWriter.wLine(['ara::core::Promise<',m3iMthd.Name,'::Output> mthdPrm;']);
            codeWriter.wLine(['mthdPrm.set_value(',m3iMthd.Name,'::Output{});']);
            codeWriter.wLine('return mthdPrm.get_future();');
        end
        codeWriter.wBlockEnd();
        codeWriter.wBlockEnd();

        codeWriter.wBlockEnd();
        codeWriter.wLine(';');
    end
    codeWriter.wBlockEnd('namespace methods');
end

function[argTypeStr,argInvokeStr,argSignatureStr,retTypesEmpty,retTypesArr,retArgNames]=...
    GetOperatorMethodConfig(m3iMthd,modelName)



    mthdArgs=m3iMthd.Arguments;


    argSignatureStr='';
    argInvokeStr='';
    argTypeStr='';



    retTypesEmpty=true;
    retTypesArr={};
    arrContType=get_param(modelName,'ArrayContainerType');
    retArgNames={};

    for jj=1:mthdArgs.size()
        arg=mthdArgs.at(jj);
        if~isempty(arg.Type)
            if(arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.In)||...
                (arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut)


                if isa(arg.Type,'Simulink.metamodel.types.Matrix')&&...
                    strcmp(arrContType,'C-style array')
                    type=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getCArrayTypeName(arg.Type);
                else
                    type=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getGenCodeDataType(arg.Type);
                end
                argTypeStr=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(argTypeStr,...
                ', ',type);
                if isa(arg.Type,'Simulink.metamodel.types.Structure')
                    argSignatureStr=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(argSignatureStr,...
                    ', ',[type,' *',arg.Name]);
                    argInvokeStr=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(argInvokeStr,...
                    ', ',['*',arg.Name]);
                else
                    argSignatureStr=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(argSignatureStr,...
                    ', ',[type,' ',arg.Name]);
                    argInvokeStr=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(argInvokeStr,...
                    ', ',arg.Name);
                end
            elseif(arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out)


                if isa(arg.Type,'Simulink.metamodel.types.Matrix')&&...
                    strcmp(arrContType,'C-style array')
                    retTypesArr{end+1}=...
                    autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getCArrayTypeName(arg.Type);
                else
                    retTypesArr{end+1}=...
                    autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getGenCodeDataType(arg.Type);%#ok<*AGROW>
                end
                retArgNames{end+1}=arg.Name;
                retTypesEmpty=false;
            end
        end
    end
end



