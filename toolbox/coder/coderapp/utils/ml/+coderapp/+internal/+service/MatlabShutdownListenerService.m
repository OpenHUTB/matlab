classdef ( Sealed )MatlabShutdownListenerService < coderapp.internal.service.EventListenerService





methods 
function this = MatlabShutdownListenerService( mfzModel )

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
opts.callback{ mustBeValidEventListenerCallback( opts.callback, numArgsIn = 0 ) }
end 
eventListener = coderapp.internal.event.MatlabPreShutdownEventListener( this.MfzModel );
eventListener.Callback = opts.callback;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXLV_xx.p.
% Please follow local copyright laws when handling this file.

