function validateEnumType(aEnumName)



    try
        mClass=meta.class.fromName(aEnumName);
        if isempty(mClass)
            error(message('Coder:builtins:UndefinedFunctionOrVariable',aEnumName));
        end


        allowPackages=true;
        [isValid,msg]=coder.internal.isSupportedEnumClass(mClass,allowPackages);
        assert(isValid,msg);

        methodNames={'addClassNameToEnumNames','getDefaultValue','getHeaderFile'};
        checkFcns={@checkAddClassNameToEnumNames,@checkGetDefaultValue,@checkGetHeaderFile};
        checkMap=containers.Map(methodNames,checkFcns,'UniformValues',true);

        for k=1:numel(methodNames)
            methodName=methodNames{k};
            checkStaticFcn(aEnumName,methodName,mClass,checkMap(methodName));
        end
    catch ME
        throwAsCaller(ME);
    end



    function checkStaticFcn(aEnumName,aMethodName,aMclass,aCheckFcn)


        cMethod=findobj(aMclass.MethodList,'Name',aMethodName,'Static',true);
        if~isempty(cMethod)
            res=checkedInvoke(aEnumName,aMethodName);
            aCheckFcn(aEnumName,res);
        end



        function res=checkedInvoke(aEnumName,aMethodName)


            try
                res=feval([aEnumName,'.',aMethodName]);
            catch ME
                exc=MException('Coder:builtins:ClassdefEnumStaticMethod',...
                message('Coder:builtins:ClassdefEnumStaticMethod',aEnumName,aMethodName,ME.message).getString());
                throwAsCaller(exc);
            end



            function checkAddClassNameToEnumNames(aEnumName,aVal)
                assert(isscalar(aVal)&&islogical(aVal),...
                message('Coder:builtins:ClassdefEnumBadPrefixFlag',aEnumName));



                function checkGetDefaultValue(aEnumName,aVal)
                    assert(isscalar(aVal)&&isa(aVal,aEnumName),...
                    message('Coder:builtins:ClassdefBadEnumDefaultValue',...
                    aEnumName,aEnumName,class(aVal),numel(aVal)));



                    function checkGetHeaderFile(aEnumName,aVal)
                        assert(ischar(aVal)||(isscalar(aVal)&&isstring(aVal)),...
                        message('Coder:builtins:ClassdefEnumBadHeader',aEnumName));


