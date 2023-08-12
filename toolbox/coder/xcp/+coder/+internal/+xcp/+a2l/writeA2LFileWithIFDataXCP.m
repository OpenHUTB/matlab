










function writeA2LFileWithIFDataXCP( outputFile, a2lContents, ifDataXcp, nameValueArgs )

R36
outputFile( 1, : )char
a2lContents( 1, : )char
ifDataXcp( 1, 1 )asam.mcd2mc.ifdata.xcp.IFDataXCPInfo
nameValueArgs.CustomizationObject( 1, : ) = ''
nameValueArgs.OriginalFileName( 1, : )char = ''
end 



[ checkoutSuccess, errmsg ] = license( 'checkout', 'rtw_embedded_coder' );
if ~checkoutSuccess
DAStudio.error( 'coder_xcp:a2l:RequiresEmbeddedCoder', errmsg );
end 


[ a2lContentsFirst, a2lContentsLast ] = splitA2LContents( a2lContents );
if ~isempty( nameValueArgs.CustomizationObject ) && ~isempty( nameValueArgs.CustomizationObject.AfterBeginModuleContents )

a2lBeforeBeginPart = extractBefore( a2lContentsLast, "/begin" );
a2lContentsLast = append( '   /begin', extractAfter( a2lContentsLast, '/begin' ) );
end 


fileWriter = getFileWriter( outputFile );
a2lWriter = coder.internal.xcp.a2l.A2LWriter( fileWriter );










if ~isempty( nameValueArgs.OriginalFileName )

[ ~, origFileName, origExt ] = fileparts( nameValueArgs.OriginalFileName );
origFileName = strcat( origFileName, origExt );


[ ~, opFileName, opExt ] = fileparts( outputFile );
opFileName = strcat( opFileName, opExt );


a2lWriter.wLine( [ '/', repmat( '*', 1, 78 ) ] );
a2lWriter.wLine( ' * ' );
a2lWriter.wLine( sprintf( ' *  ASAP2 File: %s', opFileName ) );
a2lWriter.wLine( ' * ' );
a2lWriter.wLine( ' * This is an auto-generated file, containing the information needed to connect' )
a2lWriter.wLine( ' * to the MathWorks Simulink Coder XCP Slave using an XCP calibration tool.' );
a2lWriter.wLine( ' * ' );
a2lWriter.wLine( sprintf( ' * The header below refers to the original file ''%s''.', origFileName ) )
a2lWriter.wLine( ' * ' );
a2lWriter.wLine( [ ' ', repmat( '*', 1, 78 ), '/' ] );
a2lWriter.wLine( '' );
end 


a2lWriter.wLine( a2lContentsFirst );
a2lWriter.wLine( '' );
if ~isempty( nameValueArgs.CustomizationObject ) && ~isempty( nameValueArgs.CustomizationObject.AfterBeginModuleContents )





if ~isempty( strip( a2lBeforeBeginPart ) )
a2lWriter.wLine( a2lBeforeBeginPart );
a2lWriter.wLine( '' );
end 
end 

a2lWriter.wLine( [ '    ', getA2ML(  ) ] );



baseIndent = 4;
indentSpacing = 2;
str = asam.mcd2mc.writeIFDataXCPInfo( ifDataXcp,  ...
baseIndent,  ...
indentSpacing );

a2lWriter.wLine( str );
a2lWriter.wLine( '' );


a2lWriter.wLine( a2lContentsLast );

end 


function varargout = splitA2LContents( a2lContents )


varargout = regexp( a2lContents,  ...
'(?<=(/begin MODULE.*))\n',  ...
'split', 'once', 'dotexceptnewline' );
end 

function text = getA2ML(  )





mfd = fileparts( mfilename( 'fullpath' ) );
text = fileread( fullfile( mfd, 'xcp100.aml' ) );
end 


function fileWriter = getFileWriter( outputFile )


append = false;
callCBeautifier = false;
obfuscateCode = false;
fileWriter = rtw.connectivity.FileWriter( outputFile, append, callCBeautifier, obfuscateCode );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQcsNlD.p.
% Please follow local copyright laws when handling this file.

