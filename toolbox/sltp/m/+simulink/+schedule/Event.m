classdef Event



















    properties ( Access = private )
        Id( 1, 1 )int64 =  - 1
    end

    properties









        Name( 1, 1 )string
    end

    properties









        Scope( 1, 1 )simulink.schedule.EventScope
    end

    properties ( SetAccess = private )





        Broadcasters( :, 1 )string
    end

    properties










        Listeners( :, 1 )string
    end

    properties ( Access = private )

        Version( 1, 1 )double = 2.0
    end

    methods
        function tf = eq( s1, s2 )








            tf = arrayfun( @( a, b )eqElement( a, b ), s1, s2 );
        end

        function tf = ne( s1, s2 )








            tf = ~eq( s1, s2 );
        end

        function tf = isequal( s1, s2 )
            if size( s1 ) == size( s2 )
                tf = all( eq( s1, s2 ) );
            else
                tf = false;
            end
        end
    end

    methods ( Hidden = true )
        function this = Event( name, id, modelHandle )
            arguments
                name( 1, 1 )string = ""
                id( 1, 1 )int64 =  - 1
                modelHandle( 1, 1 )double =  - 1
            end

            if id >= 0
                assert( name == "", "Name must be empty when using id" );
                assert( modelHandle ~=  - 1, "model handle must be provided when using id" );
                em = sltp.EventManager( modelHandle );

                sids = em.getSenderSIDs( id );
                allBlocks = cellfun(  ...
                    @( x )simulink.schedule.Event.safeGetBlockFromSID( modelHandle, x ),  ...
                    sids,  ...
                    'UniformOutput', false );
                allBlocks( strcmp( allBlocks, char ) ) = [  ];

                this.Id = id;
                this.Name = em.getEventName( id );
                this.Broadcasters = em.getSenderTasks( id );
                this.Listeners = sort( em.getEventTasks( id ) );
                this.Scope = simulink.schedule.EventScope.toExternalScopeType( em.getEventScope( id ) );
            else
                this.Name = name;
            end
        end

        function applyToModel( this, modelHandle )
            arguments
                this( 1, 1 )simulink.schedule.Event
                modelHandle( 1, 1 )double
            end

            eventManager = sltp.EventManager( modelHandle );




            eventId = eventManager.getEvent( this.Name );

            internalScopeType = simulink.schedule.EventScope.toInternalScopeType( this.Scope );
            if ~isequal( eventManager.getEventScope( eventId ), internalScopeType )
                eventManager.setEventScope( eventId, internalScopeType );
            end
        end

        function out = saveobj( this )
            out = struct(  ...
                'Name', { this.Name },  ...
                'Scope', { this.Scope },  ...
                'Broadcasters', { this.Broadcasters },  ...
                'Listeners', { this.Listeners },  ...
                'Version', { this.Version } );
        end
    end

    methods ( Access = private )
        function tf = eqElement( a, b )
            tf = isequal( a.Name, b.Name ) &  ...
                isequal( a.Scope, b.Scope ) &  ...
                isequal( a.Broadcasters, b.Broadcasters ) &  ...
                isequal( a.Listeners, b.Listeners );
        end
    end

    methods ( Static = true, Access = private )
        function block = safeGetBlockFromSID( model, sid )
            try
                block = Simulink.ID.getFullName( [ get_param( model, 'Name' ), ':', char( sid ) ] );
            catch e




                if strcmp( e.identifier, 'Simulink:utility:objectDestroyed' )
                    block = char;
                else
                    e.rethrow(  );
                end
            end
        end

        function obj = loadobj( in )
            obj = simulink.schedule.Event(  );


            if in.Version < 2.0
                in.Scope = simulink.schedule.EventScope.Scoped;
                in.Version = 2.0;
            end

            obj.Name = in.Name;
            obj.Scope = in.Scope;
            obj.Broadcasters = in.Broadcasters;
            obj.Listeners = in.Listeners;
            obj.Version = in.Version;
        end
    end
end

