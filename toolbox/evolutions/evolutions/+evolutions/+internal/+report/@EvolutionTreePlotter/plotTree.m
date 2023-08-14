function plotTree(this)





    if~isempty(this.RootEi)


        createTreePlot(this);

        gatherXYPlotInfo(this);

        gatherLayoutInfo(this);

        delete(this.TreePlot);

        drawRectanglesWithText(this);

        drawLines(this);
    end
end

function createTreePlot(this)
    this.NodeMap=containers.Map;
    eis=gatherAllEis(this,this.RootEi);
    numEvs=numel(eis);
    tableCell=cell(numEvs,1);
    edgeMatrix=zeros(numEvs-1,2);
    for evIdx=1:numEvs
        curEi=eis(evIdx);
        tableCell{evIdx}=char(curEi.getName);
        nodeInfo=evolutions.internal.report.NodeInfo;
        nodeInfo.Index=evIdx;
        nodeInfo.Ei=curEi;
        nodeInfo.Name=curEi.getName;
        this.NodeMap(curEi.Id)=nodeInfo;
    end
    this.NodeTable=table(tableCell,'VariableNames',{'Name'});
    edgeIdx=0;
    for evIdx=1:numEvs
        curEi=eis(evIdx);
        curId=curEi.Id;
        for childIdx=1:numel(curEi.Children)
            edgeIdx=edgeIdx+1;
            infoOne=this.NodeMap(curId);
            infoTwo=this.NodeMap(curEi.Children(childIdx).Id);
            edgeMatrix(edgeIdx,:)=[infoOne.Index,...
            infoTwo.Index];
        end
    end
    this.EdgeTable=table(edgeMatrix,'VariableNames',{'EndNodes'});
    this.Digraph=digraph(this.EdgeTable,this.NodeTable);
    this.TreePlot=plot(this.TreeAxes,this.Digraph);
end

function eis=gatherAllEis(this,ei)
    eis=ei;
    eis=addChildrenRecursively(this,eis,ei);
end

function eis=addChildrenRecursively(this,eis,ei)
    if ei.IsWorking
        this.CurrentEi=ei.Parent;
        this.ActiveEi=ei;
    end

    children=ei.Children;
    for chdIdx=1:numel(children)
        curChild=children(chdIdx);
        eis=[eis,curChild];%#ok<AGROW>
        eis=addChildrenRecursively(this,eis,curChild);
    end
end

function gatherXYPlotInfo(this)
    nodeKeys=this.NodeMap.keys;
    this.IndexToXY=containers.Map('KeyType','double',...
    'ValueType','any');
    for keyIdx=1:numel(nodeKeys)
        curKey=nodeKeys{keyIdx};
        nodeInfo=this.NodeMap(curKey);
        nodeInfo.X=this.TreePlot.XData(nodeInfo.Index);
        nodeInfo.Y=this.TreePlot.YData(nodeInfo.Index);
        this.IndexToXY(nodeInfo.Index)=[...
        this.TreePlot.XData(nodeInfo.Index),...
        this.TreePlot.YData(nodeInfo.Index)];
    end
end

function gatherLayoutInfo(this)




    this.LayoutInfo.xMinDist=inf;
    this.LayoutInfo.xLines=[];
    this.LayoutInfo.xMin=[];
    this.LayoutInfo.xMax=[];
    this.LayoutInfo.yLines=0;
    this.LayoutInfo.yLinesDist=inf;
    this.LayoutInfo.yMin=[];
    this.LayoutInfo.yMax=[];


    nodeInfos=this.NodeMap.values;
    numPoints=numel(nodeInfos);


    xVals=zeros(1,numPoints);
    yVals=zeros(1,numPoints);



    yBuckets=containers.Map('KeyType','double','ValueType','any');
    for infosIdx=1:numPoints
        curInfo=nodeInfos{infosIdx};
        curX=curInfo.X;
        curY=curInfo.Y;
        xVals(infosIdx)=curX;
        yVals(infosIdx)=curY;
        if yBuckets.isKey(curY)
            xLineVals=yBuckets(curY);
            xLineVals=[xLineVals,curX];%#ok<AGROW>
            yBuckets(curY)=xLineVals;
        else
            yBuckets(curY)=curX;
        end
    end


    xVals=unique(xVals);
    yVals=unique(yVals);


    this.LayoutInfo.xMin=xVals(1);
    this.LayoutInfo.xMax=xVals(end);
    this.LayoutInfo.yMin=yVals(1);
    this.LayoutInfo.yMax=yVals(end);


    this.LayoutInfo.xLines=numel(xVals);
    this.LayoutInfo.yLines=numel(yVals);



    yBucketKeys=yBuckets.keys;
    for keyIdx=1:numel(yBucketKeys)
        curKey=yBucketKeys{keyIdx};
        xVals=yBuckets(curKey);
        numVals=numel(xVals);
        if numVals>1

            xVals=sort(xVals);
            curDist=xVals(2)-xVals(1);
            if curDist<this.LayoutInfo.xMinDist
                this.LayoutInfo.xMinDist=curDist;
            end
        end
    end


    if this.LayoutInfo.yLines>1
        this.LayoutInfo.yLinesDist=yVals(2)-yVals(1);
    end
end

function drawRectanglesWithText(this)
    hold(this.TreeAxes,'on');
    nodeKeys=this.NodeMap.keys;
    [recLength,recHeight]=calculateRectangleDims(this);
    for keyIdx=1:numel(nodeKeys)
        curKey=nodeKeys{keyIdx};
        nodeInfo=this.NodeMap(curKey);
        if isequal(nodeInfo.Ei,this.ActiveEi)
            pos=[nodeInfo.X-recLength/2,nodeInfo.Y-recHeight/2,...
            recLength,recHeight];
            nodeInfo.RecObj=rectangle(this.TreeAxes,...
            'Position',pos,...
            'Curvature',this.NodeCurvature,...
            'FaceColor',this.BackgroundColor,...
            'EdgeColor',this.NodeColor,...
            'LineStyle',':',...
            'LineWidth',this.NodeEdgeWeight);
        else
            pos=[nodeInfo.X-recLength/2,nodeInfo.Y-recHeight/2,...
            recLength,recHeight];
            nodeInfo.RecObj=rectangle(this.TreeAxes,...
            'Position',pos,...
            'Curvature',this.NodeCurvature,...
            'FaceColor',this.BackgroundColor,...
            'EdgeColor',this.NodeColor,...
            'LineWidth',this.NodeEdgeWeight);
        end

        nodeInfo.RecObj.UserData=nodeInfo;
        nodeInfo.TextObj=text(this.TreeAxes,...
        nodeInfo.X,nodeInfo.Y,...
        nodeInfo.Name,...
        'HorizontalAlignment','center');

        nodeInfo.TextObj.Position(3)=0.2;
    end
    hold(this.TreeAxes,'off');
end

function[recLength,recHeight]=calculateRectangleDims(this)
    if this.LayoutInfo.xLines==1
        recLength=this.SingleXRowNodeFill;
        xAxesMin=this.LayoutInfo.xMin-.5;
        xAxesMax=this.LayoutInfo.xMax+.5;
    else
        recLength=this.LayoutInfo.xMinDist*...
        this.MultipleXRowNodeFill;
        xAxesMin=this.LayoutInfo.xMin-this.LayoutInfo.xMinDist/2;
        xAxesMax=this.LayoutInfo.xMax+this.LayoutInfo.xMinDist/2;
    end
    this.TreeAxes.XLim=[xAxesMin,xAxesMax];

    if this.LayoutInfo.yLines==1
        recHeight=this.SingleYRowNodeFill;
        yAxesMin=this.LayoutInfo.yMin-.5;
        yAxesMax=this.LayoutInfo.yMax+.5;
    else
        recHeight=this.LayoutInfo.yLinesDist*...
        this.MultipleYRowNodeFill;
        yAxesMin=this.LayoutInfo.yMin-this.LayoutInfo.yLinesDist/2;
        yAxesMax=this.LayoutInfo.yMax+this.LayoutInfo.yLinesDist/2;
    end
    this.TreeAxes.YLim=[yAxesMin,yAxesMax];
end


function drawLines(this)
    this.EdgeTable;
    hold(this.TreeAxes,'on');
    for edgeIdx=1:numel(this.EdgeTable)
        curEdge=this.EdgeTable{edgeIdx,'EndNodes'};
        nodeOneXY=this.IndexToXY(curEdge(1));
        nodeTwoXY=this.IndexToXY(curEdge(2));
        if nodeOneXY(1)==nodeTwoXY(1)

            xVals=[nodeOneXY(1),nodeTwoXY(1)];
            yVals=[nodeOneXY(2),nodeTwoXY(2)];
            drawSingleLine(this,xVals,yVals);
        else

            yVals=sort([nodeOneXY(2),nodeTwoXY(2)]);
            yDist=yVals(2)-yVals(1);


            if nodeOneXY(2)>nodeTwoXY(2)
                XYMax=nodeOneXY;
                XYMin=nodeTwoXY;
            else
                XYMax=nodeTwoXY;
                XYMin=nodeOneXY;
            end
            xValsOne=[XYMax(1),XYMax(1)];
            yValsOne=[XYMax(2),XYMax(2)-yDist/2];
            drawSingleLine(this,xValsOne,yValsOne);
            xValsTwo=[XYMin(1),XYMin(1)];
            yValsTwo=[XYMin(2),XYMin(2)+yDist/2];
            drawSingleLine(this,xValsTwo,yValsTwo);
            yValsThree=[XYMin(2)+yDist/2,XYMin(2)+yDist/2];
            xValsThree=[XYMin(1),XYMax(1)];
            drawSingleLine(this,xValsThree,yValsThree);
        end
    end
    hold(this.TreeAxes,'off');
end

function drawSingleLine(this,xVals,yVals)
    hold(this.TreeAxes,'on');
    curLine=plot(this.TreeAxes,xVals,yVals,...
    'LineStyle','-',...
    'LineWidth',this.LineWeight,...
    'Color',this.NodeColor);

    curLine.ZData=-0.1*size(curLine.XData);
    hold(this.TreeAxes,'off');
end


