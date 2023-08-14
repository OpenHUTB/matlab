function updateResults(this)





    modelH=get_param(this.modelName,'Handle');
    handles=get_param(modelH,'AutoVerifyData');
    if isempty(handles)
        return;
    end

    fileNames=[];
    if isfield(handles,'currentResult')
        handles.currentResult.Report='';
        handles.currentResult.PDFReport='';
        set_param(modelH,'AutoVerifyData',handles);

        fileNames=handles.currentResult;
    end

    refresh_mdlexplr_result(modelH);

    modelView=[];
    dvData=[];
    if isfield(handles,'modelView')&&handles.modelView.isvalid
        modelView=handles.modelView;
        dvData=modelView.data;
    end
    if isempty(dvData)&&~isempty(fileNames)
        s=load(fileNames.DataFile);
        dvData=s.sldvData;
    end

    htmlSummary='';
    if~isempty(dvData)&&~isempty(fileNames)
        htmlSummary=Sldv.ReportUtils.getHTMLsummary(dvData,...
        fileNames,...
        get_param(modelH,'Name'),...
        false);
    end

    progressUI=[];
    if isfield(handles,'ui')&&ishandle(handles.ui)
        progressUI=handles.ui;
    end


    if~isempty(progressUI)&&~isempty(htmlSummary)
        progressUI.setLog(htmlSummary);
    end


    if isfield(handles,'res_dialog')&&ishandle(handles.res_dialog)
        handles.res_dialog.refresh;
    end


    if~isempty(modelView)
        if isempty(modelView.data)
            modelView.updateSldvData(dvData);
        end
        if~modelView.isHighlighted
            modelView.initializeHighlighting;
        end
        modelView.view(this,fileNames);
    end
end

function refresh_mdlexplr_result(modelH)
    try
        modelObj=get_param(modelH,'Object');

        children=modelObj.getHierarchicalChildren;

        for child=children(:)'
            if isa(child,'Simulink.DVOutput')
                child.refresh;
                break;
            end
        end


        root=slroot;
        me=[];
        daRoot=DAStudio.Root;
        explorers=daRoot.find('-isa','DAStudio.Explorer');
        for i=1:length(explorers)
            if root==explorers(i).getRoot
                me=explorers(i);
                break;
            end
        end


        if~isempty(me)
            dlg=me.getDialog;
            dlgSrc=dlg.getSource;

            if isa(dlgSrc,'Simulink.DVOutput')&&dlgSrc.up==modelObj
                dlg.refresh();
            end
        end
    catch Mex %#ok<NASGU>
    end
end