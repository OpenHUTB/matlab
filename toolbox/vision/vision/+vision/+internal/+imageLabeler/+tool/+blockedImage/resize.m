function bimResized = resize( bim, outSize, namedargs )

arguments
    bim( 1, 1 )blockedImage
    outSize( 1, 2 )double{ mustBeNonempty, mustBePositive, mustBeFinite }
    namedargs.Level double{ mustBePositive, mustBeFinite, mustBeScalarOrEmpty } = [  ];
end

numLevels = size( bim.Size, 1 );
if isempty( namedargs.Level ) || namedargs.Level > numLevels


    if numLevels == 1
        level = 1;
    else


        numRows = bim.Size( :, 1 );
        [ ~, level ] = min( abs( numRows - outSize( 1 ) ) );
    end

else
    validateattributes( namedargs.Level, { 'double' }, '>=', 0, '<=', numLevels, mfilename, 'LEVEL' );
    level = namedargs.Level;
end

imgSize = bim.Size( level, 1:2 );

resizeFactor = outSize( 1 ) / imgSize( 1 );

bimResized = apply( bim, @( bstruct )resizeBlock( bstruct, resizeFactor ),  ...
    'Adapter', images.blocked.InMemory,  ...
    'PadPartialBlocks', false,  ...
    'Level', level,  ...
    'DisplayWaitbar', false );

end

function out = resizeBlock( bstruct, resizeFactor )
out = imresize( bstruct.Data, resizeFactor, 'nearest' );



drawnow limitrate
end

