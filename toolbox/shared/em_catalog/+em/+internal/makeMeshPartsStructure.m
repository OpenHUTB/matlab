function parts=makeMeshPartsStructure(varargin)












    parts.GroundPlanes.Gnd=[];
    parts.NumGnds=0;
    parts.Radiators.Rad=[];
    parts.NumRads=0;
    parts.Feeds.Feed=[];
    parts.NumFeeds=0;
    parts.Vias.Via=[];
    parts.NumVias=0;
    parts.Others.Other=[];
    parts.NumOthers=0;


    codelist=varargin(1:2:end);
    partlist=varargin(2:2:end);
    idxGnd=1;
    idxRad=1;
    idxFeed=1;
    idxVia=1;
    idxOther=1;
    for i=1:numel(codelist)
        switch codelist{i}
        case 'Gnd'
            parts.GroundPlanes.Gnd{idxGnd}=partlist{i};
            idxGnd=idxGnd+1;
        case 'Rad'
            parts.Radiators.Rad{idxRad}=partlist{i};
            idxRad=idxRad+1;
        case 'Feed'
            parts.Feeds.Feed{idxFeed}=partlist{i};
            idxFeed=idxFeed+1;
        case 'Via'
            parts.Vias.Via{idxVia}=partlist{i};
            idxVia=idxVia+1;
        case 'Other'
            parts.Others.Other{idxOther}=partlist{i};
            idxOther=idxOther+1;
        otherwise
            error(message('antenna:antennaerrors:InvalidOption'));
        end
    end

    parts.NumGnds=idxGnd-1;
    parts.NumRads=idxRad-1;
    parts.NumFeeds=idxFeed-1;
    parts.NumVias=idxVia-1;
    parts.NumOthers=idxOther-1;


end
