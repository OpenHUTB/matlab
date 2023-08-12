function updateConfig( obj )
obj.LastConfig = obj.Config;
obj.Config = rtw.report.Config( get_param( obj.getActiveModelName, 'handle' ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBVcKKK.p.
% Please follow local copyright laws when handling this file.

