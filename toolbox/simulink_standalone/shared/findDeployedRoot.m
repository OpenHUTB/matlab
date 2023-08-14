


function deployed_root=findDeployedRoot(file_dir)
    deployed_root='';
    evalc('file_list = dir(file_dir);');
    for i=1:length(file_list)
        if(~isempty(deployed_root))
            return;
        end
        file_name=file_list(i).name;
        if(file_name=="."||file_name=="..")
            continue
        end
        if(file_list(i).isdir)
            if(file_list(i).name=="slprj")
                deployed_root=file_dir;
                return;
            else
                deployed_root=findDeployedRoot(fullfile(file_dir,file_name));
            end
        end
    end
end
