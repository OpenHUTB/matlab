classdef ARClassicProfileManager < Simulink.interface.dictionary.internal.ProfileManager





properties ( Constant, Hidden )
ProfilesLocation = fullfile( autosarroot, 'sdp', 'profiles' );
PortInterfaceStereotypeName = 'PortInterface';
ProfileName = char( sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic );
end 

methods 
function profileName = getProfileName( this )
profileName = this.ProfileName;
end 

function profileFile = getProfileFilePath( this )
profileName = this.getProfileName(  );
profileFile = fullfile( this.ProfilesLocation, [ profileName, '.xml' ] );
end 

function profile = createProfile( this, namedargs )




R36
this
namedargs.SerializeProfile = true;
end 

profileName = this.getProfileName(  );
systemcomposer.internal.profile.Profile.unload( profileName );
profile = systemcomposer.profile.Profile.createProfile( profileName );
profile.IsMathWorksProfile = true;


this.addPortInterfaceStereotype( profile );

if ( namedargs.SerializeProfile )
profile.save( this.ProfilesLocation );
end 
end 
end 

methods ( Access = private )
function addPortInterfaceStereotype( this, profile )
pInterfaceSType = profile.addStereotype( this.PortInterfaceStereotypeName, 'AppliesTo', 'Interface' );

pIsService = pInterfaceSType.addProperty( 'IsService', 'Type', 'boolean', 'DefaultValue', 'false' );
pIsService.Derived = true;

pPackage = pInterfaceSType.addProperty( 'Package', 'Type', 'string', 'DefaultValue', '''/Interfaces''' );
pPackage.Derived = true;

pInterfaceKind = pInterfaceSType.addProperty( 'InterfaceKind', 'Type', 'autosar.dictionary.internal.InterfaceKind',  ...
'DefaultValue', 'autosar.dictionary.internal.InterfaceKind.SenderReceiverInterface' );
pInterfaceKind.Derived = true;
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpavfx7Y.p.
% Please follow local copyright laws when handling this file.

