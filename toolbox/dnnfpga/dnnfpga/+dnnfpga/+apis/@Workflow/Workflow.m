classdef Workflow < handle

    properties ( GetAccess = public, SetAccess = protected )
        Network = [  ];
        Bitstream = '';
    end

    properties ( Access = public )
        Target = [  ];
    end

    properties ( Access = private )
        hDLQuantizer = [  ];
        DeployableNet = [  ];
        AllowDAGNetwork = [  ];

        OrigFixPtLicenseFeatureValue = 0;

        NotRunTiledLayerPos = [  ];

        ResetState = false;
    end

    properties ( Dependent, Access = private )
        BitstreamChecksum
        hProcessorPlatform
        DefaultVerbose
    end

    properties ( Access = private, Transient )

        hBitstream = [  ];

        hBitstreamManager = [  ];
    end

    properties ( Constant, Hidden = true )

        ExampleStrTemplate = 'hW = dlhdl.Workflow(''Network'', net, ''Bitstream'', ''%s'')';
        ExampleStr = sprintf( dnnfpga.apis.Workflow.ExampleStrTemplate, 'zcu102_single' );

    end


    methods ( Access = public )
        function this = Workflow( varargin )

            this.checkoutLicense;

            p = inputParser;
            addParameter( p, 'Network', [  ] );
            addParameter( p, 'Bitstream', '', @( x )ischar( x ) || isstring( x ) );
            addParameter( p, 'Target', [  ] );

            parse( p, varargin{ : } );

            this.hBitstreamManager = dnnfpga.bitstream.BitstreamManager;

            this.Bitstream = p.Results.Bitstream;


            if ( isempty( this.hBitstream ) )
                error( message( 'dnnfpga:workflow:BitstreamMissing' ) );
            end

            hPC = this.hBitstream.getProcessorConfig(  );
            this.AllowDAGNetwork = isa( hPC, 'dnnfpga.config.CNN5ProcessorConfig' );

            if ( isa( p.Results.Network, 'dlquantizer' ) )


                this.hDLQuantizer = p.Results.Network;


                this.Network = this.hDLQuantizer.Net;
            else


                this.hDLQuantizer = [  ];

                this.Network = p.Results.Network;
            end


            if isempty( this.Network )
                msg = message( 'dnnfpga:workflow:CreateNoNetwork' );
                error( msg );
            end

            if ( numel( this.Network.InputNames ) > 7 )
                error( message( 'dnnfpga:workflow:MaximumInputsLimitExceeded', numel( this.Network.InputNames ) ) );
            end

            if ( numel( this.Network.OutputNames ) > 7 )
                error( message( 'dnnfpga:workflow:MaximumOutputsLimitExceeded', numel( this.Network.OutputNames ) ) );
            end

            this.Target = p.Results.Target;



            hPC = this.hBitstream.getProcessorConfig(  );
            if ( isa( hPC, 'dnnfpga.config.CNN4ProcessorConfig' ) || isa( hPC, 'dnnfpga.config.CNN5ProcessorConfig' ) )
                if ( ~strcmpi( hPC.getModule( 'conv' ).KernelDataType, 'single' ) && ~isa( p.Results.Network, 'dlquantizer' ) )
                    error( message( 'dnnfpga:quantization:UnSupportedDlquantizer', class( p.Results.Network ) ) );
                end
            end

            this.OrigFixPtLicenseFeatureValue = fifeature( 'DLHDLTBX_CUST_INT' );
            fifeature( 'DLHDLTBX_CUST_INT', 1 );

        end
    end


    methods ( Access = public, Hidden = true )


        function delete( this )





            fifeature( 'DLHDLTBX_CUST_INT', this.OrigFixPtLicenseFeatureValue );
        end
    end


    methods
        function hPlatform = get.hProcessorPlatform( this )
            hPlatform = this.constructProcessorPlatform;
        end

        function cksm = get.BitstreamChecksum( this )
            cksm = this.hBitstream.getChecksum;
        end

        function verbose = get.DefaultVerbose( ~ )
            verbose = dnnfpgafeature( 'Verbose' );
        end
    end


    methods
        function set.Network( this, net )
            if ~isempty( net ) && ~dnnfpga.compiler.canCompileNet( net, ~this.AllowDAGNetwork )
                error( message( 'dnnfpga:workflow:InvalidInputWrongClass', 'Network', 'SeriesNetwork, DAGNetwork or dlnetwork.', class( net ) ) );
            else
                this.Network = net;
                this.DeployableNet = [  ];
            end
        end

        function set.Bitstream( this, bitstreamName )






            if ~isempty( bitstreamName )
                try
                    this.hBitstream = this.hBitstreamManager.resolveBitstream( bitstreamName, this.ExampleStrTemplate );%#ok<MCSUP>
                catch ME
                    throwAsCaller( ME );
                end





                this.checkProcessorVersionMatch;

            end
            this.Bitstream = bitstreamName;
        end

        function set.Target( this, target )
            if isempty( target ) || isa( target, 'dnnfpga.hardware.Target' )
                this.Target = target;
            else
                error( message( 'dnnfpga:workflow:InvalidInputWrongClass', 'Target', 'dlhdl.Target', class( target ) ) );
            end
        end
    end


    methods ( Access = public, Hidden = false )


        result = activations( this, varargin )

        function deploy( this, varargin )



            p = inputParser;

            addParameter( p, 'ProgramBitstream', true, @( x )islogical( x ) );
            addParameter( p, 'ProgramNetwork', true, @( x )islogical( x ) );
            addParameter( p, 'Verbose', this.DefaultVerbose, @isnumeric );


            parse( p, varargin{ : } );
            ProgramBitstream = p.Results.ProgramBitstream;
            ProgramNetwork = p.Results.ProgramNetwork;
            verbose = p.Results.Verbose;


            this.ResetState = false;


            this.checkoutLicense;



            this.validateBitstream(  );
            if ProgramNetwork
                this.validateNet(  );
            end


            if ProgramBitstream && ~isempty( this.Target )
                if ( this.Target.Interface ~= dlhdl.TargetInterface.File )
                    this.programBitstream( verbose );
                end
            end

            if ProgramNetwork
                if ( ( isempty( this.DeployableNet ) ) )





                    this.compile(  );
                end
                this.programNetwork( verbose );
            end








            if ( ProgramBitstream )

                this.writeChecksum(  );
            end


            if this.Target.Interface == dlhdl.TargetInterface.File
                this.Target.release(  );
            end

        end

        function resetState( this, varargin )
            this.ResetState = true;
        end

        function [ varargout ] = predictAndUpdateState( this, varargin )
            modified = this.addDefaultResetParams( false, false, varargin{ : } );
            varargout = this.predictBase( modified{ : } );
        end

        function [ varargout ] = predict( this, varargin )
            modified = this.addDefaultResetParams( true, false, varargin{ : } );
            varargout = this.predictBase( modified{ : } );
        end

        function dn = compile( this, varargin )



            p = inputParser;



            addParameter( p, 'InputFrameNumberLimit', 30, @isnumeric );


            addParameter( p, 'DeployableNetworkFileName', '', @ischar );
            addParameter( p, 'OutputTileWidthX', '' );
            addParameter( p, 'OutputTileWidthY', '' );
            addParameter( p, 'OutputTileWidthZ', '' );

            addParameter( p, 'ForceCompile', false, @islogical );
            addParameter( p, 'Verbose', this.DefaultVerbose, @isnumeric );
            addParameter( p, 'ActivationLayer', '', @ischar );
            addParameter( p, 'ActivationTile', [  ] );
            addParameter( p, 'UniqueActivations', 'off', @dnnfpga.parseUtils.validateBoolean );
            addParameter( p, 'HardwareNormalization', 'auto', @dnnfpga.parseUtils.validateOnOffOrAuto );
            parse( p, varargin{ : } );

            inputFrameNumberLimit = p.Results.InputFrameNumberLimit;
            uniqueActivations = dnnfpga.parseUtils.toBool( p.Results.UniqueActivations );
            hardwareNormalization = p.Results.HardwareNormalization;


            if ~isempty( p.Results.InputFrameNumberLimit ) && p.Results.InputFrameNumberLimit <= 0
                msg = message( 'dnnfpga:dnnfpgacompiler:InputFrameNumberLessThanZero',  ...
                    sprintf( '[%d]', p.Results.InputFrameNumberLimit ) );
                error( msg );
            end


            deployableNetworkFileName = p.Results.DeployableNetworkFileName;
            outputTileWidthX = p.Results.OutputTileWidthX;
            outputTileWidthY = p.Results.OutputTileWidthY;
            outputTileWidthZ = p.Results.OutputTileWidthZ;
            forceCompile = p.Results.ForceCompile;
            verbose = p.Results.Verbose;
            activationLayer = p.Results.ActivationLayer;
            tileActivation = p.Results.ActivationTile;


            this.validateBitstreamAndNet(  );


            this.checkoutLicense;





            if ( ~isempty( this.DeployableNet ) )
                compileParameter = this.DeployableNet.compileParameter;


                if ( any( compileParameter.outputTileWidthX ~= outputTileWidthX ) ||  ...
                        any( compileParameter.outputTileWidthY ~= outputTileWidthY ) ||  ...
                        any( compileParameter.outputTileWidthZ ~= outputTileWidthZ ) ||  ...
                        compileParameter.inputFrameNumberLimit ~= inputFrameNumberLimit ||  ...
                        compileParameter.verbose ~= verbose ||  ...
                        ~strcmp( compileParameter.hardwareNormalization, hardwareNormalization ) )
                    forceCompile = true;
                end
            end


            if isempty( this.DeployableNet ) || forceCompile



                this.displayCompileStartBanner( verbose );


                this.DeployableNet = this.compileNetwork(  ...
                    inputFrameNumberLimit, uniqueActivations, hardwareNormalization,  ...
                    outputTileWidthX, outputTileWidthY, outputTileWidthZ,  ...
                    verbose, activationLayer, tileActivation );


                this.displayCompileEndBanner( verbose );
            end

            this.emit( deployableNetworkFileName );

            singletonFPGALayer = this.DeployableNet.getSingletonFPGALayer;
            if ~isempty( singletonFPGALayer )
                data = singletonFPGALayer.getData(  );
                hProcessor = this.hBitstream.getProcessor(  );
                if isa( hProcessor, 'dnnfpga.processorbase.cnn5Processor' )























                    dn = data;
                end
            else
                dn = [  ];
            end

        end

        function info = getBuildInfo( this, NV )






            arguments
                this
                NV.Verbose{ mustBeMember( NV.Verbose, [ 0, 1 ] ) } = 1
            end


            if isempty( this.Bitstream )
                error( message( 'dnnfpga:workflow:BuildInfoWithoutBitstream', 'getBuildInfo' ) );
            end


            metric = 'Resources';
            info = [  ];
            switch metric
                case 'Resources'

                    info = this.hBitstream.getResources(  );
            end


            if NV.Verbose == 1


                if isempty( info )
                    warning( message( 'dnnfpga:workflow:BuildInfoEmptyMetricValue', 'Resource utilization' ) );
                else
                    format = dnnfpga.estimate.FormatTable.getParsedInformationFormat(  );
                    dnnfpga.estimate.FormatTable.printParsedInformation( info, format, metric );
                end
            end

        end

    end

    methods ( Access = protected )
        function out = predictBase( this, varargin )



            p = this.createPredictParser(  );

            n = numel( this.Network.InputNames );
            ln = this.countLeadingImages( varargin );


            if ln > n
                msg = message( 'dnnfpga:workflow:TooManyInputs', n );
                error( msg );
            end

            if ln < n
                msg = message( 'dnnfpga:workflow:NotEnoughInputs', n, ln );
                error( msg );
            end

            parse( p, varargin{ : } );



            n = numel( this.Network.InputNames );
            inputImages = cell( 1, n );
            for i = 1:n
                inputName = strcat( 'inputImage', int2str( i ) );
                inputImages{ i } = getfield( p.Results, inputName );
            end

            ProgramBitstream = p.Results.ProgramBitstream;
            ProgramNetwork = p.Results.ProgramNetwork;
            isCalledFromActivations = p.Results.IsCalledFromActivations;
            activationLayer = p.Results.ActivationLayer;
            verbose = p.Results.Verbose;
            profiler = dnnfpga.parseUtils.toBool( p.Results.Profiler );
            displayTable = dnnfpga.parseUtils.toBool( p.Results.DisplayProfilerResults );
            streamingMode = dnnfpga.parseUtils.toBool( p.Results.StreamingMode );
            streamingContinuous = dnnfpga.parseUtils.toBool( p.Results.StreamingContinuous );
            resetBefore = dnnfpga.parseUtils.toBool( p.Results.ResetBefore );
            resetAfter = dnnfpga.parseUtils.toBool( p.Results.ResetAfter );

            if this.ResetState
                resetBefore = true;
                this.ResetState = false;
            end



            this.validateInputRequirements( inputImages );


            if ( streamingMode )
                if ( numel( this.Network.InputNames ) > 1 || numel( this.Network.OutputNames ) > 1 )
                    error( message( 'dnnfpga:workflow:MIMOStreamingModeNotSupported' ) );
                end
            end


            if profiler && ( ( numel( this.Network.InputNames ) > 1 || numel( this.Network.OutputNames ) > 1 ) )
                error( message( 'dnnfpga:workflow:MIMOProfilerNotSupported' ) );
            end


            if ~isempty( this.Target )
                if this.Target.Interface == dlhdl.TargetInterface.File
                    error( [ 'Target Object is a File and not a Hardware Target.  ',  ...
                        'Please use a valid Hardware Target Object when calling predict.' ] );
                end
            end


            dnnfpga.UserSpecifiedBaseAddr.checkNonNegative( p.Results.InputBaseAddr, p.Results.OutputBaseAddr );

            useCustomBaseAddr = dnnfpga.parseUtils.toBool( p.Results.UseCustomBaseAddr );
            inputBaseAddr = uint32( p.Results.InputBaseAddr );
            outputBaseAddr = uint32( p.Results.OutputBaseAddr );

            if ( useCustomBaseAddr && ~isempty( this.DeployableNet ) )
                hPC = this.hBitstream.getProcessorConfig(  );
                dnnfpga.UserSpecifiedBaseAddr.checkValidAddress( hPC, inputBaseAddr, 'input' );
                dnnfpga.UserSpecifiedBaseAddr.checkValidAddress( hPC, outputBaseAddr, 'output' );

                dnnfpga.UserSpecifiedBaseAddr.checkNoCollisions( this.DeployableNet, inputBaseAddr, outputBaseAddr );
            end


            this.validateBitstreamAndNet(  );


            this.checkoutLicense;


            if isa( this.Network, 'dlnetwork' )
                for i = 1:numel( inputImages )
                    inputImages{ i } = extractdata( inputImages{ i } );
                end
            end




















            this.deploy( 'Verbose', 2, 'ProgramBitstream', ProgramBitstream, 'ProgramNetwork', ProgramNetwork );



            fpgalayer = this.DeployableNet.getSingletonFPGALayer;
            hIR = fpgalayer.getDepolyableIR( true );
            inputcomps = hIR.sgraph.getInputComponents;
            selectInputImages = cell( 1, numel( inputcomps ) );
            for i = 1:numel( inputcomps )
                input = inputcomps{ i }.name;
                matchingIndex = find( strcmpi( this.Network.InputNames, input ), 1 );
                selectInputImages( i ) = inputImages( matchingIndex );
            end


            result = this.predictOnNetwork(  ...
                selectInputImages, streamingMode, streamingContinuous,  ...
                useCustomBaseAddr, inputBaseAddr, outputBaseAddr, resetBefore, resetAfter,  ...
                verbose );



            outputnames = this.Network.OutputNames;
            NA = nnet.internal.cnn.analyzer.NetworkAnalyzer( this.Network );
            layers = NA.ExternalLayers;
            fn = @( x )x.Name;
            layernames = arrayfun( fn, layers, 'UniformOutput', false );


            for outputIndex = 1:numel( result )










                isFormatOneByOneByN = sum( size( result{ outputIndex }, 1:2 ) == 1 ) > 1;
                if isFormatOneByOneByN && ~isCalledFromActivations
                    result{ outputIndex } = dnnfpga.bitstreambase.fpgaDeployment.formatPredictions( result{ outputIndex } );
                end

                if ( isa( this.Network, 'dlnetwork' ) )


                    if isCalledFromActivations
                        nameparts = strsplit( activationLayer, '/' );
                        outname = nameparts{ 1 };
                    else
                        outname = outputnames{ outputIndex };
                    end
                    tf = strcmp( outname, layernames );
                    LA = NA.LayerAnalyzers( tf );
                    fmt = LA.Outputs.Meta{ 1 }.dims;





                    bdim = find( fmt == 'B' );
                    if size( result{ outputIndex }, bdim ) == 1
                        fmt = fmt( 1:bdim - 1 );
                    end
                    result{ outputIndex } = dlarray( result{ outputIndex }, fmt );
                end
            end
            out = result;
            if ( profiler )
                this.scanProfiler( [  ] );

                isSequential = dnnfpga.dagCompile.Utils.isRNN( this.Network );
                if isSequential
                    dim = 2;
                else
                    dim = 4;
                end
                if iscell( inputImages )
                    numImages = size( inputImages{ 1 }, dim );
                else
                    numImages = size( inputImages, dim );
                end



                fpgaLayerParams = this.DeployableNet.getSingletonFPGALayer.getDepolyableIR;

                speed = this.parseProfileLogs( 'profileRawLogs.mat', fpgaLayerParams, verbose, numImages, displayTable );

                if ( isempty( speed ) )
                    dnnfpga.disp( message( 'dnnfpga:workflow:SpeedTableEmpty' ) );
                end
            else
                speed = [  ];
            end
            out{ end  + 1 } = speed;

        end
    end


    methods ( Access = protected )
        deployableNW = compileNetwork( this, inputFrameNumberLimit, uniqueActivations, hardwareNormalization, outputTileWidthX, outputTileWidthY, outputTileWidthZ, verbose, activationLayer, tileActivation )

        results = predictOnNetwork( this, imgs, streamingMode, streamingContinuous,  ...
            useCustomBaseAddr, inputBaseAddr, outputBaseAddr, resetBefore, resetAfter,  ...
            verbose )

        programBitstream( this, verbose )

        programNetwork( this, verbose )

        setupProfiler( this, options )

        profRawLogs = scanProfiler( this, options )

        profileTable = parseProfileLogs( this, rawLogs, fpgaLayerParams, verbose, numImages, displayTable )
    end


    methods ( Access = protected )
        function validateBitstream( this )
            if isempty( this.hBitstream )
                error( message( 'dnnfpga:workflow:InvalidInputEmpty', 'Bitstream' ) );
            end

            if ~isa( this.hBitstream, 'dnnfpga.bitstream.Bitstream' )
                error( message( 'dnnfpga:workflow:InvalidDataWrongClass', 'hBitstream', 'dlhdl.Bitstream', class( this.hBitstream ) ) );
            end






        end

        function validateNet( this )
            if isempty( this.Network )
                error( message( 'dnnfpga:workflow:InvalidInputEmpty', 'Network' ) );
            end

            if ~dnnfpga.compiler.canCompileNet( this.Network, ~this.AllowDAGNetwork )
                error( message( 'dnnfpga:workflow:InvalidInputWrongClass', 'Network', 'SeriesNetwork or DAGNetwork', class( this.Network ) ) );
            end
        end

        function validateBitstreamAndNet( this )
            this.validateBitstream(  );
            this.validateNet(  );
        end

        function validateTarget( this )
            if isempty( this.Target )
                error( message( 'dnnfpga:workflow:InvalidInputEmpty', 'Target' ) );
            end

            if ~isa( this.Target, 'dnnfpga.hardware.Target' )
                error( message( 'dnnfpga:workflow:InvalidInputWrongClass', 'Target', 'dlhdl.Target', class( this.Target ) ) );
            end
        end

        function validateInputRequirements( this, inputImages )
            frames = 0;
            for i = 1:numel( inputImages )

                if ( isa( inputImages{ i }, 'matlab.io.datastore.ImageDatastore' ) )
                    error( message( 'dnnfpga:workflow:ImageDatastoreInputsNotSupported' ) );
                end

                if ( ~frames )
                    frames = size( inputImages{ i }, 4 );
                else
                    if ( size( inputImages{ i }, 4 ) ~= frames )
                        inputnames = this.Network.InputNames;
                        msgid = 'dnnfpga:workflow:MultipleInputsFrameNumberMismatch';
                        msg = message( msgid, inputnames{ 1 }, frames, inputnames{ i }, size( inputImages{ i }, 4 ) );
                        error( msg );
                    end
                end

                if ( isa( this.Network, 'dlnetwork' ) )
                    if ( ~isa( inputImages{ i }, 'dlarray' ) || isempty( dims( inputImages{ i } ) ) )
                        error( message( 'dnnfpga:workflow:InputMustbeDlarray' ) );
                    end
                elseif ( isa( this.Network, 'SeriesNetwork' ) || isa( this.Network, 'DAGNetwork' ) )
                    if isdlarray( inputImages{ i } )
                        error( message( 'dnnfpga:workflow:DlarrayUnsupported', this.Network.InputNames{ i } ) );
                    end
                end
            end
        end
        function n = countLeadingImages( ~, args )
            function v = likelyIsImage( im )
                v = ~ischar( im ) && ~isstring( im );
            end
            n = 0;
            for i = 1:numel( args )
                val = args{ i };
                if ~likelyIsImage( val )
                    break ;
                end
                n = i;
            end
            n = max( n, 1 );
        end
        function modified = addDefaultResetParams( this, resetBefore, resetAfter, varargin )
            p = this.createPredictParser( resetBefore, resetAfter );
            try
                p.parse( varargin{ : } );
            catch
                modified = varargin;
                return ;
            end

            modified = [ varargin, { 'ResetBefore', p.Results.ResetBefore, 'ResetAfter', p.Results.ResetAfter } ];
        end
        function p = createPredictParser( this, resetBefore, resetAfter )
            if nargin < 2
                resetBefore = 'on';
            end
            if nargin < 3
                resetAfter = 'off';
            end


            p = inputParser;



            n = numel( this.Network.InputNames );
            for i = 1:n
                addRequired( p, strcat( 'inputImage', int2str( i ) ), @( x )dnnfpga.apis.Workflow.validateInputImages( x, true ) )
            end
            addParameter( p, 'ProgramBitstream', true, @islogical );
            addParameter( p, 'ProgramNetwork', true, @islogical );
            addParameter( p, 'Profiler', 'off', @dnnfpga.parseUtils.validateBoolean );
            addParameter( p, 'Verbose', this.DefaultVerbose, @isnumeric );
            addParameter( p, 'IsCalledFromActivations', false, @islogical );
            addParameter( p, 'ActivationLayer', '', @ischar );

            addParameter( p, 'DisplayProfilerResults', 'on', @dnnfpga.parseUtils.validateBoolean );
            addParameter( p, 'StreamingMode', 'off', @dnnfpga.parseUtils.validateBoolean );
            addParameter( p, 'StreamingContinuous', 'off', @dnnfpga.parseUtils.validateBoolean );
            addParameter( p, 'UseCustomBaseAddr', 'off', @dnnfpga.parseUtils.validateBoolean );
            addParameter( p, 'InputBaseAddr', 0, @isnumeric );
            addParameter( p, 'OutputBaseAddr', 0, @isnumeric );
            addParameter( p, 'ResetBefore', resetBefore, @dnnfpga.parseUtils.validateBoolean );
            addParameter( p, 'ResetAfter', resetAfter, @dnnfpga.parseUtils.validateBoolean );
        end

        function connectTarget( this )






            this.validateTarget;
            this.Target.connectToBitstream( this.hBitstream );
        end

        function disconnectTarget( this )
            this.validateTarget;
            this.Target.release(  );
        end

        function emit( this, outputFileName )
            if ( ~isempty( outputFileName ) )
                deployableNW = this.DeployableNet;
                save( outputFileName, 'deployableNW' );
            end
        end

        function hPlatform = constructProcessorPlatform( this )

            this.connectTarget(  );







            hPlatform = dnnfpga.bitstreambase.cnn5ProcessorPlatform( this.hBitstream, this.Target );
        end

        function writeChecksum( this )

            hPlatform = this.constructProcessorPlatform;
            hPlatform.writeBitstreamChecksumToFPGA( this.BitstreamChecksum );
        end

        function cksm = readChecksum( this )

            hPlatform = this.constructProcessorPlatform;
            cksm = hPlatform.readBitstreamChecksumFromFPGA;
        end

        function checkoutLicense( ~ )

            try
                dnnfpga.utilscripts.checkUtility;
            catch ME

                throwAsCaller( ME );
            end
        end

    end

    methods ( Static = true, Hidden = true )
        function isAcceptableImgs = validateInputImages( Imgs, checkNonEmpty )
            if nargin < 2
                checkNonEmpty = false;
            end
            attributes = { 'real' };
            if checkNonEmpty
                attributes{ end  + 1 } = 'nonempty';
            end
            validateattributes( Imgs, { 'numeric', 'matlab.io.datastore.ImageDatastore' }, attributes )
            isAcceptableImgs = true;
        end

        [ acts_idx, acts_lname, acts_output ] = parseActivationLayerName( net, activationLayer )
    end

    methods ( Access = public, Hidden = true )

        function notRunTiledLayerPos = getNonRunTiledLayerPos( this )
            notRunTiledLayerPos = this.NotRunTiledLayerPos;
        end


        function [ prediction, fps ] = predictWithProfile( obj, varargin )

            p = inputParser;
            addRequired( p, 'InputImages', @( x )dnnfpga.apis.Workflow.validateInputImages( x, true ) );
            parse( p, varargin{ : } );
            inputImages = p.Results.InputImages;
            [ prediction, profiler ] = obj.predict( inputImages, 'Profiler', 'on', 'DisplayProfilerResults', 'off' );

            fps = str2double( profiler{ 1, { 'Frame/s' } } );
        end

    end

    methods ( Access = protected, Hidden = true )
        checkProcessorVersionMatch( this )

    end

    methods ( Access = private )
        function displayCompileStartBanner( this, verbose )
            dnnfpga.disp( message( 'dnnfpga:dnnfpgadisp:CompileStartMsg' ), this.DefaultVerbose, verbose );
            dnnfpga.disp( message( 'dnnfpga:dnnfpgadisp:TargetBitstreamMsg', this.Bitstream ), this.DefaultVerbose, verbose );
        end

        function displayCompileEndBanner( this, verbose )
            dnnfpga.disp( char( "Network compilation complete." + newline ), this.DefaultVerbose, verbose );
        end
    end
end



