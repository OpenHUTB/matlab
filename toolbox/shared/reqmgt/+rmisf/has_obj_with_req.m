function out=has_obj_with_req(apiObj)

    out=false;

    if rmisf.has_req(apiObj,false)
        out=true;
        return;
    end
    if~rmi.settings_mgr('get','reportSettings','followLibraryLinks')&&objIsFromLib(apiObj);
        return;
    end

    sfFilter=rmisf.sfisa('isaFilter');
    testObjs=apiObj.find(sfFilter);

    for obj=testObjs(:)'
        if rmisf.has_req(obj)
            out=true;
            return;
        end

        if isa(obj,'Stateflow.AtomicSubchart')
            if rmisf.has_obj_with_req(obj.Subchart)
                out=true;
                return;
            end
        end
    end

end


function result=objIsFromLib(apiObj)
    try
        hostName=strtok(apiObj.Path,'/');
        slData=rptgen_sl.appdata_sl;
        rptMdl=slData.CurrentModel;
        result=~strcmp(hostName,rptMdl);
    catch ex %#ok<NASGU>
        result=false;
    end
end

