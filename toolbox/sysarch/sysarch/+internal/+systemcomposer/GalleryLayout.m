function GalleryLayout(gallery,sceneWidth)
    itemOffsetX=25;
    itemOffsetY=25;
    curPosition=struct('x',itemOffsetX,'y',itemOffsetY);
    maxWidth=sceneWidth-itemOffsetX;
    if(maxWidth<0)
        maxWidth=1024-itemOffsetX;
    end

    for i=1:gallery.entities.Size
        entity=gallery.entities.at(i);

        if strcmp(entity.type,'gallery.GalleryItem')
            entity.position.x=round(curPosition.x);
            entity.position.y=round(curPosition.y);

            curPosition.x=curPosition.x+entity.size.width+itemOffsetX;
            if(curPosition.x+entity.size.width+itemOffsetX>maxWidth)
                curPosition.y=round(curPosition.y+entity.size.height+itemOffsetY);
                curPosition.x=itemOffsetX;
            end
        end
    end

    if(curPosition.x+entity.size.width+itemOffsetX>maxWidth)
        curPosition.y=round(curPosition.y+entity.size.height+itemOffsetY);
        curPosition.x=itemOffsetX;
    end
    gallery.GhostItem.position.x=round(curPosition.x);
    gallery.GhostItem.position.y=round(curPosition.y);
end