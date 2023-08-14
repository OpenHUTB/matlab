


















function obj=getCurrentObject(name)

    obj=slreq.internal.callback.CurrentInformation.getCurrentObject();
    if~isempty(obj)
        return;
    end

    dasObj=[];
    lastOperatedView=slreq.app.MainManager.getInstance().getLastOperatedView();
    showingReqTable=isa(lastOperatedView,'slreq.internal.gui.SfReqView');

    if~slreq.app.MainManager.hasEditor()&&~showingReqTable
        return;
    end

    if nargin==0
        dasObj=slreq.app.MainManager.getCurrentObject();
    else
        name=convertStringsToChars(name);
        appMgr=slreq.app.MainManager.getInstance();
        if strcmpi(name,'editor')
            if~isempty(appMgr.requirementsEditor)
                dasObj=appMgr.requirementsEditor.getCurrentSelection();
            end
        else
            if ischar(name)&&(~dig.isProductInstalled('Simulink')||~bdIsLoaded(name))
                error(message('Slvnv:slreq:InvalidNameSpecifiedForCurrentSelection',name))
            end
            modelH=get_param(name,'Handle');
            spObj=appMgr.getSpreadSheetObject(modelH);
            if~isempty(spObj)
                dasObj=spObj.getCurrentSelection();
            end
        end
    end

    for n=1:length(dasObj)
        o=slreq.utils.dataToApiObject(dasObj(n).dataModelObj);
        if n==1

            obj=o;
        else
            obj(n)=o;%#ok<AGROW>
        end
    end
end
