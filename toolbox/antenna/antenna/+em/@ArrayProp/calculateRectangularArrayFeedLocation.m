function feedloc=calculateRectangularArrayFeedLocation(obj)

    if isfield(obj.privateArrayStruct,'RowSpacing')&&all(~cellfun(@isempty,{obj.ArraySize,obj.RowSpacing,obj.ColumnSpacing,obj.Lattice}))
        checkRowSpacing(obj);
        checkColumnSpacing(obj);
        checkLattice(obj);
        arraysize=obj.ArraySize;
        rowspacing=obj.RowSpacing;
        colspacing=obj.ColumnSpacing;
        lattice=obj.Lattice;
        skew=obj.LatticeSkew;
    else
        feedloc=[];
        return;
    end
    if any(strcmpi(class(obj.Element),{'linearArray','rectangularArray'}))
        sub_array=em.Array.makeSubArray(obj);
        feedloc=sub_array.FeedLocation;
    else
        feedloc=translateAndCalculateFeedLoc(obj,arraysize,rowspacing,...
        colspacing,lattice,skew);

        feedloc=assignFeedLocation(obj,feedloc);
    end
end