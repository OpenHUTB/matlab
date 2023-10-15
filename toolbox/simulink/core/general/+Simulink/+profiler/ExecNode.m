



classdef ExecNode < handle
    properties ( Dependent, Transient )
        totalTime
        selfTime
        numberOfCalls
        location
        children
        objectPath
    end

    properties ( Transient, Hidden )
        ch = Simulink.profiler.ExecNode.empty;
    end

    properties ( Hidden )
        realData;
    end

    methods
        function this = ExecNode( realData )
            arguments
                realData = Simulink.internal.SimulinkProfiler.ExecRow.empty;
            end
            this.realData = realData;
        end

        function val = get.totalTime( this )
            val = this.realData.totalTime;
        end

        function val = get.selfTime( this )
            val = this.realData.selfTime;
        end

        function val = get.numberOfCalls( this )
            val = double( this.realData.numCalls );
        end

        function val = get.children( this )
            if isempty( this.ch )
                realChildren = this.realData.children;
                n = numel( realChildren );
                for idx = n: - 1:1
                    this.ch( idx ) = Simulink.profiler.ExecNode( realChildren( idx ) );
                end
            end
            val = this.ch;
        end

        function val = get.objectPath( this )
            val = string( this.realData.objectPath );
        end

        function val = get.location( this )
            val = string( this.realData.locationName );
        end

        function bool = eq( this, that )
            bool = eq( this.realData, that.realData );
        end
    end
end
