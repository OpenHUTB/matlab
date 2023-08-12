function varargout = repairInvalidEnumUsage( mdlName, pdFqn, action )



splitNames = strsplit( pdFqn, '.' );
assert( length( splitNames ) == 3 );
profName = splitNames{ 1 };
stereoName = splitNames{ 2 };
propName = splitNames{ 3 };

prof = systemcomposer.profile.Profile.find( profName ).getImpl;
stereo = prof.prototypes.getByKey( stereoName );
propDef = stereo.propertySet.properties.toArray.findobj( 'p_Name', propName );

assert( isa( propDef.type, 'systemcomposer.property.Enumeration' ) );



zcModel = get_param( mdlName, 'SystemComposerModel' ).getImpl;
profNamespace = zcModel.getProfileNamespace;
psu = profNamespace.getPropertySet( stereo.fullyQualifiedName );
propUsage = psu.getPropertyUsage( propName );




invalidElems = {  };
elemsWithPropUsage = psu.p_AppliedElements.toArray;
for elem = elemsWithPropUsage
if ~isValueValid( elem, pdFqn )
invalidElems = [ invalidElems, elem ];%#ok<AGROW>
end 
end 



switch action
case 'fix'


try 
propUsageType = propUsage.propertyDef.defaultValue.type;
if ~systemcomposer.property.Enumeration.isValidEnumerationName( propUsageType.MATLABEnumName )
throwInvalidEnumErrorDialog( propUsage.propertyDef.defaultValue.expression, propUsage.propertyDef.fullyQualifiedName );


remakeNotification( mdlName, pdFqn );
return ;
else 
defaultValue = propUsage.propertyDef.defaultValue.getValue.char;
if ~strcmp( defaultValue, eval( propUsage.propertyDef.defaultValue.expression ) )



throwInvalidEnumErrorDialog( propUsage.propertyDef.defaultValue.expression, propUsage.propertyDef.fullyQualifiedName );


remakeNotification( mdlName, pdFqn );
return ;
end 
end 
catch ME
if ( strcmp( ME.identifier, 'SystemArchitecture:Property:InvalidEnumPropValue' ) )
throwInvalidEnumErrorDialog( propUsage.propertyDef.defaultValue.expression, propUsage.propertyDef.fullyQualifiedName );


remakeNotification( mdlName, pdFqn );
return ;
else 
rethrow( ME )
end 
end 




for elem = invalidElems
elem.clearPropVal( pdFqn );
end 


if ~propUsageType.isValidEnumString( propUsage.initialValue.expression )
propUsage.updateDefaultValue;
end 

case 'report'

tempMap = containers.Map( 'KeyType', 'char', 'valueType', 'char' );
for elem = invalidElems
tempMap( elem.UUID ) = elem.getName;
end 
names = tempMap.values;%#ok<AGROW>       
varargout{ : } = names';


remakeNotification( mdlName, pdFqn );
end 

end 



function remakeNotification( mdlName, propDefFqn )
ZCStudio.makeZcFixitNotification( mdlName, 'InvalidEnum',  ...
'SystemArchitecture:zcFixitWorkflows:InvalidEnumStudioNotification',  ...
'warn', propDefFqn );

end 

function tf = isValueValid( elem, propName )
tf = true;
try 
valObj = elem.getPropValObject( propName );
propUsageType = valObj.type;
if ( ~systemcomposer.property.Enumeration.isValidEnumerationName( propUsageType.MATLABEnumName ) )
tf = false;
else 
val = valObj.getValue;
if ~strcmp( val.char, eval( valObj.expression ) )
tf = false;
end 
end 
catch ME
if ( strcmp( ME.identifier, 'SystemArchitecture:Property:InvalidEnumPropValue' ) )
tf = false;
else 
rethrow( ME )
end 
end 
end 

function throwInvalidEnumErrorDialog( enumExpression, propDefName )
dp = DAStudio.DialogProvider;
dp.errordlg(  ...
DAStudio.message( 'SystemArchitecture:Property:InvalidDefaultEnumPropValue', enumExpression, propDefName ),  ...
DAStudio.message( 'SystemArchitecture:Property:InvalidEnumLiteral' ),  ...
true );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpDB8tEZ.p.
% Please follow local copyright laws when handling this file.

