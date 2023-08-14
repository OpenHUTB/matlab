classdef XMakefileGenerator<linkfoundation.util.File






    properties(Constant=true)
        EXECUTABLE=0;
        LIBRARY=1;
        MAKEFILE_WORKSPACE_EXTENSION='.wks';
    end

    properties(Access='protected')
        DirtyFlag=true;
        CodeGenCompilerFlags='';
        CodeGenLinkerFlags='';
        Template=[];
        Configuration=[];
        Type=linkfoundation.xmakefile.XMakefileGenerator.EXECUTABLE;
        Files=[];
        FilesOrder=[];
        MakeUtility=[];
        MakeFile=[];
        CompilerTool=[];
        LinkerTool=[];
        PrebuildTool=[];
        PostbuildTool=[];
        ExecuteTool=[];
        PILTool=[];
    end

    properties(Access='protected',Dependent=true)
SourceFiles
HeaderFiles
LibraryFiles
SkippedFiles
    end

    properties(Access='public',Dependent=true)
OutputPath
BuildConfiguration
CurrentPath
    end

    methods(Access='private')

        function[result,output,warnings]=evaluate(h)

            if(h.generateMakefile())

                [result,output,warnings]=h.execute();



                h.unloadConfiguration();
            end
        end


        function files=filterByFileExtensions(h,fileExtensions)
            tokens=textscan(fileExtensions,'%s','Delimiter',',','MultipleDelimsAsOne',1);
            extensions=tokens{1,1};
            expression='';
            for index=1:length(extensions)
                extension=extensions{index};
                if('.'==extension(1))
                    extension=extension(2:end);
                end
                if(isempty(expression))
                    expression=sprintf('[\\.]?%s$',extension);
                else
                    expression=sprintf('%s|[\\.]?%s$',expression,extension);
                end
            end
            v=h.Files.values;
            files={};
            for index=1:length(v)
                if(~isempty(regexp(v{index}.Extension,expression,'once')))
                    files{length(files)+1}=v{index}.FullPathName;%#ok
                end
            end
        end


        function loadConfiguration(h)




            context=linkfoundation.xmakefile.XMakefileConfigurationEvent.ARCHIVE_TARGET_BEFORE_BUILD;
            if(linkfoundation.xmakefile.XMakefileGenerator.EXECUTABLE==h.Type)
                context=linkfoundation.xmakefile.XMakefileConfigurationEvent.EXECUTABLE_TARGET_BEFORE_BUILD;
            end
            h.Configuration.reloadSettings(context,h.BuildConfiguration);
        end




        function unloadConfiguration(h)
            postContext=linkfoundation.xmakefile.XMakefileConfigurationEvent.ARCHIVE_TARGET_AFTER_BUILD;
            if(linkfoundation.xmakefile.XMakefileGenerator.EXECUTABLE==h.Type)
                postContext=linkfoundation.xmakefile.XMakefileConfigurationEvent.EXECUTABLE_TARGET_AFTER_BUILD;
            end
            h.Configuration.reloadSettings(postContext,h.BuildConfiguration);
        end









        function result=generateMakefile(h)
            result=false;
            try
                if(h.DirtyFlag||~h.MakeFile.exists())
                    h.populateTemplate();
                    fid=fopen(h.MakeFile.FullPathName,'w');
                    if(-1==fid)
                        linkfoundation.xmakefile.raiseException('XMakefileGenerator','generateMakefile','open',[],h.MakeFile.FullPathName);
                    end
                    fprintf(fid,'%s',h.Template.instantiate());
                    fclose(fid);
                end
                result=true;
                h.DirtyFlag=false;
            catch ex
                linkfoundation.xmakefile.raiseException('XMakefileGenerator','generateMakefile','',ex);
            end
        end







        function populateTemplate(h)
            try
                h.loadConfiguration();
                h.populateCodeGenData();
                h.populateToolChainData();
            catch ex
                linkfoundation.xmakefile.raiseException('XMakefileGenerator','populateTemplate','',ex);
            end
        end




        function populateCodeGenData(h)
            context=linkfoundation.xmakefile.XMakefileConfigurationEvent.ARCHIVE_TARGET_BEFORE_BUILD;
            if(linkfoundation.xmakefile.XMakefileGenerator.EXECUTABLE==h.Type)
                context=linkfoundation.xmakefile.XMakefileConfigurationEvent.EXECUTABLE_TARGET_BEFORE_BUILD;
            end
            event=linkfoundation.xmakefile.XMakefileConfigurationEvent(context,h.BuildConfiguration);
            if(isa(h.Configuration.SourceFilesOverride,'function_handle'))
                h.Template.SourceFiles=h.Template.instantiate(h.Configuration.SourceFilesOverride(h.Configuration,h.SourceFiles,event));
            else
                h.Template.SourceFiles=h.SourceFiles;
            end
            if(isa(h.Configuration.HeaderFilesOverride,'function_handle'))
                h.Template.HeaderFiles=h.Template.instantiate(h.Configuration.HeaderFilesOverride(h.Configuration,h.HeaderFiles,event));
            else
                h.Template.HeaderFiles=h.HeaderFiles;
            end
            if(isa(h.Configuration.LibraryFilesOverride,'function_handle'))
                h.Template.LibraryFiles=h.Template.instantiate(h.Configuration.LibraryFilesOverride(h.Configuration,h.LibraryFiles,event));
            else
                h.Template.LibraryFiles=h.LibraryFiles;
            end
            if(isa(h.Configuration.SkippedFilesOverride,'function_handle'))
                h.Template.SkippedFiles=h.Template.instantiate(h.Configuration.SkippedFilesOverride(h.Configuration,h.SkippedFiles,event));
            else
                h.Template.SkippedFiles=h.SkippedFiles;
            end
            if(isa(h.Configuration.CodeGenCompilerFlagsOverride,'function_handle'))
                h.Template.CodeGenCompilerArgs=h.Template.instantiate(h.Configuration.CodeGenCompilerFlagsOverride(h.Configuration,h.CodeGenCompilerFlags,event));
            else
                h.Template.CodeGenCompilerArgs=h.CodeGenCompilerFlags;
            end
            if(isa(h.Configuration.CodeGenLinkerFlagsOverride,'function_handle'))
                h.Template.CodeGenLinkerArgs=h.Template.instantiate(h.Configuration.CodeGenLinkerFlagsOverride(h.Configuration,h.CodeGenLinkerFlags,event));
            else
                h.Template.CodeGenLinkerArgs=h.CodeGenLinkerFlags;
            end


            if(isa(h.Configuration.PrebuildLineOverride,'function_handle'))
                h.Template.PrebuildLineOverride=h.Template.instantiate(h.Configuration.PrebuildLineOverride(h.Configuration,event));
            end
            if(isa(h.Configuration.CompilerLineOverride,'function_handle'))
                h.Template.CompilerLineOverride=h.Template.instantiate(h.Configuration.CompilerLineOverride(h.Configuration,event));
            end
            if(isa(h.Configuration.LinkerLineOverride,'function_handle'))
                h.Template.LinkerLineOverride=h.Template.instantiate(h.Configuration.LinkerLineOverride(h.Configuration,event));
            end
            if(isa(h.Configuration.PostbuildLineOverride,'function_handle'))
                h.Template.PostbuildLineOverride=h.Template.instantiate(h.Configuration.PostbuildLineOverride(h.Configuration,event));
            end
            if(isa(h.Configuration.ExecuteLineOverride,'function_handle'))
                h.Template.ExecuteLineOverride=h.Template.instantiate(h.Configuration.ExecuteLineOverride(h.Configuration,event));
            end
        end





        function populateToolChainData(h)


            h.MakeUtility=linkfoundation.util.Executable(h.Configuration.MakePath);
            h.CompilerTool=linkfoundation.util.Executable(h.Configuration.CompilerPath);
            h.CompilerTool.addFlags(h.Template.instantiate(h.Configuration.CompilerFlags));
            if(linkfoundation.xmakefile.XMakefileGenerator.EXECUTABLE==h.Type)
                h.LinkerTool=linkfoundation.util.Executable(h.Configuration.LinkerPath);
                h.LinkerTool.addFlags(h.Template.instantiate(h.Configuration.LinkerFlags));
                h.Template.TargetExtension=h.Configuration.TargetExtension;
                if(~isempty(h.Configuration.TargetNamePrefix))
                    h.Template.TargetNamePrefix=h.Configuration.TargetNamePrefix;
                end
                if(~isempty(h.Configuration.TargetNamePostfix))
                    h.Template.TargetNamePostfix=h.Configuration.TargetNamePostfix;
                end
            else
                h.LinkerTool=linkfoundation.util.Executable(h.Configuration.ArchiverPath);
                h.LinkerTool.addFlags(h.Template.instantiate(h.Configuration.ArchiverFlags));
                h.Template.TargetExtension=h.Configuration.ArchiveExtension;
                if(~isempty(h.Configuration.ArchiveNamePrefix))
                    h.Template.TargetNamePrefix=h.Configuration.ArchiveNamePrefix;
                end
                if(~isempty(h.Configuration.ArchiveNamePostfix))
                    h.Template.TargetNamePostfix=h.Configuration.ArchiveNamePostfix;
                end
            end
            if(h.Configuration.PrebuildEnable)
                h.PrebuildTool=linkfoundation.util.Executable(h.Configuration.PrebuildToolPath);
                h.PrebuildTool.addFlags(h.Template.instantiate(h.Configuration.PrebuildFlags));
            end
            if(h.Configuration.PostbuildEnable)
                h.PostbuildTool=linkfoundation.util.Executable(h.Configuration.PostbuildToolPath);
                h.PostbuildTool.addFlags(h.Template.instantiate(h.Configuration.PostbuildFlags));
            end
            if(~h.Configuration.ExecuteDefault)



                h.ExecuteTool=linkfoundation.util.Executable(h.Configuration.ExecuteToolPath);
                h.ExecuteTool.addFlags(h.Template.instantiate(h.Configuration.ExecuteFlags));
            end

            h.Template.ToolChainConfiguration=h.Configuration.Configuration;
            h.Template.ToolChainConfigurationVersion=h.Configuration.Version;
            if(~isempty(h.Configuration.OutputPath))
                h.Template.OutputPath=h.Template.instantiate(h.Configuration.OutputPath);
            end
            if(~isempty(h.Configuration.DerivedPath))
                h.Template.DerivedPath=h.Template.instantiate(h.Configuration.DerivedPath);
            end
            h.Template.ObjectExtension=h.Configuration.ObjectExtension;
            if(~isempty(h.Configuration.MakeInclude))
                h.Template.MakeInclude=h.Configuration.MakeInclude;
            end
            h.Template.ToolChainCompilerArgs=h.CompilerTool.CommandLine;
            h.Template.CompilerPath=h.CompilerTool.FullPathName;
            h.Template.ToolChainLinkerArgs=h.LinkerTool.CommandLine;
            h.Template.LinkerPath=h.LinkerTool.FullPathName;
            if(h.Configuration.PrebuildEnable)
                h.Template.PrebuildFeatureEnable=true;
                h.Template.PrebuildArgs=h.PrebuildTool.CommandLine;
                h.Template.PrebuildPath=h.PrebuildTool.FullPathName;
            else
                h.Template.PrebuildFeatureEnable=false;
            end
            if(h.Configuration.PostbuildEnable)
                h.Template.PostbuildFeatureEnable=true;
                h.Template.PostbuildArgs=h.PostbuildTool.CommandLine;
                h.Template.PostbuildPath=h.PostbuildTool.FullPathName;
            else
                h.Template.PostbuildFeatureEnable=false;
            end
            if(h.Configuration.ExecuteDefault)
                h.Template.ExecuteTargetFeatureEnable=true;
                h.Template.ExecuteArgs=h.Template.instantiate(h.Configuration.ExecuteFlags);
            else
                h.Template.ExecuteTargetFeatureEnable=false;
                h.Template.ExecutePath=h.ExecuteTool.FullPathName;
                h.Template.ExecuteArgs=h.ExecuteTool.CommandLine;
            end

            h.Template.Custom1=h.Template.instantiate(h.Configuration.Custom1);
            h.Template.Custom2=h.Template.instantiate(h.Configuration.Custom2);
            h.Template.Custom3=h.Template.instantiate(h.Configuration.Custom3);
            h.Template.Custom4=h.Template.instantiate(h.Configuration.Custom4);
            h.Template.Custom5=h.Template.instantiate(h.Configuration.Custom5);
        end


        function[result,output,warnings]=execute(h)
            try
                warnings=0;
                h.MakeUtility.resetCommandLine();
                h.MakeUtility.addFlags(h.Template.instantiate(h.Configuration.MakeFlags));
                if(strcmpi(h.Template.BuildAction,linkfoundation.xmakefile.XMakefileTemplate.TARGET_EXECUTE))
                    h.MakeUtility.Asynchronous=true;
                end
                [result,output]=h.MakeUtility.execute();
            catch ex
                linkfoundation.xmakefile.raiseException('XMakefileGenerator','execute','',ex);
            end
        end
    end

    methods(Access='public')
        function h=XMakefileGenerator(configuration,template,name,type)










            args={};
            if(0~=nargin)
                prjExt=linkfoundation.xmakefile.XMakefileGenerator.MAKEFILE_WORKSPACE_EXTENSION;
                prjName=linkfoundation.util.File.replaceFileExtension(name,prjExt);
                args{1}=prjName;
            end
            h=h@linkfoundation.util.File(args{:});
            if(0~=nargin)
                if(isempty(name)||isempty(configuration)||isempty(template)||~linkfoundation.xmakefile.XMakefileGenerator.isValidProjectType(type))
                    linkfoundation.xmakefile.raiseException('XMakefileGenerator','XMakefileGenerator','');
                end
                [~,name,ext]=fileparts(name);
                if isempty(ext)
                    ext=template.GeneratedFileExtension;
                end
                h.MakeFile=linkfoundation.util.File([name,ext]);
                h.Template=template;
                h.Template.reset();
                h.Template.ModelName=h.MakeFile.Name;
                h.Template.GeneratedFileName=h.MakeFile.FullPathName;
                h.Configuration=configuration;
                h.Type=type;
                h.Files=containers.Map();
                h.FilesOrder=containers.Map();
            end
        end








        function addFile(h,name)
            file=linkfoundation.util.File(name);
            if(isempty(file.Path))
                file.Path=h.CurrentPath;
            end
            tokens=textscan(h.Configuration.HeaderExtensions,'%s','Delimiter',',','MultipleDelimsAsOne',1);
            extensions=tokens{1,1};
            for index=1:length(extensions)
                extension=extensions{index};
                if('.'~=extension(1))
                    extension=['.',extension];%#ok
                end
                hFile=linkfoundation.util.File(linkfoundation.util.File.replaceFileExtension(file.FullPathName,extension));
                if(hFile.exists)
                    h.Files(hFile.FullPathName)=hFile;
                end
            end
            h.Files(file.FullPathName)=file;
            h.FilesOrder(file.FullPathName)=length(h.Files);
            h.DirtyFlag=true;
        end


        function removeFile(h,name)
            file=linkfoundation.util.File(name);
            if(h.Files.isKey(file.FullPathName))
                h.Files.remove(file.FullPathName);
                h.FilesOrder.remove(file.FullPathName);
                h.DirtyFlag=true;
            end
        end


        function addCompilerFlags(h,flags)
            if(isempty(flags))
                return;
            end
            h.CodeGenCompilerFlags=sprintf('%s%s',h.CodeGenCompilerFlags,strrep(flags,'\','/'));
            h.DirtyFlag=true;
        end


        function addLinkerFlags(h,flags)
            if(isempty(flags))
                return;
            end
            h.CodeGenLinkerFlags=sprintf('%s%s',h.CodeGenLinkerFlags,strrep(flags,'\','/'));
            h.DirtyFlag=true;
        end

        function close(~)
        end

        function value=create(h)
            value=h.generateMakefile();
            if(value)



                h.unloadConfiguration();
            end
        end

        function[result,output,warnings]=build(h,~,~)
            h.Template.BuildAction=linkfoundation.xmakefile.XMakefileTemplate.TARGET_BUILD;
            [result,output,warnings]=h.evaluate();
        end

        function[result,output,warnings]=run(h,~)
            h.Template.BuildAction=linkfoundation.xmakefile.XMakefileTemplate.TARGET_EXECUTE;
            [result,output,warnings]=h.evaluate();
        end




        function value=getConfigurationInstallDir(h)
            value=h.Configuration.InstallPath;
        end




        function fileExt=getFileExtension(h,fileType)
            switch lower(fileType)
            case 'workspace'
                fileExt=linkfoundation.xmakefile.XMakefileGenerator.MAKEFILE_WORKSPACE_EXTENSION;
            case{'project','projext','projlib'}
                fileExt=h.Template.GeneratedFileExtension;
            case 'program'
                fileExt=h.Template.TargetExtension;
                if(isempty(fileExt))
                    fileExt=h.Configuration.TargetExtension;
                end
            case 'library'
                fileExt=h.Template.TargetExtension;
                if(isempty(fileExt))
                    fileExt=h.Configuration.LibraryExtensions;
                end
            otherwise
                linkfoundation.xmakefile.raiseException('XMakefileGenerator','getFileExtension','');
            end
        end
    end

    methods(Static=true)


        function test=isValidProjectType(type)
            switch(type)
            case linkfoundation.xmakefile.XMakefileGenerator.EXECUTABLE
                test=true;
            case linkfoundation.xmakefile.XMakefileGenerator.LIBRARY
                test=true;
            otherwise
                test=false;
            end
        end
    end

    methods

        function files=get.SourceFiles(h)
            files=h.filterByFileExtensions(h.Configuration.SourceExtensions);
        end

        function files=get.HeaderFiles(h)
            files=h.filterByFileExtensions(h.Configuration.HeaderExtensions);
        end

        function files=get.LibraryFiles(h)
            filesTemp=h.filterByFileExtensions(h.Configuration.LibraryExtensions);
            if~isempty(filesTemp)



                files=cell(length(filesTemp),2);
                for i=1:length(filesTemp)
                    files{i,1}=filesTemp{i};
                    files{i,2}=h.FilesOrder(filesTemp{i});
                end
                files=sortrows(files,2);
                files=files(:,1);
            else
                files={};
            end
        end


        function files=get.SkippedFiles(h)
            files={};
            fileExtensions=[h.Configuration.SourceExtensions,','...
            ,h.Configuration.HeaderExtensions,',',h.Configuration.LibraryExtensions];
            tokens=textscan(fileExtensions,'%s','Delimiter',',','MultipleDelimsAsOne',1);
            extensions=tokens{1,1};
            expression='';
            for index=1:length(extensions)
                extension=extensions{index};
                if('.'==extension(1))
                    extension=extension(2:end);
                end
                if(isempty(expression))
                    expression=sprintf('[\\.]?%s$',extension);
                else
                    expression=sprintf('%s|[\\.]?%s$',expression,extension);
                end
            end
            v=h.Files.values;
            for index=1:length(v)
                if(isempty(regexp(v{index}.Extension,expression,'once')))
                    files{end+1}=v{index}.FullPathName;%#ok
                end
            end
        end
        function value=get.BuildConfiguration(h)
            value=h.Template.BuildConfiguration;
        end



        function set.BuildConfiguration(h,value)
            if(~strcmpi(h.Template.BuildConfiguration,value))
                h.DirtyFlag=true;
            end
            h.Template.BuildConfiguration=value;
        end
        function value=get.OutputPath(h)
            value=h.Template.OutputPath;
        end
        function set.OutputPath(h,value)
            h.Template.OutputPath=value;
        end
        function value=get.CurrentPath(h)
            value=h.Template.SourcePath;
        end
        function set.CurrentPath(h,value)
            h.Template.SourcePath=value;
        end
    end
end
