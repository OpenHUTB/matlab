classdef UINode < handle
    properties ( Dependent, Transient )
        totalTime
        selfTime
        numberOfCalls
        children
        execNodes
        path
    end

    properties ( Hidden )
        realData;
    end

    properties ( Transient, Hidden )
        ch = Simulink.profiler.UINode.empty;
        en = Simulink.profiler.ExecNode.empty;
    end

    methods
        function this = UINode( realData )
            arguments
                realData = Simulink.internal.SimulinkProfiler.UIrow.empty;
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
                    this.ch( idx ) = Simulink.profiler.UINode( realChildren( idx ) );
                end
            end
            val = this.ch;
        end

        function val = get.execNodes( this )
            if isempty( this.en )
                realExecNodes = this.realData.execNodes;
                n = numel( realExecNodes );
                this.en = Simulink.profiler.ExecNode.empty;
                for idx = n: - 1:1
                    this.en( idx ) = Simulink.profiler.ExecNode( realExecNodes( idx ) );
                end
            end
            val = this.en;
        end

        function val = get.path( this )
            val = string( this.realData.objectPath );
        end

        function bool = eq( this, that )
            bool = eq( this.realData, that.realData );
        end
    end

end

