function breakpointsInfo=CollectBreakpointsInfoForSFAndCGXEMex(modelH)
    modelName=get_param(modelH,'Name');
    breakpointsInfo=[];
    idx=0;

    cgxeProjRootDir=cgxeprivate('get_cgxe_proj_root');
    cgxeMexFileName=fullfile(cgxeProjRootDir,[modelName,'_cgxe.',mexext]);
    if exist(cgxeMexFileName,'file')==3
        mexFcnName=[modelName,'_cgxe'];
        chksums=feval(mexFcnName,'get_checksums');
        chksumStr=cgxe('MD5AsString',chksums.modules{1});
        filePath=fullfile(cgxeProjRootDir,'slprj','_cgxe',modelName,'src',strcat('m_',chksumStr,'.c'));
        fileText=regexp(fileread(filePath),'\n','split');

        lineNums=find(contains(fileText,'static void cgxe_mdl_outputs('));
        idx=idx+1;
        breakpointsInfo().FunctionName='cgxe_mdl_outputs';
        breakpointsInfo(idx).FileName=strcat('m_',chksumStr,'.c');
        breakpointsInfo(idx).FileFullPath=filePath;
        breakpointsInfo(idx).Line=lineNums(end);
    end


    sfProjRootDir=sfprivate('get_sf_proj_root');
    sfMexFileName=fullfile(sfProjRootDir,[modelName,'_sfun.',mexext]);

    if exist(sfMexFileName,'file')==3
        machineId=sf('find','all','machine.name',modelName);
        chartIds=sf('get',machineId,'machine.charts');
        machineName=sf('get',machineId,'.name');
        dirPath=sfprivate('get_sf_proj',sfProjRootDir,machineName,machineName,'sfun','src');
        for i=1:numel(chartIds)
            chartFileNumber=sf('get',chartIds(i),'chart.chartFileNumber');
            fileName=['c',num2str(chartFileNumber),'_',machineName,'.c'];
            fcnName=['sf_gateway_','c',num2str(chartFileNumber),'_',machineName];
            filePath=fullfile(dirPath,fileName);
            fileText=regexp(fileread(filePath),'\n','split');
            pattern=['static void ',fcnName];
            lineNums=find(contains(fileText,pattern));
            idx=idx+1;
            breakpointsInfo(idx).FunctionName=fcnName;
            breakpointsInfo(idx).FileName=fileName;
            breakpointsInfo(idx).FileFullPath=filePath;
            breakpointsInfo(idx).Line=lineNums(end);
        end
    end
end