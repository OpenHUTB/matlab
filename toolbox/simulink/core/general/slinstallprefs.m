function [ success, msg ] = slinstallprefs














p = Simulink.Preferences.getInstance;
try 
p.Load;
success = true;
msg = '';
catch E

success = false;
msg = E.message;
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpR6SIvS.p.
% Please follow local copyright laws when handling this file.

