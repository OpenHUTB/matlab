function spars = simrfV2_sparm_from_ratmodel( ratmod, nports, freqs )





freqsLen = length( freqs );


Poles = ratmod.A;
Residues = ratmod.C;
DF = ratmod.D;

if isempty( Poles )


Poles( 1:nports ^ 2, 1 ) = { 1 + 1i };
Residues( 1:nports ^ 2, 1 ) = { 0 };
end 
if isempty( DF )
DF( 1:nports ^ 2, 1 ) = { 0 };
end 
if ~iscell( DF )
DF = num2cell( DF );
end 

DFshape = reshape( DF, nports, [  ] );


spars = zeros( nports, nports, freqsLen );


[ row_idx, col_idx ] = ind2sub( [ nports, nports ], 1:nports ^ 2 );
for idx = 1:nports ^ 2
hRatMod = rfmodel.rational( 'A', Poles{ idx }, 'C', Residues{ idx },  ...
'D', DFshape{ idx } );
spars( row_idx( idx ), col_idx( idx ), : ) = freqresp( hRatMod, freqs );
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpo5VWvi.p.
% Please follow local copyright laws when handling this file.

