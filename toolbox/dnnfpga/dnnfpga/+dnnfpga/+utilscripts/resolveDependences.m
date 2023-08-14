function[dep,visited]=resolveDependences(dir,visited)



    dep={};
    curDir=pwd;
    cd(dir);
    if(~findInCell(visited,pwd))
        visited=[visited;pwd];
        if(exist(fullfile(pwd,'dependence.m'),'file')==2)
            depends=dependence();
        else
            depends={};
        end
        for i=1:length(depends)
            [depT,visited]=dnnfpga.utilscripts.resolveDependences(depends{i},visited);
            dep=[dep;depT];
        end
        dep=[dep;pwd];

        [status,libMdlStr]=system('ls *lib.slx');
        if(status==0)
            libMdls=split(libMdlStr);
            for i=1:length(libMdls)
                if(~isempty(libMdls{i}))
                    load_system(libMdls{i});
                end
            end
        end
    end
    cd(curDir);
end

function found=findInCell(visited,new)
    found=any(strcmp(visited,new));
end
