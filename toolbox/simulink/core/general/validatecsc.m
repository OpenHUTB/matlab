function invalidList = validatecsc( pkgDir, cscDefns, msDefns )






















invalidList = {  };

invalidCSCs = {  };
invalidMSs = {  };





tmpAllNames = {  };
for i = 1:length( msDefns )

tmpName = msDefns( i ).Name;

if ismember( tmpName, tmpAllNames )
tmpReason = 'Name is not unique.';
invalidMSs = [ invalidMSs, { tmpName;tmpReason } ];
continue ;
end 
tmpAllNames = [ tmpAllNames, { tmpName } ];


invalidMSs = [ invalidMSs, msDefns( i ).validate ];
end 





tmpAllNames = {  };
for i = 1:length( cscDefns )

tmpName = cscDefns( i ).Name;

if ismember( tmpName, tmpAllNames )
tmpReason = 'Name is not unique.';
invalidCSCs = [ invalidCSCs, { tmpName;tmpReason } ];
continue ;
end 
tmpAllNames = [ tmpAllNames, { tmpName } ];


invalidCSCs = [ invalidCSCs, cscDefns( i ).validate( invalidMSs, msDefns, pkgDir ) ];
end 

invalidList = { invalidCSCs, invalidMSs };

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmppFKbFk.p.
% Please follow local copyright laws when handling this file.

