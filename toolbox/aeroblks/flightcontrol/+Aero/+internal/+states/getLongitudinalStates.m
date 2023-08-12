function lonstates = getLongitudinalStates( states )





R36
states( 1, : )string
end 

expectedStates = [ "U", "W", "Q", "theta" ];
expectedStateIdx = ismember( lower( states ), lower( expectedStates ) );

if any( expectedStateIdx )
lonstates = states( expectedStateIdx );
else 
lonstates = [  ];
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpq3Fxxt.p.
% Please follow local copyright laws when handling this file.

