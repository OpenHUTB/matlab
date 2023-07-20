function[unsplitViaEdges,unsplitFeedEdges]=makeUnsplitEdgeArray(obj,via_pt1,via_pt2,feed_pt1,feed_pt2)

    unsplitViaEdges=[];
    unsplitFeedEdges=[];
    if~isempty(via_pt1)
        via1=via_pt1(cellfun(@(x)~isempty(x),via_pt1));
        via2=via_pt2(cellfun(@(x)~isempty(x),via_pt2));
        for i=1:numel(via1)
            viap1=via1{i}(:,1:2);
            viap2=via2{i}(:,1:2);
            for j=1:size(viap1,1)
                unsplitViaEdges=[unsplitViaEdges;viap1(j,:);viap2(j,:)];
            end
        end

    end

    if~isempty(feed_pt1)
        unsplitFeedEdges=[unsplitFeedEdges;feed_pt1;feed_pt2];
    end

end