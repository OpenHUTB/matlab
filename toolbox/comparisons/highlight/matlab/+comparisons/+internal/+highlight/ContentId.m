classdef ContentId




    properties(Constant)
        Report="Report",
        Left="Left",
        Right="Right",
        Theirs="Theirs",
        Base="Base",
        Mine="Mine",
        Target="Target"

        AllSides=getAllSides()
    end
end

function allSides=getAllSides()
    import comparisons.internal.highlight.ContentId

    allSides=[;...
    ContentId.Left,...
    ContentId.Right,...
    ContentId.Theirs,...
    ContentId.Base,...
    ContentId.Mine,...
    ContentId.Target,...
    ];

end
