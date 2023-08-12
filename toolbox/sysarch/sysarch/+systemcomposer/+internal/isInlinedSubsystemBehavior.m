function tf = isInlinedSubsystemBehavior( handleOrPath )



tf = class( systemcomposer.internal.validator.getComponentBlockType( handleOrPath ) ) ==  ...
"systemcomposer.internal.validator.SubsystemInlinedBehavior";
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpPS_TBg.p.
% Please follow local copyright laws when handling this file.

