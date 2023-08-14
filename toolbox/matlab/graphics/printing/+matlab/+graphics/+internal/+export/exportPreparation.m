function pj=exportPreparation(pj,mode)





    if strcmp(mode,'prepare')
        pj=exportPrepare(pj);
    else
        exportRestore(pj);
    end

end

function pj=exportPrepare(pj)
    pj=matlab.graphics.internal.export.saveFigProps(pj);

    pj.ParentFig.InPrint='on';
    if~matlab.ui.internal.isUIFigure(pj.ParentFig)

        pj.setPaintDisabled(true);
    end
    matlab.graphics.internal.export.updateSelectionState(pj,'remove');


    pj.ParentFig.Visible_I='on';
    matlab.graphics.internal.export.firePrintBehavior(pj,'PrePrintCallback');


    if~matlab.ui.internal.isUIFigure(pj.ParentFig)&&...
        pj.DPI~=pj.temp.DeviceDPI


        allContents=unique(findall(pj.temp.exportInclude));
        dpiAdjustment=1;
        objUnitsModified=pj.modifyUnitsForPrint('modify',allContents,dpiAdjustment);
    else
        objUnitsModified=[];
    end
    pj.temp.ObjUnitsModified=objUnitsModified;

    if~matlab.ui.internal.isUIFigure(pj.ParentFig)

        pj=matlab.graphics.internal.export.viewerPreparation(pj,'prepare');
    end


    pj.temp.SubplotManager.slm=getappdata(pj.ParentFig,'SubplotListenersManager');
    if~isempty(pj.temp.SubplotManager.slm)
        pj.temp.SubplotManager.slm.disable();
    end



    pj.temp.axesState=matlab.graphics.internal.export.axesPreparation('prepare',...
    pj.Handles{1},pj.temp.exportInclude,pj.temp.exportExclude,pj.temp.exportKeepVisible);

end

function exportRestore(pj)

    matlab.graphics.internal.export.axesPreparation('restore',pj.temp.axesState);

    pj.temp.SubplotManager.slm=getappdata(pj.ParentFig,'SubplotListenersManager');
    if~isempty(pj.temp.SubplotManager.slm)
        pj.temp.SubplotManager.slm.enable();
    end

    if~matlab.ui.internal.isUIFigure(pj.ParentFig)

        matlab.graphics.internal.export.viewerPreparation(pj,'restore');
    end

    pj.modifyUnitsForPrint('revert',pj.temp.ObjUnitsModified);

    matlab.graphics.internal.export.firePrintBehavior(pj,'PostPrintCallback');

    matlab.graphics.internal.export.restoreFigProps(pj,pj.ParentFig);
    pj.ParentFig.InPrint='off';
    matlab.graphics.internal.export.updateSelectionState(pj,'restore');
    if~matlab.ui.internal.isUIFigure(pj.ParentFig)

        pj.setPaintDisabled(false);
    end
end
