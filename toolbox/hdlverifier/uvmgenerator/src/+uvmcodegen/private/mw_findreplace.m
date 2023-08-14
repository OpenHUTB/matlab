function string=mw_findreplace(instring)







    pkginfo=what('+uvmcodegen');


    if(exist('user_custom.mat')==2)
        load('user_custom.mat');
        keys=user_custom.keys;
        for k=1:length(uvmcodegen_semaphore.keys);
            try
                keyval=evalin('base',user_custom(keys{k}));
            catch
                keyval=user_custom(keys{k});
            end

            instring=replace(instring,['%',keys{k},'%'],keyval);
        end
    end


    load([pkginfo.path,'/lib/uvmcodegen_semaphore.mat']);
    keys=uvmcodegen_semaphore.keys;
    for k=1:length(uvmcodegen_semaphore.keys);
        try
            keyval=evalin('base',uvmcodegen_semaphore(keys{k}));
        catch
            keyval=uvmcodegen_semaphore(keys{k});
        end

        instring=replace(instring,['%',keys{k},'%'],keyval);
    end

    string=instring;
end
