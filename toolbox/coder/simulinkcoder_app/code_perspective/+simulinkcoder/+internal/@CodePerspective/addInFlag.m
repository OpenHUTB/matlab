function out=addInFlag(obj,mdl,studio)


    obj.cleanupFlags(mdl);
    flags=get_param(mdl,'CodePerspectiveFlags');


    for i=1:length(flags)
        f=flags{i};
        if studio==f.studio
            return;
        end
    end


    out=simulinkcoder.internal.CodePerspectiveInStudio(studio);
    flags{end+1}=out;
    set_param(mdl,'CodePerspectiveFlags',flags);


