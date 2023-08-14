function ret=getCustomBoardParams(boardName)
    ret=[];
    targetFolder=soc.internal.getTargetFolder(boardName);
    matFileName=[regexprep(boardName,'\s+',''),'.mat'];
    fpgaParamsMat=fullfile(targetFolder,'registry','parameters',matFileName);
    if exist(fpgaParamsMat,'file')
        load(fpgaParamsMat,'newfpgaparams');
        ret=newfpgaparams;
    end
end