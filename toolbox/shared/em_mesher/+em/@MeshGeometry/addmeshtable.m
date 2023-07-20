function addmeshtable(obj,hfig)

    tempp=meshinfo(obj);
    addtatoo(tempp,hfig);

    if~isprop(obj,'Element')
        return;
    end

    numElements=numel(obj.Element);
    if numElements==1
        return;
    end
    strcell=cell(numElements+1,1);
    strcell{1}='Full Array';
    for m=1:numElements
        strcell{m+1}=strcat('Element',num2str(m));
    end

    if isa(obj,'em.Array')
        numElements=numel(obj.Element);
        strcell=cell(numElements+1,1);
        strcell{1}=' Full Array';
        for m=1:numElements
            strcell{m+1}=strcat('Element',num2str(m));
        end

        uicontrol('Style','popupmenu','String',strcell,...
        'Units','Normalized','Position',[0.01,0.95,0.15,0.05],...
        'Callback',@selectionCallback,'Tag','patternpopUp');
    end


    function selectionCallback(hObj,~,~)

        val=get(hObj,'Value');
        if val==1
            meshval=meshinfo(obj);
        else
            if iscell(obj.Element)
                meshval=meshinfo(obj.Element{val-1});
            else
                meshval=meshinfo(obj.Element(val-1));
            end
        end
        updatetatoo(meshval,hfig);
    end
end

function updatetatoo(tempp,hfig)

    vals=findobj(hfig,'tag','Tatoo');
    aa=cell(5,1);
    aa{1}=sprintf('NumTriangles: %d',tempp.NumTriangles);
    aa{2}=sprintf('NumTetrahedra: %d',tempp.NumTetrahedra);
    aa{3}=sprintf('NumBasis: %d',tempp.NumBasis);
    aa{4}=sprintf('MaxEdgeLength: %0.5g',tempp.MaxEdgeLength);
    aa{5}=sprintf('MeshMode: %s',tempp.MeshMode);
    vals.String=aa;

end

function addtatoo(tempp,hfig)

    aa=cell(5,1);
    aa{1}=sprintf('NumTriangles: %d',tempp.NumTriangles);
    aa{2}=sprintf('NumTetrahedra: %d',tempp.NumTetrahedra);
    aa{3}=sprintf('NumBasis: %d',tempp.NumBasis);
    aa{4}=sprintf('MaxEdgeLength: %0.5g',tempp.MaxEdgeLength);
    aa{5}=sprintf('MeshMode: %s',tempp.MeshMode);

    try
        uicontrol('Parent',hfig,'Style','text','String',aa,...
        'Units','Normalized','Position',[0.01,0.78,0.25,0.17],...
        'HorizontalAlignment','left','BackgroundColor',...
        [0.94,0.94,0.94],'Tag','Tatoo');
    catch
        parentpos=hfig.Position;
        pos=[0.01,0.78,0.25,0.17];
        pos([1,3])=pos([1,3]).*parentpos(3);
        pos([2,4])=pos([2,4]).*parentpos(4);

        uilabel('Parent',hfig,'Position',pos,'Text',aa,...
        'FontSize',10,'HorizontalAlignment','left','Tag','Tatoo');

    end

end