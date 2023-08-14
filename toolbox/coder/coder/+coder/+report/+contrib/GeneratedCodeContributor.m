

classdef(Sealed)GeneratedCodeContributor<coder.report.Contributor


    properties(Constant)
        ID='coder-generated'
        DATA_GROUP='generated'
        ARTIFACT_GROUP='generatedSource'
        MARKUP_KEY='markup'
        SUBFOLDER='generatedSource'
        InjectedDependencies={'coder.report.contrib.ClangToolingContributor'}
    end

    properties(Access=private)


ClangContributor
    end

    methods
        function obj=GeneratedCodeContributor(aClangContributor)
            obj.ClangContributor=aClangContributor;
        end

        function supported=isSupportsVirtualMode(~,~)
            supported=true;
        end

        function contribute(this,reportContext,contribContext)
            srcFiles=this.ClangContributor.SourceFiles;
            if isempty(srcFiles)
                return;
            end

            this.copySourceFiles(reportContext,contribContext,srcFiles);
            contribContext.addData(this.DATA_GROUP,'fileList',srcFiles);
            this.getLinks(contribContext);
        end
    end

    methods(Access=private)
        function copySourceFiles(this,reportContext,contribContext,srcFileStruct)
            sourceFolder=fullfile(reportContext.ReportDirectory,this.SUBFOLDER);

            if~contribContext.VirtualMode&&~contribContext.DryRun
                mkdir(sourceFolder);
            end
            fileMappings=cell(0,2);

            fileFields=fieldnames(srcFileStruct);
            for i=1:numel(fileFields)
                files=srcFileStruct.(fileFields{i});
                if isempty(files)
                    continue;
                end

                fileMappingOffset=size(fileMappings,1);
                fileMappings(fileMappingOffset+numel(files),:)=cell(1,2);

                for j=1:numel(files)
                    file=files{j};

                    [~,filename,ext]=fileparts(file);
                    destFile=fullfile(sourceFolder,[filename,ext]);
                    suffix=1;
                    while exist(destFile,'file')
                        suffix=suffix+1;
                        destFile=fullfile(sourceFolder,sprintf('%s_%d%s',filename,suffix,ext));
                    end
                    [~,filename]=fileparts(destFile);
                    relDestFile=[this.SUBFOLDER,'/',[filename,ext]];
                    fileMappings(fileMappingOffset+j,:)={file,relDestFile};

                    if contribContext.VirtualMode
                        contribContext.embedArtifact(this.ARTIFACT_GROUP,file,...
                        'File',relDestFile,'Content',fileread(file));
                    else
                        if~exist(fileparts(destFile),'dir')
                            mkdir(fileparts(destFile));
                        end
                        if~contribContext.DryRun
                            copyfile(file,destFile);
                        end
                        contribContext.linkArtifact(this.ARTIFACT_GROUP,file,'File',relDestFile);
                    end
                end
            end

            if~contribContext.VirtualMode&&~contribContext.DryRun
                generatedCodeInfo.generatedSourceFiles=fileMappings;%#ok<STRNU>
                contribContext.saveMatFile(fullfile(reportContext.ReportDirectory,...
                codergui.ReportServices.GENERATED_CODE_INFO_FILE),'generatedCodeInfo');
            end
        end

        function analyzed=getLinks(this,contribContext)
            if~isempty(this.ClangContributor.LinksResult)
                contribContext.addData(this.DATA_GROUP,this.MARKUP_KEY,...
                this.ClangContributor.LinksResult.Links);
                analyzed=true;
            else
                analyzed=false;
            end
        end
    end

    methods(Static,Access=private)
        function fileRows=emitLegacyCHtml(outDir,srcFiles)

            validateattributes(srcFiles,{'struct'},{'scalar'});

            oldpwd=pwd;
            cd(outDir);
            cleanup=onCleanup(@()cd(oldpwd));

            allSrcFiles=[srcFiles.Source;srcFiles.Examples;srcFiles.Interfaces;srcFiles.AutoVerify];
            htmlFiles=cell(numel(allSrcFiles),1);
            outMarker=0;

            generateHtmlFilenames(srcFiles.Source,'__source__');
            generateHtmlFilenames(srcFiles.Examples,'__examples__');
            generateHtmlFilenames(srcFiles.Interfaces,'__interfaces__');
            generateHtmlFilenames(srcFiles.AutoVerify,'__auto__');
            removeOversizedFiles();

            rtwprivate('rtwctags',allSrcFiles,false,false,htmlFiles,false);

            for i=1:numel(htmlFiles)
                htmlFiles{i}=fullfile(outDir,htmlFiles{i});
            end
            fileRows=[allSrcFiles,htmlFiles];

            function generateHtmlFilenames(fileset,prefix)
                for j=1:numel(fileset)
                    [~,name,ext]=fileparts(fileset{j});
                    outMarker=outMarker+1;
                    htmlFiles{outMarker}=[prefix,name,regexprep(ext,'\.','_'),'.html'];
                end
            end

            function removeOversizedFiles()
                sizeMask=true(size(allSrcFiles));
                for j=1:numel(allSrcFiles)

                    info=dir(allSrcFiles{j});
                    if isempty(info)
                        sizeMask(j)=false;
                    else
                        sizeMask(j)=info.bytes<(15*1024^2);
                    end
                end
                allSrcFiles=allSrcFiles(sizeMask);
                htmlFiles=htmlFiles(sizeMask);
            end
        end
    end
end


