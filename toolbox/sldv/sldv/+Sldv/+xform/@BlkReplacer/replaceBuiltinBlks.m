function replaceBuiltinBlks( obj )







if obj.ReplacedMdlRefBlk || obj.ReplacedSubsystem
obj.ErrorGroup = 3;
else 
obj.ErrorGroup = 2;
end 



if ~obj.HasRepRulesForBuiltinBlks
return ;
end 


obj.MdlInfo.compileModel( 'compile' );


obj.MdlInfo.constructSubsystemTree( false, true );



obj.MdlInfo.termModel;


obj.updateTableLibLinkBrokenSS;



obj.ErrorGroup = 3;


obj.exeBuiltinBlkRepRules;



obj.MdlInfo.compileModel;



obj.compareBuiltinBlkReplacements;
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpqlR5mD.p.
% Please follow local copyright laws when handling this file.

