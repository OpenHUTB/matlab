function uniqueFiles=ne_uniquifysourcefiles(files)









    mFilesIdx=~cellfun(@isempty,regexp(files,'\.m$','once'));
    pFilesIdx=~cellfun(@isempty,regexp(files,'\.p$','once'));
    sscFilesIdx=~cellfun(@isempty,regexp(files,'\.ssc$','once'));
    sscpFilesIdx=~cellfun(@isempty,regexp(files,'\.sscp$','once'));
    mFiles=files(mFilesIdx);
    pFiles=files(pFilesIdx);
    sscFiles=files(sscFilesIdx);
    sscpFiles=files(sscpFilesIdx);

    otherFiles=files(~(mFilesIdx|pFilesIdx|sscFilesIdx|sscpFilesIdx));




    mFilesNoExt=regexprep(mFiles,'\.m$','');
    pFilesNoExt=regexprep(pFiles,'\.p$','');
    sscFilesNoExt=regexprep(sscFiles,'\.ssc$','');
    sscpFilesNoExt=regexprep(sscpFiles,'\.sscp$','');



    pm_assert(numel(mFiles)==numel(mFilesNoExt),'MATLAB files and MATLAB files w/o extension don''t match');
    pm_assert(numel(pFiles)==numel(pFilesNoExt),'p files and p files w/o extension don''t match');
    pm_assert(numel(sscFiles)==numel(sscFilesNoExt),'ssc files and ssc files w/o extension don''t match');
    pm_assert(numel(sscpFiles)==numel(sscpFilesNoExt),'sscp files and sscp files w/o extension don''t match');



    [junk,pFileIdx]=setdiff(pFilesNoExt,mFilesNoExt);
    uniquePFiles=pFiles(pFileIdx);
    uniquePFilesNoExt=regexprep(uniquePFiles,'\.p$','');



    [junk,sscFileIdx]=setdiff(sscFilesNoExt,mFilesNoExt);
    uniqueSscFiles=sscFiles(sscFileIdx);


    sscFilesNoMNoExt=regexprep(uniqueSscFiles,'\.ssc$','');
    [junk,sscFileIdx2]=setdiff(sscFilesNoMNoExt,uniquePFilesNoExt);
    uniqueSscFiles2=uniqueSscFiles(sscFileIdx2);


    [junk,sscpFileIdx]=setdiff(sscpFilesNoExt,sscFilesNoExt);
    uniqueSscpFiles1=sscpFiles(sscpFileIdx);


    sscpFilesOnlyNoExt=regexprep(uniqueSscpFiles1,'\.sscp$','');
    [junk,sscpFileIdx]=setdiff(sscpFilesOnlyNoExt,mFilesNoExt);
    uniqueSscpFiles2=uniqueSscpFiles1(sscpFileIdx);


    sscpFilesOnlyNoExt2=regexprep(uniqueSscpFiles2,'\.sscp$','');
    [junk,sscpFileIdx2]=setdiff(sscpFilesOnlyNoExt2,uniquePFilesNoExt);
    uniqueSscpFiles3=uniqueSscpFiles2(sscpFileIdx2);


    uniqueFiles={mFiles{:},uniquePFiles{:},...
    uniqueSscFiles2{:},uniqueSscpFiles3{:},otherFiles{:}};

end
