function cleanup(this)




    this.uncompileAllModels();
    closeModels(this);
    cleanRtwFiles(this);


    this.FailedCompiledModelList.clear();
    this.CompiledModelList.clear();


    this.reset;



    function closeModels(z)

        okModels=z.PreRunOpenModels;

        if any(isnan(okModels))
            okModels=[];
        end

        allModels=find_system(0,...
        'SearchDepth',1,...
        'type','block_diagram');

        badModels=setdiff(allModels,okModels);

        for i=1:length(badModels)
            try
                bdclose(badModels(i));
            catch ME %#ok 
            end
        end


        function cleanRtwFiles(adSL)


            rtwDir=tempdir;
            for i=1:length(adSL.RtwCompiledModels)
                fName=fullfile(rtwDir,[adSL.RtwCompiledModels{i},'.rtw']);
                if exist(fName,'file')
                    try
                        delete(fName);
                    catch ME
                        warning(ME.message);
                    end
                end
            end
