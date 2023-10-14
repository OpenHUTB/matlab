classdef WriteRestriction < lutdesigner.data.restriction.AccessRestriction

    properties ( SetAccess = immutable )
        Reason
    end

    methods
        function this = WriteRestriction( reason )
            arguments
                reason( 1, 1 )message = 'lutdesigner:data:unspecifiedDataSource'
            end
            this.Reason = reason;
        end

        function tf = isequalExceptPeerLock( wr1, wr2 )
            arguments
                wr1 lutdesigner.data.restriction.WriteRestriction
                wr2 lutdesigner.data.restriction.WriteRestriction
            end

            wr1( arrayfun( @( wr )strcmp( wr.Reason.Identifier, 'lutdesigner:data:peerLocked' ), wr1 ) ) = [  ];
            wr2( arrayfun( @( wr )strcmp( wr.Reason.Identifier, 'lutdesigner:data:peerLocked' ), wr2 ) ) = [  ];
            tf = isequal( wr1, wr2 );
        end
    end
end

