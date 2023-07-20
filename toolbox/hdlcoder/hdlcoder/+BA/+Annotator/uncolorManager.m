


classdef uncolorManager<handle
    properties(SetAccess=private,GetAccess=private)
        coloredObjects;
        connectingNets;
        textBlocks;
        annotatedPorts;
    end

    methods


        function print(thisMgr)
            fprintf('Printing Components\n');
            for i=1:length(thisMgr.coloredObjects)
                compHandle=thisMgr.coloredObjects(i);
                o=get_param(compHandle,'Object');
                path=o.Path;
                compName=o.Name;
                fprintf(1,'C(%d) = %s\n',i,[path,'/',compName]);
            end

            fprintf('Printing Coordinates of the connections\n');
            for i=1:length(thisMgr.connectingNets)
                pos=get_param(thisMgr.connectingNets(i),'Position');
                fprintf(1,'N(%d) = [%d, %d]\n',i,pos(1),pos(2));
            end

            fprintf('Printing text blocks\n');
            for i=1:length(thisMgr.textBlocks)

                fprintf(1,'T(%d) = %s\n',i,thisMgr.textBlocks{i});
            end
        end


        function addToColoredObjects(thisMgr,object)
            thisMgr.coloredObjects=[thisMgr.coloredObjects,object];
        end


        function addToTextBlocks(thisMgr,block)
            thisMgr.textBlocks{end+1}=block;
        end


        function addToConnectingNets(thisMgr,net)
            thisMgr.connectingNets=[thisMgr.connectingNets,net];
        end


        function addToAnnotatedPorts(thisMgr,port)
            thisMgr.annotatedPorts=[thisMgr.annotatedPorts,port];
        end


        function resetColors(thisMgr)
            for i=1:length(thisMgr.coloredObjects)
                hilite_system(thisMgr.coloredObjects(i),'none');
            end
            thisMgr.coloredObjects=[];

            for i=1:length(thisMgr.connectingNets)
                hilite_system(thisMgr.connectingNets(i),'none');
            end
            thisMgr.connectingNets=[];
        end


        function removeAnnotations(thisMgr)
            for i=1:length(thisMgr.annotatedPorts)
                Simulink.AnnotationGateway.Annotate(thisMgr.annotatedPorts(i),'');
            end
        end



        function found=findObject(thisMgr,o)
            found=false;
            for i=1:length(thisMgr.coloredObjects)
                if thisMgr.coloredObjects(i)==o
                    found=true;
                    return;
                end
            end
        end
    end
end