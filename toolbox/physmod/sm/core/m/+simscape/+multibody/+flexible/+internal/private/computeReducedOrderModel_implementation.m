






























function rom=computeReducedOrderModel_implementation(varargin)










    rom.status=5;






    isPdeInstalled=~isempty(ver('pde'));
    if~isPdeInstalled
        rom.status=1;
        return;
    end

    isPdeLicensed=license('test','PDE_Toolbox');
    if~isPdeLicensed
        rom.status=2;
        return;
    end

    isPdeCheckoutSuccessful=license('checkout','PDE_Toolbox');
    if~isPdeCheckoutSuccessful
        rom.status=3;
        return;
    end








    nodesSM=varargin{1};
    elemsSM=varargin{2}+1;
    mtlData=varargin{3};
    mpcData=varargin{4};
    displayVertexIDs=varargin{5}+1;
    numModes=varargin{6};

    model=createpde('structural','modal-solid');
    SM_TO_PDETbxMapping=[1,2,3,4,7,5,6,8,9,10];
    geometryFromMesh(model,nodesSM,elemsSM(SM_TO_PDETbxMapping,:));
    [p,~,t]=model.Mesh.meshToPet;
    model.structuralProperties('YoungsModulus',mtlData.YoungsModulus,'PoissonsRatio',mtlData.PoissonsRatio,'MassDensity',mtlData.MassDensity);
    mpc.Nodes=[];
    for i=1:size(mpcData.ElementIDs,2)
        mpcElems=mpcData.ElementIDs{i};
        mpc.Nodes=[mpc.Nodes;t(1:end-1,mpcElems(1))'];
    end
    mpc.Reference=mpcData.Reference';
    coefstruct=model.packCoefficients;
    rom=reduceSimscape(model,p,t,coefstruct,mpc,numModes,displayVertexIDs);




    rom.status=0;

end
