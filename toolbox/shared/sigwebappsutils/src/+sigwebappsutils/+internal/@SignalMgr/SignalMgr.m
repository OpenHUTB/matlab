

classdef SignalMgr<handle




    properties(Access=private)
WebscopesStreamingSource
    end

    methods

        function this=SignalMgr(webscopesStreamingSource)
            this.WebscopesStreamingSource=webscopesStreamingSource;
        end


        function signalIDs=createSignalIDs(this,numberOfSignals)
            signalIDs=string(this.WebscopesStreamingSource.addSignal(numberOfSignals));
        end

        function signalIDs=removeSignalIDs(this,signalIDs)
            signalIDs=string(this.WebscopesStreamingSource.removeSignal(signalIDs));
        end

        function release(this)
            this.WebscopesStreamingSource.release();
        end
    end
end