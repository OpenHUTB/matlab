function makeCodeProverFilterCallback(obj,filterEditor)





    [status,msg]=SlCov.CoverageAPI.checkCvLicense;
    if status==0
        errordlg(getString(msg),getString(message('Slvnv:simcoverage:cvresultsexplorer:WindowTitle')),'modal');
        return
    end


    [status,msg]=SlCov.CoverageAPI.checkPolyspaceLicense;
    if status==0
        errordlg(getString(msg),getString(message('Slvnv:simcoverage:cvresultsexplorer:WindowTitle')),'modal');
        return
    end


    [fileName,path,~]=uigetfile('ps_results.pscp',...
    getString(message('Slvnv:simcoverage:cvresultsexplorer:MakeCPFilterSelectDlgTitle')));
    if fileName==0
        return
    end
    fullFileName=fullfile(path,fileName);


    cvds={};
    if~isempty(obj.maps.uniqueIdMap)

        cvdNodes=obj.maps.uniqueIdMap.values();
        cvdDates=cellfun(@(x)datenum(x.date),cvdNodes);
        [~,idx]=sort(cvdDates,'descend');
        for ii=idx
            cvd=cvdNodes{ii}.getCvd();
            if~isempty(cvd)
                cvds{end+1}=cvd;%#ok<AGROW> 
            end
        end
    end


    filterRules=slcoverage.Filter.makeCodeProverFilterRules(obj.topModelName,fullFileName,cvds,true);
    if isempty(filterRules)
        return
    end

    obj.ed.broadcastEvent('MESleepEvent');

    try

        filterObj=slcoverage.Filter;
        filterObj.filter=filterEditor;
        for ii=1:numel(filterRules)
            filterObj.addRule(filterRules(ii));
        end


        obj.showFilter(true,[]);
        resetLastReportLinks(obj);
        activeDlg=obj.imme.getDialogHandle;
        if~isempty(activeDlg)
            activeDlg.enableApplyButton(true);
        end
    catch
    end

    obj.ed.broadcastEvent('MEWakeEvent');
