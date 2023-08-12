function slConvertCustomMenus( options )
R36
options.CompName{ mustBeTextScalar } = "custom";
options.CompFolder{ mustBeTextScalar, mustBeFolder } = pwd;
options.Replace{ mustBeNumericOrLogical, mustBeScalarOrEmpty } = [  ];
end 

start_simulink;
simulink.toolstrip.internal.loadConfig(  );


slTabName = 'slCustomTab';


converter = dig.config.SchemaConverter( 'sl_toolstrip_plugins' );


menuGenerator = createMenuGenerator(  );


[ ~, mdlname ] = fileparts( tempname );
open_system( new_system( mdlname ) );
cleanup = onCleanup( @(  )cleanupFcn( mdlname ) );
bdHandle = get_param( mdlname, 'Handle' );
studioApp = SLM3I.SLDomain.getLastActiveStudioAppFor( bdHandle );
toolstrip = studioApp.getStudio(  ).getToolStrip(  );



converter.convertToTab( slTabName,  ...
menuGenerator,  ...
toolstrip.ActiveContext,  ...
CompName = options.CompName,  ...
CompFolder = options.CompFolder,  ...
Replace = options.Replace );
end 

function cleanupFcn( mdlname )
close_system( mdlname );
sl_refresh_customizations;
end 

function generator = createMenuGenerator(  )
generator = @doIt;
end 

function schemas = doIt( ~ )
schemas = {  };


cm = sl_customization_manager;


fileChildrenFcns = cm.getCustomMenuFcns( 'Simulink:FileMenu' );
if ~isempty( fileChildrenFcns )
tag = 'fileMenu';
label = 'Simulink:studio:FileSection';
tooltip = '';
fileGenerator = @( cbinfo )menuGenerator( tag, label, tooltip, fileChildrenFcns, cbinfo );
schemas = { fileGenerator };
end 


editChildrenFcns = cm.getCustomMenuFcns( 'Simulink:EditMenu' );
if ~isempty( editChildrenFcns )
tag = 'editMenu';
label = 'Simulink:studio:EditSection';
tooltip = '';
editGenerator = @( cbinfo )menuGenerator( tag, label, tooltip, editChildrenFcns, cbinfo );
if isempty( schemas )
schemas = { editGenerator };
else 
schemas = [ schemas, { editGenerator } ];
end 
end 


viewChildrenFcns = cm.getCustomMenuFcns( 'Simulink:ViewMenu' );
if ~isempty( viewChildrenFcns )
tag = 'viewMenu';
label = 'Simulink:studio:ViewSection';
tooltip = '';
viewGenerator = @( cbinfo )menuGenerator( tag, label, tooltip, viewChildrenFcns, cbinfo );
if isempty( schemas )
schemas = { viewGenerator };
else 
schemas = [ schemas, { viewGenerator } ];
end 
end 


displayChildrenFcns = cm.getCustomMenuFcns( 'Simulink:DisplayMenu' );
if ~isempty( displayChildrenFcns )
tag = 'displayMenu';
label = 'Simulink:studio:DisplaySection';
tooltip = '';
displayGenerator = @( cbinfo )menuGenerator( tag, label, tooltip, displayChildrenFcns, cbinfo );
if isempty( schemas )
schemas = { displayGenerator };
else 
schemas = [ schemas, { displayGenerator } ];
end 
end 


diagramChildrenFcns = cm.getCustomMenuFcns( 'Simulink:DiagramMenu' );
if ~isempty( diagramChildrenFcns )
tag = 'diagramMenu';
label = 'Simulink:studio:DiagramSection';
tooltip = '';
diagramGenerator = @( cbinfo )menuGenerator( tag, label, tooltip, diagramChildrenFcns, cbinfo );
if isempty( schemas )
schemas = { diagramGenerator };
else 
schemas = [ schemas, { diagramGenerator } ];
end 
end 


simulationChildrenFcns = cm.getCustomMenuFcns( 'Simulink:SimulationMenu' );
if ~isempty( simulationChildrenFcns )
tag = 'simulationMenu';
label = 'Simulink:studio:SimulationSection';
tooltip = '';
simulationGenerator = @( cbinfo )menuGenerator( tag, label, tooltip, simulationChildrenFcns, cbinfo );
if isempty( schemas )
schemas = { simulationGenerator };
else 
schemas = [ schemas, { simulationGenerator } ];
end 
end 


analysisChildrenFcns = cm.getCustomMenuFcns( 'Simulink:AnalysisMenu' );
if ~isempty( analysisChildrenFcns )
tag = 'analysisMenu';
label = 'Simulink:studio:AnalysisSection';
tooltip = '';
analysisGenerator = @( cbinfo )menuGenerator( tag, label, tooltip, analysisChildrenFcns, cbinfo );
if isempty( schemas )
schemas = { analysisGenerator };
else 
schemas = [ schemas, { analysisGenerator } ];
end 
end 


codeChildrenFcns = cm.getCustomMenuFcns( 'Simulink:CodeMenu' );
if ~isempty( codeChildrenFcns )
tag = 'codeMenu';
label = 'Simulink:studio:CodeSection';
tooltip = '';
codeGenerator = @( cbinfo )menuGenerator( tag, label, tooltip, codeChildrenFcns, cbinfo );
if isempty( schemas )
schemas = { codeGenerator };
else 
schemas = [ schemas, { codeGenerator } ];
end 
end 


toolsChildrenFcns = cm.getCustomMenuFcns( 'Simulink:ToolsMenu' );
if ~isempty( toolsChildrenFcns )
tag = 'toolsMenu';
label = 'Simulink:studio:ToolsSection';
tooltip = '';
toolsGenerator = @( cbinfo )menuGenerator( tag, label, tooltip, toolsChildrenFcns, cbinfo );
if isempty( schemas )
schemas = { toolsGenerator };
else 
schemas = [ schemas, { toolsGenerator } ];
end 
end 




menuBarGenerators = cm_get_custom_schemas( 'Simulink:MenuBar' );
if ~isempty( menuBarGenerators )
if isempty( schemas )
schemas = menuBarGenerators;
else 
schemas = [ schemas, menuBarGenerators ];
end 
end 


helpChildrenFcns = cm.getCustomMenuFcns( 'Simulink:HelpMenu' );
if ~isempty( helpChildrenFcns )
tag = 'helpMenu';
label = 'Simulink:studio:HelpSection';
tooltip = '';
helpGenerator = @( cbinfo )menuGenerator( tag, label, tooltip, helpChildrenFcns, cbinfo );
if isempty( schemas )
schemas = { helpGenerator };
else 
schemas = [ schemas, { helpGenerator } ];
end 
end 
end 

function schema = menuGenerator( tag, label, tooltip, childrenGenerators, ~ )
schema = sl_container_schema;
schema.tag = tag;
schema.label = label;
schema.tooltip = tooltip;
schema.generateFcn = @( cbinfo )generateMenuChildren( cbinfo, childrenGenerators );
end 

function schemas = generateMenuChildren( ~, childrenGenerators )

schemas = {  };
for ii = 1:length( childrenGenerators )
generator = childrenGenerators{ ii };
if isempty( schemas )
schemas = generator(  );
else 
schemas = [ schemas, generator(  ) ];%#ok<AGROW> 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpoVoMno.p.
% Please follow local copyright laws when handling this file.

