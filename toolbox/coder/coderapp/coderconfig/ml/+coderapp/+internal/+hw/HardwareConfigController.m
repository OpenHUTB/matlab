classdef HardwareConfigController < coderapp.internal.config.AbstractController

    properties ( Constant, Hidden )
        HW_NONE = "<<<NONE>>>"
        HW_MATLAB = "<<<MATLAB>>>"
        MATLAB_HOST = "MATLAB Host Computer"
    end

    properties ( Constant, Access = private )
        OPT_HW_NONE = toOption( coderapp.internal.hw.HardwareConfigController.HW_NONE,  ...
            'coderApp:config:coderGeneral:hwCustomNone' )
        OPT_HW_MATLAB = toOption( coderapp.internal.hw.HardwareConfigController.HW_MATLAB,  ...
            'coderApp:config:coderGeneral:hwMatlabHost' )
        HardwareImpl = coder.HardwareImplementation
    end

    methods
        function updateProdDeviceVendor( this, hardwareName, hardware, isBoundHwImpl, prodEqTarget )
            if prodEqTarget && ~isempty( hardware )
                this.set( extractVendor( hardware.HardwareInfo.ProdHWDeviceType ) );
            elseif prodEqTarget && ~isBoundHwImpl && hardwareName == this.HW_MATLAB
                this.set( 'Generic' );
            else
                this.set( 'DefaultValue', 'Generic' );
            end
            if this.Awake
                this.import( 'AllowedValues', this.getHardwareVendors( true ) );
            else
                this.useCurrentValueAsEnumeration(  );
            end
            this.disableIfHardware( true, hardwareName, isBoundHwImpl, prodEqTarget );
        end

        function updateProdDeviceType( this, hardwareName, hardware, isBoundHwImpl, prodEqTarget, prodDeviceVendor )
            this.updateDeviceTypeParam( isBoundHwImpl, hardwareName, prodDeviceVendor, prodEqTarget );
            if prodEqTarget && ~isempty( hardware )
                this.set( extractType( hardware.HardwareInfo.ProdHWDeviceType ) );
            elseif prodEqTarget && ~isBoundHwImpl && strcmp( hardwareName, this.HW_MATLAB )
                this.set( this.MATLAB_HOST );
            end
            this.disableIfHardware( true, hardwareName, isBoundHwImpl, prodEqTarget );
        end

        function updateTargetDeviceVendor( this, hardwareName, hardware, isBoundHwImpl, prodEqTarget )
            if ~prodEqTarget && ~isempty( hardware )
                this.set( extractVendor( hardware.HardwareInfo.ProdHWDeviceType ) );
            elseif ~prodEqTarget && ~isBoundHwImpl && hardwareName == this.HW_MATLAB
                this.set( 'Generic' );
            else
                this.set( 'DefaultValue', 'Generic' );
            end
            if this.Awake
                this.import( 'AllowedValues', this.getHardwareVendors( false ) );
            else
                this.useCurrentValueAsEnumeration(  );
            end
            this.disableIfHardware( false, hardwareName, isBoundHwImpl, prodEqTarget );
        end

        function updateTargetDeviceType( this, hardwareName, targetDeviceVendor, hardware, isBoundHwImpl, prodEqTarget )
            this.updateDeviceTypeParam( isBoundHwImpl, hardwareName, targetDeviceVendor, ~prodEqTarget );
            if ~prodEqTarget
                if ~isempty( hardware )
                    this.set( extractType( hardware.HardwareInfo.ProdHWDeviceType ) );
                elseif ~isBoundHwImpl && strcmp( hardwareName, this.HW_MATLAB )
                    this.set( this.MATLAB_HOST );
                end
            end
            this.disableIfHardware( false, hardwareName, isBoundHwImpl, prodEqTarget );
        end

        function updateProdDeviceCategoryName( this, prodEqTarget )
            if prodEqTarget
                msgKey = 'coderApp:config:coderParams:category_sameDevice';
            else
                msgKey = 'coderApp:config:coderParams:category_prodDevice';
            end
            this.set( 'Name', getString( message( msgKey ) ) );
        end

        function updateHardwareNames( this, gpuEnabled, prodEqTarget, isStandaloneHwImpl )
            if ~isStandaloneHwImpl
                if this.Awake
                    boards = this.getValidHardwareNames(  );
                    boardOpts = repmat( coderapp.internal.config.data.EnumOption, 1, numel( boards ) );
                    [ boardOpts.Value ] = boards{ : };
                    if gpuEnabled
                        enabled = num2cell( startsWith( lower( boards ), 'nvidia' ) );
                        [ boardOpts.Enabled ] = enabled{ : };
                    end
                    this.set( 'DefaultValue', this.HW_MATLAB );
                else
                    boardOpts = coderapp.internal.config.data.EnumOption.empty(  );
                end


                current = this.get(  );
                if ~any( strcmp( current, [ this.HW_NONE, this.HW_MATLAB ] ) )
                    boardOpts( end  + 1 ).Value = current;
                    boardOpts( end  ).Enabled = false;
                end

                this.set( 'AllowedValues', [ this.OPT_HW_MATLAB, boardOpts, this.OPT_HW_NONE ] );
            else
                this.set( 'AllowedValues', coderapp.internal.config.data.EnumOption.empty(  ) );
            end

            if prodEqTarget
                msgKey = 'coderApp:config:coderParams:hardwareName';
            else
                msgKey = 'coderApp:config:coderParams:hardwareName_target';
            end
            this.set( 'Name', getString( message( msgKey ) ) );
        end

        function updateHardwareImplPropState( this, defaultHwImpl, isBoundHwImpl, prodEqTarget, hwName )
            prop = this.metadata( 'objectProperty' );
            this.set( 'Enabled',  ...
                this.shouldEnableProperty( startsWith( prop, 'Prod' ), hwName, isBoundHwImpl, prodEqTarget ) &&  ...
                defaultHwImpl.isEnabledProperty( prop ) );
            this.set( 'Visible', defaultHwImpl.isVisibleProperty( prop ) );
        end
    end

    methods ( Access = private )
        function updateDeviceTypeParam( this, isBoundHwImpl, hwName, vendor, constrain )
            if this.Awake
                [ deviceTypes, globalDefault ] = this.getHardwareTypes( vendor, true );
                default = globalDefault;
                if ~isBoundHwImpl && vendor == "Generic"
                    switch hwName
                        case this.HW_NONE
                            default = "Custom";
                        case this.HW_MATLAB
                            deviceTypes( { deviceTypes.Value } ~= this.MATLAB_HOST ) = [  ];
                            default = this.MATLAB_HOST;
                        otherwise
                            if constrain
                                deviceTypes( ismember( { deviceTypes.Value }, [ this.MATLAB_HOST, "Custom", globalDefault ] ) ) = [  ];
                                default = "Unspecified (assume 32-bit Generic)";
                            end
                    end
                end
                this.import( 'AllowedValues', deviceTypes );
                if constrain && ( ~strcmp( default, globalDefault ) || ~ismember( this.get(  ), { deviceTypes.Value } ) )
                    this.SetAsExternal = true;
                    this.set( default );
                    this.SetAsExternal = false;
                end
                this.set( 'DefaultValue', globalDefault );
            else
                if isempty( this.get(  ) ) && vendor == "Generic"
                    this.set( this.MATLAB_HOST );
                end
                this.useCurrentValueAsEnumeration(  );
            end
        end

        function vendors = getHardwareVendors( this, isProduction )
            vendors = this.HardwareImpl.VendorNames( logicalToArg( isProduction ) );
        end

        function [ options, default ] = getHardwareTypes( this, vendor, isProduction )
            if ~this.isValidVendor( vendor, isProduction )

                options = coderapp.internal.config.data.EnumOption.empty(  );
                return
            end
            if isProduction
                prodStr = 'Production';
            else
                prodStr = 'Target';
            end
            hwImpl = this.HardwareImpl;
            hwImpl.VendorName( prodStr, vendor );
            types = hwImpl.TypeNames( prodStr );
            selectable = ismember( types, hwImpl.SelectableTypeNames( prodStr ) );
            options = repmat( coderapp.internal.config.data.EnumOption(  ), 1, numel( types ) );
            for i = 1:numel( types )
                options( i ).Value = types{ i };
                options( i ).Enabled = selectable( i );
            end
            if strcmp( vendor, 'Generic' )
                default = this.MATLAB_HOST;
            else
                default = hwImpl.TypeName( prodStr );
            end
        end

        function valid = isValidVendor( this, vendor, isProduction )
            valid = ismember( vendor, this.getHardwareVendors( isProduction ) );
        end

        function useCurrentValueAsEnumeration( this, varargin )
            current = this.get(  );
            if isempty( current )
                current = {  };
            else
                current = { current };
            end
            this.import( 'AllowedValues', unique( [ current, varargin ], 'stable' ) );
        end

        function disableIfHardware( this, isProd, hwName, isBoundHwImpl, prodEqTarget )
            this.set( 'Enabled', this.shouldEnableProperty( isProd, hwName, isBoundHwImpl, prodEqTarget ) );
        end

        function enabled = shouldEnableProperty( this, isProd, hwName, isBoundHwImpl, prodEqTarget )
            if isBoundHwImpl || strcmp( hwName, this.HW_NONE )
                enabled = isProd || ~prodEqTarget;
            elseif prodEqTarget
                enabled = false;
            else
                enabled = isProd;
            end
        end
    end

    methods ( Static )
        function yes = isHardwareName( hwName )
            arguments
                hwName{ mustBeTextScalar( hwName ) }
            end
            yes = ~isempty( hwName ) && ~any( strcmp( hwName, [
                coderapp.internal.hw.HardwareConfigController.HW_NONE
                coderapp.internal.hw.HardwareConfigController.HW_MATLAB
                ] ) ) && ismember( hwName, emlcprivate( 'projectCoderHardware' ) );
        end

        function boards = getValidHardwareNames(  )
            persistent isValid;
            if ~isa( isValid, 'containers.Map' )
                isValid = containers.Map(  );
            end

            boards = cellstr( setdiff( reshape( emlcprivate( 'projectCoderHardware' ), 1, [  ] ),  ...
                coderapp.internal.hw.HardwareConfigController.MATLAB_HOST, 'stable' ) );
            usable = true( size( boards ) );
            seen = isValid.isKey( boards );
            sUsable = isValid.values( boards( seen ) );
            usable( seen ) = [ sUsable{ : } ];

            for i = find( ~seen )
                [ valid, error ] = coder.internal.checkHardwareGuiCompliance( boards{ i } );
                if ~valid
                    usable( i ) = false;
                    if iscell( error )
                        error = error{ 1 };
                    end
                    coder.internal.gui.asyncDebugPrint( error );
                end
                isValid( boards{ i } ) = valid;
            end
            boards = boards( usable );
        end
    end
end


function vendor = extractVendor( typeStr )
vendor = extractBefore( typeStr, '->' );
end


function vendor = extractType( typeStr )
vendor = extractAfter( typeStr, '->' );
end


function opt = toOption( value, dispKey )
arguments
    value
    dispKey = ''
end
opt = coderapp.internal.config.data.EnumOption(  );
opt.Value = value;
if ~isempty( dispKey )
    opt.DisplayValue = message( dispKey ).getString(  );
end
end


function argStr = logicalToArg( isProduction )
if isProduction
    argStr = 'Production';
else
    argStr = 'Target';
end
end


