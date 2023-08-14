
function xlsInfo=getInputFileInfo(fileName)




    scenarios='';
    xlsInfo.FileType=0;
    [~,~,ext]=fileparts(fileName);
    if(strcmpi(ext,'.mat'))
        xlsInfo.FileType=1;

        scenarios=whos('-file',fileName);
        if~isempty(scenarios)&&strcmpi(scenarios(1).name,'sldvdata')
            xlsInfo.FileType=3;

            s=load(fileName);


            isTest=isfield(s.sldvData,'TestCases');
            isCounterExample=isfield(s.sldvData,'CounterExamples');

            if(isTest)
                count=numel(s.sldvData.TestCases);
            end

            if(isCounterExample)
                count=numel(s.sldvData.CounterExamples);
            end

            if isTest||isCounterExample

                [~,title]=Sldv.DataUtils.getSimData(s.sldvData);
                scenarios=repmat(string(title),[1,count]);
                scenarios=cellstr(scenarios+":"+(1:count));
            else

                error(message('stm:InputsView:EmptySLDVFile'));
            end
        end
    elseif any(strcmpi(ext,[xls.internal.WriteTable.SpreadsheetExts,"csv"]))
        xlsInfo.FileType=2;
        scenarios=sheetnames(fileName).cellstr.';
    end

    xlsInfo.Scenarios=scenarios;
end
