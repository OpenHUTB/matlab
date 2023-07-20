function[FeedPoints,feed_pt1,feed_pt2]=getProbeFeedPortPoints(obj)

    FeedPoints=obj.PortPoints;
    feed_pt1=FeedPoints(:,1);
    feed_pt2=FeedPoints(:,2);

end