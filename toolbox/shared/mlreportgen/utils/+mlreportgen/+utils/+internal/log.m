function state = log( newState )

arguments
    newState logical = logical.empty(  );
end

persistent STATE

mlock(  );
if isempty( STATE )
    STATE = false;
end

state = STATE;
if ~isempty( newState )
    STATE = newState;
end
end

