classdef ViewerDataExporter<slreportgen.webview.DataExporter






    methods
        function this=ViewerDataExporter()
            this=this@slreportgen.webview.DataExporter();

            this.bind('Simulink.Object',@exportElementHandler);
            this.bind('Stateflow.Object',@exportElementHandler);

            this.bind('Simulink.DataStoreWrite',@exportDataStoreReadWriteHandler);
            this.bind('Simulink.DataStoreMemory',@exportDataStoreMemoryHandler);
            this.bind('Simulink.DataStoreRead',@exportDataStoreReadWriteHandler);

            this.bind('Simulink.Goto',@exportGotoBlockHandler);
            this.bind('Simulink.From',@exportFromBlockHandler);
        end

        function preExport(this,varargin)
            preExport@slreportgen.webview.DataExporter(this,varargin{:});
        end
    end

    methods(Access=protected)
        function ret=exportElementHandler(~,~)
            ret=struct(...
            'jshandler','webview/handlers/ElementHandler'...
            );
        end

        function ret=exportFromBlockHandler(~,obj)
            ret=struct(...
            'jshandler','webview/handlers/ElementLinkHandler',...
            'destinations',{getSIDDestinations(obj,'GotoBlock')}...
            );
        end

        function ret=exportGotoBlockHandler(~,obj)
            ret=struct(...
            'jshandler','webview/handlers/ElementLinkHandler',...
            'destinations',{getSIDDestinations(obj,'FromBlocks')}...
            );
        end

        function ret=exportDataStoreReadWriteHandler(~,obj)
            dsmBlk=slreportgen.utils.findMatchingDataStoreMemoryBlock(obj);

            ret=struct(...
            'jshandler','webview/handlers/ElementLinkHandler',...
            'destinations',{[...
            Simulink.ID.getSID(dsmBlk),...
            getSIDDestinations(obj,'DSReadOrWriteSource')]}...
            );
        end

        function ret=exportDataStoreMemoryHandler(~,obj)
            ret=struct(...
            'jshandler','webview/handlers/ElementLinkHandler',...
            'destinations',{getSIDDestinations(obj,'DSReadWriteBlocks')}...
            );
        end
    end

end

function destSIDs=getSIDDestinations(obj,param)
    dests=obj.(param);
    nDests=numel(dests);

    destSIDs=cell(1,nDests);
    for i=1:nDests
        destSIDs{i}=Simulink.ID.getSID(dests(i).name);
    end
end
