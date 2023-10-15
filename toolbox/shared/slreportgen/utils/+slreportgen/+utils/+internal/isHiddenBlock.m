function tf = isHiddenBlock( blocks, isEngineInterfaceEnabled )

arguments

    blocks

    isEngineInterfaceEnabled logical = false;
end

type = mlreportgen.utils.safeGet( blocks, 'Type', 'get_param' );
isBlock = strcmp( type, "block" );
if all( isBlock )
    nBlocks = numel( type );
    tf = false( nBlocks, 1 );


    blockHandles = mlreportgen.utils.safeGet( blocks, "Handle", 'get_param' );


    if slreportgen.utils.isModelCompiled( bdroot( blockHandles{ 1 } ) )
        if ~isEngineInterfaceEnabled
            sess = Simulink.CMI.EIAdapter( Simulink.EngineInterfaceVal.byFiat );%#ok
        end

        for idx = 1:nBlocks
            obj = get_param( blockHandles{ idx }, "Object" );
            tf( idx ) = obj.isSynthesized;
        end
    end
else
    if iscolumn( blocks )
        blocks = blocks';
    end
    blocksStr = string( blocks );
    blockStr = blocksStr( ~isBlock );
    error( message( "slreportgen:utils:error:invalidBlock", strjoin( blockStr, " " ) ) );
end
end

