classdef ( Abstract )EventListenerService < coderapp.internal.service.AbstractService

    properties ( GetAccess = protected, SetAccess = immutable )
        MfzModel mf.zero.Model
    end

    properties ( Access = protected )

        EventListenersById
    end

    properties ( SetAccess = private )
        Started
    end

    methods ( Abstract, Access = protected )

        eventListener = createEventListener( this, opts )
    end

    methods
        function this = EventListenerService( mfzModel )

            arguments
                mfzModel( 1, 1 )mf.zero.Model
            end
            this.MfzModel = mfzModel;
            this.EventListenersById = dictionary( string.empty, coderapp.internal.event.EventListener.empty );
            this.Started = false;
        end

        function start( this )

            if ~this.Started
                this.Started = true;
            end
        end

        function shutdown( this )

            if this.Started

                for listenerKey = this.EventListenersById.keys(  )'
                    this.deleteEventListener( listenerKey );
                end
                this.Started = false;
            end
        end

        function id = register( this, varargin )



            arguments
                this( 1, 1 )
            end
            arguments( Repeating )
                varargin
            end
            if ~this.Started
                this.start(  );
            end
            eventListener = this.createEventListener( varargin{ : } );
            id = eventListener.UUID;
            this.EventListenersById( id ) = eventListener;
            eventListener.start(  );
        end

        function result = unregister( this, id )







            arguments
                this( 1, 1 )
                id{ mustBeNonempty( id ), mustBeTextScalar( id ) }
            end
            this.assertServiceStarted(  );
            result = this.deleteEventListener( id );
        end

        function delete( this )

            this.shutdown(  );
        end
    end

    methods ( Hidden )
        function result = isEventListenerAlive( this, id )







            arguments
                this( 1, 1 )
                id{ mustBeNonempty( id ), mustBeTextScalar( id ) }
            end
            this.assertServiceStarted(  );
            eventListener = this.getEventListener( id );
            result = ~isempty( eventListener ) && eventListener.Started;
        end

        function result = pauseEventListener( this, id )






            arguments
                this( 1, 1 )
                id{ mustBeNonempty( id ), mustBeTextScalar( id ) }
            end
            this.assertServiceStarted(  );
            eventListener = this.getEventListener( id );
            assert( ~isempty( eventListener ), message( "coderApp:services:eventListenerInvalid", id ) );
            if eventListener.Started
                eventListener.stop(  );
            end
            result = eventListener.Started;
        end

        function result = resumeEventListener( this, id )






            arguments
                this( 1, 1 )
                id{ mustBeNonempty( id ), mustBeTextScalar( id ) }
            end
            this.assertServiceStarted(  );
            eventListener = this.getEventListener( id );
            assert( ~isempty( eventListener ), message( "coderApp:services:eventListenerInvalid", id ) );
            if ~eventListener.Started
                eventListener.start(  );
            end
            result = eventListener.Started;
        end
    end

    methods ( Access = private )
        function eventListener = getEventListener( this, id )

            arguments
                this( 1, 1 )
                id{ mustBeNonempty( id ), mustBeTextScalar( id ) }
            end
            if ~this.EventListenersById.isKey( id )
                error( message( "coderApp:services:noMatchingEventListenerFound", id ) );
            end
            eventListener = this.EventListenersById( id );

            if ~isvalid( eventListener ) || isempty( eventListener.UUID )
                eventListener = coderapp.internal.event.EventListener.empty(  );
            end
        end


        function result = deleteEventListener( this, id )

            arguments
                this( 1, 1 )
                id{ mustBeNonempty( id ), mustBeTextScalar( id ) }
            end
            eventListener = this.getEventListener( id );
            if ~isempty( eventListener )
                if eventListener.Started
                    eventListener.stop(  );
                end
                eventListener.destroy(  );
            end
            this.EventListenersById( id ) = [  ];
            result = true;
        end
    end
end


