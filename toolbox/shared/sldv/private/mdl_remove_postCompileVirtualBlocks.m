function mdl_remove_postCompileVirtualBlocks()





    [objs,source]=avtcgirunsupcollect('getall');
    index=strcmp('simulink',source);

    if any(index)
        sl_objects=objs(index);
        removePostCompileVirtualBlocks(sl_objects);
    end
end

function removePostCompileVirtualBlocks(objects)

    objects=unique(objects);

    for i=1:length(objects)
        if ishandle(objects(i))
            obj=get_param(objects(i),'object');
            try
                if obj.isPostCompileVirtual||...
                    strcmp(get_param(objects(i),'Virtual'),'on')
                    blk_mark_supported(objects(i),false);
                end
            catch Mex %#ok<NASGU>
            end
        end
    end
end
