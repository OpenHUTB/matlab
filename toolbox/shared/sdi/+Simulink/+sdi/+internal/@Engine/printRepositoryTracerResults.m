
function[xlsDataSortedByTotalTime,xlsDataSortedByTotalVisits]=...
    printRepositoryTracerResults(~,filename)

    results=sdi.Repository.getTracerResults();
    fieldnames=fields(results);
    headers={'','Visits','Total (s)'};

    xlsData=cell(length(fieldnames)+1,3);
    xlsData(1,:)=headers;

    indicesToRemove=[];

    for idx=1:length(fieldnames)
        callsite=fieldnames{idx};


        total=results.(callsite).Total;
        if~total
            indicesToRemove=[indicesToRemove,idx+1];%#ok<AGROW>
            continue;
        end

        visits=total/results.(callsite).Average;

        xlsData{idx+1,3}=total;
        xlsData{idx+1,2}=visits;
        xlsData{idx+1,1}=callsite;
    end

    xlsData(indicesToRemove,:)=[];
    xlsDataCopy=xlsData;

    [~,sortIndiciesByTotalTime]=sort(cell2mat(xlsDataCopy(2:end,3)),'descend');
    xlsDataSortedByTotalTime=cell(size(xlsData));
    xlsDataSortedByTotalTime(1,:)=headers;
    xlsDataSortedByTotalTime(2:end,:)=xlsDataCopy(sortIndiciesByTotalTime+1,:);

    [~,sortIndiciesByTotalVisits]=sort(cell2mat(xlsDataCopy(2:end,2)),'descend');
    xlsDataSortedByTotalVisits=cell(size(xlsData));
    xlsDataSortedByTotalVisits(1,:)=headers;
    xlsDataSortedByTotalVisits(2:end,:)=xlsDataCopy(sortIndiciesByTotalVisits+1,:);


    if size(xlsDataSortedByTotalTime,1)==1||size(xlsDataSortedByTotalVisits,1)==1
        if slsvTestingHook('SDIProfilePerformanceForMLDATX')
            disp('No tracer data! Did you perform a save or load action with the test hook enabled?');
        else
            disp('No tracer data! Did you remember to build with the ''RELEASE_MODE_PROFILE'' flag?');
        end
        return
    end

    if nargout>0
        return;
    end

    disp('Writing Excel file...');


    warnAddSheet=warning('off','MATLAB:xlswrite:AddSheet');

    xlswrite(filename,xlsDataSortedByTotalTime,'By Time');
    xlswrite(filename,xlsDataSortedByTotalVisits,'By Visits');


    warning(warnAddSheet.state,warnAddSheet.identifier);

    disp('Done.');
end