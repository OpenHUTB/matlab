function[outComponentPath]=getReferenceBlockPath(inComponentPath)




    outComponentPath=inComponentPath;
    if~strcmp(get_param(inComponentPath,'Type'),'block_diagram')&&...
        (strcmp(get_param(inComponentPath,'LinkStatus'),'resolved')||...
        strcmp(get_param(inComponentPath,'LinkStatus'),'implicit'))
        outComponentPath=get_param(inComponentPath,'ReferenceBlock');
    end

end

