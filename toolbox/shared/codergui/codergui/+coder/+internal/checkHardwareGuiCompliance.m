function [ valid, error ] = checkHardwareGuiCompliance( hwArg, opts )

arguments
    hwArg = [  ]
    opts.Strict( 1, 1 ){ mustBeNumericOrLogical( opts.Strict ) } = false
end

if isempty( hwArg )
    hwArg = emlcprivate( 'projectCoderHardware' );
elseif ischar( hwArg ) || isstring( hwArg )
    hwArg = cellstr( hwArg );
else
    hwArg = num2cell( hwArg );
end

valid = false( size( hwArg ) );
error = cell( size( hwArg ) );

for i = 1:numel( hwArg )
    [ valid( i ), error{ i } ] = validateHardware( hwArg{ i }, opts.Strict );
end
end


function [ valid, err ] = validateHardware( hardware, strict )
if isempty( hardware ) || isequal( hardware, 'MATLAB Host Computer' )
    valid = true;
    err = [  ];
    return
end

hwName = '????';
try
    if ischar( hardware ) || isstring( hardware )

        hwName = hardware;
        hardware = emlcprivate( 'projectCoderHardware', hardware );
    end

    validateattributes( hardware, { 'coder.Hardware', 'coder.TargetPackageHardware' }, {  } );
    hwName = hardware.Name;



    validateattributes( hardware.Name, { 'char' }, { 'nonempty' } );
    validateattributes( hardware.Version, { 'char', 'double' }, { 'nonempty' } );
    validateattributes( hardware.HardwareInfo, { 'codertarget.targethardware.TargetHardwareInfo' }, { 'size', [ 1, 1 ] } );
    validateattributes( hardware.ParameterInfo, { 'struct' }, { 'size', [ 1, 1 ] } );


    verifyFieldsAndProperties( hardware.HardwareInfo, 'Name', 'TargetName', 'DeviceID',  ...
        'SubFamily', 'TargetFolder', 'ProdHWDeviceType', 'ToolChainInfo' );
    assert( ~isempty( hardware.HardwareInfo.Name ), 'HardwareInfo.Name must not be empty' );
    verifyFieldsAndProperties( hardware.HardwareInfo.ToolChainInfo, 'Name', 'LoaderName',  ...
        'LoadCommand', 'IsLoadCommandMATLABFcn' );
    verifyDeviceName( hardware.HardwareInfo.ProdHWDeviceType );


    verifyFieldsAndProperties( hardware.ParameterInfo, 'ParameterGroups', 'Parameter' );
    cellfun( @( paramGroup )assert( ischar( paramGroup ) ), hardware.ParameterInfo.ParameterGroups );


    validateattributes( hardware.ParameterInfo.Parameter, { 'cell' },  ...
        { 'size', size( hardware.ParameterInfo.ParameterGroups ) } );


    validateParametersForApp( hardware.ParameterInfo.Parameter );
    if strict


        validateParameterStorage( hardware );
    end

    valid = true;
    err = [  ];
catch me
    err = addCause( MException( 'coder:hardware:invalidHardware', 'Hardware "%s" failed validation', hwName ), me );
    valid = false;
end
end


function validateParameterStorage( hw )



groups = codergui.internal.getHardwareParameterInfo( hw );
badStorage = {  };

for i = 1:numel( groups )
    for j = 1:numel( groups( i ).parameters )
        pDef = groups( i ).parameters{ j };
        if ~pDef.DoNotStore && ~isempty( pDef.Storage )
            try
                evalc( [ 'hw.', pDef.Storage ] );
            catch
                badStorage{ end  + 1 } = pDef.Storage;%#ok<AGROW>
            end
        end
    end
end

if ~isempty( badStorage )
    error( 'Expected storage path(s) %s do not valid on hardware object', strjoin( strcat( '"', badStorage, '"' ), ', ' ) );
end
end


function validateParametersForApp( parameters )
validateattributes( parameters, { 'cell' }, {  } );

if ~usejava( 'jvm' )
    return ;
end


persistent javaParamFields;
if isempty( javaParamFields )
    javaParamFields = javaMethod( 'getRequiredFields', 'com.mathworks.toolbox.coder.target.CtRawField' );
    javaParamFields = cell( javaParamFields.toArray(  ) );
    for i = 1:numel( javaParamFields )
        javaParamField = javaParamFields{ i };
        javaParamFields{ i } = char( javaParamField.getRawKey(  ) );
    end
end

for i = 1:numel( parameters )

    cellfun( @( param )verifyFieldsAndProperties( param, javaParamFields{ : } ), parameters{ i } );
end
end


function verifyFieldsAndProperties( actual, varargin )
assert( isstruct( actual ) || isobject( actual ) );
if isstruct( actual )
    fieldsOrProps = fields( actual );
else
    fieldsOrProps = properties( actual );
end
assert( all( ismember( varargin, fieldsOrProps ) ) );
end


function verifyDeviceName( deviceName )
hwi = coder.HardwareImplementation;
try
    hwi.ProdHWDeviceType = deviceName;
catch
    error( '"%s" is not a valid ProdHWDeviceType', deviceName );
end
end
