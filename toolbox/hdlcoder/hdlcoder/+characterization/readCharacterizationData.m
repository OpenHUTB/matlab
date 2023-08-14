function readCharacterizationData(ctx,suppressWarning)



    fullCharacterizationData={};
    try

        fullPath=characterization.getCharacterizationDataPath(suppressWarning);
        allDetails=what(fullPath);
        allMatFiles=allDetails.mat;
        for i=1:numel(allMatFiles)
            matfile=allMatFiles{i};

            [~,compName,~]=fileparts(matfile);
            cData=load(fullfile(fullPath,matfile));
            if isempty(fullCharacterizationData)
                fullCharacterizationData={{{compName},{cData}}};
            else
                fullCharacterizationData{end+1}={{compName},{cData}};
            end

        end
        ctx.buildCharacterizationData(fullCharacterizationData);
    catch e
        e.getReport()
    end





    if(ctx.dutHasMultipleSampleTimes())
        warnObj=message('HDLShared:hdlshared:cpeignoresmultirate');
        if~suppressWarning
            warning(warnObj);
        end
    end
