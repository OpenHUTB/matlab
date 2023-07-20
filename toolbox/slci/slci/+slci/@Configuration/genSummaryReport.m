function genSummaryReport(aObj,summary)





    htmlReportFile=aObj.getSummaryReportFile();

    [data,~]=convertFieldsToCell(summary);
    header={'Model','Code inspection status','Report'};
    htmlsection=slci.internal.ReportUtil.genTable(header,data,1);

    dm=aObj.getDataManager(aObj.getModelName());
    modelFileName=dm.getMetaData('ModelFileName');
    modelLink=slci.internal.ReportUtil.createModelLink(modelFileName,...
    aObj.getModelName());
    Title=['Simulink Code Inspector Summary Report for ',modelLink];
    TitleSection=Title;

    Header='<!DOCTYPE html>\n';
    Header=[Header,'<html>\n'];
    Header=[Header,'<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >\n'];
    Header=[Header,'<head>\n'];

    Config=slci.internal.ReportConfig;


    Css=slci.internal.ReportUtil.genCSS(Config);
    Header=[Header,Css];



    Script=slci.internal.ReportUtil.genScript();
    Header=[Header,Script];


    Header=[Header,'<title>',Title,'</title>'];
    Header=[Header,'</head>\n'];

    BodyBegin='<body>\n';
    BodyEnd='</body></html>\n';

    Fid=fopen(htmlReportFile,'w','n','utf-8');
    fprintf(Fid,Header);
    fprintf(Fid,BodyBegin);

    Caption=['<div style="text-align:center"> '...
    ,slci.internal.ReportUtil.makeHeader2(TitleSection)...
    ,'</div>'];
    fprintf(Fid,Caption);

    fprintf(Fid,'<hr>\n');
    fprintf(Fid,htmlsection);

    fprintf(Fid,BodyEnd);
    fclose(Fid);


end




function[dataCell,fnames]=convertFieldsToCell(tableData)
    if~isempty(tableData)
        fnames=fields(tableData);
        numCols=numel(fnames);
        numRows=numel(tableData);
        dataCell=cell(numRows,numCols);
        for p=1:numCols
            for k=1:numRows
                fname=fnames{p};
                dataInfo=processField(tableData(k).(fname),fname);
                dataCell{k,p}=dataInfo.CONTENT;
            end
        end
    else
        dataCell={''};
        fnames={''};
    end
end

function opDataInfo=processField(dataInfo,fname)
    if isfield(dataInfo,'CONTENT')
        switch fname
        case 'Status'
            if isfield(dataInfo,'ATTRIBUTES')
                opDataInfo.CONTENT=...
                slci.internal.ReportUtil.appendColorAndTip(...
                dataInfo.CONTENT,dataInfo.ATTRIBUTES);
            else
                opDataInfo.CONTENT=dataInfo.CONTENT;
            end
        case 'Model'
            modelName=dataInfo.CONTENT;

            if~isempty(dataInfo.ATTRIBUTES)
                modelFileName=dataInfo.ATTRIBUTES;
            else
                modelFileName=dataInfo.CONTENT;
            end
            opDataInfo.CONTENT=slci.internal.ReportUtil.createModelLink(...
            modelFileName,modelName);

        case 'Report'

            dispFileName=dataInfo.CONTENT;
            reportFile=dataInfo.ATTRIBUTES;

            reportFileLink=slci.internal.ReportUtil.createRelativeFileLink(...
            reportFile,...
            dispFileName);
            opDataInfo.CONTENT=reportFileLink;
        otherwise
            opDataInfo.CONTENT=dataInfo.CONTENT;
        end
    else
        opDataInfo.CONTENT='';
    end
end


