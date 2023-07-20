function feedloc=calculateLinearArrayFeedLocation(obj)


    if isfield(obj.privateArrayStruct,'ElementSpacing')&&...
        all(~cellfun(@isempty,{obj.ArraySize,obj.ElementSpacing}))
        checkElementSpacing(obj);
        arraysize=obj.ArraySize;
        rowspacing=[];
        colspacing=obj.ElementSpacing;
        lattice='none';
        skew=0;
    else
        feedloc=[];
        return;
    end
    if any(strcmpi(class(obj.Element),'linearArray'))
        sub_array=em.Array.makeSubArray(obj);
        feedloc=sub_array.FeedLocation;
    else
        feedloc=translateAndCalculateFeedLoc(obj,arraysize,rowspacing,...
        colspacing,lattice,skew);

        feedloc=assignFeedLocation(obj,feedloc);
    end
end