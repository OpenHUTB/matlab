


function createThumbnailFromModel(thumbnailFileDestination,modelName)
    modelName=get_param(modelName,'Name');



    sel=find_system(modelName,'FindAll','on','SearchDepth',1,'Selected','on');
    if~isempty(sel)
        restore_sel=onCleanup(@()i_select(sel,'on'));
        i_select(sel,'off');
    end


    hilited=find_system(modelName,'FindAll','on','Regexp','on','SearchDepth',1,'HiliteAncestors','^((?!none).)*$');
    if~isempty(hilited)
        vals=get_param(hilited,'HiliteAncestors');
        if~iscell(vals)
            vals={vals};
        end
        restore_hilite=onCleanup(@()i_rehilite(hilited,vals));
        i_unhilite(hilited);
    end

    slCreateThumbnailImage(modelName,thumbnailFileDestination,...
    'Width',400,'Height',225);
end

function i_select(obj,val)
    arrayfun(@(e)set_param(e,'Selected',val),obj);
end

function i_unhilite(obj)
    arrayfun(@(e)set_param(e,'HiliteAncestors','none'),obj);
end

function i_rehilite(obj,val)
    for i=1:numel(obj)
        set_param(obj(i),'HiliteAncestors',val{i});
    end
end
