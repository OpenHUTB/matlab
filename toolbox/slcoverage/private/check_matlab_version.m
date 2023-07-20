function matlabVersion=check_matlab_version






    remain=['.',version];
    matlabVersion=[];
    for i=1:3
        [token1,remain]=strtok(remain(2:end),'.');
        matlabVersion=[matlabVersion,token1];
    end


    matlabVersion=eval(matlabVersion);
    isOk=(matlabVersion>=530);
    if~isOk
        more('off');
        fileName=mfilename;
        [i,j,k]=regexp(fileName,['\',filesep,'(\w+)\',filesep,'private\',filesep,'.*$'],'once');
        if(~isempty(i)&&~isempty(k))

            componentName=fileName(k{1}(1):k{1}(2));
            componentVersion=evalc(['type(''',componentName,'/Contents.m'')']);
            [s,e]=regexp(componentVersion,'Version[^\n]*','once');
            if(~isempty(s))
                componentVersion=componentVersion(s:e);
            else
                componentVersion='unknown (there is no version number in its Contents.m)';
            end
        else
            componentName='<unknown component>';
            componentVersion='unknown';
        end

        componentName(1)=upper(componentName(1));
        error(message('Slvnv:simcoverage:check_matlab_version:MatlabVersionCheck',componentName,componentName,componentName,componentVersion,version,componentName));


    end


