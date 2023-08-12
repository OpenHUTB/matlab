function replacementModelH = updateGeneratedMdls( obj )




if ~obj.ErrorOccurred


if obj.RepMdlGenerated && ( obj.ReplacedAtLeastOnce || obj.MdlInfo.ForceReplaceModel )
warningIds = Sldv.xform.BlkReplacer.listWarningsToTurnOff;
warningStatus = Sldv.xform.BlkReplacer.turnOffWarnings( warningIds );

replacementModelFileName = get_param( obj.MdlInfo.ModelH, 'filename' );
replacementModelName = get_param( obj.MdlInfo.ModelH, 'Name' );

if obj.SubSystemTreeConstWithCompiledInfo
set_param( obj.MdlInfo.ModelH, 'SaveWithParameterizedLinksMsg', 'none' );
end 








obj.MdlInfo.reopenGeneratedModel(  );
replacementModelH = obj.MdlInfo.ModelH;

if ~obj.IsReplacementForAnalysis
open_system( replacementModelFileName );
else 



if obj.MdlInfo.TestComp.analysisInfo.fixptRangeAnalysisMode
set_param( replacementModelName, 'InRangeAnalysisMode', 'on' );
end 
end 

Sldv.xform.BlkReplacer.restoreWarningStatus( warningIds, warningStatus );

obj.refreshKeysReplacedAndNotReplacedBlkTables;

obj.refreshHandlesBlockApproximations;

if obj.IsReplacementForAnalysis

obj.MdlInfo.CloseLoadedForModelReference = false;

obj.MdlInfo.TestComp.analysisInfo.replacementInfo.replacementsApplied = true;
obj.MdlInfo.TestComp.analysisInfo.replacementInfo.replacementModelH =  ...
replacementModelH;
obj.MdlInfo.TestComp.analysisInfo.replacementInfo.tempReplacement =  ...
~obj.BlockReplacementsEnforced;

if ~isempty( obj.ReplacedBlocksTable.keys )
obj.MdlInfo.TestComp.analysisInfo.replacementInfo.replacementTable =  ...
containers.Map( obj.ReplacedBlocksTable.keys, obj.ReplacedBlocksTable.values );
else 
obj.MdlInfo.TestComp.analysisInfo.replacementInfo.replacementTable =  ...
containers.Map;
end 

if ~isempty( obj.NotReplacedBlocksTable.keys )
obj.MdlInfo.TestComp.analysisInfo.replacementInfo.notReplacedBlksTable =  ...
containers.Map( obj.NotReplacedBlocksTable.keys, obj.NotReplacedBlocksTable.values );
else 
obj.MdlInfo.TestComp.analysisInfo.replacementInfo.notReplacedBlksTable =  ...
containers.Map;
end 

obj.MdlInfo.TestComp.analysisInfo.replacementInfo.mdlsLoadedForMdlRefTree =  ...
obj.MdlInfo.MdlsLoadedForMdlRefTree;




if ~Sldv.utils.isValidContainerMap( obj.MdlInfo.TestComp.analysisInfo.mappedSfId )
obj.MdlInfo.TestComp.analysisInfo.mappedSfId =  ...
containers.Map( 'KeyType', 'double', 'ValueType', 'double' );
end 
if ~Sldv.utils.isValidContainerMap( obj.MdlInfo.TestComp.analysisInfo.mappedBlockH )
obj.MdlInfo.TestComp.analysisInfo.mappedBlockH =  ...
containers.Map( 'KeyType', 'double', 'ValueType', 'double' );
end 
obj.MdlInfo.TestComp.resolvedSettings.BlockReplacementModelFileName =  ...
get_param( replacementModelH, 'FileName' );

obj.MdlInfo.TestComp.mdlApproxErrorsInfo = obj.ApproxErrorsInfo;
obj.MdlInfo.TestComp.hasMultiInsNormalMode = obj.MdlInfo.HasMultiInsNormalMode;
end 
else 
if obj.BlockReplacementsEnforced
originalModelName = get_param( obj.ModelH, 'Name' );
warning( message( 'Sldv:BLOCKREPLACEMENT:NoReplacement', originalModelName, originalModelName ) );
end 
replacementModelH = obj.ModelH;


if obj.IsReplacementForAnalysis
obj.MdlInfo.TestComp.resolvedSettings.BlockReplacementModelFileName = '';

obj.refreshKeysReplacedAndNotReplacedBlkTables;

if ~isempty( obj.NotReplacedBlocksTable.keys )
obj.MdlInfo.TestComp.analysisInfo.replacementInfo.notReplacedBlksTable =  ...
containers.Map( obj.NotReplacedBlocksTable.keys, obj.NotReplacedBlocksTable.values );
else 
obj.MdlInfo.TestComp.analysisInfo.replacementInfo.notReplacedBlksTable =  ...
containers.Map;
end 

if sldvshareprivate( 'util_is_analyzing_for_fixpt_tool' )
set_param( replacementModelH, 'InRangeAnalysisMode', 'on' );
end 
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp4DWMZV.p.
% Please follow local copyright laws when handling this file.

