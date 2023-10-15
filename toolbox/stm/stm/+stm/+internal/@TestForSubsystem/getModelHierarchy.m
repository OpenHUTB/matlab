function treeItems = getModelHierarchy( rootModel )





arguments
    rootModel char
end
if rootModel == ""
    error( "stm:TestFromModelComponents:CUTStep_NoModelSpecified", message( "stm:TestFromModelComponents:CUTStep_NoModelSpecified" ).getString(  ) );
end



if ~bdIsLoaded( rootModel )
    load_system( rootModel );
end
treeItems = convertSystemHierarchyToTree( rootModel, true );






refModels = reshape( string( find_mdlrefs( rootModel, "KeepModelsLoaded", true, "ReturnTopModelAsLastElement", false, 'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices ) ), 1, [  ] );
for refModel = refModels
    treeItems = [ treeItems, convertSystemHierarchyToTree( refModel, true ) ];%#ok<AGROW>
end
end

function treeItems = convertSystemHierarchyToTree( rootSystemName, isBDRoot )
if isBDRoot
    icon = "Model";
    type = "block_diagram";
    blockType = "";
else
    icon = "SubSystem";
    type = "block";
    blockType = "Subsystem";
end
treeItems = getTreeItemStruct( rootSystemName, icon, type, blockType );

childUserDfndBlks = reshape( string( getfullname( Simulink.findBlocks( rootSystemName, Simulink.FindOptions( "SearchDepth", 1, "MatchFilter", @stm.internal.TestForSubsystem.findAllUserDefinedFcnBlks ) ) ) ), 1, [  ] );
childMdlBlks = reshape( string( getfullname( Simulink.findBlocks( rootSystemName, Simulink.FindOptions( "SearchDepth", 1, "MatchFilter", @stm.internal.TestForSubsystem.findAllModelBlks ) ) ) ), 1, [  ] );
childSFBlks = reshape( string( getfullname( Simulink.findBlocks( rootSystemName, Simulink.FindOptions( "SearchDepth", 1, "MatchFilter", @stm.internal.TestForSubsystem.findAllSFBlks ) ) ) ), 1, [  ] );
childSubsysBlks = reshape( string( getfullname( Simulink.findBlocks( rootSystemName, Simulink.FindOptions( "SearchDepth", 1, "MatchFilter", @stm.internal.TestForSubsystem.findAllSubsysBlks ) ) ) ), 1, [  ] );

for childUserDfndBlk = childUserDfndBlks
    treeItems = [ treeItems, getTreeItemStruct( childUserDfndBlk, "Block", "block", "UserDefinedFunction" ) ];%#ok<AGROW>
end
for childMdlBlk = childMdlBlks
    treeItems = [ treeItems, getTreeItemStruct( childMdlBlk, "MdlRef", "block", "ModelReference" ) ];%#ok<AGROW>
end
for childSFBlk = childSFBlks
    treeItems = [ treeItems, getTreeItemStruct( childSFBlk, "Stateflow", "block", "Stateflow" ) ];%#ok<AGROW>
end
for childSubsysBlk = childSubsysBlks
    treeItems = [ treeItems, convertSystemHierarchyToTree( childSubsysBlk, false ) ];%#ok<AGROW>
end
end

function data = getTreeItemStruct( item, iconImgPath, type, blockType )
data.fullName = item;
data.iconUri = iconImgPath;
data.type = type;
data.blockType = blockType;
data.id = Simulink.ID.getSID( item );
data.label = strrep( get_param( item, "Name" ), newline, " " );
parent = get_param( item, "Parent" );
if parent ~= ""
    data.parent = Simulink.ID.getSID( parent );
else
    data.parent = NaN;
end
end
