


classdef GenMakefile<handle


    properties(Abstract)
mToolName
    end

    properties(Abstract)
        mTemplateFile;
    end
    properties
        mBuildInfo;
        mModuleName;
        Porting;
        BuildConfiguration;
        CustomToolchainOptions;
    end
    methods(Abstract)
        r=getIncludePaths(obj);
        r=getObjFiles(obj);
    end

    methods
        function this=GenMakefile(moduleName,buildInfo,Porting,...
            lBuildConfiguration,lCustomToolchainOptions)
            this.mModuleName=moduleName;
            this.mBuildInfo=buildInfo;
            this.Porting=Porting;
            this.CustomToolchainOptions=lCustomToolchainOptions;
            this.BuildConfiguration=lBuildConfiguration;
        end

        function incList=getIncludeFileList(obj)
            [~,incList]=obj.mBuildInfo.getFullFileList('include');
        end

        function NonBuildSrc=getNonBuildSrcFile(obj)

            [files,groups]=getFiles(obj.mBuildInfo,'other',false,false);


            groupToFilter='DEFINES';
            discardIdx=strcmp(groups,groupToFilter);
            files=files(~discardIdx);


            discardNonSVFilesIdx=contains(files,'.sv');
            files=files(discardNonSVFilesIdx);
            discardSVTBfiles=~contains(files,'_tb.sv');
            files=files(discardSVTBfiles);

            assert(~isempty(files),'No DPI-C component SystemVerilog files found.')

            NonBuildSrc=cell(1,length(files));
            for idx=1:length(files)
                fileval=files{idx};
                [~,FileName,Ext]=fileparts(fileval);
                NonBuildSrc{idx}=[FileName,Ext];
            end
        end

        function modelSrcList=getSourceFileList(obj)
            [srcPaths,srcList]=obj.mBuildInfo.getFullFileList('source');
            if obj.Porting
                modelSrcList=srcList;
            else
                modelSrcList=srcPaths;
            end
        end

        function libList=getLibFileList(obj)
            libList='';
            for m=1:length(obj.mBuildInfo.LinkObj)
                tmp=obj.mBuildInfo.LinkObj(m);
                libList=[fullfile(tmp.Path,tmp.Name),' ',libList];%#ok<AGROW>
            end
        end



        function doIt(obj)
            targetFile=fullfile(pwd,obj.mMakefileName);
            dpigenerator_disp(sprintf('Generating %s makefile/script %s',...
            obj.mToolName,dpigenerator_getfilelink(targetFile)));
            [fid,msg]=fopen(obj.mTemplateFile,'r');
            if fid==-1
                error(msg);
            end
            context=fread(fid,inf,'uint8=>char')';
            fclose(fid);






            srcFiles=l_cell2string(getSourceFileList(obj));
            context=strrep(context,'__SOURCES__',srcFiles);


            NonBuildsrcFiles=l_cell2string(getNonBuildSrcFile(obj));
            context=strrep(context,'__NON_BUILD_SOURCES__',NonBuildsrcFiles);

            if strcmp(obj.BuildConfiguration,'Specify')

                context=strrep(context,'__LINKERFLAGS__',obj.CustomToolchainOptions{4});


                context=strrep(context,'__COMPILERFLAGS__',obj.CustomToolchainOptions{2});
            else

                context=strrep(context,'__LINKERFLAGS__','');


                context=strrep(context,'__COMPILERFLAGS__',strjoin(obj.mBuildInfo.getDefines()));
            end

            objFiles=l_cell2string(getObjFiles(obj));
            context=strrep(context,'__OBJECTS__',objFiles);


            context=strrep(context,'__DPINAME__',obj.mModuleName);


            incPaths=l_cell2string(getIncludePaths(obj));
            context=strrep(context,'__INCLUDE_PATH__',incPaths);


            libPaths=getLibFileList(obj);
            context=strrep(context,'__LIBS__',libPaths);

            [fidw,msg]=fopen(targetFile,'w');
            if fidw==-1
                error(msg);
            end
            fwrite(fidw,context,'char');
            fclose(fidw);
        end
    end
end

function r=l_cell2string(c)

    if isempty(c)
        r='';
    else
        tmp=cellfun(@(x)[x,' '],c,'UniformOutput',false);
        r=[tmp{:}];
    end
end






