function newPaths=emcGuardProjectPaths(oldPaths)



    paths=strtrim(regexp(oldPaths,sprintf('[\n%s]',pathsep),'split'));

    newPaths=strjoin(paths,newline);
end