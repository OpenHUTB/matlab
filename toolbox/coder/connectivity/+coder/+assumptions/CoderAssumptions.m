classdef(Hidden=true)CoderAssumptions<handle







    properties(Access=private,Constant)

        PreprocessorHeaderNamePostfix='_ca_preproc';
        HeaderNamePostfix='_ca';
        SourceNamePostfix='_ca';
        EntryPointHeaderName='coder_assumptions';

        BuildSubFolder='coderassumptions';

        StaticFile_App='coder_assumptions_app';
        StaticFile_DataStream='coder_assumptions_data_stream';
        StaticFile_HWImpl='coder_assumptions_hwimpl';
        StaticFile_FLT='coder_assumptions_flt';
        StaticFile_SharedEnums='coder_assumptions_shared_enums';

        SourceExt='.c';
        HeaderExt='.h';

        LibSubFolder='lib';
        PWSLibSubFolder='pwslib';

        EntryPointFcnPostfix='_caRunTests';
    end

    methods(Access=public,Static)

        function serializeCoderAssumptionsToCodeDescriptor(configInterface,buildDir)
            codeDescriptorPath=coder.assumptions.CoderAssumptions.getCodeDescriptorPath(buildDir);
            coderAssumptionsSerializer=coder.assumptions.CoderAssumptionsSerializer(configInterface,codeDescriptorPath);
            coderAssumptionsSerializer.serializeCoderAssumptionsToCodeDescriptor;
        end


        function generateCoderAssumptionsChecks(...
            buildDir,startDir,configInterface,componentArgs,...
            isHost,componentBuildInfoPath,obfuscateCode,lXilCompInfo,encoding)





            coderAssumptionsDir=coder.assumptions.CoderAssumptions.getBuildFolder(buildDir);
            coder.assumptions.CoderAssumptions.mkdir(coderAssumptionsDir);

            codeDescriptorPath=coder.assumptions.CoderAssumptions.getCodeDescriptorPath(buildDir);
            assert(isfile(codeDescriptorPath),...
            'Code descriptor path does not exist: %s',codeDescriptorPath);
            componentName=configInterface.getCodeGenComponent;
            preprocessorHeaderName=...
            coder.assumptions.CoderAssumptions.getPreprocessorHeaderFileName(componentName);
            preprocessorCheckPath=fullfile(coderAssumptionsDir,preprocessorHeaderName);

            libUpToDate=true;
            [sources,libFile,libExt]=coder.assumptions.CoderAssumptions.getDependencies(...
            componentName,buildDir,configInterface,isHost,lXilCompInfo);

            sourcesUpToDate=coder.assumptions.CoderAssumptions.sourcesUpToDate(sources,buildDir,startDir);


            if~sourcesUpToDate
                mf0Model=mf.zero.Model;
                mfdatasource.attachDMRDataSource(codeDescriptorPath,mf0Model,mfdatasource.ToModelSync.None,mfdatasource.ToDataSourceSync.None);
                mdl=coder.descriptor.Model.findModel(mf0Model);


                preprocessorCheckWriter=...
                coder.assumptions.PreprocessorCheckWriter(mdl.CoderAssumptions,preprocessorCheckPath);
                append=false;
                callCBeautifier=true;
                preprocessorCheckWriter.writeOutput(append,callCBeautifier,obfuscateCode,encoding);

                caWriter=coder.assumptions.RuntimeCheckWriter(mdl.CoderAssumptions,coderAssumptionsDir,componentName);
                caWriter.writeOutput(append,callCBeautifier,obfuscateCode,encoding);

                libUpToDate=false;
                coder.assumptions.CoderAssumptions.removeInvalidLibraryFiles(...
                componentName,buildDir,libExt);
            end


            if~libUpToDate||~isfile(libFile)

                coder.assumptions.LibraryBuilder.buildStaticLibrary(...
                buildDir,startDir,configInterface,...
                componentArgs,isHost,componentBuildInfoPath,...
                lXilCompInfo);




                assumptionsInfo.DependencyChecksums=coder.internal.utils.Checksum.dependencyChecksumsStruct(...
                sources,codeDescriptorPath,startDir);

                coderAssumptionsInfoPath=coder.assumptions.CoderAssumptions.getCoderAssumptionsInfoPath(buildDir);

                save(coderAssumptionsInfoPath,'-struct','assumptionsInfo');

            end

        end

        function codeDescriptorPath=getCodeDescriptorPath(buildDir)
            codeDescriptorPath=fullfile(buildDir,'codedescriptor.dmr');
        end

        function coderAssumptionsInfoPath=getCoderAssumptionsInfoPath(buildDir)
            coderAssumptionsDir=coder.assumptions.CoderAssumptions.getBuildFolder(buildDir);
            coderAssumptionsInfoPath=fullfile(coderAssumptionsDir,'coderAssumptionsInfo.mat');
        end

        function proprocHeaderFileName=getPreprocessorHeaderFileName(component)
            proprocHeaderFileName=[component,...
            coder.assumptions.CoderAssumptions.PreprocessorHeaderNamePostfix,...
            coder.assumptions.CoderAssumptions.HeaderExt];
        end

        function headerFileName=getHeaderFileName(component)
            headerFileName=[component,...
            coder.assumptions.CoderAssumptions.HeaderNamePostfix,...
            coder.assumptions.CoderAssumptions.HeaderExt];
        end

        function sourceFileName=getSourceFileName(component)
            sourceFileName=[component,...
            coder.assumptions.CoderAssumptions.SourceNamePostfix,...
            coder.assumptions.CoderAssumptions.SourceExt];
        end

        function entryPointHeaderFileName=getEntryPointHeaderFileName()
            entryPointHeaderFileName=[...
            coder.assumptions.CoderAssumptions.EntryPointHeaderName,...
            coder.assumptions.CoderAssumptions.HeaderExt];
        end

        function[sources,library,libExt]=getDependencies...
            (component,codeGenDir,configInterface,isHost,lXilCompInfo)



            coderAssumptionsDir=coder.assumptions.CoderAssumptions.getBuildFolder(codeGenDir);

            sources=fullfile(coderAssumptionsDir,{...
            coder.assumptions.CoderAssumptions.getSourceFileName(component),...
            coder.assumptions.CoderAssumptions.getHeaderFileName(component),...
            coder.assumptions.CoderAssumptions.getPreprocessorHeaderFileName(component),...
            coder.assumptions.CoderAssumptions.getEntryPointHeaderFileName,...
            });


            isPWS=strcmp(configInterface.getParam('PortableWordSizes'),'on');
            libBuildDir=coder.assumptions.CoderAssumptions.getLibraryBuildFolder(...
            coderAssumptionsDir,isHost,isPWS);
            libExt=lXilCompInfo.XilLibraryExt;
            library={fullfile(libBuildDir,...
            coder.assumptions.CoderAssumptions.getLibraryName(component,libExt))};
        end

        function coderAssumpBuildFolder=getBuildFolder(codeDir)


            coderAssumpBuildFolder=fullfile(codeDir,...
            coder.assumptions.CoderAssumptions.BuildSubFolder);
        end

        function staticSources=getXILAppStaticSourceFileNames
            extension=coder.assumptions.CoderAssumptions.SourceExt;
            staticSources={...
            [coder.assumptions.CoderAssumptions.StaticFile_App,extension]...
            ,[coder.assumptions.CoderAssumptions.StaticFile_DataStream,extension]...
            };
        end

        function staticSources=getXILAppStaticHeaderFileNames
            extension=coder.assumptions.CoderAssumptions.HeaderExt;
            staticSources={...
            [coder.assumptions.CoderAssumptions.StaticFile_App,extension]...
            ,[coder.assumptions.CoderAssumptions.StaticFile_DataStream,extension]...
            ,[coder.assumptions.CoderAssumptions.StaticFile_SharedEnums,extension]...
            };
        end

        function header=getStaticHeader_HWImpl
            header=[...
            coder.assumptions.CoderAssumptions.StaticFile_HWImpl,...
            coder.assumptions.CoderAssumptions.HeaderExt];
        end

        function libName=getLibraryName(component,extension)
            libName=[component,...
            coder.assumptions.CoderAssumptions.SourceNamePostfix,...
            extension];
        end

        function postfix=getSourceFileNamePostfix()
            postfix=coder.assumptions.CoderAssumptions.SourceNamePostfix;
        end

        function emitReport(messages,model,...
            silpilInterfaceStr,inTheLoopType,blockPath)


            if coder.internal.connectivity.featureOn('CoderAssumptionsEmitReport')
                pilInterface=coder.connectivity.ClientInterface.getSILPILInterface(...
                silpilInterfaceStr,inTheLoopType,blockPath);
                coderAssumptionsDir=...
                coder.assumptions.CoderAssumptions.getBuildFolder(pilInterface.getCodeDir);
                reportFile=fullfile(coderAssumptionsDir,'report.txt');
                fid=fopen(reportFile,'w');
                fprintf(fid,'Coder Assumptions Report for %s\n\n',model);
                fprintf(fid,'%-25s%-16s%-16s%s\n\n','Test name','Status','Expected','Actual');
                for idx=1:numel(messages)

                    paramName=messages(idx).Name;
                    status=messages(idx).Status;
                    expected=num2str(messages(idx).Expected);
                    actual=num2str(messages(idx).Actual);
                    fprintf(fid,'%-25s%-16s%-16s%s\n',paramName,status,expected,actual);
                end
                fclose(fid);
            end
        end

        function headers=getLibraryStaticHeaders()
            extension=coder.assumptions.CoderAssumptions.HeaderExt;
            headers={...
            [coder.assumptions.CoderAssumptions.StaticFile_HWImpl,extension],...
            [coder.assumptions.CoderAssumptions.StaticFile_SharedEnums,extension]};
        end

        function sources=getLibraryStaticSources()
            extension=coder.assumptions.CoderAssumptions.SourceExt;
            sources={...
            [coder.assumptions.CoderAssumptions.StaticFile_HWImpl,extension],...
            [coder.assumptions.CoderAssumptions.StaticFile_FLT,extension]};
        end

        function file=getStaticFile_FLT()
            extension=coder.assumptions.CoderAssumptions.SourceExt;
            file=[coder.assumptions.CoderAssumptions.StaticFile_FLT,extension];
        end

        function dir=getLibraryBuildFolder(caPath,isHost,isPWS)
            if isHost&&isPWS
                subDir=coder.assumptions.CoderAssumptions.PWSLibSubFolder;
            else
                subDir=coder.assumptions.CoderAssumptions.LibSubFolder;
            end
            dir=fullfile(caPath,subDir);
        end

        function configObj=getConfigObject(configInterface)


            if isa(configInterface,'coder.connectivity.SimulinkConfig')
                configObj=configInterface.getConfig;
            else
                configObj=configInterface;
            end
        end

        function fcnName=getEntryPointFcnName(component)

            fcnName=[component...
            ,coder.assumptions.CoderAssumptions.EntryPointFcnPostfix];
        end

        function mkdir(fullpathToDir)

            if~exist(fullpathToDir,'dir')
                [success,msg,msgid]=mkdir(fullpathToDir);
                if~success
                    error(msgid,'%s',msg);
                end
            end
        end

        function deleteLibraryFile(aLibFile)

            if isfile(aLibFile)
                delete(aLibFile);
            end
        end

    end


    methods(Access=private,Static)
        function removeInvalidLibraryFiles(componentName,buildDir,libExt)

            caPath=coder.assumptions.CoderAssumptions.getBuildFolder(buildDir);

            isHost=true;
            isPWS=true;
            pwsLibPath=coder.assumptions.CoderAssumptions.getLibraryBuildFolder(caPath,isHost,isPWS);
            pwsLibFile=fullfile(pwsLibPath,...
            coder.assumptions.CoderAssumptions.getLibraryName(componentName,libExt));
            coder.assumptions.CoderAssumptions.deleteLibraryFile(pwsLibFile);

            isPWS=false;
            libPath=coder.assumptions.CoderAssumptions.getLibraryBuildFolder(caPath,isHost,isPWS);
            libFile=fullfile(libPath,...
            coder.assumptions.CoderAssumptions.getLibraryName(componentName,libExt));
            coder.assumptions.CoderAssumptions.deleteLibraryFile(libFile);
        end

        function upToDate=sourcesUpToDate(sources,buildDir,startDir)

            codeDescriptorPath=coder.assumptions.CoderAssumptions.getCodeDescriptorPath(buildDir);
            coderAssumptionsInfoPath=coder.assumptions.CoderAssumptions.getCoderAssumptionsInfoPath(buildDir);


            if isfile(coderAssumptionsInfoPath)

                upToDate=true;


                coderAssumptionsInfo=load(coderAssumptionsInfoPath);



                if~coder.internal.utils.Checksum.equal({codeDescriptorPath},...
                    coderAssumptionsInfo.DependencyChecksums.CodeDescriptorChecksum)

                    upToDate=false;
                end



                if upToDate
                    dependencies=coderAssumptionsInfo.DependencyChecksums.Dependencies.Files;
                    dependencyDirs=coderAssumptionsInfo.DependencyChecksums.Dependencies.Dirs;
                    dependencyPaths=fullfile(startDir,dependencyDirs,dependencies);

                    if~all(isfile(dependencyPaths))||~all(contains(sources,dependencyPaths))
                        upToDate=false;
                    end
                end

                if upToDate



                    storedFileChecksums=coderAssumptionsInfo.DependencyChecksums.Dependencies.Checksums;

                    if~coder.internal.utils.Checksum.equal(dependencyPaths,storedFileChecksums)
                        upToDate=false;
                    end
                end

            else

                upToDate=false;
            end

        end

    end

end
