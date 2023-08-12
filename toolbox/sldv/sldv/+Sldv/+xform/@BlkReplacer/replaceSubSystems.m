function replaceSubSystems( obj )






if obj.ReplacedMdlRefBlk
obj.ErrorGroup = 3;
else 
obj.ErrorGroup = 2;
end 



if ~obj.HasRepRulesForSubSystem ||  ...
( ~obj.HasRepRulesForMdlRef && ~obj.AutoRepRuleForSubSystemWillWork )



return ;
end 



if slavteng( 'feature', 'SSysStubbing' )
obj.updateLibForStubCopy;
end 


obj.MdlInfo.compileModel( 'compile' );




obj.constructSubsystemTreeWithCompiledInfo;



obj.MdlInfo.termModel;


obj.updateTableLibLinkBrokenSS;



obj.ErrorGroup = 3;


obj.exeSubSystemRepRules;



if slavteng( 'feature', 'SSysStubbing' ) && ~obj.ReplacedSubsystem
obj.destroyLibForStubCopy;
end 



obj.MdlInfo.compileModel( 'compile' );



obj.compareSubSystemReplacements;
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpvZwTpL.p.
% Please follow local copyright laws when handling this file.

