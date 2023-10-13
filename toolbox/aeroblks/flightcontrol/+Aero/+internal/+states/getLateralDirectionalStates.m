function latstates = getLateralDirectionalStates( states )

arguments
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



