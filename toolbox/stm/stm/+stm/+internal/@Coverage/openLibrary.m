

function model=openLibrary(cvdata,model,harnessOwner)
    harnessList=sltest.harness.find(harnessOwner,'OpenOnly','on');
    if~isempty(harnessList)

        model={harnessList.name};
    else
        harnessModels=strsplit(cvdata.modelinfo.harnessModel,', ');
        for i=1:length(harnessModels)
            harnessList=sltest.harness.find(harnessOwner,'Name',harnessModels{i});
            if~isempty(harnessList)
                model={harnessModels{i}};
                sltest.harness.open(harnessOwner,model);
                break;
            end
        end
    end
end