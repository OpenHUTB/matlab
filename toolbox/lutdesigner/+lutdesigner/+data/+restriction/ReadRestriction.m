classdef ReadRestriction < lutdesigner.data.restriction.AccessRestriction

    properties ( SetAccess = immutable )
        Reason
    end

    methods
        function this = ReadRestriction( reason )
            arguments
                reason( 1, 1 )message = 'lutdesigner:data:unspecifiedDataSource'
            end
            this.Reason = reason;
        end
    end
end


