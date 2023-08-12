function varargout = sfunctionwizard( varargin )














persistent USERDATA;
if nargin < 1
argchkstr = getString( message( 'MATLAB:narginchk:notEnoughInputs' ) );
elseif nargin > 4
argchkstr = getString( message( 'MATLAB:narginchk:tooManyInputs' ) );
else 
argchkstr = '';
end 
if ~isempty( argchkstr )
DAStudio.error( 'Simulink:tools:SFunctionWizardInvalidArgs', argchkstr );
end 

blockHandle = varargin{ 1 };
rtwsimTest = 0;
mlock
if nargin == 1

Action = 'Create';
else 
Action = varargin{ 2 };
rtwsimTest = 1;
end 


switch ( Action )



case 'Create'
rtwsimTest = 0;
sfcnbuilder.setup( blockHandle, rtwsimTest );
return ;



case 'delete'
sfcnbuilder.destroyViewAndModel( blockHandle );
return ;



case 'GetRequiredFiles'


ad = sfcnbuilder.setupdata( blockHandle, rtwsimTest );


files = {  };
if ~isempty( ad.SfunWizardData.LibraryFilesText )
tmpCell = textscan( ad.SfunWizardData.LibraryFilesText, '%s',  ...
'delimiter', sprintf( '\n' ) );
if iscell( tmpCell )
files = tmpCell{ 1 };
end 
end 



[ ~, sfunctionName ] = fileparts( ad.SfunWizardData.SfunName );
if ~isempty( sfunctionName )
files = [ files;CheckExist( [ sfunctionName, '.', ad.LangExt ] ) ];
files = [ files;CheckExist( [ sfunctionName, '.tlc' ] ) ];
files = [ files;CheckExist( [ sfunctionName, '_wrapper.', ad.LangExt ] ) ];
files = [ files;CheckExist( [ 'SFB__', sfunctionName, '__SFB.mat' ] ) ];
end 
varargout{ 1 } = files( ~cellfun( 'isempty', files ) );


folders = ad.IncludeDir;
if iscell( folders )
varargout{ 2 } = folders( ~cellfun( 'isempty', folders ) );
else 
varargout{ 2 } = {  };
end 


handcode = { ad.SfunWizardData.IncludeHeadersText; ...
ad.SfunWizardData.UserCodeText };
varargout{ 3 } = handcode( ~cellfun( 'isempty', handcode ) );
return 




case 'GetApplicationData'
sfcnbuilder.setup( blockHandle, rtwsimTest );
sfcnmodel = sfunctionbuilder.internal.sfunctionbuilderModel.getInstance(  );
ad = sfcnmodel.getApplicationData( blockHandle );
varargout{ 1 } = ad;




case 'doBuild'
ad = varargin{ 3 };
ad = sfcnbuilder.doBuild_CheckNameAndLangext( blockHandle, ad );
varargout{ 1 } = ad;



case 'doSilentMexBuild'
idx = FindSFunctionBuilder( blockHandle );
ad = sfcnbuilder.setupdata( blockHandle, rtwsimTest );
if ~isempty( idx )

USERDATA = doBuild( blockHandle );
else 
try 
doSilentBuild( blockHandle, ad );
catch ex
msg = message( 'Simulink:blocks:SFunctionBuilderBlockError', getfullname( blockHandle ) );
blockEx = MException( msg.Identifier, '%s', msg.getString );
blockEx = blockEx.addCause( ex );
throwAsCaller( blockEx );
end 
end 




case 'Build'
ad = varargin{ 3 };




ad = sfcnbuilder.sfunbuilderLangExt( 'ComputeLangExtFromWidget', ad );
ad = sfcnbuilder.doFinish( blockHandle, ad );
varargout{ 1 } = ad;
clearIncludePath( ad );

case 'doPackage'
ad = varargin{ 3 };
sfbController = sfunctionbuilder.internal.sfunctionbuilderController.getInstance(  );
try 
if isequal( ad.SfunWizardData.SaveCodeOnly, '0' )


ad.CreateCompileMexFileFlag = 1;
doSilentBuild( blockHandle, ad );
else 
ad = sfcnbuilder.doBuild_CheckNameAndLangext( blockHandle, ad );
end 

str = message( 'Simulink:blocks:SFunctionBuilderPackageMsg', getfullname( ad.inputArgs ) );
sfbController.refreshViews( ad.inputArgs, 'refresh buildlog', str.getString );
ad = sfcnbuilder.doPackage( ad );
varargout{ 1 } = ad;
str = message( 'Simulink:blocks:SFunctionBuilderPackageSuccess', getfullname( ad.inputArgs ) );
sfbController.refreshViews( blockHandle, 'refresh buildlog', str.getString );

catch SFBException

msg = message( 'Simulink:blocks:SFunctionBuilderPackageError', getfullname( ad.inputArgs ) );
sfbController.refreshViews( blockHandle, 'refresh buildlog', msg.getString );
callDiagnosticViewer( ad, SFBException.message, 'Error' );
rethrow( SFBException );
end 


otherwise 
DAStudio.error( 'Simulink:blocks:SFunctionBuilderInvalidInput' );
end 


function [ idx, UD ] = FindSFunctionBuilder( H )


sfbDataModel = sfunctionbuilder.internal.sfunctionbuilderModel.getInstance(  );
idx = sfbDataModel.findSFunctionBuilder( H );
UD = sfbDataModel.USERDATA;


sfName = get_param( H, 'FunctionName' );
if ( ~strcmp( sfName, 'system' ) && isempty( idx ) && ~isempty( UD ) )
idx = strmatch( sfName, { UD( : ).SfunName }, 'exact' );
if ( ~isempty( idx ) )
if isempty( UD( idx ).CopiedBlocks )
UD( idx ).CopiedBlocks = { H };
else 
UD( idx ).CopiedBlocks{ end  + 1 } = H;
end 
end 
end 


function doSilentBuild( blockHandle, ad )







if ~ad.CreateCompileMexFileFlag
return ;
end 

if ( ~isvarname( deblank( ad.SfunWizardData.SfunName ) ) )
ex = MException( message( 'Simulink:blocks:SFunctionBuilderInvalidName', ad.SfunWizardData.SfunName ) );
throw( ex );
end 

if ( exist( ad.SfunWizardData.SfunName ) == 4 )


potentialPackageFile = [ ad.SfunWizardData.SfunName, getSFcnPackageExtension ];
files = which( potentialPackageFile );
if ~isempty( files )
if iscell( files )
potentialPackageFile = files{ 1 };
else 
potentialPackageFile = files;
end 
end 


try 
isSFcnPackage = Simulink.SFcnPackage.isSFcnPackage( ad.SfunWizardData.SfunName,  ...
potentialPackageFile );
catch 
isSFcnPackage = false;
end 
if ~isSFcnPackage
ex = MException( message( 'Simulink:SFunctionBuilder:NameConflictWithAModel', ad.blockName ) );
throw( ex );
end 
end 

ad = sfcnbuilder.sfunbuilderLangExt( 'ComputeLangExtFromWizardData', ad );

sfunctionName = [ ad.SfunWizardData.SfunName, '.', ad.LangExt ];
sfunctionTLCName = [ ad.SfunWizardData.SfunName, '.tlc' ];
sfunctionWrapperName = [ ad.SfunWizardData.SfunName, '_wrapper.', ad.LangExt ];

sfunctionGenerated = 0;
sfunctionTLCGenerated = 0;
sfunctionWrapperGenerated = 0;



if isFileInCurrentDir( sfunctionName ) ||  ...
( ad.SfunWizardData.GenerateTLC && isFileInCurrentDir( sfunctionTLCName ) ) ...
 || isFileInCurrentDir( sfunctionWrapperName )
generateSourceCode = 0;
else 
generateSourceCode = 1;
end 

try 

[ libFileList, srcFileList, objFileList,  ...
addIncPaths, addLibPaths, addSrcPaths,  ...
preProcList, preProcUndefList ] =  ...
parseLibCodePaneText( ad.SfunWizardData.LibraryFilesText, ad.inputArgs );

libAndObjFilesWithFullPath = locateFileInPath( { libFileList{ : }, objFileList{ : } },  ...
{ addLibPaths{ : }, addSrcPaths{ : }, pwd },  ...
filesep );
srcFilesSearchPaths = { addSrcPaths{ : }, './' };
srcFilesWithFullPath = locateFileInPath( srcFileList, srcFilesSearchPaths, filesep );

if generateSourceCode



SFBInfoStruct.includePath = addIncPaths;
SFBInfoStruct.sourcePath = addSrcPaths;
sfBuilderBlockNameMATFile = [ '.', filesep, 'SFB__' ...
, ad.SfunWizardData.SfunName ...
, '__SFB.mat' ];
if ~isempty( libFileList ) || ~isempty( objFileList )
SFBInfoStruct.additionalLibraries = { libAndObjFilesWithFullPath{ : } };
for nAddLib = 1:length( SFBInfoStruct.additionalLibraries )
SFBInfoStruct.additionalLibraries{ nAddLib } = rtw_alt_pathname( SFBInfoStruct.additionalLibraries{ nAddLib } );
end 
end 

if exist( sfBuilderBlockNameMATFile )%#ok
delete( sfBuilderBlockNameMATFile );
end 
try 
eval( [ 'save ', sfBuilderBlockNameMATFile, ' ', 'SFBInfoStruct' ] );
catch SFBException
newExc = MException( message( 'Simulink:SFunctionBuilder:CouldNotCreateMATFileForCodeGen', sfBuilderBlockNameMATFile ) );
newExc = newExc.addCause( SFBException );
warning( newExc.identifier, '%s', newExc.getReport( 'basic' ) );
end 
clear SFBInfoStruct;

currentArgs = get_param( bdroot, 'RTWMakeCommand' );
preprocUpdatedMakeCmd = UpdatePreProcDefsInMakeCmd( currentArgs, preProcList, preProcUndefList );
preprocWarningMsg = [  ];
if ( ~strcmp( currentArgs, preprocUpdatedMakeCmd ) )
try 
set_param( bdroot, 'RTWMakeCommand', preprocUpdatedMakeCmd );
catch SFBException
preprocWarningMsg = DAStudio.message( 'Simulink:blocks:SFunctionBuilderReferenceConfigSetWarning', preprocUpdatedMakeCmd );
callDiagnosticViewer( ad, preprocWarningMsg, 'Warning' );
end 
end 

panelIndex = '0';
methodsFlags = [ '0';'0' ];
if ( ~isempty( strtrim( ad.SfunWizardData.UserCodeTextmdlStart ) ) &&  ...
~strcmp( strtrim( ad.SfunWizardData.UserCodeTextmdlStart ), strtrim( DAStudio.message( 'Simulink:SFunctionBuilder:SampleCodeStart' ) ) ) )
methodsFlags( 1 ) = '1';
end 
if ( ~isempty( strtrim( ad.SfunWizardData.UserCodeTextmdlTerminate ) ) &&  ...
~strcmp( strtrim( ad.SfunWizardData.UserCodeTextmdlTerminate ), strtrim( DAStudio.message( 'Simulink:SFunctionBuilder:SampleCodeTerminate' ) ) ) )
methodsFlags( 2 ) = '1';
end 







libTextCodeForTempFile = regexprep( ad.SfunWizardData.LibraryFilesText, sprintf( '\n' ), '__SFB__' );
libTextCodeForTempFile = [ '__SFB__', libTextCodeForTempFile ];
wizardParamsTempFile = tempname;

[ busUsed, busHeader ] = busInfo( ad.SfunWizardData.InputPorts, ad.SfunWizardData.OutputPorts, bdroot( ad.inputArgs ) );
busHeaderFile = tempname;


SampleTime = strrep( strrep( ad.SfunWizardData.SampleTime, ']', '' ), '[', '' );
warnMsg = sprintf( [ 'Warning: You have specified an invalid sample time.\n\tSetting' ...
, ' the S-function sample time to be inherited' ] );
warnMsg1 = sprintf( [ 'Warning: Sample Time was not specified.\n\tSetting' ...
, ' the S-function sample time to be inherited' ] );
try 
if ( str2double( SampleTime ) >= 0 )
elseif ( findstr( SampleTime, 'UserDefined' ) )
SampleTime = 'INHERITED_SAMPLE_TIME';
disp( warnMsg1 );
elseif isnan( str2double( SampleTime ) )

if ( strcmp( SampleTime, 'Inherited' ) || strcmp( SampleTime, getString( message( 'Simulink:dialog:inheritedLabel' ) ) ) )
SampleTime = 'INHERITED_SAMPLE_TIME';
end 
if ( strcmp( SampleTime, 'Continuous' ) || strcmp( SampleTime, getString( message( 'Simulink:dialog:continuousLabel' ) ) ) )
SampleTime = '0';
end 
elseif ~( isempty( str2double( SampleTime ) ) )
if ( str2double( SampleTime ) ==  - 1 )
SampleTime = 'INHERITED_SAMPLE_TIME';
elseif ( str2double( SampleTime ) <  - 1 )
disp( warnMsg );
SampleTime = 'INHERITED_SAMPLE_TIME';
end 
end 
catch 
disp( warnMsg );
SampleTime = 'INHERITED_SAMPLE_TIME';
end 

[ ad.SfunWizardData.Majority, ad.SfunWizardData.InputPorts, ad.SfunWizardData.OutputPorts, ad.SfunWizardData.Parameters ] =  ...
sfunbuilderports( 'UpdatePortsInfo', ad.inputArgs, ad.SfunWizardData.Majority,  ...
ad.SfunWizardData.InputPorts, ad.SfunWizardData.OutputPorts, ad.SfunWizardData.Parameters );
try 
busInfoStruct = generateFileParams( wizardParamsTempFile, busHeaderFile,  ...
strrep( strrep( ad.SfunWizardData.InputPortWidth, ']', '' ), '[', '' ),  ...
strrep( strrep( ad.SfunWizardData.OutputPortWidth, ']', '' ), '[', '' ),  ...
ad.SfunWizardData.DirectFeedThrough, SampleTime, ad.SfunWizardData.NumberOfParameters,  ...
strrep( strrep( ad.SfunWizardData.NumberOfDiscreteStates, ']', '' ), '[', '' ),  ...
ad.SfunWizardData.DiscreteStatesIC,  ...
strrep( strrep( ad.SfunWizardData.NumberOfContinuousStates, ']', '' ), '[', '' ),  ...
ad.SfunWizardData.ContinuousStatesIC,  ...
ad.SfunWizardData.NumberOfPWorks,  ...
ad.SfunWizardData.NumberOfDWorks,  ...
ad.SfunWizardData.GenerateTLC,  ...
libTextCodeForTempFile,  ...
panelIndex,  ...
ad.SfunWizardData.SfunName,  ...
ad.SfunWizardData.Majority,  ...
ad.SfunWizardData.InputPorts,  ...
ad.SfunWizardData.OutputPorts,  ...
busUsed, busHeader,  ...
ad.SfunWizardData.Parameters, methodsFlags,  ...
ad.SfunWizardData.UseSimStruct,  ...
ad.SfunWizardData.ShowCompileSteps,  ...
ad.SfunWizardData.CreateDebugMex,  ...
ad.SfunWizardData.SaveCodeOnly,  ...
i_getCoverageSupport( ad.SfunWizardData ),  ...
i_getSldvSupport( ad.SfunWizardData ),  ...
bdroot( ad.inputArgs ) );

catch ex

wizardParamsTempFileCleanUp = onCleanup( @(  )deleteTempFiles( wizardParamsTempFile ) );
mexVerboseText = getExceptionMsgReport( ex );
callDiagnosticViewer( ad, mexVerboseText, 'Info' );
slblocksetdesignerHelper( ad, sfunctionName, sfunctionWrapperName, 1, mexVerboseText );
rethrow( ex );

end 









mdlStartTempFile = CreateTempFileFromText( ad.SfunWizardData.UserCodeTextmdlStart );
mdlStartTempFileCleanUp = onCleanup( @(  )deleteTempFiles( mdlStartTempFile ) );

mdlOutputTempFile = CreateTempFileFromText( ad.SfunWizardData.UserCodeText );
mdlOutputTempFileCleanUp = onCleanup( @(  )deleteTempFiles( mdlOutputTempFile ) );

mdlUpdateTempFile = CreateTempFileFromText( ad.SfunWizardData.UserCodeTextmdlUpdate );
mdlUpdateTempFileCleanUp = onCleanup( @(  )deleteTempFiles( mdlUpdateTempFile ) );

mdlDerivativeTempFile = CreateTempFileFromText( ad.SfunWizardData.UserCodeTextmdlDerivative );
mdlDerivativeTempFileCleanUp = onCleanup( @(  )deleteTempFiles( mdlDerivativeTempFile ) );

mdlTerminateTempFile = CreateTempFileFromText( ad.SfunWizardData.UserCodeTextmdlTerminate );
mdlTerminateTempFileCleanUp = onCleanup( @(  )deleteTempFiles( mdlTerminateTempFile ) );

externDeclarationTempFile = CreateTempFileFromText( ad.SfunWizardData.ExternalDeclaration );
externDeclarationTempFileCleanUp = onCleanup( @(  )deleteTempFiles( externDeclarationTempFile ) );

headersTempFile = CreateTempFileFromText( ad.SfunWizardData.IncludeHeadersText );
headersTempFileCleanUp = onCleanup( @(  )deleteTempFiles( headersTempFile ) );


pathFcnCall = fullfile( matlabroot, 'toolbox', 'simulink', 'core', 'sfunctionwizard' );

createmessage = generateFormatedMessage( ad, sfunctionName, busHeader, ad.SfunWizardData.GenerateTLC );

callDiagnosticViewer( ad, DAStudio.message( 'Simulink:blocks:SFunctionBuilderGenerateMsg', sfunctionName ), 'Info' );


if ( strcmp( ad.Version, '' ) )
ad.Version = '3.0';
end 

slVer = ver( 'Simulink' );

sfunctionwizardhelper( sfunctionName, sfunctionWrapperName,  ...
mdlStartTempFile, mdlOutputTempFile, mdlUpdateTempFile, mdlDerivativeTempFile, mdlTerminateTempFile, headersTempFile, externDeclarationTempFile, pathFcnCall, wizardParamsTempFile, busHeaderFile, slVer.Version, ad.Version, busInfoStruct );

callDiagnosticViewer( ad, createmessage, 'Info' );

end 


sldvInfo = [  ];
if i_getSldvSupport( ad.SfunWizardData ) == '1'
sldvInfo = sldv.code.sfcn.internal.getSFcnInfoFromSfunWizard( ad );
end 


escApostrophe = @( x )regexprep( x, '''', '''''' );
customSrcAndLibAndObj = [ '''' ...
, joinCellToStr(  ...
escApostrophe(  ...
{ sfunctionWrapperName,  ...
libAndObjFilesWithFullPath{ : },  ...
srcFilesWithFullPath{ : } } ...
 ),  ...
''',''' ) ...
, '''' ];

callDiagnosticViewer( ad, [ '### Building S-function ''', sfunctionName, ''' for ', getfullname( blockHandle ) ], 'Info' );

try 
[ mexVerboseText, errorOccurred ] = sfbuilder_mexbuild( ad, sfunctionName, customSrcAndLibAndObj,  ...
addIncPaths, preProcList, sldvInfo, logical( str2double( ad.SfunWizardData.ShowCompileSteps ) ), logical( str2double( ad.SfunWizardData.CreateDebugMex ) ) );
catch ex
errorOccurred = 1;
mexVerboseText = getExceptionMsgReport( ex );
if ( isempty( mexVerboseText ) )
mexVerboseText = sprintf( [ '\n\n\n\t\tAn unexpected error occurred during compilation. Please' ...
, ' verify the following:\n' ...
, '\t\t -The MEX command is configured correctly. Type ''mex -setup'' at \n',  ...
'\t\t  MATLAB command prompt to configure this command.\n',  ...
'\t\t -The S-function settings in the Initialization or Libraries tab were entered incorrectly.\n',  ...
'\t\t  (i.e. use comma separated list for the library/source files)\n',  ...
'\t\t -If S-Function Builder dialog box in an invalid state, please restart\n' ...
, '\t\t  MATLAB before using this dialog further.' ] );
end 
end 

if errorOccurred
slblocksetdesignerHelper( ad, sfunctionName, sfunctionWrapperName, errorOccurred, mexVerboseText );


ex = MException( '', '%s', mexVerboseText );
throw( ex );
else 
callDiagnosticViewer( ad, mexVerboseText, 'Info' );
slblocksetdesignerHelper( ad, sfunctionName, sfunctionWrapperName, errorOccurred, mexVerboseText );
end 

catch ex
if generateSourceCode
if sfunctionGenerated && exist( sfunctionName, 'file' )
delete( sfunctionName );
end 

if sfunctionTLCGenerated && exist( sfunctionTLCName, 'file' )
delete( sfunctionTLCName );
end 

if sfunctionWrapperGenerated && exist( sfunctionWrapperName, 'file' )
delete( sfunctionWrapperName );
end 
end 
rethrow( ex );
end 


function clearIncludePath( ad )

if ad.IncPathExists
try 
rmappdata( 0, 'SfunctionBuilderIncludePath' );
end 
end 


function USERDATA = doBuild( blockHandle )

sfbDataModel = sfunctionbuilder.internal.sfunctionbuilderModel.getInstance(  );
idx = sfbDataModel.findSFunctionBuilder( blockHandle );
if isempty( idx )
return 
else 
ad = sfbDataModel.getApplicationData( blockHandle );



ad.SfunWizardData.SaveCodeOnly = '0';
end 

ad = sfcnbuilder.doBuild_CheckNameAndLangext( blockHandle, ad );
USERDATA = sfbDataModel.USERDATA;






function ad = updateParamValues( ad )
try 
numDlgP = ad.SfunBuilderWidgets.getNumParams;
for k = 1:numDlgP
ad.SfunWizardData.Parameters.Value{ k } = char( ad.SfunBuilderWidgets.getParameterValueStringAt( k - 1 ) );

end 

set_param( ad.inputArgs, 'WizardData', ad.SfunWizardData )
catch SFBException
warning( SFBException.identifier, '%s', SFBException.getReport( 'basic' ) )
end 


function name = getFileName( name )
name = strtok( name, '.' );

try 
clear( name );
nameWithPath = which( name );
p = filesep;
indexp = findstr( nameWithPath, p );
name = nameWithPath( 1 + indexp( end  ):end  );
end 



function out = isFileInCurrentDir( fileName )

presentDir = pwd;
out = 0;
fileNamefullPath = [ presentDir, filesep, fileName ];
if ( exist( fileNamefullPath ) == 2 )
out = 1;
end 

function out = getSelectedValue( in )

if ( in.isSelected == logical( 0 ) )
out = '0';
else 
out = '1';
end 

function [ tempFileName, tf, delFlag ] = CreateTempFile( ad, adField )

tempFileName = '';
tf = '';
switch adField
case { 'tfmdlStart', 'tfmdlOutput', 'tfmdlUpdate', 'tfmdlDerivative', 'tfmdlTerminate' }
tf = ad.getUserCode( adField );
otherwise 
tf = getfield( ad, adField );
tf = tf.getText;
end 



tf = char( tf );
if isempty( tf )
tf = ' ';
end 

if ( ~isempty( tf ) )
delFlag = 1;
tempFileName = tempname;
fid = fopen( tempFileName, 'w' );
fprintf( fid, '%s', tf );
fclose( fid );
else 
delFlag = 0;
end 


function tempFileName = CreateTempFileFromText( tf )
if isempty( tf )
tf = ' ';
end 


tempFileName = tempname;
fid = fopen( tempFileName, 'w' );
fprintf( fid, '%s', tf );
fclose( fid );


function [ createmessage, ad ] = generateFormatedMessage( ad, sfunctionName, busHeader, generateTLC )

textWidth = 500;
wrapperFile = [ strtok( sfunctionName, '.' ), '_wrapper.', ad.LangExt ];
str1 = DAStudio.message( 'Simulink:blocks:SFunctionBuilderCreationWithHyperlinks', sfunctionName, sfunctionName );
str2 = DAStudio.message( 'Simulink:blocks:SFunctionBuilderCreationWithHyperlinks', wrapperFile, wrapperFile );

space = blanks( textWidth );
space1 = blanks( textWidth - length( str1 ) );
space2 = blanks( textWidth - length( str2 ) );
createmessage = [ space, str1, space1, str2, space2 ];

if ( generateTLC )
sfunctionNameTLC = strrep( sfunctionName, [ '.', ad.LangExt ], '.tlc' );
str3 = DAStudio.message( 'Simulink:blocks:SFunctionBuilderCreationWithHyperlinks', sfunctionNameTLC, sfunctionNameTLC );
space3 = blanks( textWidth - length( str3 ) );
createmessage = [ createmessage, str3, space3 ];
end 
if ( busHeader )
sfunbusheaderName = [ strrep( sfunctionName, [ '.', ad.LangExt ], '' ), '_bus.h' ];
str4 = DAStudio.message( 'Simulink:blocks:SFunctionBuilderCreationWithHyperlinks', sfunbusheaderName, sfunbusheaderName );
space4 = blanks( textWidth - length( str4 ) );
createmessage = [ createmessage, str4, space4 ];
end 


function aSFuncWizardObj = setcompileStatsTextArea( aSFuncWizardObj, aExistingMsgText, aNewMsgText )
aComponent = 'S-function Builder';
aCategory = 'S-function Builder';
aStageId = '';

aFullMsgText = Simulink.messageviewer.internal.processhtmllinks( [ aExistingMsgText, aNewMsgText ], aComponent, aCategory, slmsgviewer.m_InfoSeverity, aStageId );

try 
aSFuncWizardObj.SfunBuilderPanel.fCompileStatsTextArea.setAutoWrap( 1 );
aSFuncWizardObj.SfunBuilderPanel.fCompileStatsTextArea.setSize( 500, 300 );


aSFuncWizardObj.SfunBuilderPanel.fCompileStatsTextArea.setText( '' );
aSFuncWizardObj.SfunBuilderPanel.fCompileStatsTextArea.setText( aFullMsgText );
catch 
aSFuncWizardObj.SfunBuilderPanel.fCompileStatsTextArea.setText( aExistingMsgText );
end 


function callDiagnosticViewer( aSFuncWizardObj, aMsgText, aMsgType )
aFullName = getfullname( aSFuncWizardObj.inputArgs );
aModelName = strtok( aFullName, '/' );
aStageName = 'S-function Builder';
aComponent = 'S-function Builder';
aCategory = 'Build';
aObjects = { aFullName };


aStageObj = Simulink.output.Stage( aStageName, 'ModelName', aModelName, 'UIMode', true );

switch ( lower( aMsgType ) )
case 'error'
Simulink.output.error( aMsgText, 'Component', aComponent, 'Category', aCategory, 'Objects', aObjects );
case 'info'
Simulink.output.info( aMsgText, 'Component', aComponent, 'Category', aCategory, 'Objects', aObjects );
case 'warning'
Simulink.output.warning( aMsgText, 'Component', aComponent, 'Category', aCategory, 'Objects', aObjects );
otherwise 
assert( false );
end 


function deleteTempFiles( name )

name = strrep( name, '"', '' );
delete( name );



function makeCmdStr = UpdatePreProcDefsInMakeCmd( currentMakeCmdStr, preProcList, preProcUndefList )

makeCmdStr = currentMakeCmdStr;

if ~isempty( preProcList )
preprocListStr = '';
for idx = 1:length( preProcList )
if isempty( preProcList{ idx } )continue , end 
if isempty( regexp( currentMakeCmdStr, preProcList{ idx } ) )
preprocListStr = [ preprocListStr, ' -D', preProcList{ idx }, ' ' ];
end 
end 
if ~isempty( preprocListStr )
makeCmdStr = [ makeCmdStr, ' OPTS="', preprocListStr, '"' ];
end 
end 

if ~isempty( preProcUndefList )
for idx = 1:length( preProcUndefList )
if isempty( preProcUndefList{ idx } )continue , end 
makeCmdStr = regexprep( makeCmdStr, [ '-D', preProcUndefList{ idx } ], '' );
end 
end 


function [ busUsed, busHeader ] = busInfo( iP, oP, model )
busHeader = 0;
busUsed = 0;

for i = 1:length( iP.Name )
if strcmp( iP.Bus{ i }, 'on' )
busUsed = 1;
slObj = evalinGlobalScope( model, iP.Busname{ i } );
if isempty( strtrim( slObj.HeaderFile ) )
busHeader = 1;
end 
end 
end 

for i = 1:length( oP.Name )
if strcmp( oP.Bus{ i }, 'on' )
busUsed = 1;
slObj = evalinGlobalScope( model, oP.Busname{ i } );
if isempty( strtrim( slObj.HeaderFile ) )
busHeader = 1;
end 
end 
end 



function busInfoStruct = generateFileParams( fileName, busHeaderFile, NumberOfInputs, NumberOfOutputs, directFeed,  ...
SampleTime, NumberOfParameters, NumDStates, DStatesIC,  ...
NumCStates, CStatesIC, NumPWorks, NumDWorks, CreateWrapperTLC, LibList,  ...
PanelIndex, Sfunname, Majority, iP, oP, busUsed, busHeader, paramsList, methodsFlags, UseSimStructVal,  ...
ShowCompileStepsVal, DebugMexVal, SaveCodeVal, SupportCoverageVal, SupportSldvVal, model )

n1 = [ 'NumOfCStates=', NumCStates ];
n2 = [ 'CStatesIC=', CStatesIC ];
n3 = [ 'NumOfDStates=', NumDStates ];
n4 = [ 'DStatesIC=', DStatesIC ];
n5 = [ 'NumPWorks=', NumPWorks ];
n6 = [ 'NumDWorks=', NumDWorks ];
n7 = [ 'NumberOfParameters=', NumberOfParameters ];
n8 = [ 'SampleTime=', SampleTime ];
n9 = [ 'SFcnMajority=', Majority ];
n10 = [ 'CreateWrapperTLC=', CreateWrapperTLC ];
n11 = [ 'directFeed=', directFeed ];
n12 = [ 'LibList=', LibList ];
n13 = [ 'PanelIndex=', PanelIndex ];
n14 = [ 'UseSimStruct=', UseSimStructVal ];
n15 = [ 'ShowCompileSteps=', ShowCompileStepsVal ];
n16 = [ 'CreateDebugMex=', DebugMexVal ];
n17 = [ 'SaveCodeOnly=', SaveCodeVal ];
n18 = [ 'SupportCoverage=', SupportCoverageVal ];
n19 = [ 'SupportSldv=', SupportSldvVal ];

iP.Row{ 1 } = NumberOfInputs;
oP.Row{ 1 } = NumberOfOutputs;
fidExtern = fopen( fileName, 'w' );
fprintf( fidExtern, '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n',  ...
n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19 );

if isempty( iP.Name ) || strcmp( iP.Name{ 1 }, 'ALLOW_ZERO_PORTS' )
fprintf( fidExtern, '%s\n', [ 'NumberOfInputPorts= 0' ] );
else 
fprintf( fidExtern, '%s\n', [ 'NumberOfInputPorts=', num2str( length( iP.Name ) ) ] );
end 
if isempty( oP.Name ) || strcmp( oP.Name{ 1 }, 'ALLOW_ZERO_PORTS' )
fprintf( fidExtern, '%s\n', [ 'NumberOfOutputPorts= 0' ] );
else 
fprintf( fidExtern, '%s\n', [ 'NumberOfOutputPorts=', num2str( length( oP.Name ) ) ] );
end 

fprintf( fidExtern, '%s\n', [ 'GenerateStartFunction= ', methodsFlags( 1 ) ] );
fprintf( fidExtern, '%s\n', [ 'GenerateTerminateFunction= ', methodsFlags( 2 ) ] );

for i = 1:length( iP.Name )
fprintf( fidExtern, '%s\n', [ 'InPort', num2str( i ), '{' ] );
fprintf( fidExtern, '%s\n', [ 'inPortName', num2str( i ), '=', iP.Name{ i } ] );
fprintf( fidExtern, '%s\n', [ 'inDataType', num2str( i ), '=', iP.DataType{ i } ] );
fprintf( fidExtern, '%s\n', [ 'inDims', num2str( i ), '=', iP.Dims{ i } ] );
fprintf( fidExtern, '%s\n', [ 'inDimensions', num2str( i ), '=', iP.Dimensions{ i } ] );
fprintf( fidExtern, '%s\n', [ 'inComplexity', num2str( i ), '=', iP.Complexity{ i } ] );
fprintf( fidExtern, '%s\n', [ 'inFrameBased', num2str( i ), '=', iP.Frame{ i } ] );
fprintf( fidExtern, '%s\n', [ 'inBusBased', num2str( i ), '=', iP.Bus{ i } ] );
fprintf( fidExtern, '%s\n', [ 'inBusname', num2str( i ), '=', iP.Busname{ i } ] );
fprintf( fidExtern, '%s\n', [ 'inIsSigned', num2str( i ), '=', iP.IsSigned{ i } ] );
fprintf( fidExtern, '%s\n', [ 'inWordLength', num2str( i ), '=', iP.WordLength{ i } ] );
fprintf( fidExtern, '%s\n', [ 'inFractionLength', num2str( i ), '=', iP.FractionLength{ i } ] );
fprintf( fidExtern, '%s\n', [ 'inFixPointScalingType', num2str( i ), '=', iP.FixPointScalingType{ i } ] );
fprintf( fidExtern, '%s\n', [ 'inSlope', num2str( i ), '=', iP.Slope{ i } ] );
fprintf( fidExtern, '%s\n', [ 'inBias', num2str( i ), '=', iP.Bias{ i } ] );
fprintf( fidExtern, '%s\n', '}' );
end 

for i = 1:length( oP.Name )
fprintf( fidExtern, '%s\n', [ 'OutPort', num2str( i ), '{' ] );
fprintf( fidExtern, '%s\n', [ 'outPortName', num2str( i ), '=', oP.Name{ i } ] );
fprintf( fidExtern, '%s\n', [ 'outDataType', num2str( i ), '=', oP.DataType{ i } ] );
fprintf( fidExtern, '%s\n', [ 'outDims', num2str( i ), '=', oP.Dims{ i } ] );
fprintf( fidExtern, '%s\n', [ 'outDimensions', num2str( i ), '=', oP.Dimensions{ i } ] );
fprintf( fidExtern, '%s\n', [ 'outComplexity', num2str( i ), '=', oP.Complexity{ i } ] );
fprintf( fidExtern, '%s\n', [ 'outFrameBased', num2str( i ), '=', oP.Frame{ i } ] );
fprintf( fidExtern, '%s\n', [ 'outBusBased', num2str( i ), '=', oP.Bus{ i } ] );
fprintf( fidExtern, '%s\n', [ 'outBusname', num2str( i ), '=', oP.Busname{ i } ] );
fprintf( fidExtern, '%s\n', [ 'outIsSigned', num2str( i ), '=', oP.IsSigned{ i } ] );
fprintf( fidExtern, '%s\n', [ 'outWordLength', num2str( i ), '=', oP.WordLength{ i } ] );
fprintf( fidExtern, '%s\n', [ 'outFractionLength', num2str( i ), '=', oP.FractionLength{ i } ] );
fprintf( fidExtern, '%s\n', [ 'outFixPointScalingType', num2str( i ), '=', oP.FixPointScalingType{ i } ] );
fprintf( fidExtern, '%s\n', [ 'outSlope', num2str( i ), '=', oP.Slope{ i } ] );
fprintf( fidExtern, '%s\n', [ 'outBias', num2str( i ), '=', oP.Bias{ i } ] );
fprintf( fidExtern, '%s\n', '}' );
end 

for i = 1:length( paramsList.Name )
fprintf( fidExtern, '%s\n', [ 'Parameter', num2str( i ), '{' ] );
fprintf( fidExtern, '%s\n', [ 'parameterName', num2str( i ), '=', paramsList.Name{ i } ] );
fprintf( fidExtern, '%s\n', [ 'parameterDataType', num2str( i ), '=', paramsList.DataType{ i } ] );
fprintf( fidExtern, '%s\n', [ 'parameterComplexity', num2str( i ), '=', paramsList.Complexity{ i } ] );
fprintf( fidExtern, '%s\n', '}' );
end 

if busUsed
try 
busInfoStruct = sfbWriteBusInfo( iP, oP, paramsList, fidExtern, busHeaderFile, busHeader, Sfunname, model );
catch ex
busInfoStruct =  - 1;
fclose( fidExtern );
rethrow( ex );
end 
else 
busInfoStruct = [  ];
end 

fclose( fidExtern );


function setPortLabels( blkHandle, iP, oP )

defaultMaskString = sprintf( [ 'plot(val(:,1),val(:,2))', '\n', 'disp(sys)' ] );
inportString = '';
if ~strcmp( iP.Name{ 1 }, 'ALLOW_ZERO_PORTS' )
for k = 1:length( iP.Name )
portName = iP.Name{ k };
inportString = sprintf( [ inportString, '\n', 'port_label(''input'',', num2str( k ), ',', '''', portName, ''')' ] );
end 
end 
defaultMaskString = [ defaultMaskString, inportString ];

outportString = '';
if ~strcmp( oP.Name{ 1 }, 'ALLOW_ZERO_PORTS' )
for k = 1:length( oP.Name )
portName = oP.Name{ k };
outportString = sprintf( [ outportString, '\n', 'port_label(''output'',', num2str( k ), ',', '''', portName, ''')' ] );
end 
end 
defaultMaskString = [ defaultMaskString, outportString ];

set_param( blkHandle, 'MaskDisplay', defaultMaskString );


function wizData = i_removeFieldFromWizData( ad )

wizData = ad.SfunWizardData;
try 
wizData = rmfield( wizData, { 'InputDataType0', 'OutputDataType0', 'InputSignalType0', 'Input0DimsCol', 'Output0DimsCol',  ...
'OutputSignalType0', 'InFrameBased0', 'OutFrameBased0', 'InBusBased0', 'OutBusBased0', 'OutBusname0', 'InBusname0', 'TemplateType' } );
end 

function rtwsimTestDiagnostics( ad, textDisp )
if ad.rtwsimTest
disp( textDisp );
end 


function fout = CheckExist( fin )

if exist( fin, 'file' )
fout = fin;
else 
fout = '';
end 


function val = i_getCoverageSupport( dataStruct )

if isfield( dataStruct, 'SupportCoverage' )
val = dataStruct.SupportCoverage;
else 
val = '0';
end 


function dataStruct = i_setCoverageSupport( dataStruct, val )

if isfield( dataStruct, 'SupportCoverage' )
dataStruct.SupportCoverage = val;
end 


function val = i_getSldvSupport( dataStruct )

if isfield( dataStruct, 'SupportSldv' )
val = dataStruct.SupportSldv;
else 
val = '0';
end 


function dataStruct = i_setSldvSupport( dataStruct, val )

if isfield( dataStruct, 'SupportSldv' )
dataStruct.SupportSldv = val;
end 


function moveToBlockSDK( sfunctionName, sfunctionNameWrapper, blockRootDir, errorOccurred, mexVerboseText )
if exist( blockRootDir, 'dir' )
srcFolder = fullfile( blockRootDir, 'src' );
incFolder = fullfile( blockRootDir, 'src' );
binFolder = fullfile( blockRootDir, 'mex' );
tlcFolder = binFolder;
[ ~, sfcnName, ~ ] = fileparts( sfunctionName );
sfBuilderBlockNameMATFile = [ 'SFB__', sfcnName, '__SFB.mat' ];
if exist( fullfile( pwd, sfBuilderBlockNameMATFile ), 'file' ) && ~isequal( pwd, binFolder )
newMATFile = Simulink.BlocksetDesigner.internal.updateRTWMATFile( sfBuilderBlockNameMATFile, srcFolder, incFolder );
movefile( newMATFile, binFolder );
end 
if exist( fullfile( pwd, sfunctionName ), 'file' ) && ~isequal( pwd, srcFolder )
movefile( sfunctionName, srcFolder );
end 
if exist( fullfile( pwd, sfunctionNameWrapper ), 'file' ) && ~isequal( pwd, srcFolder )
movefile( sfunctionNameWrapper, srcFolder );
end 
sfunNameWrapperTLC = [ sfcnName, '.tlc' ];
if exist( fullfile( pwd, sfunNameWrapperTLC ), 'file' ) && ~isequal( pwd, tlcFolder )
movefile( sfunNameWrapperTLC, tlcFolder );
end 
makeConfigFile = 'rtwmakecfg.m';
if exist( fullfile( pwd, makeConfigFile ), 'file' ) && ~isequal( pwd, binFolder )
movefile( makeConfigFile, binFolder );
end 
mexFile = [ sfcnName, '.', mexext ];
if exist( fullfile( pwd, mexFile ), 'file' ) && ~isequal( pwd, binFolder )
movefile( mexFile, binFolder );
end 
sfa = Simulink.BlocksetDesigner.Sfunction(  );
sfa.importSfbuilder( sfunctionName, errorOccurred, mexVerboseText );
end 

function slblocksetdesignerHelper( ad, sfunctionName, sfunctionWrapperName, errorOccurred, mexVerboseText )
isBlockSetSDK = ad.SfunWizardData.BlockSetSDK;
if ( isBlockSetSDK )
blockRootDir = ad.SfunWizardData.BlockRootDir;
moveToBlockSDK( sfunctionName, sfunctionWrapperName, blockRootDir, errorOccurred, mexVerboseText );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpPg98UC.p.
% Please follow local copyright laws when handling this file.

