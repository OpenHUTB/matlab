function setFeedType(obj,feedtype)

    if iscell(feedtype)
        for m=1:numel(feedtype)
            testfeedtype=strcmp(feedtype{m},{'singleedge','doubleedge','multiedge'});
            if~any(testfeedtype)
                error(message('antenna:antennaerrors:IncorrectOption',...
                'feedtype','singleedge or doubleedge or multiedge'));
            end
        end
    else
        testfeedtype=strcmp(feedtype,{'singleedge','doubleedge','multiedge'});
        if~any(testfeedtype)
            error(message('antenna:antennaerrors:IncorrectOption',...
            'feedtype','singleedge or doubleedge or multiedge'));
        end
    end
    obj.MesherStruct.Mesh.FeedType=feedtype;

end