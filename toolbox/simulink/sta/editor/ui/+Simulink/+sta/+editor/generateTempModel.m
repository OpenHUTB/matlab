function modelToGenerate=generateTempModel(model)







    modelToGenerate='TmpModelForCreatingInportGroundValues';
    existing_models=find_system('type','block_diagram');


    modelToGenerate=matlab.lang.makeUniqueStrings(modelToGenerate,existing_models);
    try
        new_system(modelToGenerate,'FromTemplate','factory_default_model');

        if~isempty(model)&&bdIsLoaded(model)


            sldd_NAME=get_param(model,'DataDictionary');
            if~isempty(sldd_NAME)
                set_param(modelToGenerate,'DataDictionary',sldd_NAME);
            end



            origModelWS=get_param(model,'modelworkspace');
            tempModelWS=get_param(modelToGenerate,'modelworkspace');

            if~isempty(origModelWS)
                NUM_VARS=length(origModelWS.data);
                dataInModelWS=origModelWS.data;
                for kVar=1:NUM_VARS
                    tempModelWS.assignin(dataInModelWS(kVar).Name,dataInModelWS(kVar).Value);
                end
            end
        end
    catch ME
        bdclose(modelToGenerate);
        throw(ME)
    end
