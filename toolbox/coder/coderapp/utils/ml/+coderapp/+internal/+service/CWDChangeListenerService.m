classdef ( Sealed )CWDChangeListenerService < coderapp.internal.service.EventListenerService

    methods
        function this = CWDChangeListenerService( mfzModel )

            arguments
                mfzModel( 1, 1 )mf.zero.Model = mf.zero.Model(  )
            end
            this = this@coderapp.internal.service.EventListenerService( mfzModel );
        end
    end

    methods ( Access = protected )
        function eventListener = createEventListener( this, opts )
            arguments
                this( 1, 1 )
                opts.callback{ mustBeValidEventListenerCallback( opts.callback, numArgsIn = 1 ) }
            end
            eventListener = coderapp.internal.event.CWDChangeEventListener( this.MfzModel );
            eventListener.Callback = opts.callback;
        end
    end
end


