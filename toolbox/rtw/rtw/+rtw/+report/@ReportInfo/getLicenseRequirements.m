function lics = getLicenseRequirements( obj )

if obj.IsERTTarget
lics = { 'Matlab_Coder', 'Real-Time_Workshop', 'RTW_Embedded_Coder' };
else 
lics = { 'Matlab_Coder', 'Real-Time_Workshop' };
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpuOuHvR.p.
% Please follow local copyright laws when handling this file.

