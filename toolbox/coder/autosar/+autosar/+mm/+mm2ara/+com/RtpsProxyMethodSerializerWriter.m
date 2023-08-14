function RtpsProxyMethodSerializerWriter(filePath,intfName,mthdList,modelName)






    codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
    true,'filename',filePath,'append',true);

    codeWriter.wBlockStart('namespace proxy_io');

    for ii=1:numel(mthdList)
        m3iMthd=mthdList{ii};
        mthdArgs=m3iMthd.Arguments;


        codeWriter.wBlockStart(['class ',intfName,'_',m3iMthd.Name,'_mthd_t']);
        codeWriter.wLine('public:');

        [argTypStr,retArgTypeStr]=GetMethodParameterInfo(m3iMthd,modelName);
        codeWriter.wBlockStart(['static std::string GetSerializedPayload(',argTypStr,')']);
        sizeCode='';
        argStr='';
        lambdaNum=0;
        for jj=1:mthdArgs.size()
            arg=mthdArgs.at(jj);
            if~isempty(arg.Type)&&...
                ((arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.In)||...
                (arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut))


                arrContType=get_param(modelName,'ArrayContainerType');
                [tSizeCode,lambdaNum]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.GenerateArgSerializationRoutine(...
                codeWriter,arg.Type,arg.Name,['strarg_',num2str(jj)],isa(arg.Type,'Simulink.metamodel.types.Matrix')&&...
                strcmp(arrContType,'C-style array'),lambdaNum);
                sizeCode=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(sizeCode,' + ',...
                tSizeCode);



                argStr=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(argStr,...
                ' + ',['strarg_',num2str(jj)]);
            end
        end
        if isempty(argStr)
            codeWriter.wLine('return std::string{""};');
        else
            codeWriter.wLine(['return ',argStr,';']);
        end
        codeWriter.wBlockEnd();


        codeWriter.wBlockStart('static size_t GetSizeOfMethodArgs()');
        if isempty(sizeCode)
            codeWriter.wLine('return 0;');
        else
            codeWriter.wLine(['return ',sizeCode,';']);
        end
        codeWriter.wBlockEnd();


        codeWriter.wBlockStart('static std::string GetMethodName()');
        codeWriter.wLine(['return std::string{"',m3iMthd.Name,'"};']);
        codeWriter.wBlockEnd();


        if~(m3iMthd.FireAndForget||isempty(retArgTypeStr))

            codeWriter.wBlockStart('template <typename T> static T GetDeserializedPayload(std::string sPayload)');
            codeWriter.wLine('size_t stPos{0};');
            codeWriter.wLine('T res;');
            sizeCode='';
            resSubscript=0;
            codeWriter.wBlockStart('if(!sPayload.empty())')
            for jj=1:mthdArgs.size()
                arg=mthdArgs.at(jj);
                if~isempty(arg.Type)&&...
                    ((arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out)||...
                    (arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut))




                    arrContType=get_param(modelName,'ArrayContainerType');
                    [tSizeCode,lambdaNum]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.GenerateArgDeserializationRoutine(...
                    codeWriter,arg.Type,['arg_',num2str(jj)],'stPos','sPayload',isa(arg.Type,'Simulink.metamodel.types.Matrix')&&...
                    strcmp(arrContType,'C-style array'),lambdaNum);
                    sizeCode=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(sizeCode,' + ',...
                    tSizeCode);
                    codeWriter.wLine(['res.',arg.Name,' = arg_',num2str(jj),';']);
                    resSubscript=resSubscript+1;
                end
            end
            codeWriter.wBlockEnd();
            codeWriter.wLine('return res;');
            codeWriter.wBlockEnd();


            codeWriter.wBlockStart('static size_t GetSizeOfMethodReturnArgs()');
            if isempty(sizeCode)
                codeWriter.wLine('return 0;');
            else
                codeWriter.wLine(['return ',sizeCode,';']);
            end
            codeWriter.wBlockEnd();
        end

        codeWriter.wBlockEnd();
        codeWriter.wLine(';');
    end

    codeWriter.wBlockEnd('namespace proxy_io');

    codeWriter.close();
end

function[argTypStr,retArgTypeStr]=GetMethodParameterInfo(m3iMthd,modelName)


    mthdArgs=m3iMthd.Arguments;


    argTypStr='';
    retArgTypeStr='';
    for jj=1:mthdArgs.size()
        arg=mthdArgs.at(jj);
        if~isempty(arg.Type)


            arrContType=get_param(modelName,'ArrayContainerType');
            if isa(arg.Type,'Simulink.metamodel.types.Matrix')&&...
                strcmp(arrContType,'C-style array')
                type=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getCArrayTypeName(arg.Type);
            else
                type=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getGenCodeDataType(arg.Type);
            end
            if(arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.In)||...
                (arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut)
                argTypStr=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(argTypStr,...
                ', ',[type,' ',arg.Name]);
            end
            if(arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out)||...
                (arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut)
                retArgTypeStr=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(retArgTypeStr,...
                ', ',type);
            end
        end
    end
end


