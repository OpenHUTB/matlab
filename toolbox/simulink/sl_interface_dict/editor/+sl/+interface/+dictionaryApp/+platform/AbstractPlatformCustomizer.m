classdef ( Abstract )AbstractPlatformCustomizer < handle






properties ( SetAccess = immutable, GetAccess = protected )
DictObj Simulink.interface.Dictionary;
end 

properties ( Constant, Abstract, Access = public )
PlatformTabIds cell;
PlatformKind sl.interface.dict.mapping.PlatformMappingKind;
end 


methods ( Access = public, Abstract )

getTabAdapter( this, tabId );
platformTabs = getPlatformSpecificTabs( this );

showHelp( this );
showOptions( this );
end 

methods ( Access = protected, Abstract )

registerPlatformListener( this );
deregisterPlatformListener( this );
end 

methods ( Access = public )
function this = AbstractPlatformCustomizer( dictObj )
arguments
dictObj( 1, 1 )Simulink.interface.Dictionary;
end 
this.DictObj = dictObj;
this.registerPlatformListener(  );
end 

function delete( this )
this.deregisterPlatformListener(  );
end 


function refreshSpreadsheetList( this, listObj, changesReport )
arguments
this;%#ok custom platform customizer
listObj( 1, 1 )arch.internal.dictionaryApp.list.List;%#ok
changesReport;%#ok object type dependent on listener and platform
end 
end 
end 

methods ( Access = public, Static )
function archPlatformCustomizer = getPlatformCustomizer( platformId, dictObj )

functionPlatformIds = dictObj.getFunctionPlatformNames(  );
switch ( platformId )
case 'Native'

archPlatformCustomizer = [  ];
case functionPlatformIds
archPlatformCustomizer = [  ];
case 'AUTOSARClassic'
archPlatformCustomizer =  ...
autosar.internal.dictionaryApp.platform.AUTOSARPlatformCustomizer( dictObj );
otherwise 
assert( false, 'Unexpected platform type when retrieving platform customizer' );
end 
end 

function platformMappingKind = getPlatformMappingKind( dictObj, platformId )
functionPlatformIds = dictObj.getFunctionPlatformNames(  );
builtInPlatformIds = dictObj.getBuiltInPlatformNames(  );
switch platformId
case 'Native'
platformMappingKind = [  ];
case functionPlatformIds

platformMappingKind = [  ];
case builtInPlatformIds
platformMappingKind = sl.interface.dict.mapping.PlatformMappingKind( platformId );
otherwise 
assert( false, 'Unexpected platform type when retrieving platform mapping kind' );
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpLY0wBe.p.
% Please follow local copyright laws when handling this file.

