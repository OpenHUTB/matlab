classdef(Hidden=true,ConstructOnLoad,UseClassDefaultsOnLoad)GraphicsExportable<handle




    methods(Hidden=true)
        function included=getIncludedContent(obj)
            included=obj;
            children=findobj(obj,'-depth',1);
            children(children==included)=[];


            for idx=1:length(children)
                alsoInclude=...
                matlab.graphics.internal.export.GraphicsExportable.getObjectsToExport(children(idx));
                if~isempty(alsoInclude)
                    included=[included,alsoInclude];
                end
            end
        end

        function excluded=getExcludedContent(obj)
            children=findobj(obj,'-depth',1);
            included=obj.getIncludedContent();
            excluded=unique(setdiff(children,included));
        end
    end

    methods(Static,Hidden=true)
        function theObjects=getObjectsToExport(hndl)




            if isa(hndl,'matlab.graphics.internal.export.GraphicsExportable')

                theObjects=hndl.getIncludedContent();
            elseif~ishandle(hndl)


                theObjects=[];
            elseif isa(hndl,'matlab.graphics.axis.AbstractAxes')
                theObjects=[hndl,hndl.Colorbar,hndl.Legend,hndl.BubbleLegend];
            elseif isa(hndl,'matlab.graphics.chart.Chart')
                theObjects=[hndl,hndl.NodeChildren'];
            else
                theObjects=hndl;
                children=findobj(hndl,'-depth',1)';
                children(children==theObjects)=[];

                for idx=1:length(children)
                    alsoInclude=...
                    matlab.graphics.internal.export.GraphicsExportable.getObjectsToExport(children(idx));
                    if~isempty(alsoInclude)
                        theObjects=[theObjects,alsoInclude];
                    end
                end

            end
            theObjects=unique(theObjects);
        end

        function theObjects=getObjectsToExclude(hndl)
            import matlab.graphics.internal.export.GraphicsExportable


            keepObjects=GraphicsExportable.getObjectsToExport(hndl);

            parentsChildren=GraphicsExportable.getObjectsToExport(hndl.Parent);
            parentsChildren(parentsChildren==hndl.Parent)=[];
            theObjects=setdiff(parentsChildren,keepObjects);
        end
    end
end
