function saveLoad(obj)




    if any(strcmpi(class(obj),{'customArrayMesh','customArrayGeometry',...
        'platform','customAntennaStl','em.internal.stl.Stl'}))||...
        isa(obj,'antenna.Shape')
        Loadstruct=struct('numLoads',0,'Location',[],'Impedance',...
        [],'Frequency',[],'Feedtype',[],'isFeed',0);
    elseif strcmpi(class(obj),'dipoleCrossed')
        Loadstruct=calccrosseddipoleload(obj);
    elseif strcmpi(class(obj),'eggCrate')
        Loadstruct=getLoadinfo(obj);
    elseif any(strcmpi(class(obj),{'pcbStack','pcbComponent','birdcage','helixMultifilar','wilkinsonSplitter','wilkinsonSplitterUnequal','wilkinsonSplitterWideband','powerDividerCorporate','filterCombline'}))
        Loadstruct=calcmultifeedloadlocation(obj);
    elseif isa(obj,'em.Antenna')
        if isprop(obj,'Exciter')
            if isa(obj.Exciter,'em.Antenna')
                Loadexciter=calcloadlocation(obj.Exciter,obj.FeedLocation);
                Loadexciter=traslateExciterLoad(obj,Loadexciter);
                Loadexciter=tiltLoad(obj,Loadexciter);
            elseif isa(obj.Exciter,'em.Array')

                if ischar(obj.Load.Location)&&strcmpi(obj.Load.Location,'feed')...
                    &&~isempty(obj.Load.Impedance)
                    error(message('antenna:antennaerrors:UnsupportedLoadAtFeed'))
                end
                if isscalar(obj.Exciter.Element)
                    Loadexciter=getLoaddata(obj.Exciter);
                else
                    Loadexciter=struct('numLoads',0,'Location',[],...
                    'Impedance',[],'Frequency',[],'Feedtype',[],'isFeed',[]);
                    for m=1:numel(obj.Exciter.Element)
                        Loadstr=getLoaddata(obj.Exciter.Element(m));
                        Loadstr.Location=Loadstr.Location+obj.Exciter.TranslationVector(m,:).';
                        Loadexciter=combineloads(Loadexciter,Loadstr);
                    end
                end
                Loadexciter=traslateExciterLoad(obj,Loadexciter);
                Loadexciter=tiltLoad(obj,Loadexciter,1);
            end
            Loadbacking=calcloadlocation(obj);
            Loadstruct=combineloads(Loadexciter,Loadbacking);
        else
            Loadstruct=calcloadlocation(obj);
        end
    elseif any(strcmpi(class(obj),{'planeWaveExcitation','infiniteArray'}))
        if isprop(obj.Element,'Element')
            [element,exciter,~,~]=em.internal.dipoleCrossedLocation(obj.Element.Element);
        else
            element=0;
            exciter=0;
        end
        if element==1||exciter==1
            Loadstruct=getLoaddata(obj.Element.Element);
        else
            Loadstruct=getLoaddata(obj.Element);
        end
        Loadstruct=tiltLoad(obj,Loadstruct);
    elseif isa(obj,'em.Array')
        if isscalar(obj.Element)
            Loadstr=getLoaddata(obj.Element);
            Loadstruct=createarrayload(Loadstr,obj.TranslationVector);
            Loadstruct=tiltLoad(obj,Loadstruct,1);
        else
            Loadstruct=struct('numLoads',0,'Location',[],...
            'Impedance',[],'Frequency',[],'Feedtype',[],'isFeed',[]);
            for m=1:numel(obj.Element)
                if iscell(obj.Element)
                    Loadstr=getLoaddata(obj.Element{m});
                else
                    Loadstr=getLoaddata(obj.Element(m));
                end
                if Loadstr.numLoads~=0
                    Loadstr.Location=Loadstr.Location+obj.TranslationVector(m,:).';
                    Loadstruct=combineloads(Loadstruct,Loadstr);
                end
            end
            Loadstruct=tiltLoad(obj,Loadstruct,1);
        end

    elseif isa(obj,'installedAntenna')
        Loadstruct=getInstalledLoad(obj);
    else
        Loadstruct=struct('numLoads',0,'Location',[],'Impedance',...
        [],'Frequency',[],'Feedtype',[],'isFeed',0);
    end
    obj.MesherStruct.Load.numLoads=Loadstruct.numLoads;
    obj.MesherStruct.Load.Location=Loadstruct.Location;
    obj.MesherStruct.Load.Impedance=Loadstruct.Impedance;
    obj.MesherStruct.Load.Frequency=Loadstruct.Frequency;
    obj.MesherStruct.Load.Feedtype=Loadstruct.Feedtype;
    obj.MesherStruct.Load.isFeed=Loadstruct.isFeed;

end

function Loadstruct=combineloads(Loadexciter,Loadbacking)

    Loadstruct.numLoads=Loadexciter.numLoads+Loadbacking.numLoads;
    Loadstruct.Location=[Loadexciter.Location,Loadbacking.Location];
    Loadstruct.Impedance=[Loadexciter.Impedance,Loadbacking.Impedance];
    Loadstruct.Frequency=[Loadexciter.Frequency,Loadbacking.Frequency];
    Loadstruct.Feedtype=[Loadexciter.Feedtype,Loadbacking.Feedtype];
    Loadstruct.isFeed=[Loadexciter.isFeed,Loadbacking.isFeed];
end

function Loadstruct=createarrayload(Loadstr,TranslationVector)

    numLoads=Loadstr.numLoads;
    if numLoads==0
        Loadstruct=Loadstr;
        return;
    end

    numElems=size(TranslationVector,1);
    totalLoads=numLoads*numElems;

    ZL=cell(1,totalLoads);
    Zfrq=cell(1,totalLoads);
    Zfeed=cell(1,totalLoads);
    Zloc=zeros(3,totalLoads);
    isfeed=zeros(1,totalLoads);
    for m=1:numElems
        idx=(1:numLoads)+(m-1)*numLoads;
        Zloc(:,idx)=Loadstr.Location+TranslationVector(m,:).';
        ZL(:,idx)=Loadstr.Impedance;
        Zfrq(:,idx)=Loadstr.Frequency;
        Zfeed(:,idx)=Loadstr.Feedtype;
        isfeed(:,idx)=Loadstr.isFeed;
    end
    Loadstruct.numLoads=totalLoads;
    Loadstruct.Location=Zloc;
    Loadstruct.Impedance=ZL;
    Loadstruct.Frequency=Zfrq;
    Loadstruct.Feedtype=Zfeed;
    Loadstruct.isFeed=isfeed;

end

function Loadstruct=traslateExciterLoad(obj,Loadstruct)
    loc=Loadstruct.Location;
    isfeed=Loadstruct.isFeed;
    flag=em.internal.checkLRCArray(obj.Exciter);
    for m=1:Loadstruct.numLoads
        if~isfeed(m)||(isfeed(m)&&flag)
            if isa(obj,'reflectorParabolic')
                loc(:,m)=loc(:,m)+[0;0;obj.FocalLength];
            elseif isa(obj,'cassegrain')
                loc(:,m)=loc(:,m)+[0;0;obj.FocalLength(1)-obj.FocalLength(2)];
            elseif isa(obj,'gregorian')
                if isa(obj.Exciter,'rhombic')
                    loc(:,m)=loc(:,m)+[0;0;round(obj.FocalLength(1)-obj.FocalLength(2)+0.1412*obj.FocalLength(2),4)];
                else
                    loc(:,m)=loc(:,m)+[0;0;obj.FocalLength(1)-obj.FocalLength(2)+0.1412*obj.FocalLength(2)];
                end
            elseif isa(obj,'reflectorSpherical')
                loc(:,m)=loc(:,m)+obj.FeedOffset';
            elseif isa(obj,'cassegrainOffset')||isa(obj,'gregorianOffset')
                if isa(obj.Exciter,'rhombic')
                    ofh=obj.MainReflectorOffset;
                    beta=obj.InterAxialAngle;
                    F=obj.FocalLength(1);
                    R=obj.Radius(1);
                    R1=obj.Radius(2);
                    if ofh==0
                        theta0=atand(1*((16*F*(R-R1))/(((2*R-2*R1)^2)-(16*F))));
                    else
                        theta0=-2*(atand(ofh/(2*F)));
                    end
                    if~isa(obj,'gregorianOffset')
                        sigma=-1;
                    else
                        sigma=1;
                    end
                    num=1-(sigma*sqrt(((tand(beta/2))/(tand((beta-theta0)/2)))));
                    den=1+(sigma*sqrt(((tand(beta/2))/(tand((beta-theta0)/2)))));
                    e=num/den;
                    e=abs(e);
                    alpha=2*atand((e+1)*(tand(beta/2))/(e-1));
                    loc(:,m)=em.internal.rotateshape(loc(:,m),[0,0,0],[0,1,0],-(beta+alpha));
                    loc(:,m)=loc(:,m)+obj.FeedLocation';
                    if isa(obj,'cassegrainOffset')
                        loc(:,m)=round(loc(:,m),6);
                    else
                        loc(:,m)=round(loc(:,m),4);
                    end
                else
                    loc(:,m)=loc(:,m)+obj.FeedLocation';
                end
            else
                loc(:,m)=loc(:,m)+[0;0;obj.Spacing];
            end
        end
    end
    Loadstruct.Location=loc;
end

function Loadstruct=calcmultifeedloadlocation(obj)

    feedtype=obj.MesherStruct.Mesh.FeedType;
    numLoads=numel(obj.Load);
    for m=1:numel(obj.Load)
        if isempty(obj.Load(m).Impedance)
            numLoads=numLoads-1;
        end
    end
    numFeeds=numel(obj.FeedLocation)/3;

    loadidx=zeros(1,numLoads);
    for m=1:numLoads
        if strcmpi(obj.Load(m).Location,'feed')&&~isempty(obj.Load(m).Impedance)
            loadidx(m)=1;
        end
    end
    numloadsatfeed=numel(find(loadidx));
    numloadsnotatfeed=numel(find(~loadidx));
    totalloads=numloadsatfeed*numFeeds+numloadsnotatfeed;

    loc=zeros(3,totalloads);
    ZL=cell(1,totalloads);
    Zfrq=cell(1,totalloads);
    Zfeed=cell(1,totalloads);
    isfeed=zeros(1,totalloads);
    idx=0;
    for m=1:numLoads
        if loadidx(m)
            idx=(1:numFeeds)+(m-1)*numFeeds;
            loc(:,idx)=obj.FeedLocation';
            ZL(:,idx)={obj.Load(m).Impedance};
            Zfrq(:,idx)={obj.Load(m).Frequency};
            Zfeed(:,idx)={feedtype};
            isfeed(:,idx)=1;
        end
    end
    for m=1:numLoads
        if~loadidx(m)
            idx=max(idx)+1;
            loc(:,idx)=orientGeom(obj,obj.Load(m).Location.');
            ZL(:,idx)={obj.Load(m).Impedance};
            Zfrq(:,idx)={obj.Load(m).Frequency};
            Zfeed(:,idx)={'singleedge'};
            isfeed(:,idx)=0;
        end
    end
    [a,b]=unique(loc','rows','stable');
    if~isequal(a,loc')
        ZL=ZL(b);
        Zfrq=Zfrq(b);
        Zfeed=Zfeed(b);
        isfeed=isfeed(b);
        loc=loc(:,b);
        totalloads=numel(loc)/3;
    end
    Loadstruct.numLoads=totalloads;
    Loadstruct.Location=loc;
    Loadstruct.Impedance=ZL;
    Loadstruct.Frequency=Zfrq;
    Loadstruct.Feedtype=Zfeed;
    Loadstruct.isFeed=isfeed;
end

function Loadstruct=calccrosseddipoleload(obj)

    feedtype=obj.MesherStruct.Mesh.FeedType;
    numLoads=numel(obj.Element.Load);
    for m=1:numel(obj.Element.Load)
        if isempty(obj.Element.Load(m).Impedance)
            numLoads=numLoads-1;
        end
    end
    numFeeds=numel(obj.FeedLocation)/3;

    loadidx=zeros(1,numLoads);
    for m=1:numLoads
        if strcmpi(obj.Element.Load(m).Location,'feed')&&...
            ~isempty(obj.Element.Load(m).Impedance)
            loadidx(m)=1;
        end
    end
    numloadsatfeed=numel(find(loadidx));
    numloadsnotatfeed=numel(find(~loadidx));
    totalloads=numloadsatfeed*numFeeds+numloadsnotatfeed;

    loc=zeros(3,totalloads);
    ZL=cell(1,totalloads);
    Zfrq=cell(1,totalloads);
    Zfeed=cell(1,totalloads);
    isfeed=zeros(1,totalloads);

    for m=1:numLoads
        if loadidx(m)
            idx=(1:numFeeds)+(m-1)*numFeeds;
            loc(:,idx)=obj.FeedLocation';
            ZL(:,idx)={obj.Element.Load(m).Impedance};
            Zfrq(:,idx)={obj.Element.Load(m).Frequency};
            Zfeed(:,idx)={feedtype};
            isfeed(:,idx)=1;
        end
    end













    [a,b]=unique(loc','rows','stable');
    if~isequal(a,loc')
        ZL=ZL(b);
        Zfrq=Zfrq(b);
        Zfeed=Zfeed(b);
        isfeed=isfeed(b);
        loc=loc(:,b);
        totalloads=numel(loc)/3;
    end
    Loadstruct.numLoads=totalloads;
    Loadstruct.Location=loc;
    Loadstruct.Impedance=ZL;
    Loadstruct.Frequency=Zfrq;
    Loadstruct.Feedtype=Zfeed;
    Loadstruct.isFeed=isfeed;
end
