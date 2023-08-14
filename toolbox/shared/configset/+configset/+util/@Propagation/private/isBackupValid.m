function t=isBackupValid(file)

    t=false;

    if exist(file,'file')==2
        b=load(file);
        if isfield(b,'infoStruct')
            h=b.infoStruct;
            if isa(h,'configset.util.Propagation')
                t=true;
            end
        end
    end
