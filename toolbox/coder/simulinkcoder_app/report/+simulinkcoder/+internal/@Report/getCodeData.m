function data = getCodeData( model, ref, top, reportV2Gen )

arguments
    model
    ref = false
    top = ''
    reportV2Gen = false
end

data = [  ];
try
    [ bool, rptInfo, ref ] = simulinkcoder.internal.util.isCodeAvailable( model, ref );

    if ~bool
        data.message = rptInfo;

        xil = get_param( bdroot, 'XILLatestBlockPath' );
        if ~isempty( xil )
            data.xil = xil;
        end
        return ;
    end

    [ file, ~, covFiles, ref ] = simulinkcoder.internal.Report.getCodeDataFile( model, ref );

    if ~isfile( file ) || reportV2Gen
        data = simulinkcoder.internal.Report.genCodeData( model, file, ref, reportV2Gen );
    else
        loaded = load( file, '-mat' );
        data = loaded.data;
        files = data.files;
        fileInfo = rptInfo.getFileInfo_Cached(  );

        needUpdate = false;
        if length( files ) ~= length( fileInfo )
            needUpdate = true;
        end

        if ~needUpdate
            d = dir( file );
            for i = 1:length( fileInfo )
                info = fileInfo( i );
                source = fullfile( info.Path, info.FileName );
                s = dir( source );
                if ~isempty( s )
                    if s.datenum > d.datenum
                        needUpdate = true;
                        break ;
                    end
                end
            end
        end

        if needUpdate
            data = simulinkcoder.internal.Report.genCodeData( model, file, ref );
        end
    end


    if ~isfield( data, 'arch' )
        data.arch = struct( 'ispc', ispc, 'isunix', isunix, 'ismac', ismac );
    end


    if ~slfeature( 'DecoupleCodeMetrics' )
        cmFile = fullfile( rptInfo.getReportDir, 'codeMetrics.mat' );
    else
        cmFile = fullfile( rptInfo.CodeGenFolder, rptInfo.ModelRefRelativeBuildDir, 'tmwinternal', 'codeMetrics.mat' );
    end

    if isfile( cmFile )
        cmLoad = load( cmFile );
        codeMetrics = cmLoad.codeMetrics;
        if strcmp( codeMetrics.LatestStatus.Status, 'successful' )
            props = { 'GlobalVarInfo', 'GlobalConstInfo', 'FcnInfo' };
            cm = [  ];
            for i = 1:length( props )
                prop = props{ i };
                cm.( prop ) = codeMetrics.( prop );
            end
            data.cm = cm;
        end
    end


    st = dbstack;
    if numel( st ) >= 2 && strcmp( st( 2 ).name, 'loc_emitHTML_V2' )

        reportGen = true;
    else
        reportGen = false;
    end

    cr = simulinkcoder.internal.Report.getInstance;
    if cr.features.profiling
        if ~isempty( top )
            model = top;
        end

        if ~reportGen || ( strcmpi( get_param( model, 'CodeExecutionProfiling' ), 'on' ) && reportGen )
            try
                info = [  ];
                profilingVariable = get_param( model, 'CodeExecutionProfileVariable' );
                if strcmp( get_param( model, 'ReturnWorkspaceOutputs' ), 'on' )
                    out = get_param( model, 'ReturnWorkspaceOutputsName' );
                    outputVariable = evalin( 'base', out );
                    if isprop( outputVariable, profilingVariable )
                        info = outputVariable.get( profilingVariable );
                    end
                else
                    evalStr = sprintf( 'exist(''%s'', ''var'')', profilingVariable );
                    pVExists = evalin( 'base', evalStr );
                    if pVExists
                        info = evalin( 'base', profilingVariable );
                    end
                end

                if ~isempty( info )
                    profilingInfo = info.Sections;
                    timerTicksPerSecond = info.TimerTicksPerSecond;
                    unitOfTime = info.getUnitOfMeasurement;
                    props = { 'MaximumExecutionTimeInTicks', 'MaximumSelfTimeInTicks',  ...
                        'TotalExecutionTimeInTicks', 'TotalSelfTimeInTicks', 'NumCalls' };

                    proInfo = struct( [  ] );
                    for i = 1:length( profilingInfo )
                        for j = 1:length( props )
                            proInfo( i ).( props{ j } ) = profilingInfo( i ).( props{ j } );
                        end
                        proInfo( i ).FileNames = profilingInfo( i ).getTraceInfo.getFileNames;
                        proInfo( i ).LineNumbers = profilingInfo( i ).getTraceInfo.getLineNumbers;
                        t = profilingInfo( i ).getTraceInfo;
                        str = t.getCodeSectionName;
                        if t.isTask
                            str = regexprep( str, '\s\[[^()]*\]', '' );
                        end
                        proInfo( i ).CodeSectionName = str;


                        if cr.features.showProfilingInfo
                            lReportFcn = 'coder.internal.SLCExecTimeReport';
                            displayInSeconds = ~isempty( info.TimerTicksPerSecond ) && uint64( info.TimerTicksPerSecond ) > uint64( 0 );
                            section = profilingInfo( i );
                            proInfo( i ).Statistics = struct( 'Histogram', [  ], 'SDIPlot', [  ], 'Data', [  ], 'PieChart', [  ] );



                            [ ~, hstMatlabCmd, hstTooltip ] =  ...
                                coder.profile.ExecTimeHelper.getDataForHistogramLink ...
                                ( section, model, displayInSeconds, lReportFcn, false, false );
                            if ~isempty( hstMatlabCmd ) && ~isempty( hstTooltip )
                                proInfo( i ).Statistics.Histogram = char( hstMatlabCmd, hstTooltip );
                            end



                            [ ~, sdiMatlabCmd, sdiTooltip ] =  ...
                                coder.profile.ExecTimeHelper.getDataForSdiLink ...
                                ( section, model, lReportFcn, false, true, false );
                            if ~isempty( sdiMatlabCmd ) && ~isempty( sdiTooltip )
                                proInfo( i ).Statistics.SDIPlot = char( sdiMatlabCmd, sdiTooltip );
                            end




                            [ ~, apiMatlabCmd, apiTooltip ] =  ...
                                coder.profile.ExecTimeHelper.getDataForApiLink ...
                                ( section, model, lReportFcn, true );
                            if ~isempty( apiMatlabCmd ) && ~isempty( apiTooltip )
                                proInfo( i ).Statistics.Data = char( apiMatlabCmd, apiTooltip );
                            end



                            [ ~, pieMatlabCmd, pieTooltip ] =  ...
                                coder.profile.ExecTimeHelper.getDataForPieLink ...
                                ( section, model, lReportFcn, false );
                            if ~isempty( pieMatlabCmd ) && ~isempty( pieTooltip )
                                proInfo( i ).Statistics.PieChart = char( pieMatlabCmd, pieTooltip );
                            end
                        end
                    end
                    pInfo = struct(  );
                    pInfo.proInfo = proInfo;
                    pInfo.UnitOfTime = unitOfTime;
                    if isempty( timerTicksPerSecond )
                        pInfo.TimerTicksPerSecond = 1;
                    else
                        pInfo.TimerTicksPerSecond = timerTicksPerSecond;
                    end

                    if cr.features.showTaskSummary
                        pInfo.TaskSummary = info.getTaskSummary(  );
                    end
                    data.pInfo = pInfo;
                end
            catch
            end
        end
    end


    if cr.features.coverage
        try
            covType = {
                SlCov.coder.EmbeddedCoder.getName(  )
                coder.coverage.Bullseye.getName(  )
                coder.coverage.LDRA.getName(  )
                };

            covDisplayName = {
                SlCov.coder.EmbeddedCoder.getDisplayName(  )
                coder.coverage.Bullseye.getDisplayName(  )
                coder.coverage.LDRA.getDisplayName(  )
                };

            n = length( covType );
            covData = cell( n, 1 );
            for i = 1:n
                type = covType{ i };
                covList = {  };

                if ~strcmp( type, SlCov.coder.EmbeddedCoder.getName(  ) ) ||  ...
                        strcmp( get_param( model, 'CovUI_isHighlightingApplied' ), 'on' ) ||  ...
                        ( strcmp( type, SlCov.coder.EmbeddedCoder.getName(  ) ) && reportV2Gen )

                    for j = 1:length( covFiles )
                        covFile = [ covFiles{ j }, '_', type ];
                        if isfile( covFile )
                            covLoad = load( covFile, '-mat' );
                            cov = covLoad.covData;
                            [ ~, cov.file, ~ ] = fileparts( covFile );
                            covList{ end  + 1 } = cov;%#ok<AGROW>
                        end
                    end
                end

                covStruct = [  ];
                covStruct.id = type;
                covStruct.name = covDisplayName{ i };
                covStruct.files = covList;
                covData{ i } = covStruct;
            end
            data.coverage = covData;
        catch
        end
    end


    data.features = cr.features;

catch ME
    data = [  ];
    data.message = ME.message;
end


