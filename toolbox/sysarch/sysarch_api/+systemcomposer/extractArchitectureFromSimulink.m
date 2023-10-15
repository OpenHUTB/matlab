function extractArchitectureFromSimulink( slModelName, archModelName, nameValueArgs )

arguments
slModelName string
archModelName string
nameValueArgs.AutoArrange logical = true
nameValueArgs.ShowProgress logical = false
end 

try 
systemcomposer.internal.arch.exportToArch(  ...
char( slModelName ), char( archModelName ), pwd,  ...
nameValueArgs.AutoArrange, nameValueArgs.ShowProgress );
catch ex
throw( ex );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp0d4SCc.p.
% Please follow local copyright laws when handling this file.

