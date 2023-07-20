function htmlReport=generateExclusionReport(advisorObject)


    htmlReport='';


    manager=slcheck.getAdvisorFilterManager(advisorObject.System);


    if~advisorObject.ActiveCheck.SupportExclusion&&(manager.filters.Size>0)
        htmlReport=[htmlReport,'<H5>',DAStudio.message('ModelAdvisor:engine:CheckExclusionRules'),'</H5>'];
        htmlReport=[htmlReport,'<b>',DAStudio.message('ModelAdvisor:engine:CheckNotSupportedExclusion'),'</b><br/>'];
        return;
    end

    exclusionFilters=manager.filters;
    flags=false(1,exclusionFilters.Size);
    for rowNumber=1:exclusionFilters.Size
        excludedChecks=exclusionFilters(rowNumber).checks.toArray;
        if~isempty(excludedChecks)&&strcmp(excludedChecks{1},'.*')
            flags(rowNumber)=true;
        else
            flags(rowNumber)=any(strcmp(advisorObject.getActiveCheck,exclusionFilters(rowNumber).checks.toArray));
        end
    end

    exclusions=exclusionFilters.toArray();
    exclusions=exclusions(flags);

    if numel(exclusions)<=0
        return;
    end




    originalStateOfProjectResultData=advisorObject.ActiveCheck.ProjectResultData;

    tbl=ModelAdvisor.FormatTemplate('TableTemplate');
    contentMap=containers.Map;
    for e=1:numel(exclusions)
        key=exclusions(e).metadata.summary;
        link=tbl.formatEntry(exclusions(e).id);
        link.Content=slcheck.getFullPathFromSID(exclusions(e).id);
        if~contentMap.isKey(key)

            contentMap(key)=link;
        else

            contentMap(key)=[contentMap(key),link];
        end
    end



    advisorObject.ActiveCheck.ProjectResultData=originalStateOfProjectResultData;

    exclusionInfo=ModelAdvisor.Table(numel(contentMap.keys),2);
    exclusionInfo.setColHeading(1,DAStudio.message('slcheck:filtercatalog:Editor_FilterRationale'));
    exclusionInfo.setColHeading(2,DAStudio.message('slcheck:filtercatalog:Editor_FilterID'));


    rowNumber=0;
    for k=keys(contentMap)
        rowNumber=rowNumber+1;
        theKey=k{1};
        exclusionInfo.setEntry(rowNumber,1,theKey);
        exclusionInfo.setEntry(rowNumber,2,Advisor.Utils.getTableOfConflicts(contentMap(theKey)));
    end


    if~isempty(exclusionInfo)
        htmlReport=[htmlReport...
        ,'<br>'...
        ,'<H5>',DAStudio.message('ModelAdvisor:engine:CheckExclusionRules'),'</H5>'...
        ,'<H3>',DAStudio.message('slcheck:filtercatalog:ExclusionReportDescription'),'</H3>'...
        ,exclusionInfo.emitHTML];
    end


end
