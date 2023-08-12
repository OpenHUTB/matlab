classdef AlteraDSPBASubsystem < hdlimplbase.EmlImplBase



methods 
function this = AlteraDSPBASubsystem( block )
supportedBlocks = {  ...
'built-in/SubSystem',  ...
 };

if nargin == 0
block = '';
end 

this.init( 'SupportedBlocks', supportedBlocks,  ...
'Block', block,  ...
'ArchitectureNames', 'AlteraDSPBASubsystem',  ...
'Hidden', true );

end 

end 

methods 
val = hasDesignDelay( ~, ~, ~ )
v = validateBlock( ~, hC )
end 


methods ( Hidden )
v_settings = block_validate_settings( ~, ~ )
dspbaComp = elaborate( ~, hN, hC )
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpbWtHH3.p.
% Please follow local copyright laws when handling this file.

