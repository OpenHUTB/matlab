function createPCBStack(obj,pcb)













    if numel(obj.Element)>1
        error(message('antenna:antennaerrors:PcbStackConversionNotSupported','array with distinct elements'));
    end

    if isa(obj.Element,'em.Array')
        error(message('antenna:antennaerrors:PcbStackConversionNotSupported','sub-array'));
    end

    try
        pcbelement=pcbStack(obj.Element);
        createGeometry(obj);
    catch ME
        rethrow(ME);
    end
    translationVec=obj.TranslationVector;
    arrayFeedLocations=obj.FeedLocation;
    numElements=getTotalArrayElems(obj);


    for m=1:numel(pcbelement.Layers)
        if isa(pcbelement.Layers{m},'antenna.Shape')

            for n=1:numElements
                templayer{n}=copy(pcbelement.Layers{m});
                templayer{n}=translate(templayer{n},translationVec(n,:));
            end
            layers{m}=templayer{1};
            for n=2:numElements
                layers{m}=layers{m}+templayer{n};
            end
        else
            layers{m}=copy(pcbelement.Layers{m});
        end
    end


    for m=1:numel(pcbelement.Load)
        for n=1:numElements
            tempload=copy(pcbelement.Load(m));
            if isnumeric(tempload.Location)
                tempload.Location=em.internal.translateshape(tempload.Location',translationVec(n,:))';
            end
            loads(n,m)=tempload;
        end
    end
    pcbloads=loads(:)';


    boardshape=pcbelement.BoardShape;

    if getDynamicPropertyState(obj)&&(~isequal(obj.GroundPlaneLength,0)&&...
        ~isequal(obj.GroundPlaneWidth,0))
        if isa(boardshape,'antenna.Rectangle')
            boardshape.Length=obj.GroundPlaneLength;
            boardshape.Width=obj.GroundPlaneWidth;
            gnd=antenna.Rectangle;
            gnd.Length=boardshape.Length;
            gnd.Width=boardshape.Width;
            layers{end}=gnd;
        elseif isa(boardshape,'antenna.Circle')
            boardshape.Radius=obj.GroundPlaneRadius;
            gnd=antenna.Circle;
            gnd.Radius=boardshape.Radius;
            layers{end}=gnd;
        end
    elseif~isequal(obj.Substrate.EpsilonR,1)
        boardshape.Length=obj.Substrate.Length;
        boardshape.Width=obj.Substrate.Width;
    elseif isa(obj,'linearArray')
        boardshape.Length=obj.NumElements*boardshape.Length;
        boardshape.Width=pcbelement.BoardShape.Width;
    elseif isa(obj,'rectangularArray')||isa(obj,'circularArray')
        boardshape.Length=obj.Size(2)*boardshape.Length;
        boardshape.Width=obj.Size(1)*boardshape.Width;
    end


    pcbfeedloc=[arrayFeedLocations(:,1:2),repmat(pcbelement.FeedLocations(3:end),numElements,1)];

    pcb.Name=[class(obj),' of ',pcbelement.Name];
    pcb.BoardShape=boardshape;
    pcb.BoardThickness=pcbelement.BoardThickness;
    pcb.Layers=layers;
    pcb.FeedLocations=pcbfeedloc;
    pcb.FeedDiameter=pcbelement.FeedDiameter;
    pcb.Load=pcbloads;

end
