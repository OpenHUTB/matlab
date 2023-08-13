function g=getDigraph(this)

    roadArray=this.Roads.toArray;
    numRoads=length(roadArray);

    s=strings(numRoads,2);
    t=strings(numRoads,2);
    w=ones(numRoads,2);
    for kndx=1:length(roadArray)
        roadk=roadArray(kndx);


        if roadk.Direction==driving.roadnetwork.DirectionOfTravel.Forward
            s(kndx,1)=roadk.StartNode.ID;
            t(kndx,1)=roadk.EndNode.ID;
            w(kndx,1)=roadk.Weight;
        elseif roadk.Direction==driving.roadnetwork.DirectionOfTravel.Backward
            s(kndx,2)=roadk.EndNode.ID;
            t(kndx,2)=roadk.StartNode.ID;
            w(kndx,2)=roadk.Weight;
        elseif roadk.Direction==driving.roadnetwork.DirectionOfTravel.Both
            s(kndx,1)=roadk.StartNode.ID;
            t(kndx,1)=roadk.EndNode.ID;
            w(kndx,1)=roadk.Weight;
            s(kndx,2)=roadk.EndNode.ID;
            t(kndx,2)=roadk.StartNode.ID;
            w(kndx,2)=roadk.Weight;
        end
    end


    missingIdxs=s=="";
    s(missingIdxs)=[];
    t(missingIdxs)=[];
    w(missingIdxs)=[];


    g=digraph(s,t,w);


    nodeVars=g.Nodes.Variables;
    numNodes=length(nodeVars);
    xdata=zeros(numNodes,1);
    ydata=zeros(numNodes,1);
    zdata=zeros(numNodes,1);
    rnNodes=this.Nodes;




    for kndx=1:numNodes
        nodek=rnNodes.getByKey(uint64(str2double(nodeVars{kndx})));
        pos=nodek.getPosition';
        if isempty(pos)
            pos=[NaN,NaN,NaN];
        end
        xdata(kndx)=pos(1);
        ydata(kndx)=pos(2);
        zdata(kndx)=pos(3);
    end


    g.Nodes.Position=[xdata,ydata,zdata];

end

