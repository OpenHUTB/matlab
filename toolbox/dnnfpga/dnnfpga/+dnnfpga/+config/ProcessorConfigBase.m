classdef ( Abstract )ProcessorConfigBase < dnnfpga.config.PropertyListBase

    properties
        SynthesisToolChipFamily
        SynthesisToolDeviceName
        SynthesisToolPackageName
        SynthesisToolSpeedValue
        TargetFrequency
    end

    properties ( Dependent )
        TargetPlatform
        SynthesisTool
        ReferenceDesign

        InputRunTimeControl
        OutputRunTimeControl
    end

    properties ( Access = protected )
        TargetPlatformInternal
        SynthesisToolInternal
        ReferenceDesignInternal
    end

    properties

        RunTimeControl
        RunTimeStatus
        SetupControl

        InputStreamControl
        OutputStreamControl
        InputDataInterface
        OutputDataInterface
        ProcessorDataType
    end


    properties ( Constant, Hidden )

        GenericDLProcessorTargetName = 'Generic Deep Learning Processor';


        TargetPlatformDefault = 'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit';
        SynthesisToolDefault = dlhdl.Tool.convertToString( dlhdl.Tool.XilinxVivado );
        ReferenceDesignDefault = 'AXI-Stream DDR Memory Access : 3-AXIM';
        SynthesisToolChipFamilyDefault = 'Zynq UltraScale+';
        SynthesisToolDeviceNameDefault = 'xczu9eg-ffvb1156-2-e';
        SynthesisToolPackageNameDefault = '';
        SynthesisToolSpeedValueDefault = '';
        TargetFrequencyDefault = 200;

        RunTimeControlDefault = 'register';
        RunTimeStatusDefault = 'register';
        SetupControlDefault = 'register';

        InputStreamControlDefault = 'register';
        OutputStreamControlDefault = 'register';

        InputDataInterfaceDefault = 'External Memory';
        OutputDataInterfaceDefault = 'External Memory';
        ProcessorDataTypeDefault = 'single';



        RunTimeControlChoices = { 'register', 'port' };
        RunTimeStatusChoices = { 'register', 'port' };
        SetupControlChoices = { 'register', 'port' };
        InputStreamControlChoices = { 'register', 'port' };
        OutputStreamControlChoices = { 'register', 'port' };
        InputDataInterfaceChoices = { 'External Memory', 'AXI4-Stream' };
        OutputDataInterfaceChoices = { 'External Memory', 'AXI4-Stream' };
        ProcessorDataTypeChoices = { 'single', 'int8' };
        ProcessorDataTypeChoicesFixedPoint = { 'single', 'int8', 'int4', 'half' };
    end


    properties ( Access = protected )


        ModuleIDList = {  };
        ModuleConfigMap = [  ];

    end

    properties ( Access = protected )


        hBoardList = [  ];
        ToolEnumList = {  };
        hRDList = [  ];
    end

    properties ( Hidden, GetAccess = public, SetAccess = protected )
        CustomLayerManager = [  ]


        hBackDoorFiFeature


        ModelManager
    end

    properties ( Hidden )



        CalibrationData = [  ]
    end


    methods
        function obj = ProcessorConfigBase(  )



            obj.hBackDoorFiFeature = dnnfpga.internal.BackDoorFiFeature;


            obj.ModuleIDList = {  };
            obj.ModuleConfigMap = containers.Map(  );



            obj.Properties( 'SystemLevelProperties' ) = {  ...
                'TargetPlatform',  ...
                'TargetFrequency',  ...
                'SynthesisTool',  ...
                'ReferenceDesign',  ...
                'SynthesisToolChipFamily',  ...
                'SynthesisToolDeviceName',  ...
                'SynthesisToolPackageName',  ...
                'SynthesisToolSpeedValue',  ...
                };


            obj.Properties( 'ProcessorTopLevelProperties' ) = {  ...
                'RunTimeControl',  ...
                'RunTimeStatus',  ...
                'InputStreamControl',  ...
                'OutputStreamControl',  ...
                'SetupControl',  ...
                'ProcessorDataType' ...
                };








            obj.hBoardList = hdlturnkey.plugin.DLBoardList;













            platformList = obj.getPlatformList;
            if ismember( obj.TargetPlatformDefault, platformList )
                obj.TargetPlatform = obj.TargetPlatformDefault;
            else
                obj.TargetPlatform = platformList{ end  };
            end


            obj.TargetFrequency = obj.TargetFrequencyDefault;

            obj.RunTimeControl = obj.RunTimeControlDefault;
            obj.RunTimeStatus = obj.RunTimeStatusDefault;
            obj.SetupControl = obj.SetupControlDefault;

            obj.InputStreamControl = obj.InputStreamControlDefault;
            obj.OutputStreamControl = obj.OutputStreamControlDefault;

            obj.InputDataInterface = obj.InputDataInterfaceDefault;
            obj.OutputDataInterface = obj.OutputDataInterfaceDefault;
            obj.ProcessorDataType = obj.ProcessorDataTypeDefault;


            try
                dnnfpga.utilscripts.checkUtility;
            catch ME

                throwAsCaller( ME );
            end
        end
    end



    methods
        function setModuleProperty( obj, moduleID, propertyName, propertyValue )


            if nargin ~= 4
                error( message( 'dnnfpga:config:SetModulePropertyInputs' ) );
            end

            if ( strcmpi( propertyName, 'KernelDataType' ) )
                error( message( 'dnnfpga:config:KernelDataTypeNotSupported', propertyValue ) );
            end

            hModule = obj.validateSetGetModuleProperty( moduleID, propertyName );

            try
                moduleGeneration = hModule.ModuleGeneration;
            catch ME

                throwAsCaller( ME );
            end

            if moduleGeneration || strcmp( propertyName, 'ModuleGeneration' )
                try

                    hProp = findprop( hModule, propertyName );

                    obj.validationForSoftmaxSigmoidBlocks( hProp, hModule, propertyValue );

                    if ( strcmpi( hModule.ModuleID, 'custom' ) )
                        if ( ~strcmp( propertyName, 'ModuleGeneration' ) )


                            obj.validationForCustomBlocks( hProp, hModule, propertyValue );
                        else
                            kernelDataType = obj.ProcessorDataType;
                            if ( strcmpi( propertyValue, 'on' ) && strcmpi( kernelDataType, 'int8' ) )
                                customLayerManager = obj.CustomLayerManager;
                                registeredCustomBlocks = customLayerManager.getLayerList( true );
                                registeredCustomBlockNames = arrayfun( @( x )x.ConfigBlockName, registeredCustomBlocks, UniformOutput = false );



                                blocksSupportedForQuantization = customLayerManager.getBlocksSupportedForQuantization;

                                for i = 1:numel( blocksSupportedForQuantization )
                                    indexToRemove = strcmpi( registeredCustomBlockNames, blocksSupportedForQuantization{ i } );
                                    registeredCustomBlockNames( indexToRemove ) = [  ];
                                end

                                customModule = obj.getModule( 'custom' );
                                for i = 1:numel( registeredCustomBlockNames )
                                    blockName = registeredCustomBlockNames{ i };
                                    if ( customModule.( blockName ) )
                                        msg = message( 'dnnfpga:config:UnsupportedCustomLayerForQuantization', blockName );
                                        error( msg );
                                    end
                                end
                            end
                        end
                    end

                    if isa( hProp, 'meta.DynamicProperty' )
                        hModule.setDynamicProp( propertyValue, propertyName );
                    else
                        hModule.( propertyName ) = propertyValue;
                    end

                catch ME

                    throwAsCaller( ME );
                end
            else
                error( message( 'dnnfpga:config:CannotSetProperty', propertyName, hModule.ModuleID ) );
            end

        end

        function propertyValue = getModuleProperty( obj, moduleID, propertyName )
















            if nargin ~= 3
                error( message( 'dnnfpga:config:GetModulePropertyInputs' ) );
            end

            if ( strcmpi( propertyName, 'KernelDataType' ) )
                error( message( 'dnnfpga:config:GetKernelDataTypeNotSupported' ) );
            end


            hModule = obj.validateSetGetModuleProperty( moduleID, propertyName );


            propertyValue = dnnfpga.config.getPropertyValue( hModule, propertyName );

        end
    end

    methods ( Access = protected )

        function hModule = validateSetGetModuleProperty( obj, moduleID, propertyName )



            [ isIn, hModule ] = obj.isInModuleIDList( moduleID );
            if ~isIn

                moduleIDMsgObj = obj.getModuleIDMessageObj( moduleID );
                error( message( 'dnnfpga:config:SetGetModulePropertyFirstInput', moduleIDMsgObj.getString ) );
            end


            try
                hModule.( propertyName );
            catch ME
                choiceStr = dnnfpga.config.getPropertyChoiceString( hModule.getVisiblePropertyList );
                error( message( 'dnnfpga:config:SetGetModulePropertySecondInput', choiceStr ) );
            end
        end

        function moduleIDMsg = getModuleIDMessageObj( obj, moduleID )

            choices = obj.getModuleIDList;

            choiceStr = dnnfpga.config.getPropertyChoiceString( choices );
            moduleIDMsg = message( 'dnnfpga:config:InvalidModuleID', moduleID, choiceStr );
        end

        function validationForSoftmaxSigmoidBlocks( obj, hProp, hModule, propertyValue )


            convThreadNum = obj.getModuleProperty( 'conv', 'ConvThreadNumber' );
            isaPowerOfTwo = floor( log2( sqrt( convThreadNum ) ) ) == ceil( log2( sqrt( convThreadNum ) ) );
            ispropertyOn = strcmpi( propertyValue, 'on' );



            if ( strcmpi( hProp.Name, 'SigmoidBlockGeneration' ) && ispropertyOn && strcmpi( obj.ProcessorDataType, 'single' ) )

                msg = message( 'dnnfpga:config:UnsupportedSigmoidConfigurationForSingle' );
                error( msg );
            end

            if ( strcmpi( hProp.Name, 'Sigmoid' ) && ispropertyOn && ~strcmpi( obj.ProcessorDataType, 'single' ) )

                msg = message( 'dnnfpga:config:UnsupportedSigmoidConfigurationForQuantization' );
                error( msg );
            end







            if ( ( strcmpi( hProp.Name, 'SoftmaxBlockGeneration' ) || strcmpi( hProp.Name, 'SigmoidBlockGeneration' ) ) ...
                    && ispropertyOn )
                if ( ~isaPowerOfTwo && strcmpi( obj.getModuleProperty( 'conv', 'ModuleGeneration' ), 'on' ) )
                    msg = message( 'dnnfpga:config:NonPowerofTwoConvThreadNotSupported' );
                    warning( msg );
                end
            end

            if ( strcmpi( hProp.Name, 'ModuleGeneration' ) && strcmpi( hModule.ModuleID, 'conv' ) && ispropertyOn )
                if ( ~isaPowerOfTwo &&  ...
                        ( strcmpi( obj.getModuleProperty( 'fc', 'SoftmaxBlockGeneration' ), 'on' ) ||  ...
                        strcmpi( obj.getModuleProperty( 'fc', 'SigmoidBlockGeneration' ), 'on' ) ) )
                    msg = message( 'dnnfpga:config:NonPowerofTwoConvThreadNotSupported' );
                    warning( msg );
                end
            end

            if ( strcmpi( hProp.Name, 'ConvThreadNumber' ) )
                convThreadNum = propertyValue;
                isaPowerOfTwo = floor( log2( sqrt( convThreadNum ) ) ) == ceil( log2( sqrt( convThreadNum ) ) );
                isConvModuleOn = strcmpi( obj.getModuleProperty( 'conv', 'ModuleGeneration' ), 'on' );

                if ( ~isaPowerOfTwo && isConvModuleOn &&  ...
                        ( strcmpi( obj.getModuleProperty( 'fc', 'SoftmaxBlockGeneration' ), 'on' ) ||  ...
                        strcmpi( obj.getModuleProperty( 'fc', 'SigmoidBlockGeneration' ), 'on' ) ) )
                    msg = message( 'dnnfpga:config:NonPowerofTwoConvThreadNotSupported' );
                    warning( msg );
                end
            end
        end

        function validationForCustomBlocks( obj, hProp, hModule, propertyValue )
            if ( strcmpi( hModule.ModuleID, 'custom' ) )
                blocksSupportedForQuantization = obj.CustomLayerManager.getBlocksSupportedForQuantization;
                if ( ~strcmpi( obj.ProcessorDataType, 'single' ) && ~any( strcmp( hProp.Name, blocksSupportedForQuantization ) ) &&  ...
                        strcmpi( propertyValue, 'on' ) )
                    msg = message( 'dnnfpga:config:UnsupportedCustomLayerForQuantization', hProp.Name );
                    error( msg );
                end
            end
        end

    end

    methods ( Hidden )

        function [ isIn, hModule ] = isInModuleIDList( obj, moduleID )







            if strcmpi( moduleID, 'adder' )
                moduleID = dnnfpga.config.CustomLayerModuleConfig.DefaultModuleID;
            end

            if obj.ModuleConfigMap.isKey( moduleID )
                isIn = true;
                hModule = obj.ModuleConfigMap( moduleID );
            else
                isIn = false;
                hModule = [  ];
            end
        end


        function list = getModuleIDList( obj )

            list = obj.ModuleIDList;
        end

        function hModule = getModule( obj, moduleID )

            [ isIn, hModule ] = obj.isInModuleIDList( moduleID );
            if ~isIn

                moduleIDMsg = obj.getModuleIDMessageObj( moduleID );
                error( moduleIDMsg );
            end
        end


        function addModule( obj, hModule )

            moduleID = hModule.ModuleID;
            if ~obj.ModuleConfigMap.isKey( moduleID )
                obj.ModuleConfigMap( moduleID ) = hModule;
                obj.ModuleIDList{ end  + 1 } = moduleID;
            else


            end
        end
    end



    methods ( Hidden )


        function isa = isGenericDLProcessor( obj )

            isa = obj.isGenericDLProcessorTarget( obj.TargetPlatform );
        end

        function hRD = getReferenceDesignObject( obj, rdName )

            if nargin < 2
                rdName = obj.ReferenceDesign;
            end

            hRD = [  ];
            if ~isempty( rdName ) && ~isempty( obj.hRDList )
                hRD = obj.hRDList.getRDPlugin( rdName );
            end
        end

        function hBoard = getBoardObject( obj )

            if obj.isGenericDLProcessor


                toolEnum = dlhdl.Tool.convertToEnum( obj.SynthesisTool );
                hBoard = obj.getGenericDLBoardPlugin( toolEnum );
            else
                hBoard = obj.getBoardListObject( obj.TargetPlatform );
            end
        end

        function validateResourceAvailability( obj )
            x = obj.estimateResources( 'Verbose', 1, 'IncludeReferenceDesign', true );
            if any( contains( x.Row, 'Available' ) )
                if any( contains( x.Row, 'Total' ) )



                    dspUtilization = x{ 'Total', 'DSP' } / x{ 'Available', 'DSP' };
                    ramUtilization = x{ 'Total', 'blockRAM' } / x{ 'Available', 'blockRAM' };
                    lutUtilization = x{ 'Total', 'LUT' } / x{ 'Available', 'LUT' };
                elseif any( contains( x.Row, 'DL_Processor' ) )


                    dspUtilization = x{ 'DL_Processor', 'DSP' } / x{ 'Available', 'DSP' };
                    ramUtilization = x{ 'DL_Processor', 'blockRAM' } / x{ 'Available', 'blockRAM' };
                    lutUtilization = x{ 'DL_Processor', 'LUT' } / x{ 'Available', 'LUT' };
                end
                if ( dspUtilization > 1 || ramUtilization > 1 || lutUtilization > 1 )






                    distributedRAMOverUse = ( lutUtilization > 0.9 && ramUtilization > 1.05 );
                    dspInLogicOverUse = ( lutUtilization > 0.9 && dspUtilization > 1.05 );
                    lutOverUse = ( lutUtilization > 1 );
                    if ( distributedRAMOverUse || dspInLogicOverUse || lutOverUse )
                        error( message( "dnnfpga:config:InsufficientResourceOnDevice", obj.SynthesisToolDeviceName ) );
                    end
                end
            end
        end

    end

    methods ( Access = protected )
        function platformList = getPlatformList( obj )






            boardList = obj.getBoardList;
            filterdBoardList = {  };
            for ii = 1:length( boardList )
                boardName = boardList{ ii };
                hBoard = obj.getBoardListObject( boardName );
                if ~hBoard.isGenericIPPlatform
                    filterdBoardList{ end  + 1 } = boardName;%#ok<AGROW>
                end
            end

            platformList = [ obj.GenericDLProcessorTargetName, filterdBoardList ];
        end
        function boardList = getBoardList( obj )

            boardList = obj.hBoardList.getNameList;
        end
        function [ isIn, hP ] = isInBoardList( obj, boardName )

            [ isIn, hP ] = obj.hBoardList.isInList( boardName );
        end
        function hBoard = getBoardListObject( obj, boardName )

            [ ~, hBoard ] = obj.isInBoardList( boardName );
        end
        function isa = isGenericDLProcessorTarget( obj, boardName )

            isa = strcmpi( boardName, obj.GenericDLProcessorTargetName );
        end


        function loadGenericDLProcessorTarget( obj )


            backupToolEnumList = obj.ToolEnumList;
            try

                obj.ToolEnumList = { dlhdl.Tool.XilinxVivado, dlhdl.Tool.IntelQuartusStandard };


                obj.SynthesisTool = obj.SynthesisToolDefault;

            catch ME



                obj.ToolEnumList = backupToolEnumList;

                rethrow( ME );
            end


            obj.hRDList = [  ];
            obj.ReferenceDesign = '';
        end
        function loadGenericDLBoardPlugin( obj, toolEnum )



            hBoard = obj.getGenericDLBoardPlugin( toolEnum );


            obj.SynthesisToolChipFamily = hBoard.FPGAFamily;
            obj.SynthesisToolDeviceName = hBoard.FPGADevice;
            obj.SynthesisToolPackageName = hBoard.FPGAPackage;
            obj.SynthesisToolSpeedValue = hBoard.FPGASpeed;
        end
        function hBoard = getGenericDLBoardPlugin( obj, toolEnum )

            switch toolEnum
                case dlhdl.Tool.XilinxVivado


                    hBoard = obj.getBoardListObject( 'Generic Deep Learning Processor Xilinx' );

                case dlhdl.Tool.IntelQuartusStandard


                    hBoard = obj.getBoardListObject( 'Generic Deep Learning Processor Intel' );

                otherwise
                    error( message( 'dnnfpga:plugin:InvalidToolEnum' ) );
            end
        end


        function loadCustomDLBoard( obj, boardName )



            hBoard = obj.getBoardListObject( boardName );

            backupToolEnumList = obj.ToolEnumList;
            try
                obj.ToolEnumList = dlhdl.Tool.convertToEnum( hBoard.SupportedTool );





                obj.SynthesisTool = hBoard.SupportedTool{ 1 };

            catch ME



                obj.ToolEnumList = backupToolEnumList;

                rethrow( ME );
            end


            obj.SynthesisToolChipFamily = hBoard.FPGAFamily;
            obj.SynthesisToolDeviceName = hBoard.FPGADevice;
            obj.SynthesisToolPackageName = hBoard.FPGAPackage;
            obj.SynthesisToolSpeedValue = hBoard.FPGASpeed;

        end

        function loadCustomDLReferenceDesignList( obj, toolEnum )


            boardName = obj.TargetPlatform;
            hBoard = obj.getBoardListObject( boardName );



            obj.hRDList = hdlturnkey.plugin.ReferenceDesignListSimple;
            obj.hRDList.buildRDList( hBoard, boardName, dlhdl.Tool.convertToString( toolEnum ) );


            referenceDesignList = obj.getReferenceDesignChoice;

            obj.ReferenceDesign = referenceDesignList{ 1 };

        end

    end


    methods
        function value = get.TargetPlatform( obj )
            value = obj.TargetPlatformInternal;
        end
        function value = get.SynthesisTool( obj )
            value = obj.SynthesisToolInternal;
        end
        function value = get.ReferenceDesign( obj )
            value = obj.ReferenceDesignInternal;
        end

        function list = getTargetPlatformChoice( obj )

            list = obj.getPlatformList;
        end
        function list = getSynthesisToolChoice( obj )

            list = dlhdl.Tool.convertToString( obj.ToolEnumList );
        end
        function list = getReferenceDesignChoice( obj )

            list = { '' };
            if ~isempty( obj.hRDList )
                list = obj.hRDList.getReferenceDesignAll;
            end
        end
    end


    methods
        function set.TargetPlatform( obj, boardName )


            dnnfpga.config.validateStringProperty( boardName, 'TargetPlatform', obj.TargetPlatformDefault );

            mustBeMember( boardName, obj.getTargetPlatformChoice );

            backupTargetPlatformInternal = obj.TargetPlatformInternal;
            try

                obj.TargetPlatformInternal = boardName;

                if obj.isGenericDLProcessorTarget( boardName )

                    obj.loadGenericDLProcessorTarget;
                else

                    obj.loadCustomDLBoard( boardName );
                end
            catch ME

                obj.TargetPlatformInternal = backupTargetPlatformInternal;

                rethrow( ME );
            end
        end
        function set.SynthesisTool( obj, toolName )


            dnnfpga.config.validateStringProperty( toolName, 'SynthesisTool', obj.SynthesisToolDefault );

            mustBeMember( toolName, obj.getSynthesisToolChoice );

            toolEnum = dlhdl.Tool.convertToEnum( toolName );
            if obj.isGenericDLProcessor

                obj.loadGenericDLBoardPlugin( toolEnum );
            else

                obj.loadCustomDLReferenceDesignList( toolEnum );
            end


            obj.SynthesisToolInternal = toolName;
        end
        function set.ReferenceDesign( obj, rdName )

            arguments
                obj
                rdName char
            end

            dnnfpga.config.validateStringProperty( rdName, 'ReferenceDesign', obj.ReferenceDesignDefault );

            mustBeMember( rdName, obj.getReferenceDesignChoice );



            hRD = obj.getReferenceDesignObject( rdName );
            if ~isempty( hRD )
                try
                    hRD.validateReferenceDesign;
                    hRD.validateReferenceDesignForDeepLearning;
                catch ME
                    msg = MException( message( 'dnnfpga:config:InvalidReferenceDesign', rdName ) );
                    msg = msg.addCause( ME );
                    throw( msg );
                end
            end




            obj.ReferenceDesignInternal = rdName;
        end
        function set.SynthesisToolChipFamily( obj, val )
            dnnfpga.config.validateStringProperty( val, 'SynthesisToolChipFamily', obj.SynthesisToolChipFamilyDefault );
            obj.SynthesisToolChipFamily = val;
        end
        function set.SynthesisToolDeviceName( obj, val )
            dnnfpga.config.validateStringProperty( val, 'SynthesisToolDeviceName', obj.SynthesisToolDeviceNameDefault );
            obj.SynthesisToolDeviceName = val;
        end
        function set.SynthesisToolPackageName( obj, val )
            dnnfpga.config.validateStringProperty( val, 'SynthesisToolPackageName', obj.SynthesisToolPackageNameDefault );
            obj.SynthesisToolPackageName = val;
        end
        function set.SynthesisToolSpeedValue( obj, val )
            dnnfpga.config.validateStringProperty( val, 'SynthesisToolSpeedValue', obj.SynthesisToolSpeedValueDefault );
            obj.SynthesisToolSpeedValue = val;
        end
        function set.TargetFrequency( obj, val )
            dnnfpga.config.validatePositiveNumericProperty( val, 'TargetFrequency',  ...
                obj.TargetFrequencyDefault );
            obj.TargetFrequency = val;
        end
        function set.RunTimeControl( obj, val )
            dnnfpga.config.validateStringPropertyValue( val, 'RunTimeControl',  ...
                obj.RunTimeControlChoices, obj.RunTimeControlDefault );
            obj.RunTimeControl = val;
        end
        function set.RunTimeStatus( obj, val )
            dnnfpga.config.validateStringPropertyValue( val, 'RunTimeStatus',  ...
                obj.RunTimeStatusChoices, obj.RunTimeStatusDefault );
            obj.RunTimeStatus = val;
        end
        function set.SetupControl( obj, val )
            dnnfpga.config.validateStringPropertyValue( val, 'SetupControl',  ...
                obj.SetupControlChoices, obj.SetupControlDefault );
            obj.SetupControl = val;
        end
        function set.InputStreamControl( obj, val )
            dnnfpga.config.validateStringPropertyValue( val, 'InputStreamControl',  ...
                obj.InputStreamControlChoices, obj.InputStreamControlDefault );
            obj.InputStreamControl = val;
        end
        function set.OutputStreamControl( obj, val )
            dnnfpga.config.validateStringPropertyValue( val, 'OutputStreamControl',  ...
                obj.OutputStreamControlChoices, obj.OutputStreamControlDefault );
            obj.OutputStreamControl = val;
        end

        function value = get.InputRunTimeControl( obj )
            value = obj.InputStreamControl;
        end
        function set.InputRunTimeControl( obj, val )
            dnnfpga.config.validateStringPropertyValue( val, 'InputRunTimeControl',  ...
                obj.InputStreamControlChoices, obj.InputStreamControlDefault );
            obj.InputStreamControl = val;
        end

        function value = get.OutputRunTimeControl( obj )
            value = obj.OutputStreamControl;
        end
        function set.OutputRunTimeControl( obj, val )
            dnnfpga.config.validateStringPropertyValue( val, 'OutputStreamControl',  ...
                obj.OutputStreamControlChoices, obj.OutputStreamControlDefault );
            obj.OutputStreamControl = val;
        end
        function set.InputDataInterface( obj, val )
            dnnfpga.config.validateStringPropertyValue( val, 'InputDataInterface',  ...
                obj.InputDataInterfaceChoices, obj.InputDataInterfaceDefault );
            obj.InputDataInterface = val;
        end

        function set.OutputDataInterface( obj, val )
            dnnfpga.config.validateStringPropertyValue( val, 'OutputDataInterface',  ...
                obj.OutputDataInterfaceChoices, obj.OutputDataInterfaceDefault );
            obj.OutputDataInterface = val;
        end

        function set.ProcessorDataType( obj, val )

            if ( strcmpi( dnnfpgafeature( 'FixedPointWorkflow' ), 'on' ) )
                validProcessorDataTypeChoices = obj.ProcessorDataTypeChoicesFixedPoint;
            else
                validProcessorDataTypeChoices = obj.ProcessorDataTypeChoices;
            end
            dnnfpga.config.validateStringPropertyValue( val, 'ProcessorDataType',  ...
                validProcessorDataTypeChoices, obj.ProcessorDataTypeDefault );



            customLayerManager = obj.CustomLayerManager;%#ok<MCSUP>
            if ~isempty( customLayerManager )
                customLayerList = customLayerManager.getUserLayerList;
                if ~isempty( customLayerList ) && ~strcmpi( val, 'single' )
                    msg = message( 'dnnfpga:customLayer:UnableChangeDataType', val );
                    error( msg );
                end
                customModule = obj.getModule( 'custom' );

                if ( strcmpi( val, 'int8' ) && customModule.ModuleGeneration )


                    registeredCustomBlocks = customLayerManager.getLayerList( true );
                    registeredCustomBlockNames = arrayfun( @( x )x.ConfigBlockName, registeredCustomBlocks, UniformOutput = false );



                    blocksSupportedForQuantization = customLayerManager.getBlocksSupportedForQuantization;

                    for i = 1:numel( blocksSupportedForQuantization )
                        indexToRemove = strcmpi( registeredCustomBlockNames, blocksSupportedForQuantization{ i } );
                        registeredCustomBlockNames( indexToRemove ) = [  ];
                    end

                    for i = 1:numel( registeredCustomBlockNames )
                        blockName = registeredCustomBlockNames{ i };
                        if ( customModule.( blockName ) )
                            msg = message( 'dnnfpga:customLayer:UnableChangeDataType', val );
                            error( msg );
                        end
                    end
                end

                if ( strcmpi( obj.getModuleProperty( 'fc', 'ModuleGeneration' ), 'on' ) &&  ...
                        strcmpi( obj.getModuleProperty( 'fc', 'SigmoidBlockGeneration' ), 'on' ) &&  ...
                        strcmpi( val, 'single' ) )

                    msg = message( 'dnnfpga:config:UnsupportedSigmoidConfigurationForSingle' );
                    error( msg );
                end
            end
            obj.ProcessorDataType = val;

        end

        function set.CalibrationData( obj, calData )

            if isstruct( calData ) && isequal( fields( calData ), { 'BurstLengths';'ReadLatencies';'WriteLatencies' } ) &&  ...
                    isnumeric( calData.BurstLengths ) && isnumeric( calData.ReadLatencies ) && isnumeric( calData.ReadLatencies )
                obj.CalibrationData = calData;
            else
                error( message( 'dnnfpga:config:InvalidCalibrationData' ) );
            end
        end
    end

    methods ( Access = public )
        function varargout = estimatePerformance( obj, network, varargin )










            validInputs = { 'SeriesNetwork', 'DAGNetwork', 'dlquantizer', 'dlnetwork' };
            if ( nargin < 2 ) || ( ~ismember( class( network ), validInputs ) )
                error( message( 'dnnfpga:workflow:EstimateFirstInput' ) );
            end


            if isequal( obj.TargetPlatform, 'Generic Deep Learning Processor' )
                error( message( 'dnnfpga:config:InvalidPlatformPerfEstimation' ) );
            end



            dnnfpga.validateDLSupportPackage( 'shared', 'multiple' );

            if ( isa( network, 'dlquantizer' ) )

                network = network.Net;
            end

            p = inputParser;
            addParameter( p, 'InternalArchParam', [  ] );


            addParameter( p, 'FrameCount', 1, @isnumeric );
            addParameter( p, 'Verbose', dnnfpgafeature( 'Verbose' ) );
            parse( p, varargin{ : } );
            InternalArchParam = p.Results.InternalArchParam;
            verbose = p.Results.Verbose;
            frameNum = p.Results.FrameCount;


            if ~isscalar( frameNum )
                error( message( 'dnnfpga:config:ScalarProperty',  ...
                    'FrameCount', '10' ) );
            end

            if frameNum <= 0 || frameNum == Inf
                valueStr = sprintf( '%g', frameNum );
                error( message( 'dnnfpga:config:PositiveProperty',  ...
                    valueStr, 'FrameCount', '10' ) );
            end


            obj.hBackDoorFiFeature.enable;


            try

                if class( obj ) == "dnnfpga.config.CNN5ProcessorConfig"
                    allowDAGNetwork = 1;
                else
                    allowDAGNetwork = 0;
                end

                obj.validateNet( network, allowDAGNetwork );

                result = obj.estimateSpeed( network,  ...
                    InternalArchParam, frameNum, verbose, obj.CalibrationData );

                if isempty( obj.CalibrationData ) && ~contains( lower( obj.SynthesisToolChipFamily ), { 'zynq', 'arria 10' } )
                    dnnfpga.disp( message( 'dnnfpga:dnnfpgadisp:CustomVendor' ) );
                end
            catch ME


                obj.hBackDoorFiFeature.disable;
                throwAsCaller( ME );
            end

            if nargout > 0
                varargout{ 1 } = result;
            end


            obj.hBackDoorFiFeature.disable;
        end


        function varargout = estimateResources( obj, varargin )










            if ( mod( nargin, 2 ) == 0 )
                error( message( 'dnnfpga:config:EstimateAreaNotPair' ) );
            end
            p = inputParser;
            addParameter( p, 'Verbose', 1, @( x )( isnumeric( x ) && x >= 0 ) );
            addParameter( p, 'IncludeReferenceDesign', false, @( x )( islogical( x ) ) );
            parse( p, varargin{ : } );
            verbosity = p.Results.Verbose;
            IncludeReferenceDesign = p.Results.IncludeReferenceDesign;


            customLayerList = obj.CustomLayerManager.getUserLayerList;
            classNameList = [  ];
            for customLayer = customLayerList
                classNameList = horzcat( classNameList, convertCharsToStrings( customLayer.ClassName ) );%#ok<AGROW>
            end
            if ~isempty( customLayerList )
                msg = message( 'dnnfpga:customLayer:InaccuarateEstimateResource', strjoin( classNameList, ', ' ) );
                warning( msg );
            end

            try
                result = obj.estimateArea( verbosity, IncludeReferenceDesign );
            catch ME
                throwAsCaller( ME );
            end

            if nargout > 0
                varargout{ 1 } = result;
            end

        end


        function bitstreamPath = buildCalibrationBitstream( obj )













            modelPath = fullfile( matlabroot, 'toolbox', 'dnnfpga', 'dnnfpga', 'model', 'EstimatorCalibration' );
            addpath( modelPath );
            calibrationProjectPath = fullfile( pwd, 'EstimatorCalibration' );


            mkdir( calibrationProjectPath );
            currentPath = pwd;
            cd( calibrationProjectPath );


            obj.hBackDoorFiFeature.enable;


            try
                bitstreamPath = dnnfpga.estimate.buildCalibrationBitstream( calibrationProjectPath, obj );
            catch ME


                bdclose( 'loopback_external_memory' );
                rmpath( modelPath );
                cd( currentPath );

                obj.hBackDoorFiFeature.disable;
                throwAsCaller( ME );
            end


            obj.hBackDoorFiFeature.disable;

            rmpath( modelPath );
            cd( currentPath );
        end

        function deployCalibrationBitstream( obj, bitstreamPath )













            if ~isfile( bitstreamPath )
                error( message( 'dnnfpga:config:InvalidBitstreamFile' ) );
            end

            try

                obj.CalibrationData = dnnfpga.estimate.deployCalibrationBitstream( bitstreamPath, obj );
                dnnfpga.disp( message( 'dnnfpga:dnnfpgadisp:CalibrationFinish' ) );
            catch ME
                throwAsCaller( ME );
            end
        end
    end

    methods ( Abstract )


        validateProcessorConfig( obj )

    end


    methods ( Abstract, Hidden )































        bcc = applyProcessorConfigtoBCC( obj )


        hProcessor = createProcessorObject( obj )

    end

    methods

        function optimizeConfigurationForNetwork( ~, ~ )

        end
    end

    methods ( Hidden )

        function hProcessorModel = createProcessorModel( obj, verbose )










            hProcessorModel = dnnfpga.model.CNN5ProcessorModel( obj, verbose );

        end

    end

    methods ( Access = protected )

    end



    methods ( Access = protected )
        function result = estimateSpeed( obj, network, InternalArchParam, frameNum, verbose, calData )


            cnnp = obj.createProcessorObject;



            result = [  ];


            fpgaParamLayers = dnnfpga.compiler.codegenSN2TPEstIR( network, cnnp, 'exponentData', [  ], 'ProcessorConfig', obj, 'Verbose', verbose );



            if isempty( fpgaParamLayers )
                dnnfpga.disp( message( 'dnnfpga:config:NoEstimatableLayer' ) );
                return ;
            end

            estimator = dnnfpga.estimate.EstimatorNetworkTime( cnnp, fpgaParamLayers, obj, InternalArchParam, frameNum, verbose, calData );
            estimator.populateNetworkLayerLatency(  );
            result = estimator.getNetworkTime(  );
        end

        function result = estimateArea( obj, verbosity, includeReferenceDesign )



            cnnp = obj.createProcessorObject;
            estimator = dnnfpga.estimate.EstimatorNetworkArea( cnnp, obj );
            estimator.populateNetworkLayerArea;
            result = estimator.estimateArea( verbosity, includeReferenceDesign );


        end

        function validateNet( obj, network, allowDAGNetwork )
            if isempty( network )
                error( message( 'dnnfpga:workflow:InvalidInputEmpty', 'Network' ) );
            end

            if ~dnnfpga.compiler.canCompileNet( network, ~allowDAGNetwork )
                error( message( 'dnnfpga:workflow:InvalidInputWrongClass', 'Network', 'SeriesNetwork or DAGNetwork', class( obj.Network ) ) );
            end
        end

    end


    methods ( Hidden )
        function disp( obj, varargin )



            moduleIDList = obj.getModuleIDList;
            for ii = 1:length( moduleIDList )
                moduleID = moduleIDList{ ii };
                hModule = obj.getModule( moduleID );
                hModule.ShowHidden = obj.ShowHidden;
                hModule.disp;
            end


            obj.dispHeading( 'Processor Top Level Properties' );
            obj.dispProperties( 'ProcessorTopLevelProperties' );


            obj.dispHeading( 'System Level Properties' );
            obj.dispProperties( 'SystemLevelProperties' );

        end
    end
end



