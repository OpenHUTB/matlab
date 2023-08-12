function endBlk = tblpresrc( startBlk, startInportIdx )






























allPorts = get_param( startBlk, 'PortHandles' );
if strcmp( get_param( startBlk, 'BlockType' ), 'Interpolation_n-D' ) &&  ...
strcmp( get_param( startBlk, 'RequireIndexFractionAsBus' ), 'off' )
useInport = startInportIdx * 2 - 1;
else 
useInport = startInportIdx;
end 
if useInport > length( allPorts.Inport )
error( 'simulink:tblpresrc:InvalidIndex',  ...
'Simulink:Engine:RTI_InvalidInputPortIdx2',  ...
useInport, startBlk, length( allPorts.Inport ) );
else 
endBlk = [  ];
end 
inportH = allPorts.Inport( useInport );
lineH = get_param( inportH, 'Line' );
if ishandle( lineH )
tracedPort = get_param( lineH, 'NonVirtualSrcPorts' );
if ~isempty( tracedPort )
tracedPort = tracedPort( 1 );
else 
return ;
end 
if ishandle( tracedPort )
endBlk = get_param( tracedPort, 'Parent' );
blkType = get_param( endBlk, 'BlockType' );
if ~( strcmp( blkType, 'PreLookup' ) ||  ...
( strcmp( blkType, 'S-Function' ) &&  ...
strcmp( get_param( endBlk, 'FunctionName' ), 'sfun_idxsearch' ) ) )

endBlk = [  ];
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmphg62Tb.p.
% Please follow local copyright laws when handling this file.

