classdef hasUserImplementation


%#codegen

    methods(Static)
        function flag=do(className,methodName)
            coder.allowpcode('plain');
            coder.extrinsic('matlab.system.coder.hasUserImplementation.impl');
            flag=coder.const(matlab.system.coder.hasUserImplementation.impl(className,methodName));
        end

        function flag=impl(className,methodName)
            infrastructureClasses={...
            'matlab.system.SystemImpl',...
            'matlab.system.SystemAdaptor',...
            'matlab.system.SystemAdaptorSFun',...
            'matlab.system.SystemAdaptorCoreBlock',...
            'matlab.system.SystemProp',...
            'matlab.system.SystemAttributes',...
            'matlab.system.SystemInterface',...
            'matlab.System'};


            mc=matlab.system.coder.hasUserImplementation.getMetaClassFromClassName(className);
            m_original=findobj(mc.MethodList,'Name',methodName);
            assert(~isempty(m_original),'Impl must be found in original class.');
            m_original_is_user_defined=~any(strcmp(m_original.DefiningClass.Name,infrastructureClasses));


            re_mc=matlab.system.coder.hasUserImplementation.checkCodeGenRedirectionAndFindTarget(mc);
            if~isempty(re_mc)&&(re_mc<?matlab.system.SystemImpl||re_mc<?matlab.system.coder.System)


                m_redirect=findobj(re_mc.MethodList,'Name',methodName);
                m_redirect_is_user_defined=~isempty(m_redirect)&&~any(strcmp(m_redirect.DefiningClass.Name,infrastructureClasses));




                if~m_original_is_user_defined||...
                    (m_redirect_is_user_defined&&strcmp(m_redirect.DefiningClass.Name,m_original.DefiningClass.Name))
                    flag=m_redirect_is_user_defined;
                    return;
                end
            end

            flag=m_original_is_user_defined;
        end

        function mc=getMetaClassFromClassName(className)
            wrappedClassName=matlab.system.coder.getWrappedSFunObjectName.do(className);
            if isempty(wrappedClassName)
                mc=meta.class.fromName(className);
            else
                mc=meta.class.fromName(wrappedClassName);
            end
        end

        function re_mc=checkCodeGenRedirectionAndFindTarget(mc)





            if matlab.system.coder.hasUserImplementation.hasMatlabCodegenRedirect(mc)
                re_mc=matlab.system.coder.hasUserImplementation.getCodegenRedirectedMetaClass(mc);
            else
                re_mc=[];
            end
        end

        function flag=hasMatlabCodegenRedirect(mc)


            re_method=findobj(mc.MethodList,'Name','matlabCodegenRedirect');
            flag=(~isempty(re_method)&&strcmp(re_method.Access,'public')&&re_method.Static);

            assert(isempty(re_method)||...
            (length(re_method.OutputNames)==1&&length(re_method.InputNames)==1),...
            ['matlabCodegenRedirect method in ',mc.Name,' must define 1 input and 1 output.']);
        end

        function re_mc=getCodegenRedirectedMetaClass(mc)









            re_method=findobj(mc.MethodList,'Name','matlabCodegenRedirect');
            re_mc=meta.class.fromName(feval([mc.Name,'.',re_method.Name],coder.target));
        end

    end
end


