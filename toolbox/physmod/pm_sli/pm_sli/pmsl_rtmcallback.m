function success = pmsl_rtmcallback( hdl, event )




if pm.simscape.internal.isSimscapeComponentDependent( hdl )
success = true;
return 
end 

if ~isempty( event )
rtm = PmSli.RunTimeModule;
success = rtm.canPerformOperation( hdl, event );
else 
success = true;
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpa2eBr9.p.
% Please follow local copyright laws when handling this file.

