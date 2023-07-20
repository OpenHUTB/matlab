function refreshProperties(obj)









    if~obj.useAppContainer
        if obj.pPlotTimeScope
            frameWork=getFramework(obj.pTimeScope);
            fig=frameWork.Parent;

        elseif obj.pPlotSpectrum
            frameWork=getFramework(obj.pSpectrum1);
            fig=frameWork.Parent;

        elseif obj.pPlotConstellation
            frameWork=getFramework(obj.pConstellation);
            fig=frameWork.Parent;

        elseif obj.pPlotEyeDiagram
            fig=obj.pEyeDiagramFig;

        elseif obj.pPlotCCDF
            fig=obj.pCCDFFig;
        else
            fig=obj.pInfoFig;

            currDialog=obj.pParameters.CurrentDialog;
            customVisuals=currDialog.visualNames;
            for idx=1:length(customVisuals)
                if currDialog.getVisualState(customVisuals{idx})
                    fig=currDialog.getVisualFig(customVisuals{idx});
                end
            end
        end

        figure(fig);
drawnow

    end
