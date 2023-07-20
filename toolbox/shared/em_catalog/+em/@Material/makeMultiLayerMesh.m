function Mm=makeMultiLayerMesh(obj,h,M,isInfGP,isMetalSideWalls)




    [~,e]=engunits(M.P);
    h=h*e;


    P=M.P*e;
    t=M.t;
    PatchTriangles=M.PatchTriangles;


    p1=M.FeedVertex1*e;
    p2=M.FeedVertex2*e;
    if~isempty(p1)
        warnState=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');
        tr1=triangulation(t(:,1:3),P);
        warning(warnState);
        [vertexID1,~]=dsearchn(tr1.Points,p1);
        [vertexID2,~]=dsearchn(tr1.Points,p2);
    else
        vertexID1=[];
        vertexID2=[];
    end


    if~isfield(M,'LayerMap')
        M.LayerMap=[ones(1,size(p1,1));2.*ones(1,size(p1,1))]';
    end

    if isfield(M,'NumConnEdges')

    end


    HLayer=obj.Thickness.*e;
    EPSR=obj.EpsilonR;
    LOSSTANG=obj.LossTangent;
    NumTetLayers=M.NumLayers;
    if isInfGP
        HLayer=[fliplr(HLayer),HLayer];
        EPSR=[fliplr(EPSR),EPSR];
        LOSSTANG=[fliplr(LOSSTANG),LOSSTANG];
        NumTetLayers=[NumTetLayers,NumTetLayers];
    end
    NumSubLayers=length(HLayer);
    N=sum(NumTetLayers);




    if isequal(NumSubLayers,1)
        if NumTetLayers>1
            H=fliplr(em.internal.chebspace(HLayer/2,NumTetLayers+1,'II'))+HLayer/2;

            H=diff(H);
        else
            H=HLayer;
        end
        if(isa(obj.Parent,'draRectangular')||isa(obj.Parent,'draCylindrical'))...
            &&~(obj.Parent.FeedHeight==max(cumsum(obj.Thickness)))
            H=fliplr(em.internal.chebspace(HLayer/2,NumTetLayers+1,'II'))+HLayer/2;


            hh=obj.Parent.FeedHeight*e;
            Hb=H(H(1,:)<hh);
            Ha=H(H(1,:)>hh);
            H=[Hb,hh,Ha];
            H=diff(H);
            N=N+1;
        end
    else

        ctr=1;
        H=[];
        offsets=[0,HLayer(1:end-1)];
        while ctr<=NumSubLayers
            if NumTetLayers(ctr)>1
                Htemp=fliplr(em.internal.chebspace(HLayer(ctr)/2,NumTetLayers(ctr)+1,'II'))+HLayer(ctr)/2;

                Htemp=diff(Htemp);
                H=[H,Htemp];%#ok<AGROW>
            else
                H=[H,HLayer(ctr)];
            end
            ctr=ctr+1;
        end



        if(isa(obj.Parent,'draRectangular')||isa(obj.Parent,'draCylindrical'))...
            &&~(obj.Parent.FeedHeight==max(cumsum(obj.Thickness)))&&...
            numel(HLayer)>1&&~isinfGP(obj.Parent)



            hh=obj.Parent.FeedHeight*e;
            N=N+1;
            HLayer2=cumsum(HLayer);


            numsub=numel(HLayer2(HLayer2(1,:)<hh));

            Hsum=cumsum(H);

            num=numel(Hsum(Hsum(1,:)<hh));
            if num==0
                H=[hh,max(cumsum((H(1:num+1))))-hh,H(num+2:end)];
            else
                H=[H(1:num),hh-max(cumsum(H(1:num))),max(cumsum((H(1:num+1))))-hh,H(num+2:end)];
            end


            EPSR=[EPSR(1:numsub),EPSR(numsub+1),EPSR(numsub+1:end)];
            LOSSTANG=[LOSSTANG(1:numsub),LOSSTANG(numsub+1),LOSSTANG(numsub+1:end)];

            NumTetLayers=[NumTetLayers(1:numsub),1,NumTetLayers(numsub+1:end)];

        elseif(isa(obj.Parent,'draRectangular')||isa(obj.Parent,'draCylindrical'))...
            &&~(obj.Parent.FeedHeight==max(cumsum(obj.Thickness)))&&...
            isinfGP(obj.Parent)&&numel(HLayer)>1

            hh=obj.Parent.FeedHeight*e;
            N=N+2;
            HLayer2=cumsum(HLayer(1:numel(HLayer)/2));


            numm=numel(HLayer2(HLayer2(1,:)<hh));
            H=H(1:numel(H)/2);
            Hsum=cumsum(H);
            num=numel(Hsum(Hsum(1,:)<hh));
            if num==0
                H=[hh,max(cumsum((H(1:num+1))))-hh,H(num+2:end)];
            else
                H=[H(1:num),hh-max(cumsum(H(1:num))),max(cumsum((H(1:num+1))))-hh,H(num+2:end)];
            end


            EPSR=EPSR(1:numel(EPSR)/2);
            LOSSTANG=LOSSTANG(1:numel(LOSSTANG)/2);
            NumTetLayers=NumTetLayers(1:numel(NumTetLayers)/2);
            EPSR=[EPSR(1:numm),EPSR(numm+1),EPSR(numm+1:end)];
            LOSSTANG=[LOSSTANG(1:numm),LOSSTANG(numm+1),LOSSTANG(numm+1:end)];
            NumTetLayers=[NumTetLayers(1:numm),1,NumTetLayers(numm+1:end)];
            H=[fliplr(H),H];
            EPSR=[fliplr(EPSR),EPSR];
            LOSSTANG=[LOSSTANG,fliplr(LOSSTANG)];
            NumTetLayers=[NumTetLayers,fliplr(NumTetLayers)];

        end

    end

    if isscalar(h)
        tf=abs(cumsum(H)-h)<sqrt(eps);
    else
        cumulativeH=cumsum(H);

        tf=arrayfun(@(x)abs(x-h)<sqrt(eps),cumulativeH,'UniformOutput',false);
        tf=cellfun(@(x)h(x),tf,'UniformOutput',false);
        tf=cellfun(@(x)~isempty(x),tf);
    end
    RadiatorLayer=find(tf);

    if N>1

        if isscalar(EPSR)
            EPSR=EPSR*ones(1,N);
        else



            repeats=arrayfun(@(x)ones(x,1),NumTetLayers,'UniformOutput',false);
            epsvec=num2cell(EPSR);
            EPSR=cellfun(@(x,y)x*y,repeats,epsvec,'UniformOutput',false);
            EPSR=cell2mat(EPSR');
        end
    end

    if N>1
        if isscalar(LOSSTANG)
            LOSSTANG=LOSSTANG*ones(1,N);
        else



            repeats=arrayfun(@(x)ones(x,1),NumTetLayers,'UniformOutput',false);
            lossvec=num2cell(LOSSTANG);
            LOSSTANG=cellfun(@(x,y)x*y,repeats,lossvec,'UniformOutput',false);
            LOSSTANG=cell2mat(LOSSTANG');
        end
    end








    G=size(P,1);
    PM=P;


















    [P,T]=em.internal.makeTetrahedra(P,t,H(1));

    Pnew=P;
    Ptemp=PM;
    Tnew=T;
    Epsr=EPSR(1)*ones(size(T,1),1);
    LossTang=LOSSTANG(1)*ones(size(T,1),1);
    for m=2:N
        Tnew=[Tnew;T+(m-1)*size(PM,1)];
        Epsr=[Epsr;EPSR(m)*ones(size(T,1),1)];
        LossTang=[LossTang;LOSSTANG(m)*ones(size(T,1),1)];
        Ptemp(:,3)=sum(H(1:m));
        Pnew=[Pnew;Ptemp];
    end
    T=Tnew;
    P=Pnew;


    V=em.internal.meshprinting.meshvols(P,T);
    index=find(V<1e-14);
    if~isempty(index)
        BAD_ELIMINATED=length(index);
    end
    T(index,:)=[];
    Epsr(index)=[];
    LossTang(index)=[];






    if~isInfGP





        if isscalar(PatchTriangles)
            if isfield(M,'Fills')
                tid=M.Fills{1};
            else
                tid=1:PatchTriangles;
            end
            if isempty(RadiatorLayer)
                tgroundplane=t(tid,:);
                tpatch=t;
            else
                tgroundplane=t;
                tpatch=t(tid,:)+G*RadiatorLayer;
            end
        else





            fills=M.Fills;
            fillGnd=fills(1);
            fillRad=fills(2:end);
            gndStartIndx=1;
            gndStopIndx=PatchTriangles(1);
            tgroundplane=t(fills{1},:)+G*M.BottomMetalLayerOffset;
            tpatch=[];








            for i=1:numel(fillRad)

                tpatchlayer=t(fillRad{i},:)+G*RadiatorLayer(i);
                tpatch=[tpatch;tpatchlayer];%#ok<AGROW>
            end
        end

        feed=[];

        if~isempty(vertexID1)&&~isempty(vertexID2)





            if isscalar(RadiatorLayer)&&~isfield(M,'TopSubThickness')
                set1=arrayfun(@(x)x:G:RadiatorLayer*G+x,vertexID1,'UniformOutput',false);
                set2=arrayfun(@(x)x:G:RadiatorLayer*G+x,vertexID2,'UniformOutput',false);
                set=cell2mat([set1,set2]);
            else








                set=cell(length(vertexID1),1);

                for i=1:size(vertexID1,1)




                    if isfield(M,'FeedViaMap')
                        parentVia=M.FeedViaMap(i);
                    else
                        parentVia=i;
                    end

                    thisStartLayer=M.LayerMap(parentVia,1);
                    thisStopLayer=M.LayerMap(parentVia,2);
                    if thisStartLayer>thisStopLayer
                        thisStartLayer=M.LayerMap(parentVia,2);
                        thisStopLayer=M.LayerMap(parentVia,1);
                    end


                    startIndex1=vertexID1(i)+thisStartLayer*G;
                    stopIndex1=vertexID1(i)+thisStopLayer*G;
                    startIndex2=vertexID2(i)+thisStartLayer*G;
                    stopIndex2=vertexID2(i)+thisStopLayer*G;

                    set1=startIndex1:G:stopIndex1;
                    set2=startIndex2:G:stopIndex2;

                    set{i}=[set1,set2];%#ok<AGROW>

                end





































































            end




            for m=1:size(T,1)
                for n=1:size(set,1)
                    if(iscell(set))
                        common=intersect(T(m,:),set{n});
                    else
                        common=intersect(T(m,:),set(n,:));
                    end

                    if length(common)==3
                        if isrow(common)
                            feed=[feed;common];%#ok<AGROW>
                        else
                            feed=[feed;common'];%#ok<AGROW>
                        end
                    end
                end
            end
        end

        if isMetalSideWalls
            TR1=triangulation(T,P);
            fbtri=freeBoundary(TR1);
            warnState=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');
            TR2=triangulation(fbtri,P);
            warning(warnState);
            fntri=faceNormal(TR2);
            wallindices=abs(fntri(:,3))<1e-12;
            feed=[feed;TR2.ConnectivityList(wallindices,:)];


        end

    elseif isInfGP
        tgroundplane=t(1:PatchTriangles,:);
        tpatch=t(1:PatchTriangles,:)+G*RadiatorLayer;

        feed=[];



        set1=arrayfun(@(x)x:G:RadiatorLayer*G+x,vertexID1,'UniformOutput',false);
        set2=arrayfun(@(x)x:G:RadiatorLayer*G+x,vertexID2,'UniformOutput',false);
        set=cell2mat([set1,set2]);





        if~isempty(vertexID1)&&~isempty(vertexID2)
            for m=1:size(T,1)
                for n=1:size(set,1)
                    common=intersect(T(m,:),set(n,:));
                    if length(common)==3
                        if isrow(common)
                            feed=[feed;common];%#ok<AGROW>
                        else
                            feed=[feed;common'];%#ok<AGROW>
                        end
                    end
                end
            end
        end
    end

    feed=unique(sort(feed,2),'rows');


    if~isempty(feed)


        if isempty(p1)
            tgroundplane(:,4)=0;
            feed(:,4)=0;
            tpatch(:,4)=0;
        else
            tgroundplane(:,4)=1;
            feed(:,4)=2;
            tpatch(:,4)=3;
        end
    else
        tgroundplane(:,4)=0;
        tpatch(:,4)=0;
    end



    if isfield(M,'RemoveLayer')





        switch M.RemoveLayer
        case 'gnd'
            tgroundplane=[];
        case 'patch'
            tpatch=[];
        end
    end
    t=[tgroundplane;tpatch;feed];


    indx=find(Epsr==1);
    T(indx,:)=[];
    Epsr(indx)=[];
    LossTang(indx)=[];


    Mm.P=P'./e;
    Mm.t=t';
    Mm.tGP=tgroundplane;
    Mm.tFeed=feed;
    Mm.tRad=tpatch;
    Mm.T=T';
    Mm.EPSR=Epsr';
    Mm.LOSSTANG=LossTang';

end
