function[newX,newY]=findLocation(libName,spacing,width)




    tmpBlks=find_system(libName,'searchdepth',1,'FollowLinks','on');
    newY=spacing;

    maxX=spacing;
    for jj=2:length(tmpBlks)
        pos=get_param(tmpBlks{jj},'position');
        if pos(3)>maxX
            maxX=pos(3);
        end
    end
    if maxX+width+2*spacing>32767

        newX=spacing;
    else
        newX=maxX;
    end
end