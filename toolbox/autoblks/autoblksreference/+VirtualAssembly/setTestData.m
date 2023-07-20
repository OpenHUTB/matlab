function Indata=setTestData(ConfigInfo,TestID,in)

    Config=load(ConfigInfo);
    id=str2double(TestID);
    testplan=Config.ConfigInfos.TestPlanArray{id};
    testdata=Config.ConfigInfos.TestPlanArray{id}.Data;
    Indata=in;

    if~isempty(testdata)
        for i=1:length(testdata)
            var=testdata{i};
            newvalue=str2double(var{2});
            if isnan(newvalue)
                Indata=Indata.setVariable(var{1},var{2});
            else
                Indata=Indata.setVariable(var{1},newvalue);
            end

        end
    end

end

