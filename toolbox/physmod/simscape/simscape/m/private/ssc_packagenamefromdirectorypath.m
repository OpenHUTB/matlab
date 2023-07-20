function[packageDir,packageName]=ssc_packagenamefromdirectorypath(dirPath)




    getPackageName=ne_private('ne_packagenamefromdirectorypath');

    [packageDir,packageName]=getPackageName(dirPath);

end
