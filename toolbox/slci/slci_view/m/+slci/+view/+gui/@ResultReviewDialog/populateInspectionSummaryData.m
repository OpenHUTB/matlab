



function populateInspectionSummaryData(obj)

    cvModelToCode=[];
    cvCodeToModel=[];
    tModelToCode=[];
    tCodeToModel=[];

    conf=slci.toolstrip.util.getConfiguration(obj.getStudio);
    reportConfig=slci.internal.ReportConfig;





    aModelName=conf.getModelName();
    aReportFolder=conf.getReportFolder();
    if(slcifeature('SlciDMR')==1)
        aDataSrc=fullfile(aReportFolder,[aModelName...
        ,'_verification_results']);
    else
        aDataSrc=fullfile(aReportFolder,[aModelName...
        ,'_verification_results.sldd']);
    end

    if exist(aDataSrc,'file')

        ReportData=getReportData(conf,reportConfig);

        conf.getDataManager().discardData();

        if(~isempty(ReportData)&&~isempty(ReportData.statusData))


            if~isempty(ReportData.statusData.model)

                modelVer.SummaryData=ReportData.statusData.model.SUMMARY;
                if~isempty(modelVer.SummaryData)
                    cvModelToCode=getInspectionSummaryData(modelVer.SummaryData);
                end
            end


            if~isempty(ReportData.statusData.code)

                codeVer.SummaryData=ReportData.statusData.code.SUMMARY;
                if~isempty(codeVer.SummaryData)
                    cvCodeToModel=getInspectionSummaryData(codeVer.SummaryData);
                end
            end

        end

        if(~isempty(ReportData)&&~isempty(ReportData.trace))


            if~isempty(ReportData.trace.model)

                tmodelVer.SummaryData=ReportData.trace.model.SUMMARY;
                if~isempty(tmodelVer.SummaryData)
                    tModelToCode=getInspectionSummaryData(tmodelVer.SummaryData);
                end
            end


            if~isempty(ReportData.trace.code)

                tCodeVer.SummaryData=ReportData.trace.code.SUMMARY;
                if~isempty(tCodeVer.SummaryData)
                    tCodeToModel=getInspectionSummaryData(tCodeVer.SummaryData);
                end
            end
        end

    end

    obj.fInspectionSummaryData.('cvModelToCode')=cvModelToCode;
    obj.fInspectionSummaryData.('cvCodeToModel')=cvCodeToModel;
    obj.fInspectionSummaryData.('tModelToCode')=tModelToCode;
    obj.fInspectionSummaryData.('tCodeToModel')=tCodeToModel;


end



function reportData=getReportData(conf,reportConfig)
    try
        [~,reportData]=slci.report.processReport(conf,reportConfig);
    catch ME
        reportData=[];
    end
end



function data=getInspectionSummaryData(summaryData)
    tableData=summaryData.TABLEDATA;

    verified=struct;
    notVerified=struct;
    notConsidered=struct;

    for i=1:size(tableData,2)



        if(isfield(tableData(i),'COUNTLIST'))
            countlist=tableData(i).COUNTLIST;
        else
            countlist=tableData(i);
        end

        if(isfield(countlist,'COUNT'))

            for j=1:size(countlist,2)

                countContent=str2num(countlist(j).COUNT.CONTENT);

                if(strcmpi(countlist(j).COUNT.ATTRIBUTES,'verified')||...
                    strcmpi(countlist(j).COUNT.ATTRIBUTES,'traced')||...
                    strcmpi(countlist(j).COUNT.ATTRIBUTES,'justified'))

                    verified.(countlist(j).COUNT.ATTRIBUTES)=addAndGetFieldValue(...
                    verified,countlist(j).COUNT.ATTRIBUTES,countContent);

                else


                    if(countContent>0)




                        fieldName=countlist(j).STATUS.CONTENT;
                        fieldName_split=strsplit(fieldName,'status ');
                        if(size(fieldName_split,2)>1)
                            fieldName=fieldName_split(2);
                            fieldName=fieldName{1};
                        end

                        fieldName=strrep(strrep(fieldName,' : ',''),' ','_');

                        if(strcmpi(fieldName,'Nonfunctional_code')||...
                            strcmpi(fieldName,'Not_processed'))

                            notConsidered.(fieldName)=addAndGetFieldValue(...
                            notConsidered,fieldName,countContent);
                        else

                            notVerified.(fieldName)=addAndGetFieldValue(...
                            notVerified,fieldName,countContent);
                        end
                    end

                end

            end

        end

    end

    data.('Verified')=verified;
    data.('NotVerified')=notVerified;
    data.('NotConsidered')=notConsidered;

end

function data=addAndGetFieldValue(statusType,fieldName,contentData)

    if(isfield(statusType,fieldName))
        data=statusType.(fieldName)+contentData;
    else
        data=contentData;
    end
end
