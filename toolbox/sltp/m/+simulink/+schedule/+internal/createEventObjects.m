function events = createEventObjects( modelHandle )

arguments
    modelHandle( 1, 1 )double = 0
end

em = sltp.EventManager( modelHandle );
ids = em.getEvents(  );
events = simulink.schedule.Event.empty;

for idx = length( ids ): - 1:1
    events( idx ) = simulink.schedule.Event( "", ids( idx ), modelHandle );
end

[ ~, index ] = sort( [ events.Name ] );
events = events( index );
end

