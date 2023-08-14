function emcRemoveFile(filePath,fileName)



    ff=fullfile(filePath,fileName);

    if ischar(ff)
        ff={ff};
    end

    I=cellfun(@(f)(fileattrib(f)~=0),ff);
    ff=ff(I);

    if isempty(ff)
        return;
    end

    delete(ff{:});
end
