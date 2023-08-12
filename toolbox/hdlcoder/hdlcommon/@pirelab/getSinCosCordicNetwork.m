function hNewNet = getSinCosCordicNetwork( hN, hInSignals, hOutSignals, cordicInfo, outputMode, usePipelines, customLatency, latencyStrategy )














switch lower( outputMode )
case 'sin'
hNewNet = hdlarch.cordic.getSinCordicNetwork( hN, hInSignals, hOutSignals, cordicInfo, usePipelines, customLatency, latencyStrategy );
case 'cos'
hNewNet = hdlarch.cordic.getCosCordicNetwork( hN, hInSignals, hOutSignals, cordicInfo, usePipelines, customLatency, latencyStrategy );
case 'sincos'
hNewNet = hdlarch.cordic.getSinCosCordicNetwork( hN, hInSignals, hOutSignals, cordicInfo, usePipelines, customLatency, latencyStrategy );
case 'pol2cart'
hNewNet = hdlarch.cordic.getPol2CartCordicNetwork( hN, hInSignals, hOutSignals, cordicInfo );
otherwise 
error( message( 'hdlcommon:hdlcommon:UnsupportedTrigAlgorithm', outputMode, cordicInfo.networkName ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp9OQGHf.p.
% Please follow local copyright laws when handling this file.

