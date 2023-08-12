function [ blks, ports, portNums ] = traceSignal( port, NVOptions )




















































R36
port
NVOptions.Nonvirtual logical = true;
end 


portType = get_param( port( 1 ), "porttype" );
if ismember( portType, [ "outport", "state" ] )

baseSearchParam = "DstPort";
else 
baseSearchParam = "SrcPort";
end 

if NVOptions.Nonvirtual
searchParam = "NonVirtual" + baseSearchParam + "s";
else 
searchParam = baseSearchParam + "Handle";
end 


thisLine = get_param( port, 'Line' );
if isscalar( thisLine )
if thisLine ==  - 1

blks =  - 1;
ports = [  ];
portNums = [  ];
else 

ports = get_param( thisLine, searchParam );
blks = get_param( ports, 'Parent' );
portNums = get_param( ports, 'PortNumber' );
end 
else 


thisLine = [ thisLine{ : } ];
nLines = numel( thisLine );
[ ports, badIdx ] = mlreportgen.utils.safeGet( thisLine, searchParam, 'get_param' );


blks = cell.empty( 0, nLines );
portNums = cell.empty( 0, nLines );
validIdx = 1:nLines;
if ~isempty( badIdx )
validIdx( badIdx ) = [  ];
nBad = numel( badIdx );
for idx = 1:nBad
ports{ badIdx( idx ) } = [  ];
blks{ badIdx( idx ) } =  - 1;
portNums{ badIdx( idx ) } = [  ];
end 
end 




for idx = validIdx
blks{ idx } = get_param( ports{ idx }, "Parent" );
portNums{ idx } = get_param( ports{ idx }, 'PortNumber' );
end 
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmprfmFxx.p.
% Please follow local copyright laws when handling this file.

