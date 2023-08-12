function prevState = enableCache( state )


















R36
state logical = logical.empty(  );
end 

prevState = slreportgen.webview.internal.CacheManager.instance(  ).isEnabled(  );

if ~isempty( state )
slreportgen.webview.internal.CacheManager.instance(  ).enable( state );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpa0rgUX.p.
% Please follow local copyright laws when handling this file.

