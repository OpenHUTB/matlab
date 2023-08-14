function perspectiveChangeHandler(this,~,eventData)






    perspectiveOn=eventData.state;
    modelH=eventData.modelH;
    canvasModelH=eventData.CanvasModelH;
    cStudio=eventData.studio;
    modelName=get(modelH,'Name');

    if perspectiveOn





        needRefreshChangeInformation=~slreq.app.MainManager.hasEditor;
        this.init();
        this.badgeManager.enableBadges(canvasModelH);
        spObj=this.spreadsheetManager.attachSpreadSheet(modelH,canvasModelH,cStudio);

        if needRefreshChangeInformation&&this.isChangeInformationEnabled({spObj})


            ctmgr=this.changeTracker;
            if~isempty(ctmgr)
                ctmgr.refresh();
            end
        end

        this.setLastOperatedView(spObj);
        this.markupManager.getClientContent(canvasModelH);
        this.markupManager.showMarkupsAndConnectorsForModel(canvasModelH);





        first=spObj.registerListener('Toggled',@this.onReqSpreadSheetToggled);



        if first
            ed=slreq.gui.ReqSpreadSheetToggled();
            ed.modelH=modelH;
            ed.studio=spObj.getStudio();
            ed.state=perspectiveOn;
            spObj.notifyObservers('Toggled',ed);
        end
    else



        spreadSheet=this.spreadsheetManager.getSpreadSheetObject(modelH);
        this.hideDeferredAnalysisNotifications(spreadSheet);
        selectedReqObj=spreadSheet.currentSelectedObj;
        if~isempty(selectedReqObj)


            dlg=DAStudio.ToolRoot.getOpenDialogs(selectedReqObj);
            if~isempty(dlg)&&isvalid(spreadSheet)&&isvalid(spreadSheet.mComponent)
                expTag=['slreq_propertyinspector_',modelName];
                for index=1:length(dlg)




                    cDlg=dlg(index);

                    if strcmp(cDlg.dialogTag,expTag)
                        studio=spreadSheet.mComponent.getStudio;
                        studioapp=studio.App;


                        editor=studioapp.getActiveEditor;
                        diagram=editor.getDiagram;
                        pi=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');
                        if isa(diagram,'StateflowDI.Subviewer')

                            sfid=diagram.backendId;
                            sr=sfroot;
                            sfobj=sr.idToHandle(double(sfid));
                            pi.updateSource('GLUE2:PropertyInspector',sfobj);
                        elseif isa(diagram,'SLM3I.Diagram')

                            sels=find_system(modelH,'Selected','on');
                            if isempty(sels)
                                slHandle=diagram.handle;
                            elseif numel(sels)==1
                                slHandle=sels;
                            else
                                slHandle=gcbh;
                            end
                            pi.updateSource('GLUE2:PropertyInspector',get(slHandle,'Object'));
                        else


                        end
                    end
                end

            end
        end















        allModelHs=slreq.utils.DAStudioHelper.getModelsToHideReqInfo(modelH);

        for cmodelH=allModelHs
            this.badgeManager.disableBadges(getfullname(cmodelH));


            this.markupManager.removeClientContent(cmodelH);


            this.markupManager.hideMarkupsAndConnectorsForModel(cmodelH);
        end

        this.spreadsheetManager.detachSpreadSheet(modelH);
    end



    dlg=DAStudio.ToolRoot.getOpenDialogs();

    tagsToRefres={'Simulink:Model:Info','slim_annotation_dlg','Simulink:Dialog:Info'};
    for n=1:length(dlg)
        if any(strcmp(dlg(n).dialogTag,tagsToRefres))
            dlg(n).refresh;
        end
    end








end
