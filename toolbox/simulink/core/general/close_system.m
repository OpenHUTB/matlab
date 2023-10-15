function close_system( varargin )
































try
    if nargin == 0




        i_close_system( gcs );
    else
        i_close_system( varargin{ : } );
    end
catch E
    throw( E );
end

end

function i_close_system( sys, arg2, opts )

arguments
    sys{ handlesOrStrings };
    arg2{ stringsOrNumberOrEmpty } = [  ];
    opts.SkipCloseFcn{ logicalOrOnOff } = false;
    opts.CloseReferencedModels{ logicalOrOnOff } = true;
    opts.AllowPrompt{ logicalOrOnOff } = false;

    opts.ErrorIfShadowed{ logicalOrOnOff } = false;
    opts.OverwriteIfChangedOnDisk{ logicalOrOnOff } = false;
    opts.SaveModelWorkspace{ logicalOrOnOff } = false;
    opts.BreakUserLinks{ logicalOrOnOff } = false;
    opts.BreakToolboxLinks{ logicalOrOnOff } = false;
    opts.BreakLinks{ logicalOrOnOff } = false;
    opts.BreakAllLinks{ logicalOrOnOff } = false;
    opts.SaveDirtyReferencedModels{ logicalOrOnOff } = false;
    opts.SkipSaveFcns{ logicalOrOnOff } = false;
end



need_to_save = false;
discard_changes = false;
newsys = [  ];

if isnumeric( sys )

    sys = get_param( sys, 'Handle' );
    if iscell( sys )
        sys = cell2mat( sys );
    end
else


    sys = string( sys );
end

if ~isempty( arg2 )

    if isnumeric( arg2 ) || islogical( arg2 )
        if double( arg2 ) == 1
            need_to_save = true;

            opts.SaveModelWorkspace = true;
        else
            discard_changes = true;
        end
    else
        newsys = string( arg2 );
        if numel( newsys ) ~= numel( sys )
            error( message( 'Simulink:Commands:InputArgSizeMismatch' ) );
        end
        need_to_save = true;
    end
end

opts.SkipCloseFcn = i_onoff( opts.SkipCloseFcn );
opts.CloseReferencedModels = i_onoff( opts.CloseReferencedModels );
opts.AllowPrompt = i_onoff( opts.AllowPrompt );

if need_to_save
    ssopts = rmfield( opts, [ "SkipCloseFcn", "CloseReferencedModels" ] );
    ssargs = [ fieldnames( ssopts ), struct2cell( ssopts ) ]';
    filenames = save_system( sys, newsys, ssargs{ : } );
    if isstring( newsys ) && isstring( sys )


        [ ~, sys ] = slfileparts( filenames );
    end
end

opts = struct( 'DiscardChanges', discard_changes || need_to_save,  ...
    'SkipCloseFcn', opts.SkipCloseFcn,  ...
    'CloseReferencedModels', opts.CloseReferencedModels,  ...
    'AllowPrompt', opts.AllowPrompt );

slInternal( 'close_system', sys, opts );

end




function handlesOrStrings( v )
if isnumeric( v )
    return ;
end
if isstring( v ) || ischar( v ) || iscellstr( v )
    return ;
end
if iscell( v )

    if all( cellfun( @( x )isstring( x ) || ischar( x ), v ) )
        return ;
    end
end
error( message( 'Simulink:Commands:InvSimulinkObjSpecifier' ) );
end




function stringsOrNumberOrEmpty( v )
if isempty( v )
    return ;
elseif isnumeric( v ) || islogical( v )
    v = double( v );
    if numel( v ) ~= 1
        error( message( 'Simulink:Commands:InputArgSizeMismatch' ) );
    end
    if v ~= 1 && v ~= 0
        error( message( 'Simulink:Commands:InvSaveOption' ) );
    end
elseif ~isstring( v ) && ~ischar( v ) && ~iscellstr( v )
    error( message( 'Simulink:Commands:SaveSysBadSaveAsName' ) );
end

end




function logicalOrOnOff( v )
if islogical( v ) && isscalar( v )
    return ;
end
if isnumeric( v ) && isscalar( v )
    if v == 0 || v == 1
        return ;
    end
end
if isStringScalar( v ) || ischar( v )
    if v == "on" || v == "off"
        return ;
    end
end
error( message( 'Simulink:Commands:MustBeLogicalOrOnOff' ) );
end


function out = i_onoff( val )

if islogical( val )
    out = val;
elseif isnumeric( val )
    out = logical( val );
else
    s = string( val );
    out = s == "on";
end
end


