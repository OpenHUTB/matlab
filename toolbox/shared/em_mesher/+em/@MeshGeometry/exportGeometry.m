function g=exportGeometry(obj,varargin)

































    g.Layers=[];



















    g.FeedLocations={[]};










    g.ViaLocations={[]};













    g.DefaultConnector=[];














    g.DesignInfo=[];
    g.Source=class(obj);
    if nargin>1
        g.DesignInfo.Title=obj.Name;
        g.DesignInfo.Comment=[];
        g.DesignInfo.Attribute=obj.Revision;
    end

    numLevels=numel(obj.MetalLayers);
    layerStruct(1:numLevels)=struct('Fills',{[]},'Holes',{[]},'Substrate',[]);
    thickness=[fliplr(obj.Substrate.Thickness),0];

    for i=1:numLevels

        tempMetalLayer=obj.MetalLayers{i};

        tempFills=tempMetalLayer.FillPolygons;
        tempHoles=tempMetalLayer.HolePolygons;


        layerStruct(i).Fills=tempFills;
        layerStruct(i).Holes=cell(1,numel(tempFills));


        if numel(tempFills)==0||~iscell(tempFills)||all(cellfun(@isempty,tempFills))


            noFills=1;
        else
            noFills=0;
        end


        if~noFills

            levl=zeros(size(tempFills,2));
            for w=1:numel(tempFills)
                xw=tempFills{w}(:,1);
                yw=tempFills{w}(:,2);
                for u=1:numel(tempFills)
                    if u~=w
                        xu=tempFills{u}(:,1);
                        yu=tempFills{u}(:,2);
                        levl(w,u)=all(inpolygon(xu,yu,xw,yw));
                    end
                end
            end

            G=digraph(levl);

            topNode=[];
            for x=1:numel(tempFills)
                if~any(levl(:,x))
                    topNode=[topNode,x];
                end
            end

            ordr=[];
            lastNode=[];

            Enodes={};
            fchildordr=[];
            for z=1:length(topNode)
                childordr=bfsearch(G,topNode(z));
                fchildordr=[fchildordr,childordr];
                for u=2:length(childordr)
                    if isempty(nearest(G,childordr(u),1))
                        lastNode=[lastNode,childordr(u)];
                    end
                end
                Enodes{1,z}=lastNode;
            end


            for z=1:length(topNode)
                for w=1:length(Enodes{1,z})
                    pths=allpaths(G,topNode(z),Enodes{1,z}(w));

                    for q=1:length(pths)
                        if length(pths{q,1})>2
                            for v=2:length(fchildordr)-1
                                for u=v+1:length(fchildordr)
                                    fst=find(pths{q,1}==fchildordr(v));
                                    if~isempty(fst)
                                        scnd=find(pths{q,1}==fchildordr(u));
                                        if~isempty(scnd)
                                            if fst>scnd
                                                fstval=fchildordr(v);
                                                fchildordr=[fchildordr(1:u);fstval;fchildordr(u+1:end)];
                                                fchildordr(v)=[];
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            ordr=fchildordr;
            sFills=tempFills;
            for m=1:length(ordr)
                sFills(1,m)=tempFills(1,ordr(m));
            end
            tempFills=sFills;
        end

        layerStruct(i).Fills=tempFills;

        for j=1:numel(tempFills)
            xv=tempFills{j}(:,1);
            yv=tempFills{j}(:,2);
            if~any(cellfun(@isempty,tempHoles))
                for k=1:numel(tempHoles)
                    xq=tempHoles{k}(:,1);
                    yq=tempHoles{k}(:,2);
                    in=inpolygon(xq,yq,xv,yv);
                    if in
                        layerStruct(i).Holes{j}(k)=tempHoles(k);
                    else
                        layerStruct(i).Holes{j}(k)={[]};
                    end

                end
            end
            layerStruct(i).Substrate=thickness(i);
        end
    end


    g.Layers=layerStruct;



    isProbeConnection=size(obj.FeedLocations,2)>3;
    if~isProbeConnection
        g.DefaultConnector='PCBConnectors.SMAEdge';
    else
        g.DefaultConnector='PCBConnectors.SMA';
    end

    g.FeedLocations=num2cell(obj.FeedLocations,2);

    if~isempty(obj.ViaLocations)
        g.ViaLocations=num2cell(obj.ViaLocations,2);
    end



















