function latstates = getLateralDirectionalStates( states )





R36
states( 1, : )string
end 

expectedStates = [ "V", "P", "R", "phi" ];
expectedStateIdx = ismember( lower( states ), lower( expectedStates ) );

if any( expectedStateIdx )
latstates = states( expectedStateIdx );
else 
latstates = [  ];
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpeXLaUJ.p.
% Please follow local copyright laws when handling this file.

