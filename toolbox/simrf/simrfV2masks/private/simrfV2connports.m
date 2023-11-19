function simrfV2connports( this, block )

for ii = 1:numel( this )

DstBlk = [ block, '/', this( ii ).DstBlk ];
phDstBlk = get_param( DstBlk, 'PortHandles' );

SrcBlk = [ block, '/', this( ii ).SrcBlk ];
phSrcBlk = get_param( SrcBlk, 'PortHandles' );

SrcPorts = phSrcBlk.( this.SrcBlkPortStr );
DstPorts = phDstBlk.( this.DstBlkPortStr );
add_line( block, SrcPorts( this.SrcBlkPortIdx ),  ...
DstPorts( this.DstBlkPortIdx ), 'autorouting', 'on' )

end 

end 


