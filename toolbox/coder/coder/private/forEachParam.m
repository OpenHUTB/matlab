





function varargout = forEachParam( funcHandle, opts )
arguments
    funcHandle( 1, 1 )function_handle = @( param, varargin )param
    opts.Target{ mustBeA( opts.Target, [ "java.lang.Object", "char", "string" ] ) } = ''
    opts.ConfigType coder.Config{ mustBeScalarOrEmpty( opts.ConfigType ) } = coder.Config.empty(  )
    opts.ProductionFilter{ mustBeText( opts.ProductionFilter ) } = {  }
    opts.ArgTypes{ mustBeMember( opts.ArgTypes, [ "param", "key", "mapping" ] ) } = 'param'
    opts.ExtraArgs cell = {  }
    opts.Whitelist{ mustBeText( opts.Whitelist ) } = {  }
    opts.Blacklist{ mustBeText( opts.Blacklist ) } = {  }
    opts.MetaIndex( 1, 1 )coderapp.internal.coderconfig.ConfigMetadataIndex =  ...
        coderapp.internal.coderconfig.ConfigMetadataIndex( ForProject = true )
end

target = projectArgToTarget( opts.Target );
metaIndex = opts.MetaIndex;

if isempty( opts.ConfigType )
    profile = '';
elseif isa( opts.ConfigType, 'coder.MexCodeConfig' )
    profile = 'profile.mex';
else
    profile = 'profile.c';
end

oldOrderedKeys = metaIndex.OrderedOldKeys;
paramCell = cell( numel( oldOrderedKeys ), 2 );
pIdx = 0;


paramSets = target.getParamSets(  );
iterator = paramSets.iterator(  );
while iterator.hasNext(  )
    paramSet = iterator.next(  );
    params = paramSet.getParams(  );
    paramIterator = params.iterator(  );
    while paramIterator.hasNext(  )
        param = paramIterator.next(  );
        include = false;
        if isempty( profile )
            include = true;
        else
            profKeys = param.getProfileKeys(  );
            if profKeys.isEmpty(  ) || profKeys.contains( profile )
                include = true;
            end
        end
        if include
            pIdx = pIdx + 1;
            paramCell( pIdx, : ) = { char( param.getKey(  ) ), param };
        end
    end
end


if ~isempty( opts.Whitelist )
    paramCell = paramCell( ismember( paramCell( :, 1 ), opts.Whitelist ), : );
end
if ~isempty( opts.Blacklist )
    paramCell( ismember( paramCell( :, 1 ), opts.Blacklist ), : ) = [  ];
end


paramCell( ~ismember( paramCell( :, 1 ), oldOrderedKeys ), : ) = [  ];
if ~isempty( opts.ProductionFilter )
    prodKeyFilter = cellfun( @( prodKey )metaIndex.getSubObjectByProdKey( prodKey ).MappedOldKeys,  ...
        cellstr( opts.ProductionFilter ), 'UniformOutput', false );
else
    prodKeyFilter = arrayfun( @( sub )sub.MappedOldKeys, metaIndex.SubObjects, 'UniformOutput', false );
end
paramCell( ~ismember( paramCell( :, 1 ), vertcat( prodKeyFilter{ : } ) ), : ) = [  ];


[ ~, order ] = ismember( paramCell( :, 1 ), oldOrderedKeys );
[ ~, order ] = sort( order );
paramCell = [ paramCell( order == 0, : );paramCell( order( order ~= 0 ), : ) ];

hasOutput = nargout( funcHandle ) ~= 0;
if hasOutput
    varargout{ 1 } = cell( 1, size( paramCell, 1 ) );
end
if isempty( paramCell )
    return
end


argTypes = unique( cellstr( opts.ArgTypes ), 'stable' );
[ ~, argIdx ] = ismember( [ "param", "key", "mapping" ], argTypes );
paramIdx = argIdx( 1 );
keyIdx = argIdx( 2 );
mappingIdx = argIdx( 3 );
argTemplate = cell( 1, nnz( argIdx ) );

for i = 1:size( paramCell, 1 )
    paramObj = paramCell{ i, 2 };
    paramKey = char( paramObj.getKey(  ) );

    owner = metaIndex.owner( metaIndex.oldToNew( paramKey ) );
    mapping = metaIndex.getSubObjectByProdKey( owner ).oldKeyToProp( paramKey );

    if ~isempty( opts.ConfigType ) && strcmp( owner, 'config' ) && ~isprop( opts.ConfigType, mapping )
        continue
    end


    if paramIdx
        argTemplate{ paramIdx } = paramObj;
    end
    if keyIdx
        argTemplate{ keyIdx } = paramKey;
    end
    if mappingIdx
        argTemplate{ mappingIdx } = mapping;
    end
    if hasOutput
        varargout{ 1 }{ i } = funcHandle( argTemplate{ : }, opts.ExtraArgs{ : } );
    else
        funcHandle( argTemplate{ : }, opts.ExtraArgs{ : } );
    end
end
end


function target = projectArgToTarget( javaArg )
switch class( javaArg )
    case 'com.mathworks.project.impl.model.Project'
        target = javaArg.getConfiguration(  ).getTarget(  );
    case 'com.mathworks.project.impl.model.Configuration'
        target = javaArg.getTarget(  );
    case 'com.mathworks.project.impl.model.Target'
        target = javaArg;
    case { 'char', 'string' }
        if isempty( javaArg )
            target = com.mathworks.toolbox.coder.app.UnifiedTargetFactory.getUnifiedTarget(  );
        else
            com.mathworks.project.impl.plugin.PluginManager.allowMatlabThreadUse(  );
            target = com.mathworks.project.impl.plugin.PluginManager.getTarget( javaArg );
        end
        if isempty( target )
            error( 'No target with an ID of "%s was found"', javaArg );
        end
    otherwise
        error( 'Unexpected javaProjArg argument type: %s', class( javaArg ) );
end
end


