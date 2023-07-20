function compilerInfo=compilerman(method,isCpp)




    persistent sCompilerInfo sCompilerInfoCpp;
    if nargin<2
        isCpp=false;
    end

    switch(method)
    case 'get_compiler_info'
        if isCpp
            if isempty(sCompilerInfoCpp)
                sCompilerInfoCpp=compute_compiler_info(isCpp);
            end
        else
            if isempty(sCompilerInfo)
                sCompilerInfo=compute_compiler_info(isCpp);
            end
        end
    case 'reset_compiler_info'
        sCompilerInfo=[];
        sCompilerInfoCpp=[];
    otherwise
        error('Incorrect compiler option');
    end

    if isCpp
        compilerInfo=sCompilerInfoCpp;
    else
        compilerInfo=sCompilerInfo;
    end


    function compilerInfo=compute_compiler_info(isCpp)

        if sfpref('UseLCC64')&&ispc&&~isCpp
            compilerInfo=set_compiler_info('lcc');
            return;
        end

        supportedCompilers=cgxeprivate('supportedPCCompilers');
        mexCC=get_selected_compiler_config(isCpp);

        if isempty(mexCC)||(ispc&&~any(strcmpi(supportedCompilers,mexCC.ShortName)))
            if ispc
                compilerInfo=set_compiler_info('lcc');
            else
                compilerInfo=set_compiler_info('');
            end
        else
            compilerInfo.compilerName=lower(mexCC.ShortName);
            compilerInfo.mexSetEnv=mexCC.Details.SetEnv;
            compilerInfo.compilerFullName=mexCC.Name;
            compilerInfo.MexOpt=mexCC.MexOpt;
            compilerInfo.isCpp=isCpp;
            compilerInfo.Details=mexCC.Details;
        end


        function mexCC=get_selected_compiler_config(isCpp)

            try

                if isCpp
                    mexCC=mex.getCompilerConfigurations('C++','Selected');
                else
                    mexCC=mex.getCompilerConfigurations('C','Selected');
                end


                if numel(mexCC)>1
                    mexCC=mexCC(1);
                end
            catch
                mexCC=[];
            end


            function compilerInfo=set_compiler_info(name)
                compilerInfo.compilerName=name;
                compilerInfo.compilerFullName=name;
                compilerInfo.mexSetEnv='';
                compilerInfo.MexOpt='';
                compilerInfo.isCpp=false;
                compilerInfo.Details=[];


