function register( app )

arguments
    app( 1, 1 ){ mustBeA( app, 'comparisons.internal.App' ), mustBeNonempty, mustBeValid }
end

comparisons.internal.appstore.registerImpl( app );
end

function mustBeValid( app )
if ~app.valid(  )
    error( 'appstore:invalidapp', 'App must be valid.' );
end
end


