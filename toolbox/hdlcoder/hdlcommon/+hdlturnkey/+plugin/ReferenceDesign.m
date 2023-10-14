classdef ( Abstract )ReferenceDesign < hdlturnkey.plugin.PluginBaseWithInterface

    properties
        AuthorName = '';
        AuthorWeb = '';
        AuthorEmail = '';
        AuthorPhone = '';


        ReferenceDesignName = '';
        BoardName = '';


        SupportedToolVersion = {  };



        CustomConstraints = {  };

        CustomFiles = {  };


        PostTargetReferenceDesignFcn = [  ];
        PostTargetInterfaceFcn = [  ];
        PostCreateProjectFcn = [  ];
        PostSWInterfaceFcn = [  ];
        PostSWInterfaceScriptFcn = [  ];
        PostDeviceTreeGenerationFcn = [  ];
        PostBuildBitstreamFcn = [  ];


        CallbackCustomProgrammingMethod = [  ];


        CustomizeReferenceDesignFcn = [  ];


        HasProcessingSystem = true;


        IPRepositories = {  };
        IPRepositoriesMsgs = {  }


        MATLABAXIManagerDefaultValue = 'off';
        AddMATLABAXIManagerParameter = true;


        GenerateIPCoreDeviceTreeNodes = false;

        ResourcesUsed = struct( 'LogicElements', 0, 'DSP', 0, 'RAM', 0 );


        StaticParameterFinished = false;
        DynamicParameterFinished = false;

    end

    properties ( GetAccess = public, SetAccess = protected )

        SupportedTool = '';
    end

    properties ( Access = protected )

        hParameterList = [  ];


        hProcessingSystem hdlturnkey.ProcessingSystem
    end

    properties ( Hidden = true )

        CallbackSWModelGeneration = [  ];


        ExternalRD = false;

        RDFolderPath = '';

        SharedRD = false;

        SharedRDFolder = '';



        isSupported = true;


        hasDynamicAXI4SlaveInterface = false;



        ReferenceDesignVersion = '';


        hClockModule = [  ];


        isAXI4SlaveInterfaceInUse = false;


        EnableJTAGFPGADataCapture = true;




        SystemInitFolderName = '';









        SupportedProgrammingMethods hdlcoder.ProgrammingMethod


        ForceRBF = false;


        ReportTimingFailure = hdlcoder.ReportTiming.Error;


        ReportTimingFailureTolerance = 0;

        hashdlverifierIP = false;


        GenerateSplitBitstream = false;


        UserData = [  ];


        GenerateDeviceTreeNodesAsOverlay = false;



        AddJTAGMATLABasAXIMasterParameter = false;



        EthernetIPAddressDefaultValue = '192.168.0.2';
        EthernetPortAddr = [ 50101, 50102, 50103, 50104, 50105, 50106, 50107, 50108 ];
        EthernetMACAddr = '0x000A3502218A';
        EthernetNumChannels = 8;
    end


    properties ( Dependent, Hidden = true )














        EmbeddedCoderSupportPackage hdlcoder.EmbeddedCoderSupportPackage



        DeviceTreeName
    end


    properties ( Hidden = true, Constant )
        ClockExampleStr = hdlturnkey.ClockModuleIP.ClockExampleStr;
        IPRepositoryExampleStr = 'hRD.addIPRepository(''IPListFunction'',''adi.hdmi.vivado.hdlcoder_video_iplist'',''NonExistMessage'', msg)';
    end

    properties ( Abstract, Hidden = true, Constant )
        AXI4SlaveExampleStr
        ExpectedEmbeddedCoderSupportPackage
    end


    properties ( Access = protected )

        DeepLearningInterfaces


        DeepLearningMemoryBaseAddress double{ mustBeNonnegative } = 0;
        DeepLearningMemoryAddressRange double{ mustBeNonnegative } = 0;
    end

    properties ( Constant, Access = protected )
        MinimumDeepLearningMemorySize double = 0x2000000;
    end

    methods

        function obj = ReferenceDesign(  )

            obj = obj@hdlturnkey.plugin.PluginBaseWithInterface(  );
            obj.hParameterList = hdlturnkey.data.ParameterList( obj );
            obj.IPInsertionMethod = 'Insert';

            if obj.EnableJTAGFPGADataCapture
                obj.addCustomInterface(  ...
                    'InterfaceClass', 'hdlturnkey.interface.JTAGDataCapture',  ...
                    'InterfaceArgumentCell', {  },  ...
                    'ActionWhenInterfaceNotExist', 'Show',  ...
                    'NotExistInterfaceID', 'FPGA Data Capture (Not installed)',  ...
                    'NotExistMessage', 'HDL Verifier Hardware Support Package Not Installed' );
            end
        end


        function set.ResourcesUsed( obj, val )
            fields = fieldnames( val );
            for i = 1:numel( fields )
                if ( any( strcmp( fields{ i }, { 'RAM', 'LogicElements', 'DSP' } ) ) )
                    if ~isnumeric( val.( fields{ i } ) ) || ( val.( fields{ i } ) < 0 )
                        error( message( 'hdlcommon:plugin:InvalidPropertyValueNoEx',  ...
                            string( val.( fields{ i } ) ), fields{ i } ) );
                    end
                else
                    error( message( 'hdlcommon:plugin:InvalidPropertyName',  ...
                        fields{ i }, [ '''RAM''', ', ', '''LogicElements''', ', ', 'and ', '''DSP''' ] ) );
                end
                obj.ResourcesUsed.( fields{ i } ) = val.( fields{ i } );
            end
        end

    end


    methods
        function set.EmbeddedCoderSupportPackage( obj, sppkg )
            if ( sppkg ~= hdlcoder.EmbeddedCoderSupportPackage.None ) && ( sppkg ~= obj.ExpectedEmbeddedCoderSupportPackage )


                expectedSppkgStr = char( obj.ExpectedEmbeddedCoderSupportPackage );
                noneSppkgStr = char( hdlcoder.EmbeddedCoderSupportPackage.None );
                error( message( 'hdlcommon:plugin:InvalidSupportPackageEnumeration', obj.SupportedTool, expectedSppkgStr, noneSppkgStr ) );
            end



            if sppkg == hdlcoder.EmbeddedCoderSupportPackage.None
                hasPS = false;
            else
                hasPS = true;
            end

            obj.HasProcessingSystem = hasPS;











        end

        function set.DeviceTreeName( obj, dtName )






            obj.DeviceTree = '';


            obj.addDeviceTree( dtName );
        end
    end


    methods

        function addClockInterface( obj, varargin )



            hdlturnkey.plugin.validateSingleMethod(  ...
                obj.hClockModule, 'addClockInterface()' );


            obj.hClockModule = hdlturnkey.ClockModuleIP( varargin{ : } );
        end

        function addProcessingSystem( obj, varargin )

            hdlturnkey.plugin.validateSingleMethod(  ...
                obj.hProcessingSystem, 'addProcessingSystem()' );

            obj.hProcessingSystem = hdlturnkey.ProcessingSystem( varargin{ : } );
        end

        function addAXI4SlaveInterface( obj, varargin )





            if ( obj.isAXI4SlaveInterfaceInUse )
                error( message( 'hdlcommon:plugin:MethodOnlyOnce', 'addAXI4SlaveInterface()' ) );
            end


            if isempty( obj.hClockModule )
                error( message( 'hdlcommon:plugin:InvalidClockModule', obj.ClockExampleStr ) );
            end









            p = inputParser;
            p.KeepUnmatched = true;
            p.addParameter( 'InterfaceType', { 'AXI4-Lite', 'AXI4' } );
            p.addParameter( 'InterfaceID', '' );
            p.addParameter( 'IDWidth', 12 );
            p.addParameter( 'InterfaceConnection', '' );

            p.parse( varargin{ : } );

            interfaceType = downstream.tool.convertToCell( p.Results.InterfaceType );
            interfaceID = p.Results.InterfaceID;
            obj.validateAXI4SlaveInterfaceType( interfaceType, interfaceID );


            interfaceArgs = {  };

            interfaceArgs( end  + 1:end  + 2 ) = { 'MasterConnection', p.Results.InterfaceConnection };

            interfaceArgs( end  + 1:end  + 2 ) = { 'AXI4SlaveExampleStr', obj.AXI4SlaveExampleStr };

            if ~isempty( obj.hClockModule )



                interfaceArgs( end  + 1:end  + 2 ) = { 'ClockConnection', obj.hClockModule.ClockConnection };
                interfaceArgs( end  + 1:end  + 2 ) = { 'ResetConnection', obj.hClockModule.ResetConnection };
            end

            if ~isempty( interfaceID )
                interfaceArgs( end  + 1:end  + 2 ) = { 'InterfaceID', interfaceID };
            end

            interfaceArgs = [ interfaceArgs, namedargs2cell( p.Unmatched ) ];


            for ii = 1:length( interfaceType )
                switch interfaceType{ ii }
                    case 'AXI4'





                        interfaceArgs( end  + 1:end  + 2 ) = { 'IDWidth', p.Results.IDWidth };
                        obj.addAXI4Interface( interfaceArgs{ : } );
                    case 'AXI4-Lite'
                        obj.addAXI4LiteInterface( interfaceArgs{ : } );
                end
            end



            obj.IPInsertionMethod = 'Insert';


            obj.isAXI4SlaveInterfaceInUse = true;


        end

        function addAXI4StreamInterface( obj, varargin )


            error( message( 'hdlcommon:plugin:VivadoOrQuartus', 'AXI4-Stream' ) );
        end

        function addAXI4StreamVideoInterface( obj, varargin )


            error( message( 'hdlcommon:plugin:VivadoOnly', 'AXI4-Stream Video',  ...
                'hdlcoder.ReferenceDesign(''SynthesisTool'', ''Xilinx Vivado'')' ) );
        end

        function addAXI4MasterInterface( obj, varargin )


            error( message( 'hdlcommon:plugin:InterfaceNotSupportedByTool',  ...
                'AXI4 Master', 'Xilinx ISE' ) );
        end


        function addParameter( obj, varargin )


            if ( obj.StaticParameterFinished )

                obj.hParameterList.DynamicParameterList.addParameter( varargin{ : } );
            else

                obj.hParameterList.addParameter( varargin{ : } );
            end
        end


        function removeParameter( obj, varargin )

            obj.hParameterList.removeParameter( varargin{ : } );
        end


        function addIPRepository( obj, varargin )
            p = inputParser;
            p.addParameter( 'IPListFunction', '' );
            p.addParameter( 'NotExistMessage', '' );

            p.parse( varargin{ : } );
            inputArgs = p.Results;


            hdlturnkey.plugin.validateRequiredParameter(  ...
                inputArgs.IPListFunction, 'IPListFunction', obj.IPRepositoryExampleStr );


            hdlturnkey.plugin.validateStringProperty(  ...
                inputArgs.IPListFunction, 'IPListFunction', obj.IPRepositoryExampleStr );
            hdlturnkey.plugin.validateStringProperty(  ...
                inputArgs.NotExistMessage, 'NotExistMessage', obj.IPRepositoryExampleStr );

            obj.IPRepositories{ end  + 1 } = inputArgs.IPListFunction;
            obj.IPRepositoriesMsgs{ end  + 1 } = inputArgs.NotExistMessage;

        end
    end



    methods ( Hidden )

        function value = getAXIParameterValue( obj )
            value = 'off';
            paramCell = obj.getParameterCellFormat;
            Param_Index = find( strcmp( paramCell, 'HDLVerifierAXI' ) );
            if ~isempty( Param_Index )
                value = paramCell( Param_Index + 1 );
            end
        end


        function value = getFDCParameterValue( obj )
            value = { 'JTAG' };
            paramCell = obj.getParameterCellFormat;
            Param_Index = find( strcmp( paramCell, 'HDLVerifierFDC' ) );
            if ~isempty( Param_Index )
                value = paramCell( Param_Index + 1 );
            end
        end


        function value = getJTAGAXIParameterValue( obj )
            value = false;
            ParameterValue = getAXIParameterValue( obj );
            if strcmp( ParameterValue, 'JTAG' )
                value = true;
            end
        end



        function value = getEthernetFDCParameterValue( obj )
            value = false;
            ParameterValue = getFDCParameterValue( obj );
            if strcmp( ParameterValue, 'Ethernet' )
                value = true;
            end
        end


        function value = getEthernetAXIParameterValue( obj )
            value = false;
            ParameterValue = getAXIParameterValue( obj );
            if strcmp( ParameterValue, 'Ethernet' )
                value = true;
            end
        end


        function value = getEthernetIPAddressValue( obj )
            value = obj.EthernetIPAddressDefaultValue;
            paramCell = obj.getParameterCellFormat;
            Param_Index = find( strcmp( paramCell, 'EthernetIPAddress' ) );
            if ~isempty( Param_Index )
                value = paramCell( Param_Index + 1 );
            end
        end



        function updateIPrepository( obj )
            if ~( builtin( 'license', 'checkout', 'EDA_Simulator_Link' ) )

                error( message( 'hdlcommon:plugin:HDLVLicenseissue' ) );
            end


            if strcmp( obj.SupportedTool, 'Xilinx Vivado' )
                msg = message( 'hdlcommon:plugin:IPRepositoryHDLVerifierXilinxNotFound' ).getString;
                obj.addIPRepository(  ...
                    'IPListFunction', 'hdlverifier.fpga.vivado.iplist',  ...
                    'NotExistMessage', msg );
            end


            if strcmp( obj.SupportedTool, 'Altera QUARTUS II' ) || strcmp( obj.SupportedTool, 'Intel Quartus Pro' )
                msg = message( 'hdlcommon:plugin:IPRepositoryHDLVerifierAlteraNotFound' ).getString;
                obj.addIPRepository(  ...
                    'IPListFunction', 'hdlverifier.fpga.quartus.iplist',  ...
                    'NotExistMessage', msg );
            end
        end


        function addAXIManagerParameter( obj, hBoard )


            if strcmp( obj.SupportedTool, 'Xilinx ISE' ) || strcmp( obj.SupportedTool, 'Microchip Libero SoC' )
                obj.AddMATLABAXIManagerParameter = false;
            end


            if ( obj.AddMATLABAXIManagerParameter == true || obj.AddJTAGMATLABasAXIMasterParameter == true )


                AXIIPRepoAdded = false;
                IPReposLoaded = obj.IPRepositories;
                if strcmpi( obj.SupportedTool, 'Xilinx Vivado' )
                    IPRepos = regexp( IPReposLoaded, 'hdlverifier.fpga.vivado.iplist' );
                elseif strcmpi( obj.SupportedTool, 'Altera QUARTUS II' )
                    IPRepos = regexp( IPReposLoaded, 'hdlverifier.fpga.quartus.iplist' );
                elseif strcmpi( obj.SupportedTool, 'Intel Quartus Pro' )
                    IPRepos = regexp( IPReposLoaded, 'hdlverifier.fpga.quartus.iplist' );
                end
                if find( cellfun( 'length', IPRepos ) )
                    AXIIPRepoAdded = true;
                end



                if AXIIPRepoAdded
                    obj.AddMATLABAXIManagerParameter = false;
                    obj.hashdlverifierIP = true;
                end
            end


            if obj.AddMATLABAXIManagerParameter
                obj.addAXIManagerIP( obj.MATLABAXIManagerDefaultValue, hBoard );
            end
        end



        function addAXIManagerIP( obj, AXIDefValue, hBoard )

            if ( hBoard.hasEthernetMAC )
                AXIManagerChoiceList = { 'off', 'JTAG', 'Ethernet' };
                obj.registerEthernetMACProperties( hBoard );
            else
                AXIManagerChoiceList = { 'off', 'JTAG' };
            end
            obj.addParameter(  ...
                'ParameterID', 'HDLVerifierAXI',  ...
                'DisplayName', 'Insert AXI Manager (HDL Verifier required)',  ...
                'DefaultValue', AXIDefValue,  ...
                'ParameterType', hdlcoder.ParameterType.Dropdown,  ...
                'Choice', AXIManagerChoiceList );
        end


        function addFPGADatacaptureInterfaceParameter( obj, hBoard )


            if ~strcmpi( obj.SupportedTool, 'Xilinx Vivado' )
                return ;
            end
            hasHDLVLicense = license( 'test', 'EDA_Simulator_Link' );
            if ~hasHDLVLicense
                return ;
            end

            IPReposLoaded = obj.IPRepositories;
            if strcmpi( obj.SupportedTool, 'Xilinx Vivado' )
                IPRepos = regexp( IPReposLoaded, 'hdlverifier.fpga.vivado.iplist' );
            end
            AXIIPRepoAdded = false;
            if find( cellfun( 'length', IPRepos ) )
                AXIIPRepoAdded = true;
            end

            if ( ~AXIIPRepoAdded && hBoard.hasEthernetMAC )
                if ~strcmp( hBoard.InterfaceType, 'SGMII' )
                    FDCChoiceList = { 'JTAG', 'Ethernet' };
                else
                    FDCChoiceList = { 'JTAG' };
                end
            else
                FDCChoiceList = { 'JTAG' };
            end
            obj.addParameter(  ...
                'ParameterID', 'HDLVerifierFDC',  ...
                'DisplayName', 'FPGA Data Capture (HDL Verifier required)',  ...
                'DefaultValue', 'JTAG',  ...
                'ParameterType', hdlcoder.ParameterType.Dropdown,  ...
                'Choice', FDCChoiceList );
        end


        function addEthernetIPAddressParameter( obj )
            obj.addParameter(  ...
                'ParameterID', 'EthernetIPAddress',  ...
                'DisplayName', 'Board IP Address',  ...
                'DefaultValue', obj.EthernetIPAddressDefaultValue,  ...
                'ParameterType', hdlcoder.ParameterType.Edit,  ...
                'ValidationFcn', @obj.validateEthernetIPAddress );
        end



        function removeEthernetIPAddressParameter( obj )

            if obj.isParameterlistMember( 'EthernetIPAddress' )
                obj.removeParameter( 'ParameterID', 'EthernetIPAddress' );
            end
        end


        function registerEthernetMACProperties( obj, hBoard )
            obj.EthernetIPAddressDefaultValue = hBoard.IPAddress;


            numChanel = numel( hBoard.PortAddresses );
            obj.EthernetPortAddr( 1:numChanel ) = hBoard.PortAddresses;
            for ii = 1:numChanel
                idx = find( hBoard.PortAddresses( ii ) == obj.EthernetPortAddr( numChanel + 1:8 ) );
                tempVal = 50109;
                while ~isempty( find( tempVal == obj.EthernetPortAddr, 1 ) )
                    tempVal = randi( [ 50101, 50120 ] );
                end
                obj.EthernetPortAddr( idx + numChanel ) = tempVal;
            end

            obj.EthernetMACAddr = hBoard.MACAddress;
            obj.EthernetNumChannels = hBoard.NumChannels;
        end






        function refreshParameterListInternal( obj )

            ParamCellFormat = obj.getParameterCellFormat(  );


            obj.hParameterList.DynamicParameterList.clearParameterList;


            numEthernetChannels = obj.getEthernetAXIParameterValue + obj.getEthernetFDCParameterValue;
            if ( numEthernetChannels > obj.EthernetNumChannels )
                error( message( 'hdlcommon:workflow:lessNumberMACChannels', numEthernetChannels ) );
            end




            if ( obj.getEthernetAXIParameterValue || obj.getEthernetFDCParameterValue )
                obj.addParameter(  ...
                    'ParameterID', 'EthernetIPAddress',  ...
                    'DisplayName', 'Board IP Address',  ...
                    'DefaultValue', obj.EthernetIPAddressDefaultValue,  ...
                    'ParameterType', hdlcoder.ParameterType.Edit,  ...
                    'ValidationFcn', @obj.validateEthernetIPAddress );

                if ~isempty( ParamCellFormat )
                    obj.setParameterCellFormat( ParamCellFormat );
                end
            end




        end


        function baseaddr = getAXI4SlaveBaseAddress( obj )
            baseaddr = '';
            IntfIDlist = obj.getInterfaceIDList;
            for ii = 1:length( IntfIDlist )
                interfaceId = obj.getInterfaceIDList{ ii };
                hInterface = obj.getInterface( interfaceId );
                if hInterface.isAXI4SlaveInterface
                    baseaddr = hInterface.BaseAddress;
                    break
                end
            end
        end


        function addrspace = getAXISlaveMasterAddressSpace( obj )
            addrspace = '';
            IntfIDlist = obj.getInterfaceIDList;
            for ii = 1:length( IntfIDlist )
                interfaceId = obj.getInterfaceIDList{ ii };
                hInterface = obj.getInterface( interfaceId );
                if strcmpi( obj.SupportedTool, 'Xilinx Vivado' )
                    if hInterface.isAXI4Interface || hInterface.isAXI4LiteInterface
                        addrspace = hInterface.MasterAddressSpace;
                        break
                    end
                elseif strcmpi( obj.SupportedTool, 'Altera QUARTUS II' ) || strcmpi( obj.SupportedTool, 'Intel Quartus Pro' )
                    if hInterface.isAXI4Interface || hInterface.isAXI4LiteInterface
                        addrspace = hInterface.MasterConnection;
                        break
                    end
                end
            end
        end


        function AXI4IDWidth = getAXISlaveIDWidth( obj )
            AXI4IDWidth = 12;
            IntfIDlist = obj.getInterfaceIDList;
            for ii = 1:length( IntfIDlist )
                interfaceId = obj.getInterfaceIDList{ ii };
                hInterface = obj.getInterface( interfaceId );
                if hInterface.isAXI4Interface
                    AXI4IDWidth = hInterface.IDWidth;
                    break
                end
            end
        end
    end

    methods
        function validateReferenceDesign( obj )





            hdlturnkey.plugin.validateRequiredStringProperty(  ...
                obj.ReferenceDesignName, 'ReferenceDesignName',  ...
                'hRD.ReferenceDesignName = ''My custom system''' );


            hdlturnkey.plugin.validateRequiredStringProperty(  ...
                obj.BoardName, 'BoardName',  ...
                'hRD.BoardName = ''My custom board''' );


            hdlturnkey.plugin.validateRequiredProperty(  ...
                obj.SupportedToolVersion, 'SupportedToolVersion',  ...
                'hRD.SupportedToolVersion = {''2014.2''}' );
            hdlturnkey.plugin.validateCellProperty(  ...
                obj.SupportedToolVersion, 'SupportedToolVersion',  ...
                'hRD.SupportedToolVersion = {''2014.2''}' );
            hdlturnkey.plugin.validateCellProperty(  ...
                obj.CustomConstraints, 'CustomConstraints',  ...
                'hRD.CustomConstraints = {''abc.xyz''}' );



            if obj.isAXI4SlaveInterfaceRequired && ~obj.isAXI4SlaveInterfaceInUse
                hdlturnkey.plugin.validateRequiredMethod(  ...
                    '', 'addAXI4SlaveInterface()', obj.AXI4SlaveExampleStr );
            end


            hdlturnkey.plugin.validateRequiredMethod(  ...
                obj.hClockModule, 'addClockInterface()', obj.ClockExampleStr );



            if ~obj.HasProcessingSystem && ~isempty( obj.DeviceTree )
                error( message( 'hdlcommon:plugin:NoProcessorForDeviceTree', 'HasProcessingSystem', 'addDeviceTree' ) );
            end
            if ~obj.HasProcessingSystem && obj.isDeviceTreeGenerationEnabled
                error( message( 'hdlcommon:plugin:NoProcessorForDeviceTreeGeneration', 'HasProcessingSystem', 'GenerateIPCoreDeviceTreeNodes' ) );
            end


            obj.validateCallbackFunction( 'PostTargetReferenceDesignFcn' );
            obj.validateCallbackFunction( 'PostTargetInterfaceFcn' );
            obj.validateCallbackFunction( 'PostCreateProjectFcn' );
            obj.validateCallbackFunction( 'PostSWInterfaceFcn' );
            obj.validateCallbackFunction( 'PostBuildBitstreamFcn' );
            obj.validateCallbackFunction( 'CallbackCustomProgrammingMethod' );
            obj.validateCallbackFunction( 'CustomizeReferenceDesignFcn' );



            if ( ~isa( obj.ReportTimingFailure, 'hdlcoder.ReportTiming' ) )
                error( message( 'hdlcoder:workflow:InvalidReportTiming' ) );
            end


            obj.validateReferenceDesignInterfaces;


            obj.validateReferenceDesignAdditional;
        end

        function validateReferenceDesignInterfaces( obj )
            interfaceIDList = obj.getInterfaceIDList;
            for ii = 1:length( interfaceIDList )
                hInterface = obj.getInterface( interfaceIDList{ ii } );
                hInterface.validateInterfaceForReferenceDesign( obj );
            end
        end

        function validateReferenceDesignForBoard( obj, hBoard )



            if ~strcmp( obj.BoardName, hBoard.BoardName )
                error( message( 'hdlcommon:hdlturnkey:RDFileBoardMismatch',  ...
                    obj.BoardName, hBoard.BoardName ) );
            end




            [ boardDT, isBoardDTCompiled ] = hBoard.getDeviceTree;
            [ refDesignDT, isRefDesignDTCompiled ] = obj.getDeviceTree;
            if ~isempty( boardDT ) && ~isempty( refDesignDT )
                if isBoardDTCompiled && isRefDesignDTCompiled
                    error( message( 'hdlcommon:plugin:CompiledDeviceTreeOverlap', hBoard.BoardName, obj.ReferenceDesignName ) );
                end
            end





            if isempty( boardDT ) && isempty( refDesignDT )
                if obj.isDeviceTreeGenerationEnabled
                    error( message( 'hdlcommon:plugin:NoBaseDeviceTree', 'GenerateIPCoreDeviceTreeNodes', obj.ReferenceDesignName, hBoard.BoardName ) );
                end
            end


            obj.validateReferenceDesignForBoardAdditional( hBoard );
        end

        function validateCell = validateReferenceDesignSelected( obj, hBoard, validateCell, cmdDisplay )




            obj.validateParameterListValues;


            validateCell = obj.validateIPRepositoriesList( validateCell, cmdDisplay );






            [ boardDevTree, isBoardDTCompiled ] = hBoard.getDeviceTree;
            hasBoardDevTree = ~isempty( boardDevTree );
            hasCompiledBoardDevTree = ( hasBoardDevTree && isBoardDTCompiled );

            [ refDesignDevTree, isRefDesignDTCompiled ] = obj.getDeviceTree;
            hasRefDesignDevTree = ~isempty( refDesignDevTree );
            hasCompiledRefDesignDevTree = ( hasRefDesignDevTree && isRefDesignDTCompiled );

            if ~( hasCompiledBoardDevTree || hasCompiledRefDesignDevTree )
                if hasBoardDevTree

                    [ ~, validateCell2 ] = hBoard.getDeviceTreeIncludeDirs( cmdDisplay );
                    validateCell = [ validateCell, validateCell2 ];
                end

                if hasRefDesignDevTree

                    [ ~, validateCell2 ] = obj.getDeviceTreeIncludeDirs( cmdDisplay );
                    validateCell = [ validateCell, validateCell2 ];
                end
            end
        end



        function validateCellCallback = customizeReferenceDesign( obj, hDI, RDToolVersion )

            obj.validateCallbackFunction( 'CustomizeReferenceDesignFcn' );
            Plugin_Rdname = obj.ReferenceDesignName;
            Plugin_Boardname = obj.BoardName;
            Plugin_SupportedToolVersions = obj.SupportedToolVersion;

            validateCellCallback = hdlturnkey.plugin.runCallbackCustomizeReferenceDesign( obj, hDI, RDToolVersion );
            obj.PostCallbackvalidation( Plugin_Rdname, Plugin_Boardname, Plugin_SupportedToolVersions );

            hBoard = hDI.hTurnkey.hBoard;
            obj.customizeReferenceDesignInternal( hBoard );
        end

        function customizeReferenceDesignInternal( obj, hBoard )


            isInsertJTAGAXI = obj.getJTAGAXIParameterValue;
            isInsertEthernetAXI = obj.getEthernetAXIParameterValue;
            isInsertEthernetFDC = obj.getEthernetFDCParameterValue;

            if ( isInsertJTAGAXI || isInsertEthernetAXI || isInsertEthernetFDC )
                obj.updateIPrepository;
            end


            if ( isInsertJTAGAXI || isInsertEthernetAXI ) && ~obj.isAXI4SlaveInterfaceInUse




                obj.hasDynamicAXI4SlaveInterface = true;
                if obj.isVivado
                    obj.addAXI4SlaveInterface(  ...
                        'InterfaceConnection', 'axi_interconnect/M00_AXI',  ...
                        'BaseAddress', '0x40000000',  ...
                        'MasterAddressSpace', 'hdlverifier_axi_mngr/axi4m',  ...
                        'HasProcessorConnection', false );
                elseif ( obj.isQuartus || obj.isQuartusPro )
                    obj.addAXI4SlaveInterface(  ...
                        'InterfaceConnection', 'AXI_Manager_0.axm_m0',  ...
                        'BaseAddress', '0x0000 0000',  ...
                        'InterfaceType', 'AXI4',  ...
                        'HasProcessorConnection', false );
                end
            end

            if ( isInsertEthernetAXI || isInsertEthernetFDC )
                constraintFile = hBoard.EthernetMACConstraintFile;
                obj.CustomConstraints{ end  + 1 } = constraintFile;
            end
        end


        function PostCallbackvalidation( obj, InitPlugin_Rdname, InitPlugin_BoardName, InitPlugin_SupportedToolVersions )


            if ~strcmp( InitPlugin_Rdname, obj.ReferenceDesignName )
                error( message( 'hdlcommon:plugin:RDNameMismatch_ClBack',  ...
                    obj.ReferenceDesignName, InitPlugin_Rdname ) );
            end


            if ~strcmp( InitPlugin_BoardName, obj.BoardName )
                error( message( 'hdlcommon:plugin:BoardNameMismatch_ClBack',  ...
                    obj.BoardName, InitPlugin_BoardName ) );
            end






            if ~isempty( InitPlugin_SupportedToolVersions )
                for ii = 1:length( InitPlugin_SupportedToolVersions )
                    hRDToolVer = InitPlugin_SupportedToolVersions{ ii };

                    if ~downstream.tool.detectToolVersionMatch( hRDToolVer, obj.SupportedToolVersion )
                        error( message( 'hdlcommon:plugin:ToolVersionMismatch_ClBack' ) );
                    end
                end
            else
                error( message( 'hdlcommon:plugin:ToolVersionMismatch_ClBack' ) );
            end
        end
    end

    methods ( Hidden = true )
        function addInterface( obj, hInterface )
            hInterface.validateInterfaceForTool( obj.SupportedTool );
            addInterface@hdlturnkey.plugin.PluginBaseWithInterface( obj, hInterface );
        end


        function hProcessingSystem = getProcessingSystem( obj )
            hProcessingSystem = obj.hProcessingSystem;
        end


        function addCustomInterface( obj, varargin )
            p = inputParser;
            p.addParameter( 'InterfaceClass', '' );
            p.addParameter( 'NotExistInterfaceID', '' );
            p.addParameter( 'NotExistMessage', '' );
            p.addParameter( 'InterfaceArgumentCell', {  } );
            p.addParameter( 'ActionWhenInterfaceNotExist', 'Error' );

            p.parse( varargin{ : } );
            inputArgs = p.Results;


            if exist( inputArgs.InterfaceClass, 'class' )
                fh = str2func( inputArgs.InterfaceClass );
                hInterface = fh( inputArgs.InterfaceArgumentCell{ : } );
                obj.addInterface( hInterface );
            else
                msg = message( 'hdlcommon:interface:CustomInterfaceClassNotExist', inputArgs.InterfaceClass, obj.ReferenceDesignName, inputArgs.NotExistMessage, obj.AuthorName, obj.AuthorWeb, obj.AuthorEmail, obj.AuthorPhone );
                switch inputArgs.ActionWhenInterfaceNotExist
                    case 'Show'
                        hInterface = hdlturnkey.interface.InterfaceNotOnPathMessage( inputArgs.NotExistInterfaceID, msg );
                        obj.addInterface( hInterface );
                    case 'Error'
                        error( msg );
                    otherwise
                end
            end
        end

        function sourcePath = getFilePathFromRD( obj, sourceFile )

            sourcePath = fullfile( obj.getPluginPath, sourceFile );
        end

        function isit = isDeviceTreeGenerationEnabled( obj )
            isit = obj.GenerateIPCoreDeviceTreeNodes;
        end

        function sysPath = getSystemInit( obj )

            if ~isempty( obj.SystemInitFolderName )
                sysPath = obj.getFilePathFromRD( obj.SystemInitFolderName );
            else
                sysPath = '';
            end
        end
    end

    methods ( Abstract )

        addCustomVivadoDesign( obj, varargin )
        addCustomEDKDesign( obj, varargin )
        addCustomQsysDesign( obj, varargin )
        addCustomLiberoDesign( obj, varagin )

        addInternalIOInterface( obj, varargin )

        addExternalIOInterface( obj, varargin )
    end

    methods ( Abstract, Access = protected )

        validateReferenceDesignAdditional( obj )
    end

    methods ( Hidden = true )


        function paramCell = getParameterCellFormat( obj )
            paramCell = obj.hParameterList.getParameterCellFormat;
        end
        function setParameterCellFormat( obj, paramCell )
            obj.hParameterList.setParameterCellFormat( paramCell );
        end
        function status = isParameterEqual( obj, paramCell )

            status = obj.hParameterList.isParameterEqual( paramCell );
        end
        function paramStruct = getParameterStructFormat( obj )
            paramStruct = obj.hParameterList.getParameterStructFormat;
        end
        function tablesetting = drawParameterGUITable( obj )
            tablesetting = obj.hParameterList.drawGUITable;
        end
        function setParameterGUITable( obj, rowIdx, colIdx, newValue )
            obj.hParameterList.setGUITable( rowIdx, colIdx, newValue );
        end
        function value = getParameterTableCellGUIValue( obj, rowIdx, colIdx )
            value = obj.hParameterList.getTableCellGUIValue( rowIdx, colIdx );
        end
        function parseParameterGUITable( obj, tablesetting )
            obj.hParameterList.parseGUITable( tablesetting );
        end
        function isa = isParameterTableEmpty( obj )
            isa = obj.hParameterList.isParameterTableEmpty;
        end


        function validateEthernetIPAddress( ~, IPAddress )
            hdlturnkey.plugin.validateIPAddressProperty( char( IPAddress ), 'Board IP Address' );
        end

        function validateParameterListValues( obj )
            paramIDList = obj.hParameterList.getAllParameterIDList;


            for ii = 1:length( paramIDList )
                paramID = paramIDList{ ii };
                hParameter = obj.hParameterList.getParameterObject( paramID );
                hParameter.validateParameterValue( hParameter.Value );
            end
        end
    end

    methods ( Access = protected )

        function validateCell = validateIPRepositoriesList( obj, validateCell, cmdDisplay )

            for ii = 1:length( obj.IPRepositories )
                ipRepo = obj.IPRepositories{ ii };
                ipRepoMsg = obj.IPRepositoriesMsgs{ ii };
                ipRepoPath = which( ipRepo );
                isInsertJTAGAXIMasterSelected = obj.getJTAGAXIParameterValue;
                if isempty( ipRepoPath )
                    if isInsertJTAGAXIMasterSelected
                        msg = message( 'hdlcommon:plugin:IPPackageFuncNotOnPath', ipRepo, ipRepoMsg );
                    else
                        msg = message( 'hdlcommon:plugin:IPPackageFunctionNotOnPath', obj.ReferenceDesignName, ipRepo, ipRepoMsg );
                    end
                    if cmdDisplay
                        error( msg )
                    else
                        validateCell{ end  + 1 } = hdlvalidatestruct( 'Error', msg );
                    end
                else
                    if nargout( ipRepo ) == 1


                        ipList = feval( ipRepo );
                        [ ipDir, ~, ~ ] = fileparts( ipRepoPath );
                    elseif nargout( ipRepo ) == 2

                        [ ipList, ipDir ] = feval( ipRepo );
                    else
                        error( message( 'hdlcommon:plugin:InvalidOutputIPRepositoryFunction',  ...
                            ipRepo ) );
                    end

                    for jj = 1:length( ipList )
                        sourcePath = fullfile( ipDir, ipList{ jj } );
                        if ~isfile( sourcePath ) && ~isfolder( sourcePath )
                            msg = message( 'hdlcommon:plugin:IPNotFound', ipList{ jj }, ipRepo );
                            if cmdDisplay
                                error( msg )
                            else
                                validateCell{ end  + 1 } = hdlvalidatestruct( 'Error', msg );
                            end
                        end
                    end

                end

            end
        end

        function validateCallbackFunction( obj, callbackName )

            if isempty( obj.( callbackName ) )
                return ;
            end
            exampleStr = sprintf( 'hRD.%s = @callback_function_name', callbackName );
            hdlturnkey.plugin.validateFcnHandleProperty(  ...
                obj.( callbackName ), callbackName, exampleStr );
        end

        function validateReferenceDesignForBoardAdditional( obj, hBoard )%#ok<INUSD>

        end

        function validateAXI4SlaveInterfaceType( obj, interfaceType, interfaceID )
            hdlturnkey.plugin.validateCellStringProperty(  ...
                interfaceType, 'InterfaceType', obj.AXI4SlaveExampleStr );

            hdlturnkey.plugin.validatePropertyValue(  ...
                interfaceType, 'InterfaceType', { 'AXI4-Lite', 'AXI4' } );

            hdlturnkey.plugin.validateStringProperty(  ...
                interfaceID, 'InterfaceID', obj.AXI4SlaveExampleStr );

            if length( interfaceType ) > 1 && ~isempty( interfaceID )
                error( message( 'hdlcommon:plugin:InvalidInterfaceIDInterfaceType' ) );
            end
        end

        function addAXI4Interface( obj, varargin )
            obj.addInterface( hdlturnkey.interface.AXI4( varargin{ : } ) );
        end

        function addAXI4LiteInterface( obj, varargin )
            obj.addInterface( hdlturnkey.interface.AXI4Lite( varargin{ : } ) );
        end

        function isa = isISE( obj )

            isa = obj.isToolISE( obj.SupportedTool );
        end

        function isa = isVivado( obj )

            isa = obj.isToolVivado( obj.SupportedTool );
        end

        function isa = isQuartus( obj )

            isa = obj.isToolQuartus( obj.SupportedTool );
        end

        function isa = isQuartusPro( obj )

            isa = obj.isToolQuartusPro( obj.SupportedTool );
        end

        function isa = isLiberoSoC( obj )
            isa = obj.isToolLiberoSoC( obj.SupportedTool );
        end

        function pluginPath = getPluginPath( obj )

            if obj.ExternalRD

                pluginPath = obj.RDFolderPath;
            elseif obj.SharedRD

                pluginPath = obj.SharedRDFolder;
            else

                pluginPath = obj.PluginPath;
            end
        end
    end

    methods ( Static, Hidden )
        function isit = isToolISE( toolName )

            isit = strcmpi( toolName, 'Xilinx ISE' );
        end

        function isit = isToolVivado( toolName )

            isit = strcmpi( toolName, 'Xilinx Vivado' );
        end

        function isit = isToolQuartus( toolName )

            isit = strcmpi( toolName, 'Altera QUARTUS II' );
        end

        function isit = isToolQuartusPro( toolName )

            isit = strcmpi( toolName, 'Intel Quartus Pro' );
        end

        function isit = isToolLiberoSoC( toolName )
            isit = strcmpi( toolName, 'Microchip Libero SoC' );
        end

    end


    methods
        function registerDeepLearningTargetInterface( obj, interfaceType, varargin )
            arguments
                obj
                interfaceType dlhdl.TargetInterface
            end

            arguments( Repeating )
                varargin
            end

            if isempty( obj.DeepLearningInterfaces )





                obj.DeepLearningInterfaces = dnnfpga.tgtinterface.TargetInterfaceBase.empty;
            end

            if obj.hasDeepLearningInterfaceOfType( interfaceType )
                error( message( 'dnnfpga:plugin:DuplicateTargetInterface', char( interfaceType ), obj.ReferenceDesignName ) );
            end

            switch interfaceType
                case dlhdl.TargetInterface.JTAG
                    obj.DeepLearningInterfaces( end  + 1 ) = dnnfpga.tgtinterface.JTAG( varargin{ : } );
                case dlhdl.TargetInterface.Ethernet
                    obj.DeepLearningInterfaces( end  + 1 ) = dnnfpga.tgtinterface.Ethernet( varargin{ : } );
                otherwise
                    error( message( 'dnnfpga:plugin:UnsupportedTargetInterface', char( interfaceType ), obj.ReferenceDesignName ) );
            end
        end

        function registerDeepLearningMemoryAddressSpace( obj, baseAddr, addrRange )
            arguments
                obj
                baseAddr double{ mustBeNonnegative }
                addrRange double{ mustBeNonnegative }
            end

            obj.DeepLearningMemoryBaseAddress = baseAddr;
            obj.DeepLearningMemoryAddressRange = addrRange;
        end

        function validateReferenceDesignForDeepLearning( obj )



            if ~obj.isAXI4SlaveInterfaceInUse
                error( message( 'dnnfpga:plugin:MissingAXISlaveInterface', obj.ReferenceDesignName ) );
            end












            AXIMRequiredIDList = { 'AXI4 Master Activation Data', 'AXI4 Master Weight Data', 'AXI4 Master Debug' };
            requiredIDStr = strjoin( AXIMRequiredIDList, '\n' );
            interfaceIDList = obj.getInterfaceIDList(  );
            for ii = 1:numel( interfaceIDList )
                interfaceID = interfaceIDList{ ii };
                hInterface = obj.getInterface( interfaceID );
                if hInterface.isAXI4MasterInterface && ismember( interfaceID, AXIMRequiredIDList )

                    AXIMRequiredIDList = setdiff( AXIMRequiredIDList, interfaceID );
                end
            end


            if ~isempty( AXIMRequiredIDList )
                missingIDStr = strjoin( AXIMRequiredIDList, '\n' );
                error( message( 'dnnfpga:plugin:IncorrectAXIMasterInterfaces', requiredIDStr, obj.ReferenceDesignName, missingIDStr ) );
            end


            refDesignMemSize = obj.DeepLearningMemoryAddressRange;
            minDLMemSize = obj.MinimumDeepLearningMemorySize;
            minDLMemSizeMB = obj.MinimumDeepLearningMemorySize / 2 ^ 20;
            memSizeMsg = message( 'dnnfpga:plugin:DLRefDesignMemSize', minDLMemSizeMB, dec2hex( minDLMemSize ), 'registerDeepLearningMemoryAddressSpace' ).getString;
            if refDesignMemSize <= 0
                error( message( 'dnnfpga:plugin:DLRefDesignMemSizeEmpty', obj.ReferenceDesignName, memSizeMsg ) );
            elseif refDesignMemSize < minDLMemSize
                warning( message( 'dnnfpga:plugin:DLRefDesignMemSizeLow', obj.ReferenceDesignName, dec2hex( refDesignMemSize ), memSizeMsg ) );
            end



            if isempty( obj.DeepLearningInterfaces )
                warning( message( 'dnnfpga:plugin:DLRefDesignHWInterface', obj.ReferenceDesignName, 'registerDeepLearningTargetInterface' ) );
            end


            if strcmpi( obj.SupportedTool, 'Xilinx Vivado' )
                JTAGPCIeIPRepo = 'hdlverifier.fpga.vivado.iplist';
                EthernetIPRepo = 'hdlcoder.fpga.vivado.hdlcoder_axis2axim_iplist';
            elseif strcmpi( obj.SupportedTool, 'Altera QUARTUS II' )
                JTAGPCIeIPRepo = 'hdlverifier.fpga.quartus.iplist';
                EthernetIPRepo = 'hdlcoder.fpga.quartus.hdlcoder_axis2axim_iplist';
            end


            if obj.hasDeepLearningInterfaceOfType( "JTAG" ) && isempty( intersect( obj.IPRepositories, JTAGPCIeIPRepo ) )
                ipRepositoryExampleStr = sprintf( 'hRD.addIPRepository(''IPListFunction'',''%s'')', JTAGPCIeIPRepo );
                error( message( 'dnnfpga:plugin:HWInterfaceIPRepo', obj.ReferenceDesignName, 'JTAG', 'HDL Verifier AXI Manager', 'addIPRepository', ipRepositoryExampleStr ) );
            end


            if obj.hasDeepLearningInterfaceOfType( "PCIe" ) && isempty( intersect( obj.IPRepositories, JTAGPCIeIPRepo ) )
                ipRepositoryExampleStr = sprintf( 'hRD.addIPRepository(''IPListFunction'',''%s'')', JTAGPCIeIPRepo );
                error( message( 'dnnfpga:plugin:HWInterfaceIPRepo', obj.ReferenceDesignName, 'PCIe', 'HDL Verifier AXI Manager', 'addIPRepository', ipRepositoryExampleStr ) );
            end


            if obj.hasDeepLearningInterfaceOfType( "Ethernet" ) && isempty( intersect( obj.IPRepositories, EthernetIPRepo ) )
                ipRepositoryExampleStr = sprintf( 'hRD.addIPRepository(''IPListFunction'',''%s'')', EthernetIPRepo );
                error( message( 'dnnfpga:plugin:HWInterfaceIPRepo', obj.ReferenceDesignName, 'Ethernet', 'HDL Coder Datamover', 'addIPRepository', ipRepositoryExampleStr ) );
            end

        end
    end

    methods ( Hidden )
        function hasInterface = hasDeepLearningInterfaceOfType( obj, interfaceType )
            arguments
                obj
                interfaceType dlhdl.TargetInterface
            end

            if isempty( obj.DeepLearningInterfaces )
                hasInterface = false;
                return ;
            end

            existingTypes = [ obj.DeepLearningInterfaces.InterfaceType ];
            hasInterface = ismember( interfaceType, existingTypes );
        end

        function hInterface = getDeepLearningInterfaceOfType( obj, interfaceType )
            arguments
                obj
                interfaceType dlhdl.TargetInterface
            end

            if ~obj.hasDeepLearningInterfaceOfType( interfaceType )
                error( 'No deep learning interface of type "%s".', char( interfaceType ) );
            end

            typesInList = [ obj.DeepLearningInterfaces.InterfaceType ];
            hInterface = obj.DeepLearningInterfaces( interfaceType == typesInList );
        end

        function [ baseAddr, addrRange ] = getDeepLearningMemorySpace( obj )
            baseAddr = obj.DeepLearningMemoryBaseAddress;
            addrRange = obj.DeepLearningMemoryAddressRange;
        end
    end

end
