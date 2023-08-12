function setSampleModeForBlock( this, blkh )













blockFrameMode = this.getBlockFrameMode;

switch blockFrameMode
case 'inputproc'
set_param( blkh, 'InputProcessing', 'Elements as channels' );
case 'rateopt'
roParam = this.getRateOptionsParameter;
set_param( blkh, roParam, 'Allow multirate processing' );
case 'inputprocandrateopt'
roParam = this.getRateOptionsParameter;
set_param( blkh, roParam, 'Allow multirate processing' );
set_param( blkh, 'InputProcessing', 'Elements as channels' );
otherwise 

end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpETGgzp.p.
% Please follow local copyright laws when handling this file.

