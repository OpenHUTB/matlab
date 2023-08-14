function ARAComSkeletonImplClassWriter(codeWriter,skeletonClassName,...
    skeletonMethodList)





    codeWriter.wBlockStart(['class ',skeletonClassName,'Impl : public ',skeletonClassName]);
    codeWriter.wLine('public:');


    codeWriter.wBlockStart([skeletonClassName,'Impl'...
    ,'(ara::com::InstanceIdentifier instance, ara::com::MethodCallProcessingMode'...
    ,' mode = ara::com::MethodCallProcessingMode::kEvent): '...
    ,skeletonClassName,'(instance, mode)']);
    codeWriter.wBlockEnd();


    codeWriter.wBlockStart([skeletonClassName,'Impl'...
    ,'(ara::core::InstanceSpecifier instanceSpec, ara::com::MethodCallProcessingMode'...
    ,' mode = ara::com::MethodCallProcessingMode::kEvent): '...
    ,skeletonClassName,'(instanceSpec, mode)']);
    codeWriter.wBlockEnd();


    GenerateConcreteFunctions(codeWriter,skeletonMethodList);


    for ii=1:numel(skeletonMethodList)
        m3iMthd=skeletonMethodList{ii};
        funArgTypeStr=generateFunctionObjType(m3iMthd);
        codeWriter.wBlockStart(['void setFuncObj',m3iMthd.Name,'(',funArgTypeStr,' f)']);
        codeWriter.wLine(['funcObj',m3iMthd.Name,' = f;']);
        codeWriter.wBlockEnd();
    end

    codeWriter.wLine('private:');

    for ii=1:numel(skeletonMethodList)
        m3iMthd=skeletonMethodList{ii};
        funArgTypeStr=generateFunctionObjType(m3iMthd);
        codeWriter.wLine([funArgTypeStr,' funcObj',m3iMthd.Name,';']);
    end

    codeWriter.wBlockEnd();
    codeWriter.wLine(';');
end

function retStr=generateFunctionObjType(m3iMthd)

    argStr=[];
    mthdArgs=m3iMthd.Arguments;

    for jj=1:mthdArgs.size()
        arg=mthdArgs.at(jj);
        type='';
        if~isempty(arg.Type)


            isOutputDirection=((arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out)||...
            (arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut));
            if isa(arg.Type,'Simulink.metamodel.types.Matrix')
                type=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getCArrayTypeName(arg.Type,isOutputDirection);
            else
                type=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getGenCodeDataType(arg.Type);
            end
            if isOutputDirection&&~isa(arg.Type,'Simulink.metamodel.types.Matrix')
                type=[type,'*'];%#ok<*AGROW>
            end
        end
        argStr=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(argStr,...
        ', ',type);
    end

    retStr=['std::function<void(',argStr,')>'];
end

function GenerateConcreteFunctions(codeWriter,skeletonMethodList)


    for ii=1:numel(skeletonMethodList)
        m3iMthd=skeletonMethodList{ii};
        mthdArgs=m3iMthd.Arguments;


        argStr=[];
        argInvokeStr=[];
        inOutArgAssignments={};



        outTypesEmpty=true;
        outTypeIndex=0;
        for jj=1:mthdArgs.size()
            arg=mthdArgs.at(jj);
            if~isempty(arg.Type)
                if(arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.In)||...
                    (arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut)


                    if isa(arg.Type,'Simulink.metamodel.types.Matrix')
                        argName=[arg.Name,'.data()'];
                    else
                        argName=arg.Name;
                    end

                    type=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getGenCodeDataType(arg.Type);
                    argStr=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(argStr,...
                    ', ',[type,' ',arg.Name]);
                    if(arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.In)
                        argInvokeStr=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(argInvokeStr,...
                        ', ',argName);
                    else





                        inOutArgAssignments{end+1}=['retVal.result_',num2str(outTypeIndex),' = ',arg.Name,';'];
                    end
                end
                if(arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out)||...
                    (arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut)


                    if isa(arg.Type,'Simulink.metamodel.types.Matrix')
                        argName=['retVal.',arg.Name,'.data()'];
                    else
                        argName=['&retVal.',arg.Name];
                    end
                    outTypeIndex=outTypeIndex+1;



                    argInvokeStr=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(argInvokeStr,...
                    ', ',argName);
                    outTypesEmpty=false;
                end
            end
        end

        if m3iMthd.FireAndForget||outTypesEmpty
            codeWriter.wBlockStart(['virtual void ',m3iMthd.Name,'(',argStr,')']);
            codeWriter.wBlockStart(['if (funcObj',m3iMthd.Name,')']);
            codeWriter.wLine(['funcObj',m3iMthd.Name,'(',argInvokeStr,');']);
            codeWriter.wBlockEnd();
        else
            codeWriter.wBlockStart(['virtual ara::core::Future<',m3iMthd.Name,'Output> '...
            ,m3iMthd.Name,'(',argStr,') ']);
            codeWriter.wLine([m3iMthd.Name,'Output retVal;']);

            if~isempty(inOutArgAssignments)
                for jj=1:numel(inOutArgAssignments)
                    codeWriter.wLine(inOutArgAssignments{jj});
                end
            end
            codeWriter.wBlockStart(['if (funcObj',m3iMthd.Name,')']);
            codeWriter.wLine(['funcObj',m3iMthd.Name,'(',argInvokeStr,');']);
            codeWriter.wBlockEnd();
            codeWriter.wLine(['ara::core::Promise<',m3iMthd.Name,'Output> mthdPrm;']);
            codeWriter.wLine('mthdPrm.set_value(retVal);');
            codeWriter.wLine('return mthdPrm.get_future();');
        end
        codeWriter.wBlockEnd();
    end
end


