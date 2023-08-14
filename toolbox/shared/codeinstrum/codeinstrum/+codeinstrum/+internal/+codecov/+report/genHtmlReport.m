



function htmlFiles=genHtmlReport(varargin)

    funName='codeinstrum.internal.codecov.report.genHtmlReport';


    htmlFiles=[];


    opt=parseArgs(varargin);
    isSummaryMode=opt.summaryMode>0;


    numObjs=numel(opt.objs);
    if numObjs==0
        return

    elseif numObjs==1
        opt.cumulativeReport=false;

    elseif numObjs==2&&opt.cumulativeReport
        delta=opt.objs{2}-opt.objs{1};
        opt.objs={opt.objs{1},delta,opt.objs{2}};

    elseif numObjs==3&&opt.cumulativeReport

    else
        opt.cumulativeReport=false;
        if~opt.lastIsTotal
            totalObj=opt.objs{1};
            for ii=2:numObjs
                totalObj=totalObj+opt.objs{ii};
            end
            opt.objs{end+1}=totalObj;
        end
    end


    areCodeCovDataGroup=zeros(numel(opt.objs),1,'logical');
    resDetails=cell(numel(opt.objs),1);
    for ii=1:numel(opt.objs)
        if opt.elimUncoveredFunData
            tmp=opt.objs{ii}.clone();
            tmp.removeUncoveredFunctionsData();
        else
            tmp=opt.objs{ii};
        end
        areCodeCovDataGroup(ii)=isa(tmp,'codeinstrum.internal.codecov.CodeCovDataGroup');
        resDetails{ii}=tmp.toStruct();
    end

    if numel(areCodeCovDataGroup==true)~=numel(areCodeCovDataGroup)
        error(message('CodeInstrumentation:covrpt:wrongParams'));
    end




    if isempty(resDetails{end})
        return
    end

    options=internal.codecov.report.Options();

    options.enableOutcomeFilters=opt.enableOutcomeFilters;
    options.topMostModelName=opt.topMostModelName;
    options.doUniqueName=opt.doUniqueName;
    options.cumulativeReport=opt.cumulativeReport;
    if isempty(opt.metricNames)
        options.metricNames='';
    else
        options.metricNames=[strjoin(opt.metricNames,';'),';'];
    end
    options.allTestInMdlSumm=opt.allTestInMdlSumm;
    options.barGrInMdlSumm=opt.barGrInMdlSumm;
    options.twoColorBarGraphs=opt.twoColorBarGraphs;
    options.hitCntInMdlSumm=opt.hitCntInMdlSumm;
    options.elimFullCov=opt.elimFullCov;
    options.elimFullCovDetails=opt.elimFullCovDetails;
    options.elimUncoveredFunData=opt.elimUncoveredFunData;
    options.complexInSumm=opt.complexInSumm;
    options.complexInBlkTable=opt.complexInBlkTable;
    if~isempty(opt.imageSubDirectory)
        options.imageSubDirectory=opt.imageSubDirectory;
    end
    if~isempty(opt.scriptSection)
        options.scriptSection=opt.scriptSection;
    end
    options.covId=opt.covId;
    options.ssId=opt.ssId;
    options.explorerGeneratedReport=opt.explorerGeneratedReport;
    options.enableAggregatedTestInfo=opt.enableAggregatedTestInfo;
    options.isDockedReport=opt.isDockedReport;


    options.radixName=opt.radixName;
    options.outputDir=polyspace.internal.getAbsolutePath(opt.outputDir);




    rptCtx=codeinstrum.internal.codecov.report.ReportContext(resDetails,options);
    rptObj=codeinstrum.internal.codecov.report.HtmlReportEmitter(rptCtx);

    filesInfos=rptCtx.getFileInfos();
    numFiles=numel(filesInfos);



    if~isSummaryMode&&~exist(options.outputDir,'dir')
        mkdir(options.outputDir);
    end




    manglerFcn=@(str)regexprep(str,'\W','_');
    if isempty(opt.fileIdx)&&(numFiles>0)

        instrStatus=[filesInfos.instrStatus];
        opt.fileIdx=find((instrStatus~=internal.cxxfe.instrum.FileStatus.IGNORED)&...
        (instrStatus~=internal.cxxfe.instrum.FileStatus.FAILED));
    end

    needSummaryFile=opt.summaryFileOnly||(numel(opt.fileIdx)~=1);
    htmlFiles=cell(numel(opt.fileIdx),1);
    badIdx=[];


    outFileSuffix='_cov';
    outFileExt='.html';
    if needSummaryFile
        if isempty(opt.summaryFileRadix)
            opt.summaryFileRadix=options.radixName;
        end
    else
        if isempty(options.radixName)&&~isempty(opt.summaryFileRadix)
            options.radixName=opt.summaryFileRadix;
        end
        if opt.skipFileSuffixForSingleFile&&numel(opt.fileIdx)==1
            outFileSuffix='';
        end
    end



    srcFileKind=1;
    srcNames={filesInfos([filesInfos.fileKind]==srcFileKind).srcName};
    extraRadix='';
    if~isempty(srcNames)
        extraRadix=[manglerFcn(srcNames{1}),'_'];
    end


    for fIdx=1:numel(opt.fileIdx)

        ii=opt.fileIdx(fIdx);
        if ii>numFiles
            badIdx=[badIdx,fIdx];%#ok<AGROW>
            continue
        end

        if fIdx<=numel(opt.htmlFiles)
            outFile=opt.htmlFiles{fIdx};
        else
            fName=filesInfos(ii).srcName;
            [~,srcName]=fileparts(fName);
            if isempty(srcName)
                badIdx=[badIdx,fIdx];%#ok<AGROW>
                continue
            end


            outFileRadix=options.radixName;
            if needSummaryFile
                outFileRadix=[options.radixName,manglerFcn(fName)];
            end



            if filesInfos(ii).fileKind~=srcFileKind
                outFileRadix=[extraRadix,outFileRadix];%#ok<AGROW>
            end


            outFile=fullfile(options.outputDir,[outFileRadix,outFileSuffix,outFileExt]);
            if options.doUniqueName&&~isSummaryMode
                outFile=polyspace.internal.makeFileNameUnique(outFile);
            end
        end

        htmlFiles{fIdx}=outFile;
    end


    opt.fileIdx(badIdx)=[];
    htmlFiles(badIdx)=[];


    if isSummaryMode
        if needSummaryFile
            htmlFiles=rptObj.emitSummary(-1);
        else
            htmlFiles=rptObj.emitSummary(opt.fileIdx(1)-1);
        end


        htmlFiles=regexprep(htmlFiles,'class\s*=\s*"summary"','cellpadding="2" style="font-size:small"','ignorecase');
        htmlFiles=regexprep(htmlFiles,'class\s*=\s*"summary_theader"','style="text-align:center;font-weight:bold"','ignorecase');
        htmlFiles=regexprep(htmlFiles,'class\s*=\s*"summary_td"','align="center"','ignorecase');
        htmlFiles=regexprep(htmlFiles,'\s+href="#file"','','ignorecase');
        htmlFiles=regexprep(htmlFiles,'\s+href="#fun\d+"','','ignorecase');
        return
    end

    if~opt.summaryFileOnly
        for ii=1:numel(opt.fileIdx)

            rptObj.emitFile(opt.fileIdx(ii)-1,htmlFiles{ii});
        end
    end


    if needSummaryFile
        summaryFile=fullfile(options.outputDir,[opt.summaryFileRadix,opt.summaryFileSuffix,outFileExt]);
        if options.doUniqueName
            summaryFile=polyspace.internal.makeFileNameUnique(summaryFile);
        end
        rptObj.emitSummaryFile(summaryFile);


        htmlFiles=[{summaryFile};htmlFiles(:)];
    end


    if opt.showReport&&~isempty(htmlFiles)
        web(htmlFiles{1});
    end

    function opt=parseArgs(argv)
        opt.outputDir=pwd;
        opt.radixName='';
        opt.doUniqueName=false;
        opt.cumulativeReport=false;
        opt.metricNames={};
        opt.lastIsTotal=false;
        opt.fileIdx=[];
        opt.htmlFiles={};
        opt.objs={};
        opt.summaryFileOnly=false;
        opt.summaryFileSuffix='_summary_cov';
        opt.summaryFileRadix='';
        opt.skipFileSuffixForSingleFile=false;

        opt.showReport=false;
        opt.summaryMode=0;
        opt.allTestInMdlSumm=true;
        opt.barGrInMdlSumm=true;
        opt.hitCntInMdlSumm=false;
        opt.twoColorBarGraphs=true;
        opt.elimFullCov=false;
        opt.elimFullCovDetails=true;
        opt.elimUncoveredFunData=false;
        opt.complexInSumm=true;
        opt.complexInBlkTable=true;
        opt.imageSubDirectory=[];
        opt.scriptSection=[];
        opt.topMostModelName='';
        opt.covId=0;
        opt.ssId='';
        opt.explorerGeneratedReport=false;
        opt.isDockedReport=false;
        opt.enableAggregatedTestInfo=codeinstrumprivate('feature','enableAggregatedTestInfo');
        opt.enableOutcomeFilters=codeinstrumprivate('feature','enableOutcomeFilters');

        argc=numel(argv);
        argvIn=1;
        while argvIn<=argc
            arg=argv{argvIn};

            if isa(arg,'codeinstrum.internal.codecov.CodeCovData')
                opt.objs{end+1}=arg;
            elseif isa(arg,'codeinstrum.internal.codecov.CodeCovDataGroup')
                opt.objs{end+1}=arg;
            elseif isa(arg,'cvi.CvhtmlSettings')
                props=properties(arg);
                for jj=1:numel(props)
                    if strcmpi(props{jj},'outputDir')


                        continue
                    end
                    opt.(props{jj})=arg.(props{jj});
                end

            elseif ischar(arg)
                argvIn=argvIn+1;
                if argvIn>argc
                    error(message('MATLAB:InputParser:ParamMissingValue',arg));
                end
                val=argv{argvIn};

                switch lower(strtrim(arg))
                case 'explorergeneratedreport'
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.explorerGeneratedReport=logical(val);

                case 'isdockedreport'
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.isDockedReport=logical(val);

                case 'showreport'
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.showReport=logical(val);

                case{'alltestinsumm','alltestinmdlsumm'}
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.allTestInMdlSumm=logical(val);

                case{'bargrinsumm','bargrinmdlsumm'}
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.barGrInMdlSumm=logical(val);

                case 'twocolorbargraphs'
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.twoColorBarGraphs=logical(val);

                case{'hitcntinsumm','hitcntinmdlsumm'}
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.hitCntInMdlSumm=logical(val);

                case 'elimfullcov'
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.elimFullCov=logical(val);

                case 'elimfullcovdetails'
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.elimFullCovDetails=logical(val);

                case 'elimuncoveredfundata'
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.elimUncoveredFunData=logical(val);

                case{'resourcefolder','imagesubdirectory'}
                    validateattributes(val,{'char'},{},funName,arg,argvIn);
                    if~isempty(val)
                        validateattributes(val,{'char'},{'vector','nrows',1},funName,arg,argvIn);
                    end
                    opt.imageSubDirectory=val;

                case 'scriptsection'
                    validateattributes(val,{'char'},{},funName,arg,argvIn);
                    if~isempty(val)
                        validateattributes(val,{'char'},{'vector','nrows',1},funName,arg,argvIn);
                    end
                    opt.scriptSection=val;

                case 'fileidx'
                    validateattributes(val,{'numeric'},{'vector'},funName,arg,argvIn);
                    opt.fileIdx=val;

                case 'htmlfiles'
                    validateattributes(val,{'cell','char'},{'vector'},funName,arg,argvIn);
                    opt.htmlFiles=cellstr(val);

                case{'outputdir','outdir'}
                    validateattributes(val,{'char'},{'row'},funName,arg,argvIn);
                    opt.outputDir=strtrim(val);

                case{'radixname','rname'}
                    if isempty(val)
                        val='';
                    else
                        validateattributes(val,{'char'},{'row'},funName,arg,argvIn);
                    end
                    opt.radixName=strtrim(val);

                case 'douniquename'
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.doUniqueName=logical(val);

                case{'cumulativereport','cumreport'}
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.cumulativeReport=logical(val);

                case 'metricnames'
                    if isempty(val)
                        val={'fake_metric'};
                    end
                    validateattributes(val,{'cell'},{'vector'},funName,arg,argvIn);
                    opt.metricNames=cellstr(val);

                case 'lastistotal'
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.lastIsTotal=logical(val);

                case 'summaryfileonly'
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.summaryFileOnly=logical(val);

                case 'summaryfilesuffix'
                    if~isempty(val)
                        validateattributes(val,{'char'},{'row'},funName,arg,argvIn);
                    end
                    opt.summaryFileSuffix=strtrim(val);

                case 'summaryfileradix'
                    if~isempty(val)
                        validateattributes(val,{'char'},{'row'},funName,arg,argvIn);
                    end
                    opt.summaryFileRadix=strtrim(val);

                case{'complexinsumm','cyclocplxinsummary'}
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.complexInSumm=logical(val);

                case{'complexinblktable','cyclocplxindetails'}
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.complexInBlkTable=logical(val);

                case 'skipfilesuffixforsinglefile'
                    validateattributes(val,{'logical','numeric'},{'scalar'},funName,arg,argvIn);
                    opt.skipFileSuffixForSingleFile=logical(val);

                case 'topmostmodelname'
                    if~isempty(val)
                        validateattributes(val,{'char'},{'row'},funName,arg,argvIn);
                    end
                    opt.topMostModelName=strtrim(val);

                case 'covid'
                    if isempty(val)
                        val=0;
                    else
                        validateattributes(val,{'numeric'},{'scalar'},funName,arg,argvIn);
                    end
                    opt.covId=double(val);

                case 'ssid'
                    validateattributes(val,{'char'},{},funName,arg,argvIn);
                    if~isempty(val)
                        validateattributes(val,{'char'},{'vector','nrows',1},funName,arg,argvIn);
                    end
                    opt.ssId=val;

                otherwise
                    error(message('MATLAB:InputParser:UnmatchedParameter',arg,''));
                end
            else
                error(message('MATLAB:InputParser:NameMustBeChar'));
            end

            argvIn=argvIn+1;
        end

        if isempty(opt.topMostModelName)&&isfield(opt,'topModelName')&&~isempty(opt.topModelName)
            opt.topMostModelName=opt.topModelName;
        end

    end

end








