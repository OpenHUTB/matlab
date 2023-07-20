function htmlReport=generateJustificationReport(advisorObject)


    htmlReport='';


    manager=slcheck.getAdvisorJustificationManager(advisorObject.System);

    exclusions=manager.filters;

    if exclusions.Size<=0
        return;
    end

    tableData=[];
    for ii=1:exclusions.Size
        if~strcmp(advisorObject.getActiveCheck,exclusions(ii).checks.toArray)
            continue;
        end
        checkObj=advisorObject.getCheckObj(advisorObject.getActiveCheck);
        RDs=checkObj.ResultDetails;
        RDObj=RDs(arrayfun(@(x)strcmp(x.getHash,exclusions(ii).id),RDs));
        if isempty(RDObj)
            data=exclusions(ii).id;
        else
            sid=ModelAdvisor.ResultDetail.getData(RDObj);
            if~isempty(sid)
                templ=ModelAdvisor.FormatTemplate('ListTemplate');
                fEntry=templ.formatEntry(sid);
                if isa(fEntry,'ModelAdvisor.Text')
                    data=fEntry.Content;
                else
                    try
                        data=Simulink.ID.getFullName(sid);
                    catch
                        data='';
                    end
                end
            else
                data=sid;
            end
        end

        tableData=[tableData;{exclusions(ii).metadata.summary,data,exclusions(ii).metadata.user,datestr(exclusions(ii).metadata.timeStamp)}];
    end


    if~isempty(tableData)&&~all(cellfun(@isempty,tableData),'all')
        exclusionInfo=ModelAdvisor.Table(size(tableData,1),4);
        exclusionInfo.setColHeading(1,DAStudio.message('slcheck:filtercatalog:Editor_FilterSummary'));
        exclusionInfo.setColHeading(2,DAStudio.message('slcheck:filtercatalog:Editor_FilterID'));
        exclusionInfo.setColHeading(3,'Added by');
        exclusionInfo.setColHeading(4,'Added on');
        exclusionInfo.setEntries(tableData);

        htmlReport=[htmlReport...
        ,'<br>'...
        ,'<H1>','Justifications','</H1>'...
        ,'<p>','The following elements are justified from Check result.','</p>'...
        ,exclusionInfo.emitHTML];
    end


end
