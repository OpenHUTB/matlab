function fullname=getShippingLibFullName(libname,libpath)



    assert(isunix);
    files=dir([libpath,'/',libname,'.so*']);

    fullname='';
    if~isempty(files)

        for k=1:numel(files)

            matches=regexp(files(k).name,[libname,'.so.(\d+)$'],'match');
            if isempty(matches)

                matches=regexp(files(k).name,[libname,'.so.(\d+).0$'],'match');
            end
            if~isempty(matches)
                fullname=matches{1};
                return;
            end
        end

        fullname=files(end).name;
    end

end
