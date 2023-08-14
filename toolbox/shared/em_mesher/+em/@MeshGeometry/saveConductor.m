function saveConductor(obj)

    thick=0;cond=inf;name='PEC';
    if isa(obj,'dipoleCrossed')||isa(obj,'eggCrate')
        [cond,thick,name]=getmetalprop(obj);
    elseif isa(obj,'planeWaveExcitation')
        cond=obj.Element.MesherStruct.conductivity;
        thick=obj.Element.MesherStruct.thickness;
        name=obj.Element.MesherStruct.metalname;
    elseif isa(obj,'infiniteArray')
        [cond,thick,name]=getarraymetalprop(obj);
    elseif isa(obj,'rfpcb.PCBComponent')||isa(obj,'pcbComponent')||isa(obj,'rfpcb.PCBSubComponent')||isa(obj,'rfpcb.PCBVias')
        [cond,thick,name]=getantennametalprop(obj);
    elseif isa(obj,'em.Antenna')||isa(obj,'pcbStack')
        [cond,thick,name]=getantennametalprop(obj);
    elseif isa(obj,'em.Array')&&~isa(obj,'customArrayMesh')
        [cond,thick,name]=getarraymetalprop(obj);
    end

    if~isscalar(thick)
        if any(thick~=thick(1))
            error(message('antenna:antennaerrors:DifferentConductorsForExciterAndBacking'));
        end
    end


    if isinf(cond(1))&&thick(1)~=0
        error(message('antenna:antennaerrors:InvalidMetal'));
    elseif~isinf(cond(1))&&thick(1)==0
        error(message('antenna:antennaerrors:InvalidMetal'));
    end

    obj.MesherStruct.conductivity=cond(1);
    obj.MesherStruct.thickness=thick(1);
    obj.MesherStruct.metalname=name;


end

function[conductivity,thickness,name]=getmetalprop(elem)
    if isa(elem,'dipoleCrossed')||isa(elem,'eggCrate')
        [conductivity,thickness,name]=getantennametalprop(elem.Element);
    else
        conductivity=elem.MesherStruct.conductivity;
        thickness=elem.MesherStruct.thickness;
        name=elem.MesherStruct.metalname;
    end

end

function[conductivity,thickness,name]=getantennametalprop(elem)

    ex_t=[];ex_c=[];
    if isprop(elem,'Exciter')
        if isprop(elem.Exciter,'Conductor')&&~isempty(elem.Exciter.Conductor)
            ex_t=elem.Exciter.Conductor.Thickness;
            ex_c=elem.Exciter.Conductor.Conductivity;
        elseif isa(elem.Exciter,'em.Array')
            [ex_c,ex_t,~]=getarraymetalprop(elem.Exciter);
        elseif isprop(elem.Exciter,'Element')&&isa(elem.Exciter,'dipoleCrossed')
            [ex_c,ex_t,~]=getantennametalprop(elem.Exciter.Element);
        elseif isprop(elem.Exciter,'Element')&&...
            isprop(elem.Exciter.Element,'Conductor')&&~isempty(elem.Exciter.Element.Conductor)
            [ex_c,ex_t,~]=getarraymetalprop(elem.Exciter);
        else
            ex_t=0;
            ex_c=inf;
        end
    end
    if isprop(elem,'Conductor')&&~isempty(elem.Conductor)
        ant_t=elem.Conductor.Thickness;
        ant_c=elem.Conductor.Conductivity;
        ant_n=elem.Conductor.Name;
    else
        ant_t=0;
        ant_c=inf;
        ant_n='PEC';
    end

    thickness=[ant_t,ex_t];
    conductivity=[ant_c,ex_c];

    if~isscalar(thickness)
        if all(diff(thickness))
            error(message('antenna:antennaerrors:DifferentConductorsForExciterAndBacking'));
        end
    end

    if~isscalar(conductivity)
        if~all(isinf(conductivity))
            if all(diff(conductivity))
                error(message('antenna:antennaerrors:DifferentConductorsForExciterAndBacking'));
            end
        end
    end

    conductivity=ant_c;
    thickness=ant_t;
    name=ant_n;


end


function[cond,thick,name]=getarraymetalprop(obj)

    if isscalar(obj.Element)
        if isa(obj.Element,'em.Array')
            if isa(obj.Element.Element,'dipoleCrossed')
                [cond,thick,name]=getmetalprop(obj.Element.Element);
            else
                [cond,thick,name]=getantennametalprop(obj.Element.Element);
            end
        else
            [cond,thick,name]=getmetalprop(obj.Element);
        end
    else
        cond=zeros(1,numel(obj.Element));
        thick=zeros(1,numel(obj.Element));
        for m=1:numel(obj.Element)
            if iscell(obj.Element)
                if isa(obj.Element{m},'em.Array')
                    [cond(m),thick(m),name]=getmetalprop(obj.Element{m}.Element);
                else
                    [cond(m),thick(m),name]=getmetalprop(obj.Element{m});
                end
            else
                if isa(obj.Element(m),'em.Array')
                    [cond(m),thick(m),name]=getmetalprop(obj.Element(m).Element);
                else
                    [cond(m),thick(m),name]=getmetalprop(obj.Element(m));
                end
            end
        end
    end
end