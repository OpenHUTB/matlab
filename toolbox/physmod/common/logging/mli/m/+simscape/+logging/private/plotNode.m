function h=plotNode(nodeArray,timeWindow,units,depth,nodePath,names)





    h=[];

    numNodes=numel(nodeArray);
    numNames=numel(names);


    if(numNodes>1)
        for idx=numNames+1:numNodes
            names{idx}=['Node ',num2str(idx)];
        end
    else
        if isempty(names)
            names{1}='';
        end
    end


    if numNodes>4
        pm_error('physmod:common:logging2:mli:plotNode:TooManyOverlays',num2str(4));
    end

    rootNodeId=nodeArray{1}.getName;


    getCurrentNodes=@(nc,p)(cellfun(@(n)(n.node(p)),nc,...
    'UniformOutput',false));
    currentNodes=getCurrentNodes(nodeArray,nodePath);


    h.id=localPlotNode(currentNodes,timeWindow,units,nodePath,names);
    h.childIds=[];



    principalNode=currentNodes{1};


    if depth>0


        children=principalNode.childIds;



        leafChildren={};




        childPathPrefix=nodePath;
        if~isempty(nodePath)
            childPathPrefix=[childPathPrefix,'.'];
        end




        for idx=1:numel(children)

            childPath=[childPathPrefix,children{idx}];

            c=principalNode.child(children{idx});

            if c.numChildren~=0

                newDepth=depth-1;
                h.(children{idx})=plotNode(nodeArray,...
                timeWindow,units,newDepth,childPath,names);
            else

                leafChildren{end+1}=children{idx};%#ok<AGROW>
            end
        end

        numLeafChildren=numel(leafChildren);



        if numLeafChildren==0
            return;
        end







        three=(mod(numel(leafChildren),3)==0);
        odd=(mod(numel(leafChildren),2)~=0);


        h.childIds=figure;
        figureTitle=rootNodeId;
        if~isempty(nodePath)
            figureTitle=[figureTitle,'.',nodePath];
        end
        set(h.childIds,'Name',figureTitle,'NumberTitle','on');



        for idx=1:numLeafChildren



            if three
                subplot(3,numLeafChildren/3,idx);
            elseif odd
                if idx<numLeafChildren
                    subplot(2,ceil(numLeafChildren/2),idx);
                else
                    subplot(2,ceil(numLeafChildren/2),[idx,idx+1]);
                end
            else
                subplot(2,numLeafChildren/2,idx);
            end




            n=cell(1,numNodes);
            for jdx=1:numNodes
                n{jdx}=currentNodes{jdx}.child(leafChildren{idx});
            end


            localPlotNodeOverlays(n,units,timeWindow,leafChildren{idx},...
            names);
        end

    end

end


function h=localPlotNode(nodeArray,timeWindow,units,nodePath,names)

    h=[];
    principalNode=nodeArray{1};
    s=principalNode.series;

    if~strcmpi(s.unit,lInvalidUnit())


        h=figure;
        figureTitle=nodePath;
        if isempty(figureTitle)
            figureTitle=principalNode.id;
        end
        set(h,'Name',figureTitle,'NumberTitle','on');


        localPlotNodeOverlays(nodeArray,units,timeWindow,principalNode.id,names);

    end
end


function localPlotNodeOverlays(nodeArray,units,timeWindow,plotTitle,names)



    lineHandles=[];
    legendEntries={};
    numNodes=numel(nodeArray);

    getLineStyle(0);
    getColor(0);

    xAxisLimit=[inf,-inf];

    u=nodeArray{1}.series.unit;
    if~isempty(units)
        u=units{pm_commensurate(u,units)};
    end


    for jdx=1:numNodes
        n=nodeArray{jdx};
        s=n.series;


        time=s.time;


        if time(1)<xAxisLimit(1)
            xAxisLimit(1)=time(1);
        end
        if time(end)>xAxisLimit(2)
            xAxisLimit(2)=time(end);
        end


        values=s.values(u);
        dim=s.dimension;

        isVariableScalar=(dim(1)*dim(2)==1);
















        if isVariableScalar
            lineHandles(end+1)=plot(time,values(:),...
            'Color',getColor);%#ok<AGROW>
            legendEntries{end+1}=names{jdx};%#ok<AGROW>
            hold on;
        else
            getColor(0);
            lineStyle=getLineStyle;
            for m=1:dim(1)
                for n=1:dim(2)
                    index=sub2ind(dim,m,n);
                    valuesForThisDimension=values(1:end,index);
                    lineHandles(end+1)=...
                    plot(time,valuesForThisDimension(:),...
                    'Color',getColor,'LineStyle',lineStyle);%#ok<AGROW>
                    legendEntries{end+1}=sprintf('%s (%d,%d)',...
                    names{jdx},m,n);%#ok<AGROW>
                    hold on;
                end
            end
        end
    end

    if~isempty(lineHandles)
        isCellEmpty=@(x)(any(cellfun(@isempty,x)));
        if~isCellEmpty(legendEntries)
            legend(lineHandles,legendEntries);
        end
        hold off;
        grid on;
        if~isempty(timeWindow)
            set(gca,'XLim',timeWindow);
        else
            set(gca,'XLim',xAxisLimit);
        end
    end

    xlabel('Time, s');
    ylabel(sprintf('%s, %s',plotTitle,u),'Interpreter','none');
    title(sprintf('%s',plotTitle),'Interpreter','none');
end


function str=lInvalidUnit()
    str=message('physmod:common:logging2:core:common:Invalid').getString();
end
