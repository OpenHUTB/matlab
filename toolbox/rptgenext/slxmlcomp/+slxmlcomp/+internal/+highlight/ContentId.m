classdef ContentId




    properties(Constant)
        Report="Report",
        Left="Left",
        Right="Right",
        Theirs="Theirs",
        Base="Base",
        Mine="Mine",
        Target2="Target2"
        Target3="Target3"

        AllSides=getAllSides()
    end
end

function allSides=getAllSides()
    import slxmlcomp.internal.highlight.ContentId

    allSides=[;...
    ContentId.Left,...
    ContentId.Right,...
    ContentId.Theirs,...
    ContentId.Base,...
    ContentId.Mine,...
    ContentId.Target2,...
    ContentId.Target3,...
    ];

end
