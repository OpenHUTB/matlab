classdef EventScope

    enumeration


        Scoped

        Global
    end

    methods ( Static = true, Hidden = true )
        function externalScopeType = toExternalScopeType( internalScopeType )
            arguments
                internalScopeType( 1, 1 )sltp.mm.core.EventScope
            end

            switch internalScopeType
                case sltp.mm.core.EventScope.Global
                    externalScopeType = simulink.schedule.EventScope.Global;
                case sltp.mm.core.EventScope.Scoped
                    externalScopeType = simulink.schedule.EventScope.Scoped;
                otherwise
                    assert( false, "Internal error. Unsupported event scope type detected" );
            end
        end

        function internalScopeType = toInternalScopeType( externalScopeType )
            arguments
                externalScopeType( 1, 1 )simulink.schedule.EventScope
            end

            switch externalScopeType
                case simulink.schedule.EventScope.Global
                    internalScopeType = sltp.mm.core.EventScope.Global;
                case simulink.schedule.EventScope.Scoped
                    internalScopeType = sltp.mm.core.EventScope.Scoped;
                otherwise
                    assert( false, "Internal error. Unsupported event scope type detected" );
            end
        end
    end
end
