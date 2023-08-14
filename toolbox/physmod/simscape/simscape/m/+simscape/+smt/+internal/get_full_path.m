function fullPath=get_full_path(componentName)




    fullPath=which(componentName);









    if isempty(fullPath)
        [dir,file,ext]=fileparts(componentName);
        if isempty(ext)


            ext='.ssc';
        end
        maybePath=fullfile(dir,strcat(file,ext));
        if exist(maybePath,'file')
            fullPath=maybePath;
        end
    end



    if isempty(fullPath)
        pm_error('physmod:simscape:simscape:smt:NonExistComponent',componentName);
    end


    [~,~,ext]=fileparts(fullPath);


    if strcmpi(ext,'.sscp')
        pm_error('physmod:simscape:simscape:smt:ProtectedFile',fullPath);
    end


    if~strcmpi(ext,'.ssc')
        pm_error('physmod:simscape:simscape:smt:SimscapeFileOnly',fullPath);
    end
end
