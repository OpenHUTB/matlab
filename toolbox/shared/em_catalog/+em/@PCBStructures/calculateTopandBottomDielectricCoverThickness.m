function[T,B]=calculateTopandBottomDielectricCoverThickness(obj)



    metalLayerIndx=cellfun(@(x)isa(x,'antenna.Shape'),obj.Layers);
    dielectricLayerIndx=cellfun(@(x)isa(x,'dielectric'),obj.Layers);
    m1=find(metalLayerIndx);
    m2=m1(end);
    m1=m1(1);

    d1=find(dielectricLayerIndx);
    dtop=find(d1<m1);
    dbottom=find(d1>m2);

    if~isempty(dtop)
        subtop=obj.Layers(d1(dtop));
        subtopThickness=cellfun(@(x)(x.Thickness),subtop);
    else
        subtopThickness=0;
    end
    if~isempty(dbottom)
        subbottom=obj.Layers(d1(dbottom));
        subbottomThickness=cellfun(@(x)(x.Thickness),subbottom);
    else
        subbottomThickness=0;
    end
    T=subtopThickness;
    B=subbottomThickness;