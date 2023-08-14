classdef TransactionModule<handle








    properties(SetAccess='protected',GetAccess='protected',Hidden=true)
        isRunning=0;
        ToolChainConfiguration=[];
        MakefileTemplate=[];
    end

    properties(SetAccess='private',GetAccess='private',Hidden=true)
        Generator=[];
    end

    properties(SetAccess='public',GetAccess='public',Dependent=true)
OutputPath
    end





    methods
        function set.Generator(h,prj)
            if h.IsGeneratorObjValid()
                h.Generator.close();
            end
            h.Generator=prj;
        end
        function value=get.OutputPath(h)
            value='';
            if h.IsGeneratorObjValid()
                value=h.Generator.OutputPath;
            end
        end
        function set.OutputPath(h,value)
            if h.IsGeneratorObjValid()
                h.Generator.OutputPath=value;
            end
        end
    end

    methods(Access='public')




        function h=TransactionModule(varargin)
            try

                [pjtname,pjttype]=ParseConstructorArgs(varargin);

                h.ToolChainConfiguration=linkfoundation.xmakefile.XMakefileConfiguration.getActiveConfiguration();

                h.MakefileTemplate=linkfoundation.xmakefile.XMakefileTemplate.getActiveTemplate();

                h.NewProject(pjtname,pjttype);
            catch ex
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:TransactionModuleConstructorError'),ex);
            end
            if(isempty(h.ToolChainConfiguration))
                msg=message('ERRORHANDLER:xmakefile:TransactionModuleConstructorError');
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:EmptyToolChain',msg.getString));
            end
            if(isempty(h.MakefileTemplate))
                msg=message('ERRORHANDLER:xmakefile:TransactionModuleConstructorError');
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:EmptyTemplate',msg.getString));
            end




            function[pjtname,pjttype]=ParseConstructorArgs(args)
                pjtname=[];
                pjttype=[];
                for i=1:2:numel(args)
                    prop=lower(args{i});
                    val=args{i+1};
                    switch prop
                    case 'pjtname'
                        pjtname=val;
                    case 'pjttype'
                        pjttype=val;
                    otherwise

                    end
                end
            end
        end




        function ret=GetCurrDirectory(h)
            if h.IsGeneratorObjValid()
                ret=h.Generator.CurrentPath;
            else
                ret=pwd;
            end
        end




        function SetCurrDirectory(h,newdir)
            try
                cd(newdir);
                if h.IsGeneratorObjValid()
                    h.Generator.CurrentPath=newdir;
                end
            catch ex
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:SetCurrDirectoryError',linkfoundation.util.decoratePath(newdir)),ex);
            end
        end




        function Save(h)
            if~h.IsGeneratorObjValid()
                msg=message('ERRORHANDLER:xmakefile:SaveError');
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:MakefileNotInitialized',msg.getString));
            end
            try
                if(~h.Generator.create())
                    linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:SaveError'));
                end
            catch ex
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:SaveError'),ex);
            end
        end




        function Run(h,timeout)
            if~h.IsGeneratorObjValid()
                msg=message('ERRORHANDLER:xmakefile:RunError');
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:MakefileNotInitialized',msg.getString));
            end
            try
                [result,output,~]=h.Generator.run(timeout);
            catch ex
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:RunError'),ex);
            end
            if(result)
                if(~isempty(output))





                    output=linkfoundation.util.decoratePath(output);
                end
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:RunErrorWithResult',output));
            end
        end




        function Halt(h,timeout)%#ok<INUSD>
            try

                h.isRunning=0;
            catch ex
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:HaltError'),ex);
            end
        end




        function AddFileToProject(h,filename)
            if~h.IsGeneratorObjValid()
                msg=message('ERRORHANDLER:xmakefile:AddFileToProjectError',linkfoundation.util.decoratePath(filename));
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:MakefileNotInitialized',msg.getString));
            end
            try
                h.Generator.addFile(filename);
            catch ex
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:AddFileToProjectError',linkfoundation.util.decoratePath(filename)),ex);
            end
        end




        function RemoveFileFromProject(h,filename)
            try
                h.Generator.removeFile(filename);
            catch ex
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:RemoveFileFromProjectError',linkfoundation.util.decoratePath(filename)),ex);
            end
        end






        function NewProject(h,pjtname,pjttype)

            if(~isempty(pjtname)&&~isempty(pjttype))
                try
                    h.Generator=linkfoundation.xmakefile.createXMakefileGenerator(h.ToolChainConfiguration,h.MakefileTemplate,pjtname,pjttype);
                catch ex
                    linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:NewProjectError'),ex);
                end
            end
        end




        function NewConfig(h,name)
            if~h.IsGeneratorObjValid()
                msg=message('ERRORHANDLER:xmakefile:NewConfigError');
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:MakefileNotInitialized',msg.getString));
            end
            h.Generator.BuildConfiguration=name;
        end




        function ret=IsRunning(h)
            try
                ret=h.isRunning;
            catch ex
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:IsRunningError'),ex);
            end
        end




        function ret=Build(h,buildall,timeout)
            if~h.IsGeneratorObjValid()
                msg=message('ERRORHANDLER:xmakefile:BuildError');
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:MakefileNotInitialized',msg.getString));
            end
            try
                [result,output,~]=h.Generator.build(buildall,timeout);
                ret={result;0;output};
            catch ex
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:BuildError'),ex);
            end
            if(result)
                if(~isempty(output))





                    output=linkfoundation.util.decoratePath(output);
                end
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:BuildErrorWithResult',output));
            end
        end




        function SetProjBuildOption(h,tool,option)
            if~h.IsGeneratorObjValid()
                msg=message('ERRORHANDLER:xmakefile:SetProjBuildOptionError');
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:MakefileNotInitialized',msg.getString));
            end
            try
                if(strcmpi('linker',tool))
                    h.Generator.addLinkerFlags(option);
                elseif(strcmpi('compiler',tool))
                    h.Generator.addCompilerFlags(option);
                else
                    linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:UnrecognizedBuildTool',tool));
                end
            catch ex
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:SetProjBuildOptionError'),ex);
            end
        end










        function value=GetConfigurationInstallDir(h)
            try
                if h.IsGeneratorObjValid()
                    value=h.Generator.getConfigurationInstallDir();
                else
                    config=linkfoundation.xmakefile.XMakefileConfiguration.getConfiguration(h.ToolChainConfiguration);
                    value=config.InstallPath;
                end
            catch ex
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:GetConfigurationInstallDirError'),ex);
            end
        end







        function value=GetFileExtension(h,fileType)
            try
                if h.IsGeneratorObjValid()
                    value=h.Generator.getFileExtension(fileType);
                else
                    template=linkfoundation.xmakefile.XMakefileTemplate.getTemplate(h.MakefileTemplate);
                    value=template.GeneratedFileExtension;
                end
            catch ex
                linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:GetFileExtensionError',fileType),ex);
            end
        end




        function type=GetFileTypeBasedOnExtension(h)%#ok<MANU>
            type=linkfoundation.xmakefile.XMakefileGenerator.getFileTypeBasedOnExtension(regname,represent);
        end
    end






    methods(Access='public')

        function ClearAllRequests(h)
            h.InvokeNoopMethod('ClearAllRequests');
        end

        function TargetConnect(h,timeout)%#ok<INUSD>
            h.InvokeNoopMethod('TargetConnect');
        end

        function TargetDisConnect(h,timeout)%#ok<INUSD>
            h.InvokeNoopMethod('TargetDisConnect');
        end

        function ret=Read(h,addrOffset,addrPage,sampledata,num,timeout)%#ok<INUSD>
            ret='';
            h.InvokeNoopMethod('Read');
        end

        function ret=Write(h,addrOffset,addrPage,data,num,timeout)%#ok<INUSD>
            ret='';
            h.InvokeNoopMethod('Write');
        end

        function ret=OpenProject(h,fileName,openoption,option,timeout)%#ok<INUSD>
            ret='';
            h.InvokeNoopMethod('OpenProject');
        end

        function ActivateProject(h,fileName)%#ok<INUSD>
            h.InvokeNoopMethod('ActivateProject');
        end

        function ActivateText(h,fileName)%#ok<INUSD>
            h.InvokeNoopMethod('ActivateText');
        end

        function ActivateConfig(h,fileName)%#ok<INUSD>
            h.InvokeNoopMethod('ActivateConfig');
        end

        function CloseProject(h,option,allfiles)%#ok<INUSD>
            h.InvokeNoopMethod('CloseProject');
        end

        function CloseAnyProject(h,option,fileName)%#ok<INUSD>
            h.InvokeNoopMethod('CloseAnyProject');
        end

        function ret=GetLastLoadedProgram(h)
            ret='';
            h.InvokeNoopMethod('GetLastLoadedProgram');
        end

        function Reset(h,timeout)%#ok<INUSD>
            h.InvokeNoopMethod('Reset');
        end

        function Restart(h,timeout)%#ok<INUSD>
            h.InvokeNoopMethod('Restart');
        end

        function ret=GetAddress(h,symbolName,symbolScope)%#ok<INUSD>
            ret='';
            h.InvokeNoopMethod('GetAddress');
        end

        function InsertBreakPointFileLine(h,fileName,lineNum,timeout)%#ok<INUSD>
            h.InvokeNoopMethod('InsertBreakPointFileLine');
        end

        function InsertBreakPointAddr(h,addrOffset,addrPage,timeout)%#ok<INUSD>
            h.InvokeNoopMethod('InsertBreakPointAddr');
        end

        function InsertProbePointFileLine(h,fileName,lineNum,timeout)%#ok<INUSD>
            h.InvokeNoopMethod('InsertProbePointFileLine');
        end

        function InsertProbePointAddr(h,addrOffset,addrPage,timeout)%#ok<INUSD>
            h.InvokeNoopMethod('InsertProbePointAddr');
        end

        function DeleteBreakPointFileLine(h,fileName,lineNum,timeout)%#ok<INUSD>
            h.InvokeNoopMethod('DeleteBreakPointFileLine');
        end

        function DeleteBreakPointAddr(h,addrOffset,addrPage,timeout)%#ok<INUSD>
            h.InvokeNoopMethod('DeleteBreakPointAddr');
        end

        function DeleteAllBreakPoints(h,timeout)%#ok<INUSD>
            h.InvokeNoopMethod('DeleteAllBreakPoints');
        end

        function DeleteProbePointFileLine(h,fileName,lineNum,timeout)%#ok<INUSD>
            h.InvokeNoopMethod('DeleteProbePointFileLine');
        end

        function DeleteProbePointAddr(h,addrOffset,addrPage,timeout)%#ok<INUSD>
            h.InvokeNoopMethod('DeleteProbePointAddr');
        end

        function ret=IsWritable(h,addrOffset,addrPage,sampledata,count)%#ok<INUSD>
            ret='';
            h.InvokeNoopMethod('IsWritable');
        end

        function ret=IsReadable(h,addrOffset,addrPage,sampledata,count)%#ok<INUSD>
            ret='';
            h.InvokeNoopMethod('IsReadable');
        end

        function ret=GetPC(h)
            ret='';
            h.InvokeNoopMethod('GetPC');
        end

        function ret=GetProjBuildOption(h)
            ret='';
            h.InvokeNoopMethod('GetProjBuildOption');
        end

        function ret=GetSpecificProjBuildOption(h,buildopt)%#ok<INUSD>
            ret='';
            h.InvokeNoopMethod('GetSpecificProjBuildOption');
        end

        function ret=GetFileBuildOption(h,fileName)%#ok<INUSD>
            ret='';
            h.InvokeNoopMethod('GetFileBuildOption');
        end

        function SetFileBuildOption(h,fileName,buildoptval)%#ok<INUSD>
            h.InvokeNoopMethod('SetFileBuildOption');
        end

        function ret=GetSymbolList(h)
            ret='';
            h.InvokeNoopMethod('GetSymbolList');
        end

        function RunToHalt(h,timeout)%#ok<INUSD>
            h.InvokeNoopMethod('RunToHalt');
        end

        function ToHalt(h,timeout)%#ok<INUSD>
            h.InvokeNoopMethod('ToHalt');
        end
    end

    methods(Access='private',Hidden=true)
        function ret=IsGeneratorObjValid(h)
            ret=isa(h.Generator,'linkfoundation.xmakefile.XMakefileGenerator');
        end
        function InvokeNoopMethod(h,methodName)
            try

            catch ex
                linkfoundation.xmakefile.raiseException(...
                message('ERRORHANDLER:xmakefile:UnusedMethodError',methodName),ex);
            end
        end
    end

end

