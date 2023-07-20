function reportNames=report(varargin)




    if(nargin==0)
        if exist('rptlist.m','file')
            reportNames={};
            rptlist;
        else
            error(message('rptgen:rptgen:noRptFileName'));
        end

    else


        outputStrings=isstring(varargin{1});
        n=numel(varargin);
        for i=1:n
            if isstring(varargin{i})
                varargin{i}=char(varargin{i});
            end
        end


        [setupFiles,options]=locParseInputs(varargin);
        refreshReportList=options.isGraphical;

        if(refreshReportList)

            rgRoot=RptgenML.Root;
            refreshAction=rgRoot.refreshReportList('-deferred');
        end

        try
            nSetupFiles=length(setupFiles);
            reportNames=cell(1,nSetupFiles);
            for i=1:nSetupFiles
                setupFile=setupFiles{i};
                reportName=locGenerateReport(setupFile,options);
                if outputStrings
                    reportName=string(reportName);
                end
                reportNames{i}=reportName;
            end

            if(refreshReportList)

                rgRoot=RptgenML.Root;
                rgRoot.refreshReportList(refreshAction);
            end
        catch ex
            if(~strcmp(ex.identifier,'MATLAB:UDD:DBQUIT'))
                rethrow(ex);
            end
        end
    end


    function[setupFiles,options]=locParseInputs(inputs)

        setupFiles={};
        options.isNoView=false;
        options.isGraphical=false;
        options.isQuiet=false;
        options.isVerbose=false;
        options.isDebug=false;
        options.format='';
        options.stylesheet='';
        options.OutputDirectory='';
        options.OutputFile='';
        options.ForceXmlSource=[];
        options.CleanFonts=false;

        for i=1:length(inputs)
            input=inputs{i};

            if(ischar(input))
                if(strcmpi(input,'-noview'))
                    options.isNoView=true;
                elseif(strcmpi(input,'-graphical'))
                    options.isGraphical=true;
                elseif(strcmpi(input,'-quiet'))
                    options.isQuiet=true;
                elseif(strcmpi(input,'-verbose'))
                    options.isVerbose=true;
                elseif(strcmpi(input,'-debug'))
                    options.isDebug=true;
                elseif(strncmpi(input,'-o',2))
                    [oPath,oFile]=fileparts(input(3:end));
                    oFile=strtrim(oFile);

                    if(~isempty(oPath))
                        options.OutputDirectory=oPath;
                    end
                    if(~isempty(oFile))
                        options.OutputFile=oFile;
                    end
                elseif(strncmpi(input,'-f',2))

                    options.format=input(3:end);
                elseif(strncmp(input,'-s',2))

                    options.stylesheet=input(3:end);
                elseif(strcmp(input,'-RetainXmlSource'))
                    options.ForceXmlSource=true;
                elseif(strcmp(input,'-DiscardXmlSource'))
                    options.ForceXmlSource=false;
                elseif(strcmpi(input,'-cleanfonts'))
                    options.CleanFonts=true;
                else
                    setupFiles=[setupFiles,{input}];%#ok<AGROW>
                end

            elseif(isa(input,'rptgen.rptcomponent')||...
                isa(input,'rptsp'))
                setupFiles=[setupFiles,{input}];%#ok<AGROW>
            end
        end


        function reportName=locGenerateReport(rpt,options)



            reportName='';

            if(options.isGraphical&&ischar(rpt))
                reportName=locRunGraphicalReportV2(rpt,options);
            else
                if(locIsSimulink(rpt))
                    rpt=rptgen.findSlRptName(rpt);
                end

                if(ischar(rpt))
                    rpt=rptgen.loadRpt(rpt);
                end


                if isa(rpt,'RptgenML.CReport')...
                    &&~isempty(rpt.find('-isa','rptgen_sl.csl_sys_snap'))
                    if~builtin('license','checkout','SIMULINK_Report_Gen')
                        error(message('RptgenSL:stdrpt:BaseErrorNoLicense'));
                    end
                end

                if(isa(rpt,'rptgen.coutline'))
                    try
                        reportName=locRunReportV2(rpt,options);
                    catch ex
                        if rpt.isDebug
                            rethrow(ex);
                        else


                            for i=1:length(ex.cause)
                                if(strncmp(ex.cause{i}.identifier,...
                                    'rptgen:hardException',...
                                    length('rptgen:hardException')))
                                    rethrow(ex);
                                end
                            end

                            disp(ex.message);
                        end
                    end
                else
                    error(message('rptgen:rptgen:invalidReportType',class(rpt)));
                end
            end


            function reportName=locRunReportV2(rpt,options)


                if(options.isNoView)
                    rpt.isView=false;
                end

                if(options.isDebug)
                    rpt.isDebug=true;
                end

                if(~isempty(options.format))
                    rpt.Format=options.format;
                end

                if(~isempty(options.ForceXmlSource))
                    rpt.ForceXmlSource=options.ForceXmlSource;
                end

                if(~isempty(options.stylesheet))
                    rpt.Stylesheet=options.stylesheet;
                end

                if(~isempty(options.OutputDirectory))
                    set(rpt,'DirectoryType','other','DirectoryName',options.OutputDirectory);
                end

                if(~isempty(options.OutputFile))
                    set(rpt,'FilenameType','other','FilenameName',options.OutputFile);
                end

                rpt.cleanupFontDirectory=options.CleanFonts;


                origDisplayLevel=locInitializeDisplayClient(options);
                try
                    reportName=rpt.execute;
                    locResetDisplayClient(origDisplayLevel);
                    restoreState(rptgen.ReportState(rpt));

                catch ME
                    rptgen.displayMessage(getString(message('rptgen:rptgen:reportErrorMessage')),1);
                    rptgen.displayMessage(ME.message,4);

                    locResetDisplayClient(origDisplayLevel);
                    restoreState(rptgen.ReportState(rpt));

                    if(rpt.isDebug)
                        rethrow(ME);
                    else
                        throwAsCaller(ME);
                    end
                end


                function origFilterLevel=locInitializeDisplayClient(options)


                    rptgen.internal.gui.GenerationDisplayClient.reset;
                    origFilterLevel=rptgen.internal.gui.GenerationDisplayClient.staticGetPriorityFilter;
                    if options.isDebug
                        rptgen.internal.gui.GenerationDisplayClient.staticSetPriorityFilter(6);
                    elseif(options.isQuiet)
                        rptgen.internal.gui.GenerationDisplayClient.staticSetPriorityFilter(0);
                    elseif(options.isVerbose)
                        rptgen.internal.gui.GenerationDisplayClient.staticSetPriorityFilter(6);
                    end


                    function reportName=locRunGraphicalReportV2(rpt,options)

                        genOpt={};

                        if(options.isNoView)
                            genOpt=[genOpt,'isView',false];
                        end

                        if(options.isDebug)
                            genOpt=[genOpt,'isDebug',true];
                        end

                        if(~isempty(options.format))
                            genOpt=[genOpt,'Format',options.format];
                        end

                        if(~isempty(options.stylesheet))
                            genOpt=[genOpt,'Stylesheet',options.stylesheet];
                        end

                        if(~isempty(options.OutputDirectory))
                            genOpt=[genOpt,'DirectoryType','other'];
                            genOpt=[genOpt,'DirectoryName',options.OutputDirectory];
                        end

                        if(~isempty(options.OutputFile))
                            genOpt=[genOpt,'FilenameType','other'];
                            genOpt=[genOpt,'FilenameName',options.OutputFile];
                        end

                        rgRoot=RptgenML.Root;
                        reportName=rgRoot.cbkReport(rpt,genOpt{:});


                        function locResetDisplayClient(origFilterLevel)

                            rptgen.internal.gui.GenerationDisplayClient.staticSetPriorityFilter(origFilterLevel);


                            function isSystem=locIsSimulink(sysName)

                                if(rptgen.isSimulinkLoaded)
                                    isSystem=~isempty(find_system('SearchDepth',0,'Name',sysName));
                                else
                                    isSystem=false;
                                end
