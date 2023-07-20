function[GFMultTable,GFPowerTable,Corr,WordSize,AntiLogTable,LogTable]=HDLRSGenPoly(N,K,B,prim_poly)




    power2=ceil(log2(N+1));

    if 2^power2-1~=N
        distance=N-K;
        N=2.^power2-1;
        K=N-distance;
    end

    if nargin<4
        p_vec=[3,7,11,19,37,67,137,285,529,1033,2053,4179,8219,17475,32771,69643];
        prim_poly=p_vec(power2);
    else
        if~isscalar(prim_poly)
            prim_poly=bit2int(prim_poly.',length(prim_poly))';
        end
    end

    [genPoly,tCorr]=rsgenpoly(N,K,prim_poly,B);


    [~,~,alogt,logt]=gettables(genPoly);

    codeSize=2^genPoly.m;
    multTable=gf(zeros(2*tCorr,codeSize),genPoly.m,genPoly.prim_poly);
    g=genPoly(2:end);
    for ii=1:length(g)
        multTable(ii,:)=(0:(codeSize-1)).*g(ii);
    end

    powerTable=gf(zeros(length(g)+B+1,codeSize),genPoly.m,genPoly.prim_poly);
    GFAlpha=gf(2,genPoly.m,genPoly.prim_poly);
    for powerExp=0:(length(g)+B)
        powerTable(powerExp+1,:)=(0:(codeSize-1)).*(GFAlpha.^powerExp);
    end

    GFMultTable=uint32(multTable.x);
    GFPowerTable=uint32(powerTable.x);
    Corr=uint32(tCorr);
    WordSize=uint32(genPoly.m);
    AntiLogTable=uint32(alogt);
    LogTable=uint32(logt);
