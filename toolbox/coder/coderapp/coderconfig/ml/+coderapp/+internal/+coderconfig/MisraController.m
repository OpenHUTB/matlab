classdef ( Sealed )MisraController






properties ( SetAccess = immutable, GetAccess = private, Transient )
UiModel coderapp.internal.config.ui.ConfigUiModel
MfzModel mf.zero.Model
Configuration coderapp.internal.config.Configuration
end 

methods ( Access = ?coderapp.internal.coderconfig.CoderConfigUiController )
function this = MisraController( uiModel, mfzModel, configuration )
this.UiModel = uiModel;
this.MfzModel = mfzModel;
this.Configuration = configuration;

isTargetLangCpp = this.isTargetLangCpp(  );


this.addRecommendation(  ...
'enableRuntimeRecursion', false,  ...
'enableSignedLeftShifts', false,  ...
'enableSignedRightShifts', false,  ...
'castingMode', 'Standards',  ...
'dataTypeReplacement', 'CoderTypedefs',  ...
'parenthesesLevel', 'Maximum',  ...
'generateDefaultInSwitch', true,  ...
'dynamicMemoryAllocation', 'Off',  ...
'headerGuardStyle', 'UseIncludeGuard',  ...
'enableOpenMP', false,  ...
'runtimeChecks', false,  ...
'targetLangStandard', this.getRecommendedTargetLangStd( isTargetLangCpp ),  ...
'maxIdLength', int64( 31 ),  ...
'cppInterfaceStyle', 'Functions',  ...
'cppGenerateEnumClass', true );




this.addRecommendationWithMessage(  ...
'cppInterfaceClassName', '',  ...
getString( message( "coderApp:config:coderOptions:misraCppInterfaceClassName" ) ) );
this.addRecommendationWithMessage(  ...
'cppNamespace', this.getRecommendedCppNamespace(  ),  ...
getString( message( "coderApp:config:coderOptions:misraCppNamespaceRecommendation" ) ) );




this.updateRecommendationVisibility(  ...
'maxIdLength', ~isTargetLangCpp,  ...
'cppInterfaceStyle', isTargetLangCpp,  ...
'cppInterfaceClassName', isTargetLangCpp,  ...
'cppNamespace', isTargetLangCpp,  ...
'cppGenerateEnumClass', isTargetLangCpp );
end 

function update( this, evt )
misraSettings = this.UiModel.MisraSettings.toArray;
misraSettingKeys = { misraSettings.Key };
misraSettingsToCheck = misraSettings( ismember( misraSettingKeys, evt.Keys ) );

if ismember( 'targetLang', evt.Keys )
isTargetLangCpp = this.isTargetLangCpp(  );

this.updateRecommendationVisibility(  ...
'maxIdLength', ~isTargetLangCpp,  ...
'cppInterfaceStyle', isTargetLangCpp,  ...
'cppInterfaceClassName', isTargetLangCpp,  ...
'cppNamespace', isTargetLangCpp,  ...
'cppGenerateEnumClass', isTargetLangCpp );

this.updateRecommendedValue(  ...
'targetLangStandard', this.getRecommendedTargetLangStd( isTargetLangCpp ),  ...
'cppNamespace', this.getRecommendedCppNamespace(  ) );
end 

if ismember( 'cppInterfaceStyle', evt.Keys ) && ~ismember( 'cppInterfaceClassName', evt.Keys )
misraSettingsToCheck( end  + 1 ) = misraSettings( ismember( misraSettingKeys, 'cppInterfaceClassName' ) );
end 

for i = 1:numel( misraSettingsToCheck )
misraSetting = misraSettingsToCheck( i );
misraSetting.Compliant = this.isSettingMisraCompliant( misraSetting );
end 
end 

function applyRecommendations( this )
recommendations = struct(  );
for i = 1:this.UiModel.MisraSettings.Size
misraSetting = this.UiModel.MisraSettings( i );
settingKey = misraSetting.Key;
if misraSetting.Visible
if strcmp( settingKey, 'cppInterfaceClassName' )
this.Configuration.reset( settingKey );
else 
recommendations.( settingKey ) = misraSetting.Recommendation.Value.Value;
end 
end 
end 
this.Configuration.import( recommendations );
end 
end 

methods ( Access = private )
function addRecommendation( this, settingKey, recommendedValue )
R36
this
end 
R36( Repeating )
settingKey{ mustBeTextScalar( settingKey ) }
recommendedValue
end 

for i = 1:numel( settingKey )
createMisraSetting( this, Key = settingKey{ i }, Value = recommendedValue{ i } );
end 
end 

function addRecommendationWithMessage( this, settingKey, recommendedValue, message )
R36
this
end 
R36( Repeating )
settingKey{ mustBeTextScalar( settingKey ) }
recommendedValue
message{ mustBeTextScalar( message ) }
end 

for i = 1:numel( settingKey )
createMisraSetting( this, Key = settingKey{ i }, Value = recommendedValue{ i }, Message = message{ i } );
end 
end 

function createMisraSetting( this, opts )
R36
this
opts.Key{ mustBeTextScalar( opts.Key ) }
opts.Value
opts.Message = ''
end 

misraSetting = coderapp.internal.coderconfig.MisraSetting( this.MfzModel, struct( Key = opts.Key ) );
misraSetting.Owner = this.UiModel;

options = struct;
msg = opts.Message;
if ~isempty( msg )
options.metaClass = 'coderapp.internal.coderconfig.ImplicitAdvice';
options.Message = msg;
end 
misraSetting.createIntoRecommendation( options );

value = opts.Value;
switch class( value )
case 'int64'
value = coderapp.internal.config.data.IntegerParamData( this.MfzModel, struct( Value = value ) );
case 'double'
value = coderapp.internal.config.data.DoubleParamData( this.MfzModel, struct( Value = value ) );
case 'logical'
value = coderapp.internal.config.data.BooleanParamData( this.MfzModel, struct( Value = value ) );
otherwise 
value = coderapp.internal.config.data.StringParamData( this.MfzModel, struct( Value = string( value ) ) );
end 
misraSetting.Recommendation.Value = value;
misraSetting.Compliant = this.isSettingMisraCompliant( misraSetting );
end 

function result = isSettingMisraCompliant( this, misraSetting )
R36
this
misraSetting coderapp.internal.coderconfig.MisraSetting
end 

result = isequal( this.Configuration.export( misraSetting.Key ), misraSetting.Recommendation.Value.Value );
end 

function updateRecommendationVisibility( this, settingKey, isVisible )
R36
this
end 
R36( Repeating )
settingKey{ mustBeTextScalar( settingKey ) }
isVisible( 1, 1 )logical
end 

misraSettings = this.UiModel.MisraSettings.toArray;
misraSettings = misraSettings( ismember( { misraSettings.Key }, settingKey ) );
[ misraSettings.Visible ] = isVisible{ : };
end 

function updateRecommendedValue( this, settingKey, recommendedValue )
R36
this
end 
R36( Repeating )
settingKey{ mustBeTextScalar( settingKey ) }
recommendedValue
end 

misraSettings = this.UiModel.MisraSettings.toArray;
misraSettings = misraSettings( ismember( { misraSettings.Key }, settingKey ) );
for i = 1:numel( misraSettings )
misraSettings( i ).Recommendation.Value.Value = recommendedValue{ i };
end 
end 

function targetLangStd = getRecommendedTargetLangStd( ~, isTargetLangCpp )
if isTargetLangCpp
targetLangStd = 'C++11 (ISO)';
else 
targetLangStd = 'C99 (ISO)';
end 
end 

function cppNamespace = getRecommendedCppNamespace( this )
cppNamespace = this.Configuration.get( 'cppNamespace' );
if isempty( cppNamespace )
cppNamespace = 'Codegen';
end 
end 

function result = isTargetLangCpp( this )
result = strcmpi( this.Configuration.get( 'targetLang' ), 'c++' );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJtR7nC.p.
% Please follow local copyright laws when handling this file.

