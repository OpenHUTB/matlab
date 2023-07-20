function[modelName,ownerModelName]=getModelNameFromScenarioFile(filename)



    filename=which(filename);


    staOPCPkg=sta.StaMLDATX;

    try

        modelName=staOPCPkg.readModel(filename,'/stascenario.xml');
        ownerModelName=staOPCPkg.readModelOwner(filename,'/stascenario.xml');
    catch ME


        if strcmpi(ME.identifier,'sl_sta_repository:sta_repository:cannotReadFile')

            modelName=[];
            ownerModelName=[];
        else

            rethrow(ME);
        end
    end
