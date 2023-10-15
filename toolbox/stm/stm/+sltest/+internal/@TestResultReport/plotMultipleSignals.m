function plotMultipleSignals( obj, filePath, signalList, numRows, numCols, lastPlottedSigIdx )

arguments
obj;
filePath( 1, : )char{ mustBeNonempty };
signalList sltest.testmanager.ReportUtility.Signal;
numRows( 1, 1 )double;
numCols( 1, 1 )double;
lastPlottedSigIdx( 1, 1 )double;
end 

if stm.internal.util.getFeatureFlag( 'STMSnapshotInReport' ) > 0
snap = Simulink.sdi.CustomSnapshot;
if ( lastPlottedSigIdx + ( numRows * numCols ) <= length( signalList ) )
snap.Rows = numRows;
snap.Columns = numCols;
else 
signalsLeft = length( signalList ) - lastPlottedSigIdx;
if ( signalsLeft <= numCols )
snap.Rows = 1;
snap.Columns = signalsLeft;
else 
snap.Rows = ceil( signalsLeft / numCols );
snap.Columns = numCols;
end 
end 

sigIdx = 1;
for i = 1:numRows
for j = 1:numCols
if ( sigIdx + lastPlottedSigIdx <= length( signalList ) )
sigId = signalList( sigIdx + lastPlottedSigIdx ).TopSignal.ID;
snap.plotOnSubPlot( i, j, sigId, true );
sigIdx = sigIdx + 1;
else 
break ;
end 
end 
end 
snap.snapshot( "to", "file", "filename", filePath );
else 
figureH = figure( 'Visible', 'off', 'Renderer', 'painters' );

for i = 1:numRows * numCols
if ( i + lastPlottedSigIdx <= length( signalList ) )
subplot( numRows, numCols, i );
sig = signalList( i + lastPlottedSigIdx ).TopSignal;
sltest.internal.TestResultReport.plotOneFigure( sig, sig.signalLabel );
title( '' );
else 
break ;
end 
end 
print( figureH, '-dpng', '-r100', filePath );
close( figureH );
end 


end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpuPNnp5.p.
% Please follow local copyright laws when handling this file.

