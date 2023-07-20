
function hasNonDefaultSync=updateBaselineFile(baselineFile,sheet,range,runId)


    hasNonDefaultSync=false;

    if exist(baselineFile,'file')~=2
        error(message('stm:BaselineCriteria:BaselineFileNotExists',baselineFile));
    end

    [~,fileName,ext]=fileparts(baselineFile);

    if strcmpi(ext,'.mat')
        Simulink.sdi.exportRun(runId,'to','file','filename',baselineFile)
    elseif any(xls.internal.WriteTable.SpreadsheetExts.contains(ext,'IgnoreCase',true))

        sheetsFromFile=sheetnames(baselineFile);
        if~any(strcmp(sheetsFromFile,sheet))
            error(message('stm:BaselineCriteria:BaselineSheetNotExist',sheet,[fileName,ext]));
        end


        ds=Simulink.sdi.exportRun(runId);


        if~isempty(range)
            range=strsplit(range,':');
            range=range{1};
        end
        wt=xls.internal.WriteTable(ds,'filename',baselineFile,...
        'sheet',sheet,'range',string(range),...
        'SourceType',xls.internal.SourceTypes.Output,...
        'PreserveTolerance',true);
        wt.write;
        hasNonDefaultSync=wt.hasIntscnSync;
    else
        error(message('stm:BaselineCriteria:CannotUpdateNonMatExcelBaseline'));
    end
end
