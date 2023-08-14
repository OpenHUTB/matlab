function memEstimate=protectedmemoryEstimate(obj,varargin)






















    narginchk(1,2);
    isMeshed=~isempty(obj.MesherStruct.Mesh.p)&&~obj.MesherStruct.HasStructureChanged;

    allowedObjClasses={'rfpcb.PCBSubComponent','rfpcb.PCBComponent','rfpcb.PCBVias','em.Antenna','em.Array','customAntennaStl','pcbComponent'};
    if~any(cellfun(@(x)isa(obj,x),allowedObjClasses))
        error(message('antenna:antennaerrors:Unsupported',class(obj),'memoryEstimate'));
    end

    if isa(obj,'em.Array')
        objtype='Array';
    elseif isa(obj,'em.Antenna')
        objtype='Antenna';
    elseif isa(obj,'customAntennaStl')
        objtype='customAntennaStl';
    elseif isa(obj,'rfpcb.PCBComponent')
        objtype='rfpcb.PCBComponent';
    elseif isa(obj,'rfpcb.PCBSubComponent')
        objtype='rfpcb.PCBSubComponent';
    elseif isa(obj,'rfpcb.PCBVias')
        objtype='rfpcb.PCBVias';
    elseif isa(obj,'pcbComponent')
        objtype='pcbComponent';
    end

    if~isMeshed
        if nargin==1
            error(message('antenna:antennaerrors:UnspecifiedFrequency',objtype));
        end
        f=max(varargin{1});
        localObject=copy(obj);
        vp=physconst('lightspeed');

        lambdameshing=vp/f;
        [s,gr]=calculateMeshParams(localObject,lambdameshing);
        if isa(localObject,'em.ParabolicAntenna')
            localObject.MesherStruct.Mesh.MaxEdgeLength=s;
            localObject.MesherStruct.MeshingLambda=lambdameshing;
            localObject.MesherStruct.Mesh.MeshGrowthRate=gr;
            meshGenerator(localObject);
        else
            minel=localObject.MesherStruct.Mesh.MinContourEdgeLength;
            if~isempty(minel)&&(isa(obj,'pcbStack'))
                [~]=mesh(localObject,'MaxEdgeLength',s,'MinEdgeLength',minel);
            else
                [~]=mesh(localObject,'MaxEdgeLength',s);
            end
        end
        m=localObject.MesherStruct;
    else
        m=obj.MesherStruct;
    end


    if isfield(m,'UsePO')
        if(m.UsePO)
            trad=m.Mesh.t;
            meshsize=size(trad,2)*0.7;

        else
            meshsize=(size(m.Mesh.t,2)+size(m.Mesh.T,2));
        end
    else
        meshsize=(size(m.Mesh.t,2)+size(m.Mesh.T,2));
    end


    N=1.5;
    x=N*meshsize;


    p1=4735.1;
    p2=11920;
    p3=8181.1;
    mu=28743;
    sigma=24978;
    z=(x-mu)/sigma;
    memEstimate=p1*z^2+p2*z+p3;


    memEstimate=round(memEstimate,2,'significant')*1e6;


    [memEstimate,~,u]=engunits(memEstimate);


    memEstimate=[num2str(memEstimate),' ',u,'B'];

end
