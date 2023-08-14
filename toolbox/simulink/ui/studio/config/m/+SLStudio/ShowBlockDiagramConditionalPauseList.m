function ShowBlockDiagramConditionalPauseList(modelH,portH)

    featVal=slfeature('ConditionalPause');

    if featVal==3||featVal==5
        obj=SLStudio.GetBlockDiagramConditionalPauseListDialog(modelH);
        obj.showBlockDiagramConditionalPauseListDialog(portH);
    elseif featVal==2||featVal==4

        editors=GLUE2.Util.findAllEditors(get_param(modelH,'Name'));
        for ii=1:numel(editors)
            studio=editors(ii).getStudio;
            comp=studio.getComponent('GLUE2:SpreadSheet','Conditional Breakpoints');
            if isempty(comp)

                SLStudio.StepperBreakpointList.createSpreadSheetComponent(studio,true,true);
            elseif~comp.isVisible

                studio.showComponent(comp);
                studio.focusComponent(comp);
            elseif comp.isVisible
                studio.hideComponent(comp);
            end
        end
    end
