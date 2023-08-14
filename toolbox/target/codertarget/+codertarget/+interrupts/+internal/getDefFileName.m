function defFile=getDefFileName(tgtHWInfo,cpuName)




    if nargin<2
        cpuName='';
    end
    if~isempty(cpuName)
        cpuName=['_',cpuName];
    end
    coProcessorPattern='\W+';
    boardName=strtrim(regexprep(tgtHWInfo.Name,coProcessorPattern,''));
    boardName=strrep(boardName,' ','');
    boardName=strrep(boardName,'-','');
    defFile=fullfile(tgtHWInfo.TargetFolder,'registry','interrupts',[boardName,cpuName,'_interrupts.xml']);
end