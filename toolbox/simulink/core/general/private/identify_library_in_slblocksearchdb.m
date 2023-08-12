function product = identify_library_in_slblocksearchdb( libname )







product = '';



try 
libdetails = slblocksearchdb.getLibraryDetails( libname );
catch exp
product = exp.message;
return ;
end 

while ~isempty( libdetails )
product = libdetails.LibDisplayName;
if ~isempty( libdetails.ParentLibPath )
[ ~, libname, ~ ] = slfileparts( libdetails.ParentLibPath );
libdetails = slblocksearchdb.getLibraryDetails( libname );
else 
libdetails = [  ];
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp2MJ3zD.p.
% Please follow local copyright laws when handling this file.

