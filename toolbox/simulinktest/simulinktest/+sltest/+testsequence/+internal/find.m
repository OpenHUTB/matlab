
function res=find

    try
        if~Simulink.harness.internal.licenseTest()
            error(message('Simulink:Harness:LicenseNotAvailable'));
        end
        rt=sfroot();
        chart=rt.find('-isa','Stateflow.ReactiveTestingTableChart');
        s=size(chart);
        res=cell(1,s(1));
        for row=1:s(1)
            res{row}=chart(row).Path;
        end
    catch ME
        throwAsCaller(ME);
    end
end