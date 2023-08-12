function root = slroot






persistent ROOT;
mlock


if isempty( ROOT )
ROOT = Simulink.Root;
end 
root = ROOT;

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpQp5EiP.p.
% Please follow local copyright laws when handling this file.

