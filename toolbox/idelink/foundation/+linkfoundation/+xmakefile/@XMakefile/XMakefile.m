classdef XMakefile<linkfoundation.autointerface.baselink






















































    properties(SetAccess='public',GetAccess='public',Dependent=true)
OutputPath
    end

    properties(SetAccess='protected')
        apiversion=0;
    end




    methods(Static=true,Access='private')





        function envMessage=getEnvironmentMessage()
            if(ispc())
                tool=linkfoundation.util.Executable('set');
            else
                tool=linkfoundation.util.Executable('env');
            end
            [~,output]=tool.execute();
            envMessage=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_env_info_template',output);
        end





        function cfgMessage=getConfigurationMessage()
            activeConfiguration=linkfoundation.xmakefile.XMakefileConfiguration.getActiveConfiguration();
            activeTemplate=linkfoundation.xmakefile.XMakefileTemplate.getActiveTemplate();
            if(isempty(activeConfiguration))
                activeConfiguration=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_none');
            end
            if(isempty(activeTemplate))
                activeTemplate=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_none');
            end
            cfgMessage=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_cfg_info_template',activeConfiguration,activeTemplate);
        end
    end


    methods(Access='public')



        function h=XMakefile(varargin)
            args=varargin;
            if linkfoundation.xmakefile.XMakefile.isHostConfig
                args{end+1}='ishostonly';
                args{end+1}=1;
            end

            h=h@linkfoundation.autointerface.baselink(args{:});

            h.mIdeModule=linkfoundation.xmakefile.TransactionModule(args{:});
        end




        function save(h,~,~)
            h.mIdeModule.Save();
        end




        function info(h,opt)
            disp(linkfoundation.xmakefile.XMakefile.getConfigurationMessage());
            disp(linkfoundation.xmakefile.XMakefile.getEnvironmentMessage());
        end




        function disp(h)
            disp(linkfoundation.xmakefile.XMakefile.getConfigurationMessage());
        end




        function emitProject(h,aProjectBuildInfo)
            emitProject@linkfoundation.autointerface.baselink(h,aProjectBuildInfo);
            h.save();
        end




        function fileExt=ide_getFileExt(h,fileType)
            fileExt=h.mIdeModule.GetFileExtension(fileType);
        end




        function type=ide_getFileTypeBasedOnExt(h,regname,represent,~)
            type=h.mIdeModule.GetFileTypeBasedOnExtension(regname,represent);
        end




        function value=getHomeDir(h)
            value=h.mIdeModule.GetConfigurationInstallDir();
        end
    end


    methods(Access='public',Hidden=true)
        function loadProject(h,projectBuildInfo)%#ok

        end
    end


    methods(Static=true,Hidden=true)
        function ret=isHostConfig

            ret=true;
        end
    end


    methods
        function value=get.OutputPath(h)
            value=h.mIdeModule.OutputPath;
        end
        function set.OutputPath(h,value)
            h.mIdeModule.OutputPath=value;
        end
    end


    methods(Hidden=true)
        function resp=ide_readLargeData(h,address,datatype,count,timeout)%#ok<INUSD>
            errorHandlerNotReached(h);
        end
        function ide_writeLargeData(h,address,data,count,timeout)%#ok<INUSD>
            errorHandlerNotReached(h);
        end
        function proc_displayOneProc(h,tgtInfo)%#ok<INUSD>
            errorHandlerNotReached(h);
        end
        function proc_displayMultiProc(h,tgtInfo)%#ok<INUSD>
            errorHandlerNotReached(h);
        end
        function resp=proc_regread(h,regname,represent,timeout)%#ok<INUSD>
            errorHandlerNotReached(h);
        end
        function resp=proc_regwrite(h,regname,represent,timeout)%#ok<INUSD>
            errorHandlerNotReached(h);
        end
        function ext=ide_hitok(h)%#ok<STOUT>
            errorHandlerNotReached(h);
        end
        function resp=ide_getBuildOptionNames(h)
            errorHandlerNotReached(h);
        end
        function addr=ide_getCompleteAddress(h,addr)
            errorHandlerNotReached(h);
        end
        function ext=ide_ifReadWriteSizeLimitReached(h,excep)%#ok<INUSD>
            errorHandlerNotReached(h);
        end
    end

end

