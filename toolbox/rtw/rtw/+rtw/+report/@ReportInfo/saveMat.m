function saveMat( obj )




matFileName = fullfile( obj.BuildDirectory, 'buildInfo.mat' );
bi = load( matFileName );

reportInfoCleanup = attachReportInfoPriorToSerialize( bi.buildInfo, obj );
save( matFileName, '-struct', 'bi' );
delete( reportInfoCleanup );
obj.Dirty = false;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpEqN5i_.p.
% Please follow local copyright laws when handling this file.

