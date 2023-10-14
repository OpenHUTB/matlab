function addKeyValuePairs( mfzModel, collection, varargin )
arguments
    mfzModel( 1, 1 )mf.zero.Model
    collection( 1, 1 )
end
arguments( Repeating )
    varargin
end

if numel( varargin ) == 1 && isstruct( varargin{ 1 } )
    keys = fieldnames( varargin{ 1 } );
    values = struct2cell( varargin{ 1 } );
else
    keys = varargin( 1:2:end  );
    values = varargin( 2:2:end  );
    if numel( keys ) ~= numel( values )
        error( 'Number of keys must match the number of values' );
    end
end

txn = mfzModel.beginTransaction(  );
try
    for i = 1:numel( keys )
        key = keys{ i };
        value = values{ i };
        kvp = collection.getByKey( key );
        if ~isempty( kvp )
            kvp.destroy(  );
        end
        collection.add( codergui.internal.form.createKeyValuePair( mfzModel, key, value ) );
    end
    txn.commit(  );
catch me
    txn.rollBack(  );
    me.rethrow(  );
end
end


