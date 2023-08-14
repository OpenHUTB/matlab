function hMenu=createContextMenu(hObj)






    hMenu=uicontextmenu(...
    'Parent',hObj.Figure,...
    'Tag','DataCursorModeContextMenu',...
    'Serializable','off',...
    'HandleVisibility','off');




    matlab.graphics.shape.internal.PointDataTip.setMenuNotCopyable(hMenu);





    if~isdeployed&&hObj.Figure.HandleVisibility=="on"
        handles.EditProperties=uimenu(...
        'Parent',hMenu,...
        'Label',getString(message('MATLAB:uistring:datacursor:MenuEditContentStyle')),...
        'Tag','EditProperties',...
        'Callback',@editPropertiesFcn);
    end


    hInterpMenu=uimenu(...
    'Parent',hMenu,...
    'Label',getString(message('MATLAB:uistring:datacursor:MenuSelectionStyle')),...
    'Tag','DataCursorSelectionStyle');
    handles.SelectInterp=uimenu(...
    'Parent',hInterpMenu,...
    'Label',getString(message('MATLAB:uistring:datacursor:MenuMousePosition')),...
    'Tag','DataCursorMousePosition',...
    'Callback',{@setCursorManagerProperty,'SnapToDataVertex','off'});
    handles.SelectVertex=uimenu(...
    'Parent',hInterpMenu,...
    'Label',getString(message('MATLAB:uistring:datacursor:MenuSnapToNearestDataVertex')),...
    'Tag','DataCursorSnapDataVertex',...
    'Callback',{@setCursorManagerProperty,'SnapToDataVertex','on'});


    if~matlab.ui.internal.isUIFigure(hObj.Figure)
        hDisplayMenu=uimenu(...
        'Parent',hMenu,...
        'Label',getString(message('MATLAB:uistring:datacursor:MenuDisplayStyle')),...
        'Tag','DataCursorDisplayStyle');
        handles.DisplayWindow=uimenu(...
        'Parent',hDisplayMenu,...
        'Label',getString(message('MATLAB:uistring:datacursor:MenuWindowInsideFigure')),...
        'Tag','DataCursorWindow',...
        'Callback',{@setCursorManagerProperty,'DisplayStyle','window'});
        handles.DisplayDatatip=uimenu(...
        'Parent',hDisplayMenu,...
        'Label',getString(message('MATLAB:uistring:datacursor:MenuDatatip')),...
        'Tag','DataCursorDatatip',...
        'Callback',{@setCursorManagerProperty,'DisplayStyle','datatip'});
    end

    if~matlab.ui.internal.isUIFigure(hObj.Figure)
        handles.CreateNew=uimenu(...
        'Parent',hMenu,...
        'Label',getString(message('MATLAB:uistring:datacursor:MenuCreateNewDatatipShift')),...
        'Tag','DataCursorNewDatatip',...
        'Separator','on',...
        'Callback',@setCreateNew);
    end
    handles.Delete=uimenu(...
    'Parent',hMenu,...
    'Label',getString(message('MATLAB:uistring:datacursor:MenuDeleteCurrentDatati')),...
    'Tag','DataCursorDeleteDatatip',...
    'Callback',@deleteCurrent);
    handles.DeleteAll=uimenu(...
    'Parent',hMenu,...
    'Label',getString(message('MATLAB:uistring:datacursor:MenuDeleteAllDatatips')),...
    'Tag','DataCursorDeleteAll',...
    'Callback',@deleteAll);


    handles.Export=uimenu(...
    'Parent',hMenu,...
    'Label',getString(message('MATLAB:uistring:datacursor:MenuExportCursorDataToWorkspace')),...
    'Tag','DataCursorExport',...
    'Separator','on',...
    'Callback',@export);



    if~isdeployed

        hUpdateFcn=uimenu(...
        'Parent',hMenu,...
        'Label',getString(message('MATLAB:uistring:datacursor:MenuTextUpdateFunction')),...
        'Tag','UpdateFunction');
        handles.EditUpdateFcn=uimenu(...
        'Parent',hUpdateFcn,...
        'Label',getString(message('MATLAB:uistring:datacursor:MenuEditTextUpdateFunction')),...
        'Tag','DataCursorEditText',...
        'Callback',@editUpdateFcn);
        handles.SelectUpdateFcn=uimenu(...
        'Parent',hUpdateFcn,...
        'Label',getString(message('MATLAB:uistring:datacursor:MenuSelectTextUpdateFunction')),...
        'Tag','DataCursorSelectText',...
        'Callback',@selectUpdateFcn);
        handles.DeleteUpdateFcn=uimenu(...
        'Parent',hUpdateFcn,...
        'Label',getString(message('MATLAB:uistring:datacursor:MenuDeleteTextUpdateFunction')),...
        'Tag','DataCursorDeleteText',...
        'Callback',@deleteUpdateFcn);
    end

    hMenu.Callback={@updateMenuState,handles};


    function updateMenuState(src,~,handles)


        hFig=ancestor(src,'figure');
        dcm=datacursormode(hFig);

        if strcmp(dcm.DisplayStyle,'window')
            handles.DisplayWindow.Checked='on';
            handles.DisplayDatatip.Checked='off';
            handles.CreateNew.Enable='off';
            handles.Delete.Enable='off';
            handles.DeleteAll.Enable='off';
        else
            handles.DisplayWindow.Checked='off';
            handles.DisplayDatatip.Checked='on';
            handles.CreateNew.Enable='on';
            handles.Delete.Enable='on';
            handles.DeleteAll.Enable='on';
        end

        if strcmp(dcm.SnapToDataVertex,'on')
            handles.SelectInterp.Checked='off';
            handles.SelectVertex.Checked='on';
        else
            handles.SelectInterp.Checked='on';
            handles.SelectVertex.Checked='off';
        end

        if~dcm.hasInfo
            set(handles.Export,'Enable','off');
        else
            set(handles.Export,'Enable','on');
        end



        if strcmp(dcm.Enable,'off')
            handles.DisplayWindow.Enable='off';
            handles.CreateNew.Enable='off';

            handles.Delete.Label=getString(message('MATLAB:uistring:datacursor:MenuDeleteCurrentDatatipNoAccelerator'))';
        else
            handles.DisplayWindow.Enable='on';
            handles.CreateNew.Enable='on';
            handles.Delete.Label=getString(message('MATLAB:uistring:datacursor:MenuDeleteCurrentDatati'))';
        end

        if~isdeployed
            if~isempty(dcm.UpdateFcn)
                handles.EditProperties.Enable='off';
                set(handles.DeleteUpdateFcn,'Enable','on');
            else
                handles.EditProperties.Enable='on';
                set(handles.DeleteUpdateFcn,'Enable','off');
            end


            if isRemoteClientThatMirrorsSwingUIs()
                set(handles.EditUpdateFcn,'Enable','off');
            else
                set(handles.EditUpdateFcn,'Enable','on');
            end
        end

        function isRemoteClient=isRemoteClientThatMirrorsSwingUIs()
            import matlab.internal.lang.capability.Capability;
            isRemoteClient=~Capability.isSupported(Capability.LocalClient)&&...
            Capability.isSupported(Capability.Swing);



            function setCursorManagerProperty(src,~,prop,value)

                hFig=ancestor(src,'figure');
                dcm=datacursormode(hFig);
                dcm.(prop)=value;


                function setCreateNew(src,~)
                    hFig=ancestor(src,'figure');
                    dcm=datacursormode(hFig);
                    dcm.ModeHandle.ModeStateData.newCursor=true;


                    function deleteCurrent(src,~)
                        hFig=ancestor(src,'figure');
                        dcm=datacursormode(hFig);
                        hAx=getAxesFromPointDatatip(dcm.CurrentCursor);
                        delete(dcm.CurrentCursor);
                        generateLiveCode(hAx)


                        function deleteAll(src,~)
                            hFig=ancestor(src,'figure');
                            dcm=datacursormode(hFig);
                            hAx=getAxesFromPointDatatip(dcm.CurrentCursor);
                            dcm.removeAllDataCursors();
                            generateLiveCode(hAx)


                            function export(src,~)
                                hFig=ancestor(src,'figure');
                                dcm=datacursormode(hFig);





                                export2wsdlg({getString(message('MATLAB:uistring:datacursor:EnterVariableName'))+":"},...
                                {dcm.DefaultExportVarName},...
                                {getCursorInfo(dcm)},...
                                getString(message('MATLAB:uistring:datacursor:TitleExportCursorDataToWorkspace')));


                                function selectUpdateFcn(src,~)
                                    hFig=ancestor(src,'figure');
                                    dcm=datacursormode(hFig);
                                    dcm.selectUpdateFcn();


                                    function editUpdateFcn(src,~)
                                        hFig=ancestor(src,'figure');
                                        dcm=datacursormode(hFig);
                                        dcm.editUpdateFcn();


                                        function deleteUpdateFcn(src,~)
                                            hFig=ancestor(src,'figure');
                                            dcm=datacursormode(hFig);
                                            dcm.UpdateFcn='';


                                            function editPropertiesFcn(src,~)
                                                hFig=ancestor(src,'figure');
                                                dcm=datacursormode(hFig);
                                                if~isempty(dcm.CurrentCursor)
                                                    hTargetObj=dcm.CurrentCursor.DataSource;
                                                    if~isempty(hTargetObj)&&isprop(hTargetObj,'DataTipTemplate')
                                                        hTips=hTargetObj.DataTipTemplate.getAllPointDataTips();
                                                        if~isempty(hTips)

                                                            inspect(hTips);
                                                        end
                                                    end
                                                end

                                                function hAx=getAxesFromPointDatatip(hTip)

                                                    hAx=[];
                                                    if~isempty(hTip)&&ishghandle(hTip.DataSource)
                                                        hAx=ancestor(hTip.DataSource,'matlab.graphics.axis.AbstractAxes');
                                                    end

                                                    function generateLiveCode(hAxes)

                                                        if~isempty(hAxes)&&isa(hAxes,'matlab.graphics.axis.AbstractAxes')
                                                            matlab.graphics.interaction.generateLiveCode(hAxes,matlab.internal.editor.figure.ActionID.DATATIP_REMOVED);
                                                        end