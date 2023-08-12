function itemsCell = getOpenParamViewSchemaForSlimDialog( blkFullPath )




txt.Type = 'text';
txt.Tag = 'OpenMessage';
txt.Name = sprintf( strcat( '\n', DAStudio.message( 'dastudio:propertyinspector:ParamViewNotAvailable' ), '\n' ) );
txt.WordWrap = true;

spacer.Type = 'panel';
spacer.Enabled = false;

btn.Type = 'pushbutton';
btn.Tag = 'OpenButton';
btn.Name = DAStudio.message( 'dastudio:propertyinspector:OpenParamDialog' );

useGCBP = false;
bp = gcbp;
if bp.getLength(  ) > 0
path = bp.getBlock( bp.getLength(  ) );
useGCBP = strcmp( path, strrep( blkFullPath, newline, ' ' ) );
end 

isVariant = false;

if ( strcmp( get_param( blkFullPath, 'BlockType' ), 'SubSystem' ) )
isVariant = strcmp( get_param( blkFullPath, 'Variant' ), 'on' );
end 

if useGCBP && ~isVariant
btn.MatlabMethod = 'open_blockpath';
btn.MatlabArgs = { gcbp };
else 
btn.MatlabMethod = 'open_system';
args = { blkFullPath };
if ( isVariant )
args = { args, 'parameter' };
end 
btn.MatlabArgs = args;
end 

btnPnl.Type = 'panel';
btnPnl.Items = { spacer, btn, spacer };
btnPnl.LayoutGrid = [ 1, 3 ];
btnPnl.ColStretch = [ 1, 0, 1 ];

viewPnl.Type = 'panel';
viewPnl.Items = { txt, btnPnl };

mainPnl.Type = 'panel';
mainPnl.Items = { viewPnl, spacer };
mainPnl.LayoutGrid = [ 2, 1 ];
mainPnl.RowStretch = [ 0, 1 ];

itemsCell = { mainPnl };

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBNBvcQ.p.
% Please follow local copyright laws when handling this file.

