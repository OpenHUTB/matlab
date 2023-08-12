function StreamSWReaderS2MBusInitFcn( blkH )

iscodegen = ~( rtwenvironmentmode( bdroot( blkH ) ) ||  ...
( exist( 'sldvisactive', 'file' ) ~= 0 && sldvisactive( bdroot( blkH ) ) ) );

dirt = get_param( bdroot, 'Dirty' );

if iscodegen
set_param( [ blkH, '/Variant' ], 'LabelModeActiveChoice', 'NOP' );
else 
set_param( [ blkH, '/Variant' ], 'LabelModeActiveChoice', 'SIM' );
end 

set_param( bdroot, 'Dirty', dirt );

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpfR9meT.p.
% Please follow local copyright laws when handling this file.

