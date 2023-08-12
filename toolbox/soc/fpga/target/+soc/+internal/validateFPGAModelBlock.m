function validateFPGAModelBlock( fpgaModelBlock )


if ~strcmp( get_param( fpgaModelBlock, 'Parent' ), bdroot( fpgaModelBlock ) )
FPGASubsystem = get_param( fpgaModelBlock, 'Parent' );


all_blks = find_system( FPGASubsystem, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'SearchDepth', 1 );

all_blks( strcmpi( all_blks, FPGASubsystem ) ) = [  ];

allowed_blkref = { 'ModelReference', 'Inport', 'Outport' };
allowed_blk = {  };
for i = 1:numel( allowed_blkref )


p = find_system( FPGASubsystem, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'SearchDepth', 1, 'BlockType', allowed_blkref{ i } );
allowed_blk = [ allowed_blk( : )', p( : )' ];
end 
for i = 1:numel( allowed_blk )
all_blks( strcmpi( all_blks, allowed_blk{ i } ) ) = [  ];
end 
if ~isempty( all_blks )
error( message( 'soc:msgs:IllegalBlkInFPGASubsystem', all_blks{ 1 }, FPGASubsystem ) );
end 
end 




end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpZp4TAB.p.
% Please follow local copyright laws when handling this file.

