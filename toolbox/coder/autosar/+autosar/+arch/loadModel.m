function archModel=loadModel(modelName)







    narginchk(1,1);

    try
        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>


        p=inputParser;
        p.addRequired('modelName',@(x)(ischar(x)||isStringScalar(x)||is_simulink_handle(x)));
        p.parse(modelName);


        if is_simulink_handle(modelName)
            modelName=get_param(modelName,'Name');
        end

        bd=load_system(modelName);


        archModel=autosar.arch.Model.create(bd);

    catch ME
        autosar.mm.util.MessageReporter.throwException(ME);
    end


