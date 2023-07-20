function Mesh=buildPcbStackWithSingleLayerMetal(obj,p_tempV,t_tempV,numLayers)


    pP=p_tempV{1};
    tP=t_tempV{1};

    [pGP,tGP]=buildGroundPlaneMesh(obj);
    feed_x=obj.modifiedFeedLocations(:,1);
    feed_y=obj.modifiedFeedLocations(:,2);
    Wfeed=obj.FeedWidth;

    Mi=em.internal.meshprinting.imprintMesh(pP',tP(1:3,:)',pGP',tGP(1:3,:)');
    Mi.FeedVertex1=[];
    Mi.FeedVertex2=[];
    Mi.NumLayers=numLayers;
    if isa(obj.Layers{1},'antenna.Shape')&&(isa(obj.Layers{2},'dielectric'))
        Mi.TopSubThickness=0;
        Mi.BottomSubThickness=obj.Layers{2}.Thickness;
        Mi.RemoveLayer='gnd';
    elseif isa(obj.Layers{1},'dielectric')&&isa(obj.Layers{2},'antenna.Shape')
        Mi.TopSubThickness=obj.Layers{1}.Thickness;
        Mi.BottomSubThickness=0;
        Mi.RemoveLayer='patch';
    elseif(isa(obj.Layers{1},'dielectric')&&isa(obj.Layers{end},'dielectric'))
        Mi.TopSubThickness=obj.Layers{1}.Thickness;
        Mi.BottomSubThickness=obj.Layers{2}.Thickness;
        Mi.RemoveLayer='gnd';
    end
    P=Mi.P;
    t=Mi.t;
    pGP=P';
    tGP=t';
    tGP(4,:)=1;


    [Mesh,~]=makeDielectricMesh(obj.Substrate,obj,Mi);


    Mesh.Points=orientGeom(obj,Mesh.Points);
end