function fcnInfo = rtwgettargetfcnlib_nothrow( model, rtwFcn, rtwType, isSimBuild )









fcnInfo = [  ];

libH = get_param( model, 'TargetFcnLibHandle' );
if isempty( libH )
replE = [  ];
else 
replE = libH.getFcnImplement( rtwFcn, rtwType );
end 

if ~isempty( replE )



if ~isSimBuild
err = rtwprivate( 'pwsCheckCrlUnsizedArgs_nothrow', model, replE );
if ( ~isempty( err ) )


fcnInfo = struct( 'ErrIdentifier', { err.Identifier },  ...
'ErrArguments', { err.Arguments } );
return ;
end 
end 

impl = replE.Implementation;
retArg = impl.Return;
if ( ~isempty( retArg ) )
retType = retArg.toString;
else 
retType = 'void';
end 
hdrFile = getHeaderFile( replE, libH );
fcnInfo = struct( 'FcnName', impl.Name,  ...
'FcnType', retType,  ...
'HdrFile', hdrFile,  ...
'NumInputs', impl.NumInputs );

end 

end 




function hf = getHeaderFile( replE, libH )

hf = replE.Implementation.HeaderFile;




if ( libH.InlineUtil )
if ~isempty( regexp( replE.GenCallback, '\.tlc\s*$', 'once' ) )
hf = '';
else 
keysToIgnore = { 'rtInf', 'rtMinusInf', 'rtNaN' };
if isequal( hf, 'rt_nonfinite.h' ) && ismember( replE.Key, keysToIgnore )
hf = '';
end 
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpgUleOw.p.
% Please follow local copyright laws when handling this file.

