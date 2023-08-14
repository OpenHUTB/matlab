function result=mdlAdvRptPath(srcName,check)




    slModel=strtok(srcName,':');
    maWorkDir=ModelAdvisor.getWorkDir(slModel);
    if ispc

        maWorkDir=strrep(maWorkDir,filesep,'/');
    end
    result=[maWorkDir,'/rmiml/',strrep(srcName,':','_'),'/',check,'.html'];

end
