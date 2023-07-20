function schema=ArrangeMenu(fncname,cbinfo)



    fcn=str2func(fncname);
    if nargout(fcn)
        schema=fcn(cbinfo);
    else
        schema=[];
        fcn(cbinfo);
    end
end

function schema=ArrangeMenuImplDisabled(~)
    schema=sl_container_schema;
    schema.tag='Simulink:ArrangeMenu';
    schema.state='Disabled';
    schema.label=DAStudio.message('Simulink:studio:ArrangeMenu');
    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
end

function schema=ArrangeMenuImpl(cbinfo)%#ok<*DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:ArrangeMenu';
    schema.label=DAStudio.message('Simulink:studio:ArrangeMenu');

    if(isa(cbinfo.domain,'StateflowDI.SFDomain'))
        chartId=SFStudio.Utils.getChartId(cbinfo);
        if(sfprivate('is_state_transition_table_chart',chartId))
            schema.state='Hidden';
        end
    end

    if SLStudio.Utils.isLockedSystem(cbinfo)||cbinfo.studio.App.hasSpotlightView()
        schema.state='Disabled';
    end

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={@BlockFitToContent,...
    'separator',...
    @AutoLayoutDiagram,...
    @AlignPorts,...
    @BeautifierMenu,...
    'separator',...
    @AlignLeftEdges,...
    @AlignCentersVertically,...
    @AlignRightEdges,...
    'separator',...
    @AlignTopEdges,...
    @AlignCentersHorizontally,...
    @AlignBottomEdges,...
    'separator',...
    im.getAction('Simulink:BringToFront'),...
    im.getAction('Simulink:SendToBack')
    };
end

function state=loc_enableAlignmentDistributeItem(callbackInfo,minSelectedItems)
    editor=callbackInfo.studio.App.getActiveEditor;
    if(editor.canPerformLayout(minSelectedItems)&&~SLStudio.Utils.isLockedSystem(callbackInfo))
        state='Enabled';
    else
        if callbackInfo.isContextMenu
            state='Hidden';
        else
            state='Disabled';
        end
    end
end

function schema=AutoLayoutDiagram(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:AutoLayoutDiagram';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='autoArrangeSimulink';
    else
        schema.label=DAStudio.message('Simulink:studio:ArrangeSystem');
    end
    schema.callback=@AutoLayoutDiagramCB;
    if isa(cbinfo.domain,'SLM3I.SLDomain')

        if SLStudio.Utils.isLockedSystem(cbinfo)||...
            SLStudio.Utils.isWebBlockInPanel(cbinfo)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    else
        schema.state='Hidden';
    end
end

function AutoLayoutDiagramCB(cbinfo)
    bdHandle=SLStudio.Utils.getDiagramHandle(cbinfo);
    SLStudio.internal.ScopedStudioBlocker();
    Simulink.BlockDiagram.arrangeSystem(bdHandle);

end

function schema=AlignLeftEdges(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:AlignLeftEdges';
    schema.label=DAStudio.message('Simulink:studio:AlignLeftEdges');
    schema.icon='Simulink:AlignLeft';
    schema.state=loc_enableAlignmentDistributeItem(cbinfo,2);
    schema.obsoleteTags={'Simulink:AlignBlocks:AlignHLeft'};
    schema.userdata='left';
    schema.callback=@AlignItemsCB;
end

function schema=AlignCentersVertically(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:AlignCentersVertically';
    schema.label=DAStudio.message('Simulink:studio:AlignCentersVertically');
    schema.icon='Simulink:AlignCenter';
    schema.state=loc_enableAlignmentDistributeItem(cbinfo,2);
    schema.obsoleteTags={'Simulink:AlignBlocks:AlignHMid'};
    schema.userdata='hcenter';
    schema.callback=@AlignItemsCB;
end

function schema=AlignRightEdges(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:AlignRightEdges';
    schema.label=DAStudio.message('Simulink:studio:AlignRightEdges');
    schema.icon='Simulink:AlignRight';
    schema.state=loc_enableAlignmentDistributeItem(cbinfo,2);
    schema.obsoleteTags={'Simulink:AlignBlocks:AlignHRight'};
    schema.userdata='right';
    schema.callback=@AlignItemsCB;
end

function schema=AlignTopEdges(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:AlignTopEdges';
    schema.label=DAStudio.message('Simulink:studio:AlignTopEdges');
    schema.icon='Simulink:AlignTop';
    schema.state=loc_enableAlignmentDistributeItem(cbinfo,2);
    schema.obsoleteTags={'Simulink:AlignBlocks:AlignVTop'};
    schema.userdata='top';
    schema.callback=@AlignItemsCB;
end

function schema=AlignCentersHorizontally(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:AlignCentersHorizontally';
    schema.label=DAStudio.message('Simulink:studio:AlignCentersHorizontally');
    schema.icon='Simulink:AlignMiddle';
    schema.state=loc_enableAlignmentDistributeItem(cbinfo,2);
    schema.obsoleteTags={'Simulink:AlignBlocks:AlignVMid'};
    schema.userdata='vcenter';
    schema.callback=@AlignItemsCB;
end

function schema=AlignBottomEdges(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:AlignBottomEdges';
    schema.label=DAStudio.message('Simulink:studio:AlignBottomEdges');
    schema.icon='Simulink:AlignBottom';
    schema.state=loc_enableAlignmentDistributeItem(cbinfo,2);
    schema.obsoleteTags={'Simulink:AlignBlocks:AlignBottom'};
    schema.userdata='bottom';
    schema.callback=@AlignItemsCB;
end

function AlignItemsCB(cbinfo)
    cbinfo.studio.App.getActiveEditor.alignItems(cbinfo.userdata);
end

function schema=DistributeItemsHorizontally(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DistributeItemsHorizontally';
    schema.label=DAStudio.message('Simulink:studio:DistributeItemsHorizontally');
    schema.icon='Simulink:DistributeItemsHorizontally';
    schema.obsoleteTags={'Simulink:DistributeBlocks:DistributeHCenters'};
    schema.state=loc_enableAlignmentDistributeItem(cbinfo,3);
    schema.userdata={'centers','horizontal'};
    schema.callback=@DistributeItemsCB;
end

function schema=DistributeItemsVertically(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DistributeItemsVertically';
    schema.label=DAStudio.message('Simulink:studio:DistributeItemsVertically');
    schema.icon='Simulink:DistributeItemsVertically';
    schema.obsoleteTags={'Simulink:DistributeBlocks:DistributeVCenters'};
    schema.state=loc_enableAlignmentDistributeItem(cbinfo,3);
    schema.userdata={'centers','vertical'};
    schema.callback=@DistributeItemsCB;
end

function schema=MakeHorizontalGapsEven(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:MakeHorizontalGapsEven';
    schema.label=DAStudio.message('Simulink:studio:MakeHorizontalGapsEven');
    schema.icon='Simulink:MakeHorizontalGapsEven';
    schema.obsoleteTags={'Simulink:DistributeBlocks:DistributeHGaps'};
    schema.state=loc_enableAlignmentDistributeItem(cbinfo,3);
    schema.userdata={'spaces','horizontal'};
    schema.callback=@DistributeItemsCB;
end

function schema=MakeVerticalGapsEven(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:MakeVerticalGapsEven';
    schema.label=DAStudio.message('Simulink:studio:MakeVerticalGapsEven');
    schema.icon='Simulink:MakeVerticalGapsEven';
    schema.obsoleteTags={'Simulink:DistributeBlocks:DistributeVGaps'};
    schema.state=loc_enableAlignmentDistributeItem(cbinfo,3);
    schema.userdata={'spaces','vertical'};
    schema.callback=@DistributeItemsCB;
end

function DistributeItemsCB(cbinfo)
    cbinfo.studio.App.getActiveEditor.distributeItems(cbinfo.userdata{1},cbinfo.userdata{2});
end

function schema=MakeItemsSameWidth(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:MakeItemsSameWidth';
    schema.label=DAStudio.message('Simulink:studio:MakeItemsSameWidth');
    schema.icon='Simulink:MakeItemsSameWidth';
    schema.state=loc_enableAlignmentDistributeItem(cbinfo,2);
    schema.obsoleteTags={'Simulink:ResizeBlocks:MakeSameWidth'};
    schema.userdata='width';
    schema.callback=@ResizeItemsCB;
end

function schema=MakeItemsSameHeight(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:MakeItemsSameHeight';
    schema.label=DAStudio.message('Simulink:studio:MakeItemsSameHeight');
    schema.icon='Simulink:MakeItemsSameHeight';
    schema.state=loc_enableAlignmentDistributeItem(cbinfo,2);
    schema.obsoleteTags={'Simulink:ResizeBlocks:MakeSameHeight'};
    schema.userdata='height';
    schema.callback=@ResizeItemsCB;
end

function schema=MakeItemsSameSize(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:MakeItemsSameSize';
    schema.label=DAStudio.message('Simulink:studio:MakeItemsSameSize');
    schema.icon='Simulink:MakeItemsSameSize';
    schema.state=loc_enableAlignmentDistributeItem(cbinfo,2);
    schema.obsoleteTags={'Simulink:ResizeBlocks:MakeSameSize'};
    schema.userdata='both';
    schema.callback=@ResizeItemsCB;
end

function ResizeItemsCB(cbinfo)
    cbinfo.studio.App.getActiveEditor.resizeItems(cbinfo.userdata);
end

function schema=BringToFront(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:BringToFront';
    schema.icon='Simulink:BringToFront';
    schema.label=DAStudio.message('Simulink:studio:BringToFront');
    if~SLStudio.Utils.selectionHasBlocks(cbinfo)&&...
        ~SLStudio.Utils.selectionHasAnnotations(cbinfo)
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end
    schema.callback=@BringToFrontCB;
end

function BringToFrontCB(cbinfo)
    if SLStudio.Utils.isWebBlockInPanel(cbinfo)
        loc_arrangeWebGlyph(cbinfo,'front');
    else
        cbinfo.studio.App.arrangeBlocks('Front');
    end
end

function loc_arrangeWebGlyph(cbinfo,direction)
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if~isempty(block)
        if strcmp(block.type,'PanelWebBlock')
            panelInfoJson=get_param(block.handle,'PanelInfo');
            panelInfo=jsondecode(panelInfoJson);
            glyphId=panelInfo.panelId;
        else
            glyphId=SLM3I.SLDomain.getBrowserWebBlockID(block.handle);
        end
        if~isempty(glyphId)
            editor=cbinfo.studio.App.getActiveEditor();
            SLM3I.SLDomain.arrangeWebGlyph(editor,glyphId,direction);
        end
    end
end

function schema=BlockFitToContent(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:BlockFitToContent';
    schema.state='Disabled';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='blockFitToContent';
    else
        schema.label=DAStudio.message('Simulink:studio:BlockFitToContent');
    end

    schema.callback=@ResizeBlocksToFitContentCB;
    editor=cbinfo.studio.App.getActiveEditor;
    if~editor.isLocked
        selection=editor.getSelection;
        for i=1:selection.size
            element=selection.at(i);
            if isa(element,'SLM3I.Block')&&SLM3I.Util.isValidDiagramElement(element)
                if SLM3I.SLDomain.blockNeedsResizeToFitContent(editor,element)
                    schema.state='Enabled';
                end
            end
        end
    end
end

function ResizeBlocksToFitContentCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    if~editor.isLocked
        SLM3I.SLDomain.resizeBlocksToFitContent(editor,editor.getSelection);
    end
end

function schema=SendToBack(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:SendToBack';
    schema.icon='Simulink:SendToBack';
    schema.label=DAStudio.message('Simulink:studio:SendToBack');
    if~SLStudio.Utils.selectionHasBlocks(cbinfo)&&...
        ~SLStudio.Utils.selectionHasAnnotations(cbinfo)
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end
    schema.callback=@SendToBackCB;
end

function SendToBackCB(cbinfo)
    if SLStudio.Utils.isWebBlockInPanel(cbinfo)
        loc_arrangeWebGlyph(cbinfo,'back');
    else
        cbinfo.studio.App.arrangeBlocks('Back');
    end
end

function schema=BeautifierMenu(cbinfo)
    schema=sl_action_schema;
    schema.tag='Stateflow:DiagramFormatting';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='autoArrangeStateflow';
    else
        schema.label=DAStudio.message('Stateflow:studio:ArrangeLayoutSchemaLabel');
    end
    schema.state='Hidden';
    if isa(cbinfo.domain,'StateflowDI.SFDomain')
        chart=SFStudio.Utils.getChartId(cbinfo);
        editorUddH=SFStudio.Utils.getLastActiveEditorForChart(chart);
        if~isempty(editorUddH)
            chartUddH=sf('IdToHandle',chart);

            schema.accelerator='Ctrl+Shift+A';
            if isa(chartUddH,'Stateflow.Chart')&&cbinfo.selection.size()<1
                schema.state='Enabled';
            end
            if Stateflow.ReqTable.internal.isRequirementsTable(chartUddH.Id)
                schema.callback=@Stateflow.ReqTable.internal.SpecBlockFormatter.autoArrangeFromUI;
            else
                schema.callback=@Stateflow.Tools.Beautifier.invoke;
            end
        end
    end
end

function schema=AlignPorts(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:AlignPorts';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:AlignPorts');
    schema.state='Hidden';


    featureOn=bitand(slfeature('SLLineStraightening'),2^9);
    if~featureOn...
        ||~isa(cbinfo.domain,'SLM3I.SLDomain')...
        ||cbinfo.isContextMenu
        return;
    end

    schema.state=loc_alignPortsState(cbinfo);
    schema.checked=loc_alignPortsChecked(cbinfo);
    schema.callback=@AlignPortsCB;
end

function AlignPortsCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    editorDomain=editor.getStudio.getActiveDomain();


    editorDomain.createParamChangesCommand(...
    editor,...
    'Simulink:studio:AlignPorts',...
    DAStudio.message('Simulink:studio:AlignPorts'),...
    @AlignPortsCB_Impl,...
    {cbinfo,editorDomain},...
    false,...
    false,...
    false,...
    true,...
    false);
end

function state=loc_alignPortsState(callbackInfo)
    if SLStudio.Utils.isLockedSystem(callbackInfo)
        state='Disabled';
    else
        state='Enabled';
    end
end

function checked=loc_alignPortsChecked(cbinfo)
    diagram=SLStudio.Utils.getDiagramFullName(cbinfo);
    alignPorts=get_param(diagram,'AlignPorts');

    switch alignPorts
    case 'on'
        checked='Checked';
    case 'off'
        checked='Unchecked';
    end
end

function[success,noop]=AlignPortsCB_Impl(cbinfo,editorDomain)
    diagramH=SLStudio.Utils.getDiagramHandle(cbinfo);
    alignPorts=get_param(diagramH,'AlignPorts');

    editorDomain.paramChangesCommandAddObjectOfType(diagramH,'GRAPH');

    switch alignPorts
    case 'on'
        set_param(diagramH,'AlignPorts','off');
    case 'off'
        set_param(diagramH,'AlignPorts','on');
    end

    success=true;
    noop=false;
end




