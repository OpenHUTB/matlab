function graphic=getLegendGraphic(hObj)
    graphic=matlab.graphics.primitive.world.Group;

    vertices=single([0.05,0.5,0.95,0.95;0.5,0.5,0.1,0.9;0,0,0,0]);
    edgeindices=uint32([1,2,2,3,2,4]);

    nledges=3;


    for k=nledges:-1:1
        edge(k)=matlab.graphics.primitive.world.LineStrip(...
        'AlignVertexCenters','on','VertexData',...
        vertices(:,edgeindices(2*k-1:2*k)),'VertexIndices',[],...
        'StripData',[],'ColorBinding','object',...
        'ColorType','truecoloralpha','Internal',true);
    end

    nEdges=numedges(hObj.BasicGraph_);

    if nEdges==0

        set(edge,'Visible','off');
    else
        set(edge,'Visible','on');


        linestyle=hObj.LineStyle;
        if ischar(linestyle)
            linestyle=repmat({linestyle},1,nEdges);
        end


        linewidth=hObj.LineWidth;
        if isscalar(linewidth)
            linewidth=repmat(linewidth,1,nEdges);
        end


        edgesvisible=true;
        if isnumeric(hObj.EdgeColor_I)
            if isrow(hObj.EdgeColor_I)

                edgecolors=repmat(uint8(255.*[hObj.EdgeColor_I,double(hObj.EdgeAlpha)].'),1,nEdges);

            else
                edgecolors=uint8(255.*[hObj.EdgeColor_I,...
                double(hObj.EdgeAlpha)*ones(nEdges,1)].');
            end
        elseif strcmp(hObj.EdgeColor_I,'flat')
            ci=matlab.graphics.axis.colorspace.IndexColorsIterator;
            ci.Colors=hObj.EdgeCData_I(:);
            ci.CDataMapping='scaled';
            cs=ancestor(hObj,'matlab.graphics.axis.colorspace.ColorSpace','node');
            cd=TransformColormappedToTrueColor(cs,ci);
            if~isempty(cd)
                edgecolors=cd.Data;
                edgecolors(4,:)=uint8(255)*hObj.EdgeAlpha;
            else
                edgesvisible=false;
            end
        else
            edgesvisible=false;
        end

        if edgesvisible

            uniqueedges=findgroups(edgecolors(1,:),edgecolors(2,:),...
            edgecolors(3,:),linestyle,linewidth);


            ind=fillseats(uniqueedges,nledges);


            for i=1:nledges
                uniqueedge=find(uniqueedges==ind(i),1);
                set(edge(i),...
                'ColorData',edgecolors(:,uniqueedge),...
                'LineWidth',linewidth(uniqueedge));
                hgfilter('LineStyleToPrimLineStyle',...
                edge(i),linestyle{uniqueedge});
            end

            set(edge,'Visible','on');
        else
            set(edge,'ColorBinding','none','Visible','off');
        end
    end
    set(edge,'Parent',graphic);

    nlnodes=4;


    for k=nlnodes:-1:1
        node(k)=matlab.graphics.primitive.world.Marker(...
        'VertexData',vertices(:,k),'VertexIndices',[],...
        'FaceColorBinding','object','FaceColorType','truecoloralpha',...
        'EdgeColorBinding','object','EdgeColorType','truecoloralpha',...
        'Size',4,'Internal',true);
    end
    if~isempty(hObj.MarkerHandles_)&&~all(strcmp({hObj.MarkerHandles_.Visible},'off'))

        numnodes=hObj.BasicGraph_.numnodes;
        markerprop=cellstr(hObj.Marker);
        markers=repmat(markerprop,1,numnodes/length(markerprop));
        nnones=sum(strcmp('none',markers));
        nodecolors=zeros(4,0,'uint8');
        markers=cell(1,0);
        for k=1:length(hObj.MarkerHandles_)

            numnodes=size(hObj.MarkerHandles_(k).VertexData,2);
            if numnodes==0


                nodecolors(:,end+1:nnones)=0;
                markers(end+1:nnones)={'none'};
            else
                facecolordata=hObj.MarkerHandles_(k).FaceColorData;
                nodecolors=[nodecolors,repmat(facecolordata,1,numnodes/size(facecolordata,2))];%#ok<AGROW>
                markers=[markers,repmat({hObj.MarkerHandles_(k).Style},1,numnodes)];%#ok<AGROW>
            end
        end


        if~isempty(nodecolors)
            uniquenodes=findgroups(nodecolors(1,:),nodecolors(2,:),...
            nodecolors(3,:),markers);
        else







            nodecolors=uint8([0;0;0;255]);
            markers={'circle'};
            uniquenodes=findgroups(nodecolors(1,:),nodecolors(2,:),...
            nodecolors(3,:),markers);
        end


        ind=fillseats(uniquenodes,nlnodes);
        for i=1:nlnodes
            uniquenode=find(uniquenodes==ind(i),1);
            set(node(i),...
            'FaceColorData',nodecolors(:,uniquenode),...
            'EdgeColorData',nodecolors(:,uniquenode),...
            'Style',markers{uniquenode},...
            'Visible','on');
        end
    else
        set(node,'FaceColorBinding','none','EdgeColorBinding','none','Visible','off');
    end
    set(node,'Parent',graphic);
end









function seats=fillseats(votes,nseats)
    seats=zeros(1,nseats);

    candidatevotes=histcounts(votes,'Normalization','probability')*nseats;
    [sortedvotes,ind]=sort(candidatevotes,'descend');
    startind=1;

    for i=1:length(ind)

        nseatsWon=floor(sortedvotes(i));
        if nseatsWon>0


            candidatevotes(ind(i))=sortedvotes(i)-nseatsWon;
            endind=min(startind+nseatsWon-1,nseats);
            seats(startind:endind)=ind(i);
            startind=endind+1;
            if startind>nseats
                break;
            end
        end
    end


    if startind<=nseats
        [~,ind]=sort(candidatevotes,'descend');

        seats(startind:nseats)=ind(1:nseats-startind+1);
    end
end
