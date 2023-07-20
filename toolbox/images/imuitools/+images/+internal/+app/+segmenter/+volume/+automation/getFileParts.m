function[path,name]=getFileParts(fullpath)







    [path,name,~]=fileparts(char(fullpath));

    if contains(path,'+')


        dirs=strsplit(path,filesep);

        if~isempty(dirs)

            for idx=numel(dirs):-1:1

                if contains(dirs{idx},'+')
                    str=strrep(dirs{idx},'+','');
                    name=[str,'.',name];%#ok<AGROW>
                else



                    path='';
                    for i=1:idx
                        path=[path,dirs{i}];%#ok<AGROW>
                    end
                    break;
                end

            end

        end

    end

end