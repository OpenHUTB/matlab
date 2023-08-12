function updateReplacementRules( obj )




if obj.BlockReplacementsEnforced
userRules = get( obj.SldvOptConfig, 'BlockReplacementRulesList' );

userRules = insertFactoryDefaultRulesList( userRules );


ruleNamesUnique = Sldv.xform.BlkReplacer.generateUniqueRulearray( userRules );
else 
ruleNamesUnique = {  };
end 




rulesTable =  ...
containers.Map( 'KeyType', 'char', 'ValueType', 'any' );

rulesList = obj.AllRules;



rulesList = removeCustomRules( rulesList );
deactivateAndStore( rulesList, rulesTable );



priorityIdx = 1;
for idx = 1:length( ruleNamesUnique )
if rulesTable.isKey( ruleNamesUnique{ idx } )
rule = rulesTable( ruleNamesUnique{ idx } );
rule.IsActive = true;
else 
try 
rule = sldvprivate( ruleNamesUnique{ idx } );
obj.BlkRepRulesTree.addRule( rule );
catch Mex


delete( rulesTable );
obj.constructBuiltinRepRulesTree;
rethrow( Mex );
end 
end 
rule.Priority = priorityIdx;
priorityIdx = priorityIdx + 1;
end 

currentAnalysisOpts = [  ];
if ~isempty( obj.TestComponent )
currentAnalysisOpts = obj.SldvOptConfig;
end 
activateAutoRules( rulesList, priorityIdx, currentAnalysisOpts );

delete( rulesTable );


ruleIteratorDFS = Sldv.xform.TreeDFSIterator( obj.BlkRepRulesTree );
ruleIteratorDFS.firstElement( obj.BlkRepRulesTree );
while true
currentNode = ruleIteratorDFS.currentElement;
if isa( currentNode, 'Sldv.xform.CompBlkRepRule' )

try 
childs = currentNode.DirectSuccessors;
updateLastNode = ~isempty( childs ) && childs{ end  } == ruleIteratorDFS.TreeLastNode;
currentNode.reorderChilds;
if updateLastNode
ruleIteratorDFS.findLastNode;
end 
catch Mex
obj.constructBuiltinRepRulesTree;
rethrow( Mex );
end 
end 

if ruleIteratorDFS.hasMoreElements
ruleIteratorDFS.nextElement;
else 
break ;
end 
end 

obj.HasRepRulesForMdlRef = ~isempty( obj.ActiveRulesForMdlRefBlks );
obj.HasRepRulesForSubSystem = ~isempty( obj.ActiveRulesForSubSystems );
obj.HasRepRulesForBuiltinBlks = ~isempty( obj.ActiveRulesForBuiltinBlks );
end 

function userRules = insertFactoryDefaultRulesList( userRules )
index = strfind( userRules, '<FactoryDefaultRules>' );
if ~isempty( index )
defaultMfiles = Sldv.xform.BlkReplacer.factoryDefaultBlkRepRules;
commaSeparatedString = defaultMfiles{ 1 };
for i = 2:length( defaultMfiles )
commaSeparatedString = [ commaSeparatedString, ', ', defaultMfiles{ i } ];%#ok<AGROW>
end 
jumpIdx = index + length( '<FactoryDefaultRules>' );
userRules = [ userRules( 1:abs( index - 1 ) ), commaSeparatedString, userRules( jumpIdx:end  ) ];
end 
end 

function filteredList = removeCustomRules( rulesList )
filteredList = [  ];
for i = 1:length( rulesList )
currentRule = rulesList{ i };
if ( currentRule.IsBuiltin )
filteredList{ end  + 1 } = currentRule;%#ok<AGROW>
else 
currentRule.disconnect;
delete( currentRule );
end 
end 

end 

function deactivateAndStore( rulesList, rulesTable )
for i = 1:length( rulesList )
currentRule = rulesList{ i };
currentRule.IsActive = false;
currentRule.Priority = 0;
rulesTable( currentRule.FileName ) = currentRule;
end 
end 

function activateAutoRules( rulesList, priorityIdx, currentAnalysisOpts )
for i = 1:length( rulesList )
currentRule = rulesList{ i };

if currentRule.IsAuto && ~currentRule.IsActive &&  ...
isActiveForAnalysissetting( currentRule, currentAnalysisOpts )
currentRule.IsActive = true;
currentRule.Priority = priorityIdx;
priorityIdx = priorityIdx + 1;
end 
end 
end 

function out = isActiveForAnalysissetting( currentRule, currentAnalysisOpts )
if isempty( currentAnalysisOpts )
out = true;
elseif strcmp( currentRule.FileName, 'blkrep_rule_comblogic_normal' ) &&  ...
( ~strcmp( currentAnalysisOpts.Mode, 'TestGeneration' ) || strcmp( currentAnalysisOpts.getDerivedModelCoverageObjectives(  ), 'None' ) )
out = false;
elseif strcmp( currentRule.FileName, 'blkrep_rule_empty_trigger_ss' ) &&  ...
(  ...
( strcmp( currentAnalysisOpts.Mode, 'TestGeneration' ) && strcmp( currentAnalysisOpts.getDerivedModelCoverageObjectives(  ), 'None' ) ) ||  ...
strcmp( currentAnalysisOpts.Mode, 'PropertyProving' ) ||  ...
( strcmp( currentAnalysisOpts.Mode, 'DesignErrorDetection' ) && strcmp( currentAnalysisOpts.DetectDeadLogic, 'off' ) ) ...
 )
out = false;
else 
out = true;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpSQr6Fz.p.
% Please follow local copyright laws when handling this file.

