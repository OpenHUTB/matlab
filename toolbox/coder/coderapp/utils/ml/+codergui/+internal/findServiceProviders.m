function results = findServiceProviders( packageName, opts )

arguments
    packageName char{ mustBeTextScalar( packageName ) }
    opts.FindFactories( 1, 1 )logical = true
    opts.FindClasses( 1, 1 )logical = true
    opts.StaticFactoryMethod char{ mustBeTextScalar( opts.StaticFactoryMethod ) } = ''
    opts.Invoke( 1, 1 )logical = false
    opts.Args cell = {  }
    opts.Validator function_handle{ mustBeScalarOrEmpty( opts.Validator ) } = function_handle.empty(  )
    opts.FilterPredicate function_handle{ mustBeScalarOrEmpty( opts.FilterPredicate ) } = function_handle.empty(  )
    opts.FilterClass char{ mustBeTextScalar( opts.FilterClass ) } = ''
end

persistent cache;
if ~isa( cache, 'containers.Map' )
    cache = containers.Map(  );
end

package = meta.package.fromName( packageName );
results = {  };

if isempty( package )
    return
end

if opts.FindFactories
    for i = 1:numel( package.FunctionList )
        factory = [ packageName, '.', package.FunctionList( i ).Name ];
        if opts.Invoke
            processInstances( feval( factory, opts.Args{ : } ) );
        else
            results{ end  + 1 } = factory;%#ok<*AGROW>
        end
    end
end

if opts.FindClasses
    for i = 1:numel( package.ClassList )
        implClass = package.ClassList( i ).Name;
        if opts.Invoke
            if ~isempty( opts.StaticFactoryMethod ) && hasStaticFactory( implClass, opts.StaticFactoryMethod )
                processInstances( feval( [ implClass, '.', opts.StaticFactoryMethod ], opts.Args{ : } ) );
            else
                processInstances( feval( implClass, opts.Args{ : } ) );
            end
        else
            results{ end  + 1 } = implClass;
        end
    end
end


    function processInstances( instance )
        if iscell( instance )
            for ii = 1:numel( instance )
                processInstances( instance{ ii } );
            end
        elseif ~isempty( instance )
            if ~isempty( opts.Validator ) && ~opts.Validator( instance )
                error( 'Invalid service: %s', instance );
            elseif ( isempty( opts.FilterClass ) || isa( instance, opts.FilterClass ) ) &&  ...
                    ( isempty( opts.FilterPredicate ) || opts.FilterPredicate( instance ) )
                results{ end  + 1 } = instance;
            end
        end
    end
end



function hasIt = hasStaticFactory( className, methodName )
metaClass = meta.class.fromName( className );
metaMethods = metaClass.MethodList;
hasIt = any( [ metaMethods.Static ] & strcmp( { metaMethods.Name }, methodName ) );
end


