function tf=isLoadDefined(obj)

    tf=false;
    if isa(obj,'em.Antenna')&&~isa(obj,'infiniteArray')||...
        (isa(obj,'rfpcb.PCBComponent')||isa(obj,'rfpcb.PCBSubComponent')||isa(obj,'pcbComponent'))
        if~isempty(obj.Load)
            if iscell(obj.Load)
                for m=1:numel(obj.Load)
                    temp(m)=~isempty(obj.Load{m}.Impedance);
                end
                tf=any(temp);
            elseif numel(obj.Load)>1
                for m=1:numel(obj.Load)
                    temp(m)=~isempty(obj.Load(m).Impedance);
                end
                tf=any(temp);
            else
                tf=any(arrayfun(@(x)~isempty(x.Load.Impedance),obj));
            end
        end
    end

    if isa(obj,'installedAntenna')
        if numel(obj.Element)>1
            if iscell(obj.Element)
                tf=any(cellfun(@(x)isLoadDefined(x),obj.Element));
            else
                tf=any(arrayfun(@(x)isLoadDefined(x),obj.Element));
            end
        else
            tf=isLoadDefined(obj.Element);
        end
    elseif isa(obj,'em.ParabolicAntenna')
        tf=isLoadDefined(obj.Exciter);
    end
