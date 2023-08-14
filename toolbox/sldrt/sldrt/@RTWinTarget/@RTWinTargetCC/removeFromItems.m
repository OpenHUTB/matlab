function obj=removeFromItems(obj,tags,names)





    for gc={'Tabs','Items'}
        g=gc{1};
        if~isfield(obj,g)
            continue;
        end

        remove=[];
        for i=1:numel(obj.(g))

            obj.(g){i}=RTWinTarget.RTWinTargetCC.removeFromItems(obj.(g){i},tags,names);


            if(isfield(obj.(g){i},'Tag')&&any(strcmp(obj.(g){i}.Tag,tags)))||...
                (isfield(obj.(g){i},'Name')&&any(strcmp(obj.(g){i}.Name,names)))
                remove(end+1)=i;%#ok<AGROW>
            end
        end


        obj.(g)(remove)=[];
    end

end
