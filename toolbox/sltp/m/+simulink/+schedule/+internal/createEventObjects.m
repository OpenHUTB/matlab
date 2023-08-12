function events = createEventObjects( modelHandle )




R36
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpuXq3mD.p.
% Please follow local copyright laws when handling this file.

