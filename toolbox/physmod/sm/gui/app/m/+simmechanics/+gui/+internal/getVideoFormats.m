function[formatNameArray,formatExtArray]=getVideoFormats()







    rawFormatNameArray={VideoWriter.getProfiles.Name};
    rawFormatExtArray={VideoWriter.getProfiles.FileExtensions};


    excludeFormats={'Grayscale AVI','Indexed AVI'};

    formatNameArray=cell(1,0);
    formatExtArray=cell(1,0);




    for k=1:length(rawFormatNameArray)

        if~ismember(rawFormatNameArray{k},excludeFormats)

            formatNameArray(end+1)=rawFormatNameArray(k);%#ok

            if length(rawFormatExtArray{k})>1
                equivalentExt=strjoin(rawFormatExtArray{k},'&');
                formatExtArray(end+1)={equivalentExt};%#ok
            else
                formatExtArray(end+1)=rawFormatExtArray{k};%#ok
            end

        end

    end


    formatExtArray=strrep(formatExtArray,'.','');
end