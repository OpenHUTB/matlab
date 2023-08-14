function allVisPrims=findallVisibleDataObjectPrimitives(hList)











    allVisPrims=matlab.graphics.primitive.world.Group.empty;
    if isempty(hList)
        return
    end

    hList=hList(:);


    isPrim=isPrimitive(hList);
    isVis=isVisible(hList);
    allVisPrims=hList(isPrim&isVis);

    nonPrimList=hList(~isPrim);
    trueChildren=matlab.graphics.primitive.world.Group.empty;
    for i=1:length(nonPrimList)

        if isa(nonPrimList(i),'matlab.graphics.axis.Axes')
            nonPrimList(i)=nonPrimList(i).ChildContainer;
        end


        trueChildren=[trueChildren;hgGetTrueChildren(nonPrimList(i))];%#ok<AGROW>
    end

    allVisPrims=[allVisPrims;matlab.graphics.chart.internal.findallVisibleDataObjectPrimitives(trueChildren)];

    function tf=isPrimitive(h)

        tf=false(size(h));
        primClasses={'matlab.graphics.primitive.world.LineStrip',...
        'matlab.graphics.primitive.world.Marker',...
        'matlab.graphics.primitive.world.Quadrilateral',...
        'matlab.graphics.primitive.world.TriangleStrip',...
        'matlab.graphics.primitive.Text'};
        for i=1:length(h)
            tf(i)=ismember(class(h(i)),primClasses);
        end

        function tf=isVisible(h)

            tf=false(size(h));
            for i=1:length(h)
                tf(i)=isprop(h(i),'Visible')&&strcmp(h(i).Visible,'on');
            end
