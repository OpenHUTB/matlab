function RtpsSkeletonMethodSerializerWriter(skeletonClassName,filePath,mthdList)






    codeWriter=rtw.connectivity.CodeWriter.create('callCBeautifier',...
    true,'filename',filePath,'append',true);

    codeWriter.wBlockStart('namespace skeleton_io');

    codeWriter.wBlockStart(['class ',skeletonClassName,'_mthd_dispatcher_t']);
    codeWriter.wLine('public:');


    methodsMap=GenerateDispatchFunctionForMethods(codeWriter,mthdList);



    GenerateMethodConfigFunction(codeWriter,methodsMap);

    codeWriter.wBlockEnd();
    codeWriter.wLine(';');

    codeWriter.wBlockEnd('namespace skeleton_io');

    codeWriter.close();
end

function methodsMap=GenerateDispatchFunctionForMethods(codeWriter,skeletonMethodList)




    if numel(skeletonMethodList)
        codeWriter.wBlockStart(['template <typename T> static void Dispatch(T* skelPtr,'...
        ,' std::string& aMethodName, std::string& sPayload, std::string& '...
        ,'sRetVal, size_t& nRetValSize)']);
    else
        codeWriter.wBlockStart(['template <typename T> static void Dispatch(T* /*skelPtr*/,'...
        ,' std::string& aMethodName, std::string& /*sPayload*/, std::string& '...
        ,'/*sRetVal*/, size_t& /*nRetValSize*/)']);
    end

    codeWriter.wBlockStart('if(aMethodName == std::string(""))');

    methodsMap=containers.Map;

    for ii=1:numel(skeletonMethodList)
        m3iMthd=skeletonMethodList{ii};
        mthdArgs=m3iMthd.Arguments;

        codeWriter.wBlockMiddle(['else if(aMethodName == std::string("',m3iMthd.Name,'"))']);

        argStr='';
        sizeCode='';
        outTypesEmpty=true;
        codeWriter.wLine('size_t stPos{0};');
        lambdaNum=0;
        for jj=1:mthdArgs.size()
            arg=mthdArgs.at(jj);
            if~isempty(arg.Type)
                if(arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.In)||...
                    (arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut)




                    [tSizeCode,lambdaNum]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.GenerateArgDeserializationRoutine(...
                    codeWriter,arg.Type,['arg_',num2str(jj)],'stPos','sPayload',false,lambdaNum);
                    sizeCode=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(sizeCode,' + ',...
                    tSizeCode);


                    argStr=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(argStr,...
                    ', ',['arg_',num2str(jj)]);
                end
                if(arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out)||...
                    (arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut)
                    outTypesEmpty=false;
                end
            end
        end


        methodsMap(m3iMthd.Name)=struct('FireForget',(m3iMthd.FireAndForget||...
        outTypesEmpty),'ArgSize',sizeCode);


        if~(m3iMthd.FireAndForget||outTypesEmpty)

            codeWriter.wLine(['ara::core::Future<typename T::',m3iMthd.Name...
            ,'Output> retFuture = skelPtr->',m3iMthd.Name,'(',argStr,');']);
            codeWriter.wLine(['typename T::',m3iMthd.Name,'Output mthdOutput = retFuture.get();']);
            sizeCode='';
            retStr='';
            for jj=1:mthdArgs.size()
                arg=mthdArgs.at(jj);
                if~isempty(arg.Type)&&...
                    ((arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out)||...
                    (arg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut))
                    [tSizeCode,lambdaNum]=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.GenerateArgSerializationRoutine(...
                    codeWriter,arg.Type,['mthdOutput.',arg.Name],['strarg_',num2str(jj)],false,lambdaNum);
                    sizeCode=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(sizeCode,' + ',...
                    tSizeCode);



                    retStr=autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.cleanAppendSizeCode(retStr,...
                    ' + ',['strarg_',num2str(jj)]);
                end
            end
            codeWriter.wLine(['sRetVal = ',retStr,';']);
            codeWriter.wLine(['nRetValSize = ',sizeCode,';']);
        else

            codeWriter.wLine(['skelPtr->',m3iMthd.Name,'(',argStr,');']);
        end
    end
    codeWriter.wBlockMiddle('else');
    codeWriter.wBlockEnd();

    codeWriter.wBlockEnd();
end

function GenerateMethodConfigFunction(codeWriter,methodsMap)






    codeWriter.wBlockStart('static std::map<std::string, std::tuple<bool, size_t>> GetMethodConfig()');
    codeWriter.wLine('std::map<std::string, std::tuple<bool, size_t>> tConfig;');



    keys=methodsMap.keys;
    for ii=1:numel(keys)
        val=methodsMap(keys{ii});
        if(val.FireForget)
            returnBool='false';
        else
            returnBool='true';
        end

        if isempty(val.ArgSize)
            valArgSize='0';
        else
            valArgSize=val.ArgSize;
        end

        codeWriter.wLine(['tConfig[std::string{"',keys{ii},'"}] = {',returnBool,', ',valArgSize,'};']);
    end

    codeWriter.wLine('return tConfig;');
    codeWriter.wBlockEnd();
end


