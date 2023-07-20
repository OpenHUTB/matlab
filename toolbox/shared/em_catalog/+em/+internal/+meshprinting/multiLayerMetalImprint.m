function[P,t,eCellInt,edges,pspecial,especial,feed_new,feed_map]=multiLayerMetalImprint(PCell,gd,numBoardHoles,...
    feed,via,...
    MaxContourLength,...
    MinContourLength,...
    GrowthRate,...
    iter_initial,...
    BaseMeshChoice,...
    RefineContours,...
    MinFeatureSize,...
    edgeStatus,...
    initialFeedMap)





















    [~,e]=engunits(cell2mat(PCell'));
    PCell=cellfun(@(x)e*x,PCell,'UniformOutput',false);
    feed=e*feed;
    via=e*via;
    MaxContourLength=e*MaxContourLength;
    MinContourLength=e*MinContourLength;
    MinFeatureSize=e*MinFeatureSize;
    gd(3:end,:)=e*gd(3:end,:);
    Epsilon=e*1e-12;










    for m=1:size(PCell,2)
        P=PCell{m};
        for n=1:size(PCell,2)
            if n==m
                continue;
            end
            P=em.internal.meshprinting.inter3_con_con(P,PCell{n},Epsilon);
        end
        PCellInt{m}=P;
    end



    [eCellInt,P]=em.internal.meshprinting.inter4_earr_parr(PCellInt);












    if~strcmpi(BaseMeshChoice,'pcb')
        if nargin<14
            initialFeedMap=[];
        end
        [P,t,edges,pspecial,especial,feed_new]=em.internal.meshprinting.inter6_full_mesh(PCell,gd,eCellInt,P,...
        MaxContourLength,...
        MinContourLength,...
        GrowthRate,...
        iter_initial,...
        feed,...
        BaseMeshChoice,...
        MinFeatureSize,...
        Epsilon,...
        RefineContours,...
        edgeStatus);

        feed_map=initialFeedMap;
    else
        [P,t,edges,pspecial,especial,feed_new,feed_map]=em.internal.meshprinting.inter6n_full_mesh(P,eCellInt,...
        MinContourLength,...
        feed,via,...
        Epsilon,...
        RefineContours,edgeStatus);
    end





    P(:,3)=0;
    [ic,r]=em.internal.meshprinting.meshincenters(P,t);
    in=inpolygon(ic(:,1),ic(:,2),PCell{1}(:,1),PCell{1}(:,2));
    t=t(in,:);

    if numBoardHoles>0

        [ic,r]=em.internal.meshprinting.meshincenters(P,t);
        IO=[];
        for i=1:numBoardHoles
            [in,on]=inpolygon(ic(:,1),ic(:,2),PCell{i+1}(:,1),PCell{i+1}(:,2));
            IO=[IO;find(in)];
        end
        t(IO,:)=[];
    end


















    A=em.internal.meshprinting.meshareas(P,t);
    P=P./e;

    if iscell(feed_new)
        feed_new=cellfun(@(x)x./e,feed_new,'UniformOutput',false);
    else
        feed_new=feed_new./e;
    end

    if iscell(pspecial)
        pspecial=cellfun(@(x)x./e,pspecial,'UniformOutput',false);
    else
        pspecial=pspecial./e;
    end

    P(:,3)=[];




    id=A<Epsilon;
    if~(numel(find(id))>ceil(0.95*size(t,1)))
        t(id,:)=[];
    end
























































