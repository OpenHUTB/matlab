function ok = slchangelog( mdlname, testmode )




if nargin == 0
mdlname = bdroot;
end 

dialog_provider = Simulink.ChangeLogDialog( mdlname );
d = DAStudio.Dialog( dialog_provider );

if nargin < 2 || ~testmode


waitfor( d, 'dialogTag', '' );
end 


ok = dialog_provider.ContinueSaving;

end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpYMy4Y_.p.
% Please follow local copyright laws when handling this file.

