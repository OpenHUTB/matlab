function [ mexVerboseText, errorOccurred ] = sfbuilder_mexbuild( ad, sfunctionName,  ...
addLibsStr, varargin )






































inport_num = length( ad.SfunWizardData.InputPorts.Name );
outport_num = length( ad.SfunWizardData.OutputPorts.Name );
PortsHaveFixPtDataType = false;
mexVerboseText = '';
errorOccurred = 0;
addLibsStr = strrep( addLibsStr, '$MATLABROOT', matlabroot );

escApostrophe = @( x )regexprep( x, '''', '''''' );

addIncludePathStr = '';
if nargin > 3
addIncludePaths = {  };
if ~isempty( varargin{ 1 } )
numAddIncPaths = 0;
if iscell( varargin{ 1 } )
numAddIncPaths = length( varargin{ 1 } );
addIncludePaths = varargin{ 1 };
elseif ischar( varargin{ 1 } )
numAddIncPaths = 1;
addIncludePaths = { varargin{ 1 } };
end 
for addIncIdx = 1:numAddIncPaths
if isempty( addIncludePaths{ addIncIdx } )
continue ;
end 
addIncludePathStr = [ addIncludePathStr, ',''-I', escApostrophe( addIncludePaths{ addIncIdx } ), '''' ];
end 
end 
end 


addPreprocDefsStr = ',''-DUSE_PUBLISHED_ONLY''';
if nargin > 4
addPreprocDefs = {  };
if ~isempty( varargin{ 2 } )
numPreprocDefs = 0;
if iscell( varargin{ 2 } )
numPreprocDefs = length( varargin{ 2 } );
addPreprocDefs = varargin{ 2 };
elseif ischar( varargin{ 2 } )
numPreprocDefs = 1;
addPreprocDefs = { varargin{ 2 } };
end 
for addPreprocIdx = 1:numPreprocDefs
if isempty( addPreprocDefs{ addPreprocIdx } )
continue ;
end 
addPreprocDefsStr = [ addPreprocDefsStr, ',''-D', escApostrophe( addPreprocDefs{ addPreprocIdx } ), '''' ];
end 
end 
end 

sldvInfo = [  ];
doSldvInstrum =  ...
isfield( ad.SfunWizardData, 'SupportSldv' ) &&  ...
ad.SfunWizardData.SupportSldv == '1';
doCov = doSldvInstrum ||  ...
( isfield( ad.SfunWizardData', 'SupportCoverage' ) &&  ...
ad.SfunWizardData.SupportCoverage == '1' );
if nargin > 5 && doSldvInstrum && isa( varargin{ 3 }, 'sldv.code.sfcn.internal.StaticSFcnInfoWriter' )
sldvInfo = varargin{ 3 };
end 

isVerbose = 0;
if nargin > 6
isVerbose = varargin{ 4 };
end 

isDebugBuild = 0;
if nargin > 7
isDebugBuild = varargin{ 5 };
end 


for k = 1:inport_num
inPortsInfo.DataType{ k } = char( ad.SfunWizardData.InputPorts.DataType( k ) );
if ( any( strcmp( inPortsInfo.DataType{ k }, { 'fixpt', 'cfixpt', 'real16_T', 'crealt16_T', 'int64_T', 'cint64_T', 'uint64_T', 'cuint64_T' } ) ) )
PortsHaveFixPtDataType = true;
break ;
end 
end 

if ~PortsHaveFixPtDataType
for m = 1:outport_num
outPortsInfo.DataType{ m } = char( ad.SfunWizardData.OutputPorts.DataType( m ) );
if ( any( strcmp( outPortsInfo.DataType{ m }, { 'fixpt', 'cfixpt', 'real16_T', 'crealt16_T', 'int64_T', 'cint64_T', 'uint64_T', 'cuint64_T' } ) ) )
PortsHaveFixPtDataType = true;
break ;
end 
end 
end 



if PortsHaveFixPtDataType
if isunix
fixptlibstr = [ '-L', matlabroot, '/bin/', lower( computer ), ''',''-lfixedpoint' ];
else 
try 
compiler_info = slgetcompilerinfo;
catch e
errorOccurred = 1;
mexVerboseText = lasterr;
return 
end 

libDir = '';
switch ( compiler_info.compilerName )
case 'lcc'
libDir = fullfile( matlabroot, 'extern', 'lib', computer( 'arch' ), 'lcc' );
case { 'bc54', 'bc53', 'bc50' }
libDir = fullfile( matlabroot, 'extern', 'lib', computer( 'arch' ), 'borland' );
case { 'msvc50', 'msvc60', 'msvc70', 'msvc80', 'msvc90', 'msvc100', 'msvc100free', 'msvc110', 'intelc91msvs2005', 'intelc11msvs2008' }
libDir = fullfile( matlabroot, 'extern', 'lib', computer( 'arch' ), 'microsoft' );
case 'watcom'
libDir = fullfile( matlabroot, 'extern', 'lib', computer( 'arch' ), 'watcom' );
case 'mingw64'
libDir = fullfile( matlabroot, 'extern', 'lib', computer( 'arch' ), 'mingw64' );
end 
fixptlibstr = fullfile( libDir, 'libfixedpoint.lib' );
end 

addLibsStr = [ addLibsStr, ',''', fixptlibstr, '''' ];

end 


IncludePath{ 1 } = [ '-I', filesep ];
IncludePath{ 2 } = [ '-I', filesep ];
IncludePath{ 3 } = [ '-I', filesep ];
baseIncludePath = cell( 1, 3 );


try 
if isappdata( 0, 'SfunctionBuilderIncludePath' )
baseIncludePath = getappdata( 0, 'SfunctionBuilderIncludePath' );
if ( iscell( baseIncludePath ) & length( baseIncludePath ) == 3 )
for k = 1:length( baseIncludePath )
if ischar( baseIncludePath{ k } ) & ~isempty( baseIncludePath{ k } )
IncludePath{ k } = [ '-I', baseIncludePath{ k } ];
end 
end 
end 
end 
end 


sfunctionName = escApostrophe( sfunctionName );
IncludePath = escApostrophe( IncludePath );



IncludePath = [ '''', IncludePath{ 1 }, ''',''', IncludePath{ 2 }, ''',''', IncludePath{ 3 }, '''' ];


if doCov
mexCommand = sprintf( 'slcovmex(''-internalfile'', ''%s'',', sfunctionName );
else 
mexCommand = 'mex(';
end 


if ( isVerbose )
mexCommand = [ mexCommand, '''-v'',' ];
end 


if ( isDebugBuild )
mexCommand = [ mexCommand, '''-g'',' ];
end 


hasComplexParameter = any( strcmp( ad.SfunWizardData.Parameters.Complexity, 'COMPLEX_YES' ) );
if ( hasComplexParameter )
mexCommand = [ mexCommand, '''-R2018a'',' ];
end 

mexCommand = [ mexCommand, '''', sfunctionName, ''',', addLibsStr, ',', IncludePath ];


if ~isempty( strtrim( addIncludePathStr ) )
mexCommand = [ mexCommand, addIncludePathStr ];
end 


if ~isempty( strtrim( addPreprocDefsStr ) )
mexCommand = [ mexCommand, addPreprocDefsStr ];
end 

if doSldvInstrum && ~isempty( sldvInfo )
mexCommand = [ mexCommand, ', ''-sldvInfo'', sldvInfo' ];
end 

mexCommand = [ mexCommand, ')' ];

mexDebugInfo = '';
if ~isempty( eval( 'DebugSFunctionBuilder;', '[]' ) )
mexDebugInfo = sprintf( 'MEX Command used: %s :\n', mexCommand );
end 

[ mexVerboseText, errorOccurred ] = evalc( mexCommand );
mexVerboseText = [ mexDebugInfo, mexVerboseText ];

% Decoded using De-pcode utility v1.2 from file /tmp/tmpGh0ST5.p.
% Please follow local copyright laws when handling this file.

