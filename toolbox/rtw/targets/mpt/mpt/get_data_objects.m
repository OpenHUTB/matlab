function objects=get_data_objects(symbolName,fileName)















    ecac=rtwprivate('rtwattic','AtticData','ecac');







    objects=[];
    if isfield(ecac,'file')==1
        for i=1:length(ecac.file)
            if strcmp(ecac.file{i}.name,fileName)==1
                for j=1:length(ecac.file{i}.sinfo)
                    if strcmp(ecac.file{i}.sinfo{j}.symbolName,symbolName)==1
                        objects=ecac.file{i}.sinfo{j}.objects;
                    end
                end
            end
        end
    end

