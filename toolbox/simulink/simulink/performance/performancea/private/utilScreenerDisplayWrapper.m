function utilScreenerDisplayWrapper(fileName)

    fileList=which(fileName);

    matlabToolboxPath=[matlabroot,filesep,'toolbox'];
    if isempty(fileList)
        return;
    elseif~isempty(strfind(fileList,matlabToolboxPath))
        msgbox(DAStudio.message('SimulinkPerformanceAdvisor:advisor:InternalFiles'));
        return;
    end

    coder.screener(fileName);
end
