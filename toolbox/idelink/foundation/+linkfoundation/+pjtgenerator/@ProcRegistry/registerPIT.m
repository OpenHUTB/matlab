function registerPIT(reg,pitFiles,pitFileTypes)





    if isempty(pitFiles)

        return;
    end




    pitFiles=cellstr(pitFiles);





    if~iscell(pitFileTypes)
        array={};
        [array{1:length(pitFiles)}]=deal(pitFileTypes);
        pitFileTypes=array;
    end

    for i=1:length(pitFiles)


        if isPITRegistered(reg,pitFiles{i})
            continue;
        end

        if~exist(pitFiles{i},'file')
            continue;
        end


        pit=loadPIT(reg,pitFiles{i});


        switch pitFileTypes{i}
        case 'default'
            len=length(reg.pit_default);
            reg.pit_default(len+1).pitFileName=pitFiles{i};
            reg.pit_default(len+1).pit=pit;
        case 'custom'
            len=length(reg.pit_custom);
            reg.pit_custom(len+1).pitFileName=pitFiles{i};
            reg.pit_custom(len+1).pit=pit;
        otherwise
            DAStudio.error('ERRORHANDLER:pjtgenerator:InvalidPITFileType',pitType);
        end
    end

end
