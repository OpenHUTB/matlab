function carrierfreqs = simrfV2checkfreqs( carrierfreqs, ispositive )

carrierfreqs = simrfV2checkparam( carrierfreqs, 'Carrier frequencies',  ...
ispositive );

if length( carrierfreqs ) ~= length( unique( carrierfreqs ) )
error( message( 'simrf:simrfV2errors:FreqsNotUnique',  ...
'Carrier frequencies' ) )
end 

end 


