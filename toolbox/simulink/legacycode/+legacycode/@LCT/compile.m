function compile(defs,varargin)













    persistent currArch isPC
    if isempty(isPC)
        currArch=computer('arch');
        isPC=ispc;
    end


    if nargin<1
        error(message('Simulink:tools:LCTErrorFirstFcnArgumentMustBeStruct'));
    end

    narginchk(1,2);
    if nargin==1

        opt={};

    elseif nargin==2

        opt=varargin{1};


        if~ischar(opt)&&~iscellstr(opt)&&~isstring(opt)
            error(message('Simulink:tools:LCTErrorBadArgumentOptionForCompilation'));
        end
    end


    opt=cellstr(opt);
    opt=opt(cellfun(@isempty,opt)==false);



    if~legacycode.lct.util.feature('newImpl')
        opt(end+1)={'-compatibleArrayDims'};
    end
    opt=opt(:);



    if isPC
        objFileExt='.obj';
        if~defs.Options.stubSimBehavior
            compInfo=slprivate('slgetcompilerinfo');
            if(isfield(compInfo,'mexOptsFile')==false)||(isempty(compInfo.mexOptsFile)==true)
                DAStudio.error('Simulink:tools:LCTErrorMexNotConfigured');
            end
        end
    else
        objFileExt='.o';
    end


    slLibPathMexOpts={};
    slLibNameMexOpts={};
    if isPC


        compInfo=mex.getCompilerConfigurations('C++','Selected');

        rtwcgLibPath='';
        if~isempty(compInfo)
            if strcmpi(compInfo.Manufacturer,'Microsoft')||strncmpi(compInfo.Manufacturer,'Intel',5)

                rtwcgLibPath=fullfile(matlabroot,'extern','lib',currArch,'microsoft');
            elseif strcmpi(compInfo.Manufacturer,'GNU')
                rtwcgLibPath=fullfile(matlabroot,'extern','lib',currArch,'mingw64');
            else


            end
        else


        end


        if~isempty(rtwcgLibPath)


            slLibNameMexOpts={'-lSimulinkBlock';'-lmwcgir_construct'};


            slLibPathMexOpts={sprintf('-L%s',rtwcgLibPath)};
        end

    else

        slLibPathMexOpts={sprintf('-L%s',...
        fullfile(matlabroot,'bin',currArch))};


        slLibNameMexOpts={'-lmwSimulinkBlock';'-lmwcgir_construct'};
    end


    mlPaths=legacycode.lct.util.getSearchPath();
    currDir=pwd;


    knownCxxExt={'.cpp','.cxx','.cc','.c++'};

    fprintf(1,'\n');
    for ii=1:length(defs)


        infoStruct=defs(ii);

        [pathInfo,sfunSourceNotFound]=legacycode.lct.util.resolvePaths(infoStruct,true,currDir,mlPaths);


        if sfunSourceNotFound
            DAStudio.error('Simulink:tools:LCTErrorCannotFindSourceFile',...
            pathInfo.SFunctionFileName);
        end
        mexArgs={pathInfo.SFunctionFileName};


        mexArgs=[mexArgs;opt];%#ok


        incArgs=pathInfo.IncPaths;
        for jj=1:length(incArgs)
            incArgs{jj}=sprintf('-I%s',incArgs{jj});
        end
        mexArgs=[mexArgs;incArgs];%#ok


        mexArgs=[mexArgs;pathInfo.LibFiles];%#ok


        libPathAdded=false;
        if infoStruct.Options.singleCPPMexFile
            mexArgs=[mexArgs;slLibPathMexOpts;slLibNameMexOpts];%#ok
            libPathAdded=true;
        end


        if legacycode.lct.util.feature('newImpl')
            lctSpecInfo=legacycode.lct.LCTSpecInfo.extract(infoStruct,'c');
        else
            lctSpecInfo=legacycode.util.lct_pGetFullInfoStructure(infoStruct,'c');
        end
        if lctSpecInfo.useInt64||lctSpecInfo.hasDynamicArrayArgument
            if~libPathAdded
                mexArgs=[mexArgs;slLibPathMexOpts];%#ok<AGROW>
            end
            if lctSpecInfo.useInt64
                mexArgs=[mexArgs;{'-lfixedpoint'}];%#ok<AGROW>
            end
            if lctSpecInfo.hasDynamicArrayArgument
                mexArgs=[mexArgs;{'-lmwsl_simtarget_instrumentation'}];%#ok<AGROW>
            end
        end


        fprintf(1,'### %s\n',...
        getString(message('Simulink:tools:LCTMsgStartCompiling',infoStruct.SFunctionName)));
        try


            doSldvInstrum=infoStruct.Options.supportCoverageAndDesignVerifier;
            doCov=doSldvInstrum||infoStruct.Options.supportCoverage;

            sldvInfo=[];
            if doSldvInstrum
                sldvInfo=sldv.code.sfcn.internal.getSFcnInfoFromLCT(lctSpecInfo);
            end


            clrObj=[];
            [tmpDir,owned]=iGetOrCreateTmpDir();
            if owned
                clrObj=onCleanup(@()rmdir(tmpDir,'s'));
            end



            commonArgs=[opt;incArgs;{'-c'};{'-outdir'};{tmpDir}];
            hasCxxFile=false;
            numSrcs=numel(pathInfo.SourceFiles);
            objFiles=cell(numSrcs,1);
            allMexArgs=cell(1,numSrcs+1);
            for jj=1:numSrcs

                mArgs=[commonArgs;pathInfo.SourceFiles(jj)];



                allMexArgs{jj}=mArgs;


                [~,f,e]=fileparts(pathInfo.SourceFiles{jj});
                objFiles(jj)={fullfile(tmpDir,[f,objFileExt])};
                if ismember(lower(e),knownCxxExt)
                    hasCxxFile=true;
                end
            end



            if~isPC&&hasCxxFile
                mexArgs=[mexArgs;{'-cxx'}];%#ok<AGROW>
            end


            allMexArgs{end}=[mexArgs;objFiles];


            if doCov


                slcovMexArgs=allMexArgs;
                slcovMexArgs{end}=[...
                slcovMexArgs{end};...
                {'-sldvInfo';sldvInfo};...
                {'-internalfile';pathInfo.SFunctionFileName}...
                ];


                slcovmex(slcovMexArgs{:});

            else

                for jj=1:numel(allMexArgs)

                    mexArgs=allMexArgs{jj};
                    fprintf(1,'%s',iConvertCellStrToMexCommand(mexArgs));
                    mex(mexArgs{:});
                end
            end


            delete(clrObj);

        catch MEmex

            rethrow(MEmex)
        end


        fprintf(1,'### %s\n',...
        getString(message('Simulink:tools:LCTMsgFinishCompiling',infoStruct.SFunctionName)));

    end

    fprintf(1,'### %s\n',getString(message('Simulink:tools:LCTMsgEndCompiling')));


    function str=iConvertCellStrToMexCommand(mexArgs)

        str=sprintf('    mex(');
        sep='';
        for ii=1:length(mexArgs)
            if~isempty(mexArgs{ii})
                str=sprintf('%s%s''%s''',str,sep,mexArgs{ii});
                sep=', ';
            end
        end
        str=sprintf('%s)\n',str);


        function[tmpDir,owned]=iGetOrCreateTmpDir()


            tmpDir=tempname();


            if~isfolder(tmpDir)
                tmpDir=rtwprivate('rtw_create_directory_path',tmpDir,'');
                owned=true;
            else
                owned=false;
            end



