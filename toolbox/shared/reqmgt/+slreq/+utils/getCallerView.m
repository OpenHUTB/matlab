function cView=getCallerView(caller,isStrict)







    if nargin<2
        isStrict=false;
    end

    mgr=slreq.app.MainManager.getInstance;
    if isStrict


        if~ishandle(caller)
            if ismember(caller,{'#?#standalone#?#','#?#standalonecontext#?#','standalone'})
                cView=mgr.requirementsEditor;
                return;
            else
                cView=[];
            end
        else
            cView=mgr.getCurrentSpreadSheetObject(caller);
        end
    else
        if ismember(caller,{'#?#standalone#?#','#?#standalonecontext#?#'})
            cView=mgr.requirementsEditor;
            return;
        else
            try
                cHandle=get_param(caller,'Handle');
                cView=mgr.getCurrentSpreadSheetObject(cHandle);
            catch ex %#ok<NASGU>


                cView=mgr.requirementsEditor;
            end
        end
    end
end