function tlcIncludePaths=getCommonTLCIncludePaths(rtwroot,aSystemTargetFile)






    tlcIncludePaths={};
    if contains(aSystemTargetFile,filesep)
        k=strfind(aSystemTargetFile,filesep);
        tlcIncludePaths{end+1}=aSystemTargetFile(1:k(end)-1);
    end
    tlcIncludePaths{end+1}=fullfile(rtwroot,'c','tlc','blocks');
    tlcIncludePaths{end+1}=fullfile(rtwroot,'c','tlc','fixpt');
    tlcIncludePaths{end+1}=fullfile(rtwroot,'c','tlc','public_api');
    tlcIncludePaths{end+1}=fullfile(rtwroot,'c','tlc','private_api');


    tlcIncludePaths{end+1}=fullfile(matlabroot,'toolbox','stateflow','src','tlc');
end
