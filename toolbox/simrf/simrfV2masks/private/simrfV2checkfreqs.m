function carrierfreqs = simrfV2checkfreqs( carrierfreqs, ispositive )








carrierfreqs = simrfV2checkparam( carrierfreqs, 'Carrier frequencies',  ...
ispositive );


if length( carrierfreqs ) ~= length( unique( carrierfreqs ) )
error( message( 'simrf:simrfV2errors:FreqsNotUnique',  ...
'Carrier frequencies' ) )
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmphho6MV.p.
% Please follow local copyright laws when handling this file.

