function hdldebugeml






    topDirName=fullfile(matlabroot,'toolbox','hdlcoder','hdlcommon','emlauthoring');



    dirList=getHDLEMLDirList(topDirName);


    for ii=1:length(dirList)
        addpath(dirList{ii});
    end

    addpath(fullfile(matlabroot,'toolbox','shared','algorithmlowering','emlauthoring','intrinsic'));


    sf('Feature','developer','on');


    sf('Feature','Attempt fully concurrent code generation for sf/eML blocks','on');



    function dir_list=getHDLEMLDirList(topDirName)
        oldDir=pwd;
        cd(topDirName);
        cmd=sprintf('fileattrib(''%s%s*'')','.',filesep);
        [status,k]=eval(cmd);

        if(status==0)
            return;
        end

        dir_list={};
        for ii=1:length(k)
            if(k(ii).directory&&isempty(strfind(k(ii).Name,'\CVS')))
                dir_list{end+1}=k(ii).Name;%#ok<AGROW>
            end
        end
        cd(oldDir);


