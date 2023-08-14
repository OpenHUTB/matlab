function result=is_doors_installed()



    persistent registered;

    if isempty(registered)
        registered=false;
        if ispc

            masterKey={'HKEY_LOCAL_MACHINE','HKEY_CURRENT_USER'};
            subKey={'SOFTWARE','SOFTWARE\Wow6432Node'};
            vendor={'Telelogic','IBM'};

            for i=1:length(masterKey)
                mKey=masterKey{i};
                for j=1:length(subKey)
                    sKey=subKey{j};
                    for k=1:length(vendor)
                        v=vendor{k};
                        try


                            winqueryreg('name',mKey,[sKey,'\',v,'\DOORS']);
                            registered=true;
                            result=true;
                            return;
                        catch ex %#ok<NASGU>
                            lasterror('reset');%#ok<LERR>
                            continue;
                        end
                    end
                end
            end
        end
    end

    result=registered;
end
