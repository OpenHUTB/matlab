classdef XformVer43To43 < handle




properties ( Access = public )
AutosarTargetNsUri
AutosarTargetVersionStr
AutosarSourceNsUri
Transformer
SkipElements
end 

methods 
function self = XformVer43To43( versionStr, transformer )
self.AutosarTargetVersionStr = versionStr;
self.AutosarSourceNsUri = autosar.mm.arxml.SchemaUtil.getSchemaUri( '4.2.1' );
self.AutosarTargetNsUri = autosar.mm.arxml.SchemaUtil.getSchemaUri( versionStr );
self.Transformer = transformer;
self.registerAttribute( 'xmlns', @self.processXmlNs );
self.registerAttribute( 'xsi:schemaLocation', @self.processSchemaLocation );
end 

function delete( self )
self.AutosarSourceNsUri = [  ];
self.Transformer = [  ];
end 

function registerAttribute( self, contextName, func )
context = self.createAutosarAttributeContext( contextName );
self.Transformer.addPreTransform( context, func );
end 

function ret = createAutosarAttributeContext( ~, roleName )
context = M3I.Context;
context.RoleName = roleName;
context.setAttributeValue( '' );
ret = context;
end 

function retSeq = processXmlNs( self, inputCtx )
retSeq = M3I.ContextSequence;
context = inputCtx;
context.setAttributeValue( self.AutosarTargetNsUri );
retSeq.addContext( context );
end 

function retSeq = processSchemaLocation( self, inputCtx )
retSeq = M3I.ContextSequence;
context = inputCtx;
autosarTargetVersionStr = regexprep( self.AutosarTargetVersionStr, '\.', '-' );
context.setAttributeValue( [ self.AutosarTargetNsUri, ' ', 'AUTOSAR_', autosarTargetVersionStr, '.xsd' ] );
retSeq.addContext( context );
end 

function registerPreTransform( self, roleName, func, namedargs )
R36
self
roleName
func
namedargs.ParentRoleName = '';
end 
context = self.createAutosarElementContext( roleName, namedargs.ParentRoleName );
self.Transformer.addPreTransform( context, func );
end 

function registerPostTransform( self, roleName, func, namedargs )
R36
self
roleName
func
namedargs.ParentRoleName = '';
end 
context = self.createAutosarElementContext( roleName, namedargs.ParentRoleName );
self.Transformer.addPostTransform( context, func );
end 

function ret = createAutosarElementContext( ~, roleName, parentRoleName )
context = M3I.Context;
context.RoleName = roleName;
if ~isempty( parentRoleName )
context.ParentRoleName = parentRoleName;
end 
context.setElement( '' );
ret = context;
end 

function retSeq = skipElements( self, ~ )
self.SkipElements = true;
retSeq = M3I.ContextSequence;
end 

function retSeq = resetSkipElements( self, ~ )
self.SkipElements = false;
retSeq = M3I.ContextSequence;
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp8zn8lg.p.
% Please follow local copyright laws when handling this file.

