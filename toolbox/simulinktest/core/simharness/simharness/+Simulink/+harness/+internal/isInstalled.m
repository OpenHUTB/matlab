function result=isInstalled
    result=strlength(which('sltest.harness.create'))>0;
end
