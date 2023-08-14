function paths=fix_windows_paths_for_make_file(paths)






    paths=RTW.transformPaths(paths,'pathType','full','ignoreErrors',true);


    paths=regexprep(paths,'\$','\$\$');
end