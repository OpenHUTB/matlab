function id = getMessageIDForEnumMember( aEnumMember )









R36
aEnumMember{ mustBeA( aEnumMember, [ "coderapp.internal.screener.Language" ...
, "coderapp.internal.screener.FIConversion" ...
, "coderapp.internal.screener.Environment" ...
, "coderapp.internal.screener.FileType" ] ) }
end 

if isa( aEnumMember, 'coderapp.internal.screener.Language' )
id = getMessageIDForLanguage( aEnumMember );
elseif isa( aEnumMember, 'coderapp.internal.screener.FIConversion' )
id = getMessageIDForFIConversion( aEnumMember );
elseif isa( aEnumMember, 'coderapp.internal.screener.Environment' )
id = getMessageIDForEnvironment( aEnumMember );
elseif isa( aEnumMember, 'coderapp.internal.screener.FileType' )
id = getMessageIDForFileType( aEnumMember );
end 
end 

function id = getMessageIDForLanguage( aLanguage )
import coderapp.internal.screener.Language;
switch ( aLanguage )
case Language.CXX
id = 'coderApp:screener:langCXX';
case Language.GPU
id = 'coderApp:screener:langGPU';
case Language.HDL
id = 'coderApp:screener:langHDL';
otherwise 
throwUnexpectedEnumMemberError( aLanguage );
end 
end 

function id = getMessageIDForFIConversion( aFIConversion )
import coderapp.internal.screener.FIConversion;
switch ( aFIConversion )
case FIConversion.NOFI
id = 'coderApp:screener:fiNo';
case FIConversion.FI
id = 'coderApp:screener:fiYes';
otherwise 
throwUnexpectedEnumMemberError( aFIConversion );
end 
end 

function id = getMessageIDForEnvironment( aEnvironment )
import coderapp.internal.screener.Environment;
switch ( aEnvironment )
case Environment.MEX
id = 'coderApp:screener:envMEX';
case Environment.LIB
id = 'coderApp:screener:envLIB';
otherwise 
throwUnexpectedEnumMemberError( aEnvironment );
end 
end 

function id = getMessageIDForFileType( aFileType )
import coderapp.internal.screener.FileType;
switch ( aFileType )
case FileType.BuiltIn
id = 'coderApp:screener:fileTypeBuiltIn';
case FileType.MFile
id = 'coderApp:screener:fileTypeMFile';
case FileType.PFile
id = 'coderApp:screener:fileTypePFile';
case FileType.MEXFile
id = 'coderApp:screener:fileTypeMEXFile';
case FileType.MLXFile
id = 'coderApp:screener:fileTypeMLXFile';
case FileType.SLXFile
id = 'coderApp:screener:fileTypeSLXFile';
case FileType.MDLFile
id = 'coderApp:screener:fileTypeMDLFile';
case FileType.SFXFile
id = 'coderApp:screener:fileTypeSFXFile';
case FileType.Other
id = 'coderApp:screener:fileTypeOther';
otherwise 
throwUnexpectedEnumMemberError( aFileType );
end 
end 

function throwUnexpectedEnumMemberError( aEnumMember )
error( 'Unhandled enum member ''%s'' of type ''%s'' provided to coderapp.internal.screener.ui.getMessageIDForEnumMember', string( aEnumMember ), class( aEnumMember ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpRjGw69.p.
% Please follow local copyright laws when handling this file.

