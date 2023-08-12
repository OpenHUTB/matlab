function [ status, msg ] = insertTimingController( topNtwk )




status = 0;
msg = '';




blkTag = 'PirTimingController';

hC = topNtwk.addComponent( 'block_comp', 0, 0, blkTag );

hC.Name = blkTag;

impl = hdlimplbase.TimingControllerHDLEmission;
if ~isempty( impl )
hC.setImplementation( impl );
else 
status = 1;
msg = 'Cannot find the default internal implementation Timing Controller';
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpl_r2kQ.p.
% Please follow local copyright laws when handling this file.

