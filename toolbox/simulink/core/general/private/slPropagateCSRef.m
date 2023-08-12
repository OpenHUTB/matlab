function slPropagateCSRef( model, csrefName, varargin )



narginchk( 1, 3 );
if nargin == 3
Progressbar = varargin{ 1 };
else 
Progressbar = [  ];
end 

if nargin == 1
csref = getActiveConfigSet( model );
else 
csref = getConfigSet( model, csrefName );
end 

if isempty( csref )
DAStudio.error( 'Simulink:ConfigSet:ConfigSetNotFound', csrefName );
elseif ~isa( csref, 'Simulink.ConfigSetRef' )
DAStudio.error( 'Simulink:ConfigSet:ConfigSetRefExpected', csrefName );
end 


cs = csref.WSVarName;
mdlsToBeModified = loc_findMdlRef( model );

if ~isempty( Progressbar )
if isempty( mdlsToBeModified )
msgbox( DAStudio.message( 'Simulink:tools:NoReferencedModel', model ), 'Error', 'warn' );
Progressbar = [  ];
return ;
elseif ~iscell( mdlsToBeModified ) && mdlsToBeModified ==  - 1
Progressbar = [  ];
return ;
end 
end 

for i = 1:length( mdlsToBeModified )
thisModel = mdlsToBeModified{ i };
mdlName = thisModel.mdlName;
if ~isempty( Progressbar )
Progressbar.setLabelText( [ DAStudio.message( 'Simulink:tools:CSRefPropagationPBarModelLabel' ), ' ', mdlName ] );
Progressbar.show(  );
end 

refs = loc_getConfigSetRefs( mdlName );
flag = 0;
for j = 1:length( refs )
r2 = refs{ j }.WSVarName;
if strcmp( cs, r2 )
setActiveConfigSet( mdlName, refs{ j }.Name );
flag = 1;
break ;
end 
end 

if flag == 0
newcsref = csref.copy;
attachConfigSet( mdlName, newcsref, true );
setActiveConfigSet( mdlName, newcsref.Name );
end 

set_param( model, 'dirty', 'on' );
if ~isempty( Progressbar )
Progressbar = [  ];
end 
end 


function mdls = loc_findMdlRef( system )

mdls = [  ];

try 


children = find_mdlrefs( system, 'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices );
catch me
msg = '';

if isempty( me.cause )
msg = me.message;
else 
for i = 1:length( me.cause )
msg = [ msg, ' ', me.cause{ i }.message ];%#ok
end 
end 

errordlg( msg, 'Error' );

mdls =  - 1;
return ;
end 

for i = 1:length( children ) - 1
child = children{ i };

if ~bdIsLoaded( child )
model.mdlLoaded = false;
load_system( child );
else 
model.mdlLoaded = true;
end 
model.mdlName = child;
mdls{ end  + 1 } = model;%#ok
end 


function refs = loc_getConfigSetRefs( model )

refs = [  ];
configSets = getConfigSets( model );
index = 1;
for i = 1:length( configSets )
cs = getConfigSet( model, configSets{ i } );
if isa( cs, 'Simulink.ConfigSetRef' )
refs{ index, 1 } = cs;
index = index + 1;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpro9nT5.p.
% Please follow local copyright laws when handling this file.

