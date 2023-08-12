classdef ( Sealed )CWDChangeListenerService < coderapp.internal.service.EventListenerService





methods 
function this = CWDChangeListenerService( mfzModel )

R36
mfzModel( 1, 1 )mf.zero.Model = mf.zero.Model(  )
end 
this = this@coderapp.internal.service.EventListenerService( mfzModel );
end 
end 

methods ( Access = protected )
function eventListener = createEventListener( this, opts )




R36
this( 1, 1 )
opts.callback{ mustBeValidEventListenerCallback( opts.callback, numArgsIn = 1 ) }
end 
eventListener = coderapp.internal.event.CWDChangeEventListener( this.MfzModel );
eventListener.Callback = opts.callback;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpGlkrrQ.p.
% Please follow local copyright laws when handling this file.

