classdef LayoutManagerFactory<handle





    methods(Static)
        function layoutManager=getLayoutManager(modelName,layoutType,isUpdateMode,centralBlockType,varargin)


            argParser=inputParser;
            argParser.addParameter('UseGotoFromToConnectLines','Auto',...
            @(x)any(strcmp(x,{'Auto','Never','Always'})));
            argParser.addParameter('LayoutStrategy','Layered',...
            @(x)any(strcmp(x,{'Layered','Vertical','Horizontal','Matrix'})));
            argParser.addParameter('LayoutLayers',[]);
            argParser.addParameter('DestinationSystem','',...
            @(x)ischar(x));
            argParser.parse(varargin{:});
            useGotoFromBlocks=argParser.Results.UseGotoFromToConnectLines;
            switch(argParser.Results.LayoutStrategy)

            case 'Matrix'
                destinationSystem=argParser.Results.DestinationSystem;
                layoutStrategy=autosar.mm.mm2sl.layout.MatrixLayoutStrategy(...
                destinationSystem);
            case 'Layered'
                layoutStrategy=autosar.mm.mm2sl.layout.LayeredLayoutStrategy(modelName,...
                useGotoFromBlocks,isUpdateMode,...
                centralBlockType,argParser.Results.LayoutLayers);
            otherwise
                assert(false,'invalid value for layoutStrategy: %s',argParser.Results.LayoutStrategy);
            end

            switch(layoutType)
            case 'TopModel'
                layoutManager=autosar.mm.mm2sl.layout.TopModelLayoutManager(modelName,...
                layoutStrategy);
            case 'SubSystem'
                layoutManager=autosar.mm.mm2sl.layout.SubSystemLayoutManager(modelName,...
                layoutStrategy);
            otherwise
                assert(false,'invalid value for layoutType: %s',layoutType);
            end
        end
    end
end
