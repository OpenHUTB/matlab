function namevalueStruct = setNameValueFromPositional( namevalueStruct, name, positional )





R36
namevalueStruct struct
name( 1, 1 ){ mustBeNonzeroLengthText }
positional
end 

if ~isfield( namevalueStruct, name )
namevalueStruct.( name ) = positional;
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp4Jjzzj.p.
% Please follow local copyright laws when handling this file.

