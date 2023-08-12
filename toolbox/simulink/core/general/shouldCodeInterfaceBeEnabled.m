function result = shouldCodeInterfaceBeEnabled( simMode )




if any( strcmpi( simMode, { 'Software-in-the-loop (SIL)',  ...
'Processor-in-the-loop (PIL)' } ) )
result = true;
else 
result = false;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpJ80OQi.p.
% Please follow local copyright laws when handling this file.

