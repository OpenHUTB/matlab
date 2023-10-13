function lonstates = getLongitudinalStates( states )

arguments
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



