

function release=fetchReleaseFromCvtFile(fileName)
    file=fullfile(fileName);
    [~,cvdata]=cvload(file);
    covObjects=cvdata{1};
    if isa(covObjects,'cv.cvdatagroup')

        covObjects=covObjects.getAll;
    end
    if(isprop(covObjects,'dbVersion'))
        release=regexprep(covObjects.dbVersion,'[() ]','');
    else
        release='-';
    end
end