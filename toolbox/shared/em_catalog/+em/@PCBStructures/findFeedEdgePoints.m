function[feed_edgept1,feed_edgept2,isFeedEdgeEmpty]=findFeedEdgePoints(obj,p_temp,t_temp,StartLayer,...
    viapolys,false)

    feed=obj.modifiedFeedLocations(:,1:2);
    feed_edgept1=[];
    feed_edgept2=[];
    isFeedEdgeEmpty=false;
    for i=1:numel(StartLayer)
        [feedpoint1,feedpoint2]=em.internal.findPortPoints(p_temp{StartLayer(i)}',t_temp{StartLayer(i)}',feed(i,:));
        if~isempty(feedpoint1)&&~isempty(feedpoint2)
            feed_edgept1=[feed_edgept1;feedpoint1(1:2)];
            feed_edgept2=[feed_edgept2;feedpoint2(1:2)];
        else
            isFeedEdgeEmpty=true;
        end

    end

end