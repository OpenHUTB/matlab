function findVarsModalSysSelector( source, startNode, wksName, varName, searchRefMdls, refreshVarUsage, searchFcn )





userData.Source = [  ];
userData.StartNode = startNode;
userData.Workspace = wksName;
userData.Variable = varName;
if ischar( source ) || isempty( source )
userData.ModelExplorer = [  ];
userData.Source = source;
userData.Scope = wksName;
else 
assert( isa( source, 'DAStudio.Explorer' ) );
userData.ModelExplorer = source;
userData.Scope = source.getListSelection.getParent;
end 
userData.searchRefMdls = searchRefMdls;
userData.updateCache = refreshVarUsage;
userData.SearchFcn = searchFcn;
systemSelectorTimerFcn( userData );
end 

function systemSelectorTimerFcn( userData )
title_str = DAStudio.message( 'Simulink:utility:FindVarsMESysSelectorTitle' );
instr_str = DAStudio.message( 'Simulink:utility:FindVarsMESysSelectorInstructions' );

systemSelectorDlg( userData.StartNode, title_str,  ...
instr_str, userData.searchRefMdls, userData.updateCache,  ...
userData.SearchFcn, userData );
end 

function systemSelectorDlg( startSystem, title, instruction, searchRefMdlsStr, forceRecompileStr, searchFcn, userData )


ssobj = Simulink.FindVarsSysSelector;
ssobj.userData = userData;
if ( strcmp( startSystem, 'Simulink Root' ) )
ssobj.ModelObj = slroot;
ssobj.SelectedSystem = 'Simulink Root';
else 
ssobj.ModelObj = get_param( bdroot( startSystem ), 'Object' );
ssobj.SelectedSystem = getfullname( startSystem );
end 

ssobj.DialogTitle = title;
ssobj.DialogInstruction = instruction;
ssobj.SearchRefMdls = strcmp( searchRefMdlsStr, 'yes' );
ssobj.RefreshVarUsage = strcmp( forceRecompileStr, 'yes' );
ssobj.ForRenameAll = strcmp( searchFcn, 'renameAll' );

h = waitbar( 0.2, DAStudio.message( 'ModelAdvisor:engine:LoadingSystemHierarchy' ) );
DAStudio.Dialog( ssobj, '', 'DLG_STANDALONE' );
if ishandle( h )
close( h );
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmp3pyVdg.p.
% Please follow local copyright laws when handling this file.

