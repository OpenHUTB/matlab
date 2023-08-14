



function varargout=slcovmexImpl(varargin)

    if~all(cellfun(@iscell,varargin))

        buildOpts=codeinstrum.internal.MexOptionsParser(varargin);
    else

        buildOpts=[];
        for ii=1:numel(varargin)
            buildOpts=[buildOpts,codeinstrum.internal.MexOptionsParser(varargin{ii})];%#ok<AGROW>
        end
    end

    hasCxx=iHasCxx(buildOpts);
    if hasCxx


        [buildOpts,hasCxx]=iAdjustForceCxx(buildOpts);
    end


    tmpDir=tempname();
    tmpDir=iGetOrCreateDir(tmpDir);

    clrInstrObj=onCleanup(@()iCleanupTmpDirForInstrumentation(tmpDir,{}));

    sldvInfo=buildOpts(end).SldvInfo;
    if isempty(sldvInfo)&&any([buildOpts.SupportSldv])
        sldvInfo=sldv.code.sfcn.internal.getSFcnInfoFromHandwritten(tmpDir,buildOpts);
    elseif~isempty(sldvInfo)&&sldvInfo.HasSimStruct
        sldvInfo.overrideHandwrittenSources(tmpDir,buildOpts);
    end


    sfcnInstrumenter=codeinstrum.internal.SFcnInstrumenter(tmpDir,buildOpts);
    if~isempty(sldvInfo)
        sfcnInstrumenter.SLDVInfo=sldvInfo;
    end
    [instrFilesPerCmd,sfcnName,extraFiles]=sfcnInstrumenter.instrument();


    origBuildOpts=buildOpts;




    idxBuildCmdForCompilingExtraFiles=[];
    if~isempty(extraFiles)


        idxBuildCmdForCompilingExtraFiles=sfcnInstrumenter.SFcnInfo.idxMain(1);
        buildOpts=iAddBuildOptionsForExtraFiles(buildOpts,extraFiles,idxBuildCmdForCompilingExtraFiles);
    end


    assert(numel(instrFilesPerCmd)==numel(buildOpts));


    mexPath='';
    for ii=1:numel(instrFilesPerCmd)





        instr2Comp=instrFilesPerCmd{ii};
        src2Comp=buildOpts(ii).Sources;
        assert(numel(instr2Comp)==numel(src2Comp));

        if buildOpts(ii).IsCompOnly




            for jj=1:numel(instr2Comp)
                [~,fname,fext]=fileparts(src2Comp{jj});
                newFile=fullfile(tmpDir,[fname,fext]);
                copyfile(instr2Comp{jj},newFile,'f');
                instr2Comp{jj}=newFile;
            end
        end


        if~isempty(idxBuildCmdForCompilingExtraFiles)&&ii==idxBuildCmdForCompilingExtraFiles
            instr2Comp=[instr2Comp(:);extraFiles(:)];
        end


        [outDir,outName]=iInvokeMex(instr2Comp,buildOpts(ii),hasCxx);
        if~isempty(outName)
            mexPath=fullfile(outDir,[outName,'.',mexext]);
        end
    end


    [instrumentedFile,extraFiles]=sfcnInstrumenter.instrumentProcessMexSfunctionEveryCall(mexPath);




    idxBuildCmdForCompilingExtraFiles=[];
    if~isempty(extraFiles)


        idxBuildCmdForCompilingExtraFiles=sfcnInstrumenter.SFcnInfo.idxMain(1);
        origBuildOpts=iAddBuildOptionsForExtraFiles(origBuildOpts,extraFiles,idxBuildCmdForCompilingExtraFiles);
    end

    for ii=1:numel(origBuildOpts)

        instr2Comp=origBuildOpts(ii).Sources;



        if ii==sfcnInstrumenter.SFcnInfo.idxMain(1)
            [~,fname,fext]=fileparts(instr2Comp{sfcnInstrumenter.SFcnInfo.idxMain(2)});
            newFile=fullfile(tmpDir,[fname,fext]);
            copyfile(instrumentedFile,newFile,'f');
            instr2Comp{sfcnInstrumenter.SFcnInfo.idxMain(2)}=newFile;
        end


        if~isempty(idxBuildCmdForCompilingExtraFiles)&&ii==idxBuildCmdForCompilingExtraFiles
            instr2Comp=[instr2Comp(:);extraFiles(:)];
        end

        iInvokeMex(instr2Comp,origBuildOpts(ii),hasCxx);
    end



    if nargout>0
        varargout{1}=0;
    end

    function[outDir,outName]=iInvokeMex(files2Comp,mexOpts,hasCxx)

        mexArgs=[mexOpts.Argv(:);files2Comp(:)];

        outDir='';
        if~isempty(mexOpts.OutDir)
            outDir=mexOpts.OutDir;
            mexArgs=[mexArgs;{'-outdir';outDir}];
        end

        if~isempty(mexOpts.Otherfiles)
            mexArgs=[mexArgs;mexOpts.Otherfiles(:)];
        end

        outName='';
        if~mexOpts.IsCompOnly

            lnkMexArgs=iGetMexLinkExtraArgs(hasCxx);
            mexArgs=[mexArgs;lnkMexArgs(:)];

            if isempty(mexOpts.OutName)
                outName=sfcnName;
            else
                outName=mexOpts.OutName;
            end
            mexArgs=[mexArgs;{'-output';outName}];
        end

        if codeinstrumprivate('feature','debug')&&...
            ~any(strcmp(mexArgs,'-v'))
            mexArgs{end+1}='-v';
        end

        cmd=strjoin(mexArgs,' ');
        fprintf(1,'mex %s\n',cmd);
        mex(mexArgs{:});
    end

end


function buildOpts=iAddBuildOptionsForExtraFiles(buildOpts,extraFiles,idxBuildCmdForCompilingExtraFiles)



    if numel(buildOpts)>1



        for ii=numel(buildOpts)

            if ii==idxBuildCmdForCompilingExtraFiles


                continue
            end

            if~buildOpts(ii).IsCompOnly

                mainBuildCmd=buildOpts(idxBuildCmdForCompilingExtraFiles);
                if~isempty(mainBuildCmd.OutDir)
                    outDir=mainBuildCmd.OutDir;
                else
                    outDir='';
                end


                if ispc
                    objExt='.obj';
                else
                    objExt='.o';
                end

                extraObjs=cell(1,numel(extraFiles));
                for jj=1:numel(extraFiles)
                    [~,fname]=fileparts(extraFiles{jj});
                    extraObjs{jj}=fullfile(outDir,[fname,objExt]);
                end


                buildOpts(ii).Otherfiles=[buildOpts(ii).Otherfiles(:);extraObjs(:)];
                break
            end
        end
    end

end


function eMexArgs=iGetMexLinkExtraArgs(hasCxx)

    arch=computer('arch');

    if ispc
        try

            if hasCxx
                lang='C++';
            else
                lang='C';
            end
            cc=mex.getCompilerConfigurations(lang,'Selected');
            if isempty(cc)
                compilerName='lcc';
            else
                compilerName=lower(strtrim(cc.ShortName));
            end

            libDir='';
            if strncmp(compilerName,'lcc',3)
                if strcmpi(arch,'win32')
                    libDir=fullfile(matlabroot,'extern','lib',arch,'lcc');
                else
                    libDir=fullfile(matlabroot,'extern','lib',arch,'microsoft');
                end
            elseif strncmp(compilerName,'msvc',4)
                libDir=fullfile(matlabroot,'extern','lib',arch,'microsoft');
            elseif strncmp(compilerName,'intel',5)
                libDir=fullfile(matlabroot,'extern','lib',arch,'microsoft');
            elseif strncmpi(compilerName,'mingw64',7)
                libDir=fullfile(matlabroot,'extern','lib',arch,'mingw64');
            end

            eMexArgs{1}=fullfile(libDir,'libmwsl_sfcn_cov_bridge.lib');

        catch Me %#ok<NASGU>
            eMexArgs=[];
        end

    else
        eMexArgs{1}=['-L',fullfile(matlabroot,'bin',lower(arch))];
        eMexArgs{2}='-lmwsl_sfcn_cov_bridge';
    end

end


function aDir=iGetOrCreateDir(aDir)



    aDir=polyspace.internal.getAbsolutePath(aDir);


    aDir=rtwprivate('rtw_create_directory_path',aDir,'');

end


function iCleanupTmpDirForInstrumentation(tmpDir,filesToRestore)

    for ii=1:size(filesToRestore,1)
        try
            if exist(filesToRestore{ii,2},'file')
                copyfile(filesToRestore{ii,2},filesToRestore{ii,1},'f');
            end
        catch me %#ok<NASGU>
        end
    end

    if codeinstrumprivate('feature','debug')
        fprintf(1,'### slcovmex instrumented files in %s\n',tmpDir);
        f=dir(tmpDir);
        for ii=1:numel(f)
            if f(ii).isdir
                continue
            end
            fprintf(1,'\t%s\n',fullfile(tmpDir,f(ii).name));
        end
        fprintf(1,'\n');
    else
        try
            rmdir(tmpDir,'s');
        catch me %#ok<NASGU>
        end
    end

end

function hasCxx=iHasCxx(buildOpts)




    hasCxx=false;
    for ii=1:numel(buildOpts)
        sources=buildOpts(ii).Sources;

        if buildOpts(ii).ForceCxx
            hasCxx=true;
            return
        end

        for jj=1:numel(sources)
            currentIsCxx=codeinstrum.internal.LCInstrumenter.isCxxFile(sources{jj});
            if currentIsCxx
                hasCxx=true;
                return
            end
        end
    end
end


function[buildOpts,hasCxx]=iAdjustForceCxx(buildOpts)
    hasCxx=false;

    cxxCompInfo=mex.getCompilerConfigurations('c++','Selected');

    cxxCompName=cxxCompInfo.ShortName;
    [associatedCComp,cxxCompilesCAsCxx,compFlagsVar,cxxCompFlags]=internal.cxxfe.util.getMexCompilerInfo('getCxxCompatInfo',cxxCompName);
    checkCompilers=false;
    cxxCompilerForcedToCxx=iHasOption(cxxCompInfo.Details.CompilerFlags,cxxCompFlags);

    for ii=1:numel(buildOpts)
        sources=buildOpts(ii).Sources;
        currentHasCxx=false;
        currentHasC=false;

        for jj=1:numel(sources)
            currentIsCxx=codeinstrum.internal.LCInstrumenter.isCxxFile(sources{jj});
            hasCxx=hasCxx||currentIsCxx;
            currentHasCxx=currentHasCxx||currentIsCxx;
            currentHasC=currentHasC||~currentIsCxx;
        end



        forcedCxx=false;
        if buildOpts(ii).MexVars.isKey(compFlagsVar)
            compFlagsVal=buildOpts(ii).MexVars(compFlagsVar);
            if iHasOption(compFlagsVal,cxxCompFlags)
                forcedCxx=true;
            end
        else
            forcedCxx=cxxCompilerForcedToCxx;
        end

        if~cxxCompilesCAsCxx&&~forcedCxx
            if currentHasC&&(buildOpts(ii).ForceCxx||currentHasCxx)
                checkCompilers=true;
                buildOpts(ii).ForceCxx=false;
            end
        else
            if currentHasCxx||forcedCxx



                buildOpts(ii).ForceCxx=true;
            end
        end

        hasCxx=hasCxx||buildOpts(ii).ForceCxx;
    end
    if checkCompilers
        cCompInfo=mex.getCompilerConfigurations('c','Selected');
        cCompName=cCompInfo.ShortName;
        if~strcmp(cCompName,associatedCComp)

            warning(message('CodeInstrumentation:instrumenter:incompatibleCompilers'));
        end
    end
end


function hasOption=iHasOption(options,flags)
    hasOption=false;
    escapedFlags=regexptranslate('escape',flags);
    for ii=1:numel(escapedFlags)
        currentOption=escapedFlags{ii};
        splitOption=strsplit(currentOption);
        rx=sprintf('\\<%s\\>',strjoin(splitOption,'\\>\\s+\\<'));
        if~isempty(regexp(options,rx,'once'))
            hasOption=true;
            return
        end
    end
end




