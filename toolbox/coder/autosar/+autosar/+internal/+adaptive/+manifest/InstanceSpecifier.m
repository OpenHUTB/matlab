classdef InstanceSpecifier







methods ( Static )
function instanceSpec = getInstanceSpecifier( m3iPort, m3iSwcPrototype )




R36
m3iPort Simulink.metamodel.arplatform.port.Port
m3iSwcPrototype Simulink.metamodel.arplatform.composition.ComponentPrototype ...
 = Simulink.metamodel.arplatform.composition.ComponentPrototype.empty(  );
end 

import autosar.internal.adaptive.manifest.InstanceSpecifier


m3iExe = InstanceSpecifier.getExecutable( m3iPort.rootModel );
m3iRootSwCompPrototype = InstanceSpecifier.getRootSwComponentPrototype( m3iExe );


if InstanceSpecifier.isaAdaptiveComponent( m3iRootSwCompPrototype.ApplicationType )
instanceSpec = InstanceSpecifier.getInstanceSpecifierForComponent( m3iExe, m3iRootSwCompPrototype, m3iPort );
elseif InstanceSpecifier.isaCompositionComponent( m3iRootSwCompPrototype.ApplicationType )
instanceSpec = InstanceSpecifier.getInstanceSpecifierForComposition( m3iExe, m3iRootSwCompPrototype, m3iPort, m3iSwcPrototype );
else 
assert( false, 'Application type is neither a composition nor an adaptive component type' );
end 
end 
end 

methods ( Access = private, Static )
function instanceSpec = getInstanceSpecifierForComponent( m3iExecutable, m3iRootSwComponentPrototype, m3iPort )
instanceSpec = [ m3iExecutable.Name, '/', m3iRootSwComponentPrototype.Name, '/', m3iPort.Name ];
end 

function instanceSpec = getInstanceSpecifierForComposition( m3iExecutable, m3iRootSwComponentPrototype, m3iPort, m3iSwcPrototype )

assert( m3iSwcPrototype.isvalid(  ), 'Invalid swc prototype provided' );
assert( ~isempty( m3i.filter( @( port )m3iPort == port, m3iSwcPrototype.Type.Port ) ),  ...
'm3iPort must be belong to component instantiated with m3iSwcPrototype' );


import autosar.internal.adaptive.manifest.InstanceSpecifier
shortnameContext = InstanceSpecifier.getShortNameContext( m3iSwcPrototype, m3iRootSwComponentPrototype );
instanceSpec = [ m3iExecutable.Name, '/', m3iRootSwComponentPrototype.Name, '/', shortnameContext, '/', m3iPort.Name ];
end 

function shortnameContext = getShortNameContext( m3iSwcPrototype, m3iRootSwCompPrototype )


import autosar.internal.adaptive.manifest.InstanceSpecifier
import autosar.composition.Utils


m3iRootComposition = m3iRootSwCompPrototype.ApplicationType;
m3iCompPrototypes = Utils.findCompPrototypesInComposition( m3iRootComposition );
existInCompositionHierachy = ~isempty( m3iCompPrototypes( arrayfun( @( m3iComponent )m3iSwcPrototype == m3iComponent, m3iCompPrototypes ) ) );
assert( existInCompositionHierachy,  ...
'software component prototype does not exist in the composition hierarchy for the root component prototype' );




m3iCompositionCompPrototypes = m3iCompPrototypes( cellfun( @( component ) ...
InstanceSpecifier.isaCompositionComponent( component ), { m3iCompPrototypes.Type } ) );
shortnameContext = m3iSwcPrototype.Name;
while ~InstanceSpecifier.isAComponentInComposition( m3iSwcPrototype, m3iRootComposition )

m3iParent = InstanceSpecifier.getParentCompositionCompPrototype( m3iSwcPrototype, m3iCompositionCompPrototypes );


shortnameContext = [ m3iParent.Name, '/', shortnameContext ];%#ok


m3iSwcPrototype = m3iParent;
end 
end 

function m3iParent = getParentCompositionCompPrototype( m3iSwcPrototype, m3iCompositionCompPrototypes )

import autosar.internal.adaptive.manifest.InstanceSpecifier

m3iParent = m3iCompositionCompPrototypes( arrayfun( @( m3iCompositionCompPrototype ) ...
InstanceSpecifier.isAComponentInComposition( m3iSwcPrototype, m3iCompositionCompPrototype.Type ), m3iCompositionCompPrototypes ) );
assert( length( m3iParent ) == 1, 'Could not find parent composition component prototype for %s', m3iSwcPrototype.Name );
end 

function res = isAComponentInComposition( m3iSwcPrototype, m3iComposition )
res = ~isempty( m3i.filter( @( component )m3iSwcPrototype == component, m3iComposition.Components ) );
end 

function m3iExecutable = getExecutable( m3iModel )
m3iExecutable = autosar.mm.Model.findObjectByMetaClass(  ...
m3iModel,  ...
Simulink.metamodel.arplatform.manifest.Executable.MetaClass );
assert( m3iExecutable.size, 1, 'Expected to find one Executable in the meta model' );
m3iExecutable = m3iExecutable.at( 1 );
end 

function m3iRootSwComponentPrototype = getRootSwComponentPrototype( m3iExecutable )
m3iRootSwComponentPrototype = m3iExecutable.RootSwComponentPrototype;
assert( m3iRootSwComponentPrototype.isvalid, 'No valid Root Sw Component Prototype' );
end 

function res = isaAdaptiveComponent( component )
res = isa( component, 'Simulink.metamodel.arplatform.component.AdaptiveApplication' );
end 

function res = isaCompositionComponent( component )
res = isa( component, 'Simulink.metamodel.arplatform.composition.CompositionComponent' );
end 

function res = isaCompositionCompPrototype( compPrototype )
res = isa( compPrototype, 'Simulink.metamodel.arplatform.composition.ComponentPrototype' );
end 

function res = isaRootSwComponentPrototype( compPrototype )
res = isa( compPrototype, 'Simulink.metamodel.arplatform.manifest.RootSwComponentPrototype' );
end 
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpQozf9s.p.
% Please follow local copyright laws when handling this file.

