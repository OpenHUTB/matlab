function feedwidth=getFeedWidth(obj)
    feedWidth=obj.MesherStruct.Mesh.FeedWidth;
    if any(iscell(feedWidth))
        feedwidth=cell2mat(feedWidth);
        feedwidth=feedwidth(:);
    else
        feedwidth=obj.MesherStruct.Mesh.FeedWidth;
    end
end
