


function result=FMUInfoMatMgr(rtwStruct,~)

    try
        fmuInfo=rtwStruct;
        cgModel=get_param(fmuInfo.Name,'CGModel');

        cgModel_copy.CGTypes=[];
        for i=1:length(cgModel.CGTypes)



            cgModel_copy.CGTypes(i).Name=cgModel.CGTypes(i).Name;
            cgModel_copy.CGTypes(i).Members=[];
            for j=1:cgModel.CGTypes(i).Members.Size
                cgModel_copy.CGTypes(i).Members(j).Name=...
                cgModel.CGTypes(i).Members(j).Name;
            end
        end

        save(fullfile(rtwStruct.RTWGenSettings.RelativeBuildDir,'fmuInfo.mat'),'fmuInfo','cgModel_copy');
        result=1;
    catch ex


        disp(ex);
        error(ex.identifier,ex.message);
        result=0;
    end
end
