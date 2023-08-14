function antennaInfo=protectedinfo(obj)



























    isSolved=~isempty(obj.SolverStruct.Solution)&&~obj.MesherStruct.HasStructureChanged;
    if isa(obj,'platform')
        if~isfield(obj.SolverStruct,'RCSSolution')
            isSolved=false;
        else
            isSolved=~isempty(obj.SolverStruct.RCSSolution)&&...
            ~obj.MesherStruct.HasStructureChanged;
        end
    end

    allowedObjClasses={'rfpcb.PCBComponent','rfpcb.PCBSubComponent','rfpcb.PCBVias','em.Antenna','em.Array','customArrayGeometry','installedAntenna','platform','customAntennaStl','pcbComponent'};

    if~any(cellfun(@(x)isa(obj,x),allowedObjClasses))
        error(message('antenna:antennaerrors:Unsupported',class(obj),'info'));
    end
    isMeshed=~isempty(obj.MesherStruct.Mesh.p)&&~obj.MesherStruct.HasStructureChanged;
    antennaInfo.IsSolved=string(isSolved);
    antennaInfo.IsMeshed=string(isMeshed);
    antennaInfo.MeshingMode=string(getMeshMode(obj));
    [tf,tfelement,tfExciter]=isDielectricSubstrate(obj);
    antennaInfo.HasSubstrate=string(tf|tfelement|tfExciter);
    if isa(obj,'rfpcb.PCBComponent')||isa(obj,'rfpcb.PCBSubComponent')||isa(obj,'rfpcb.PCBVias')
        antennaInfo.HasLoad=string(isLoadDefined(getPrintedStack(obj)));
    else
        antennaInfo.HasLoad=string(isLoadDefined(obj));
    end




    if isSolved
        if isa(obj,'rfpcb.PCBComponent')||isa(obj,'pcbComponent')||isa(obj,'rfpcb.PCBSubComponent')||isa(obj,'rfpcb.PCBVias')
            antennaInfo.PortFrequency=obj.SolverStruct.Solution.Frequency;
        elseif isa(obj,'em.Antenna')||isa(obj,'installedAntenna')
            antennaInfo.PortFrequency=obj.SolverStruct.Solution.Frequency;
            antennaInfo.FieldFrequency=obj.SolverStruct.Solution.Dirfreq;

        elseif isa(obj,'em.Array')
            antennaInfo.PortFrequency=obj.SolverStruct.Solution.YPFrequency;
            antennaInfo.FieldFrequency=obj.SolverStruct.Solution.Frequency;
        end
        if~any(cellfun(@(x)isa(obj,x),{'installedAntenna','platform'}))
            antennaInfo.MemoryEstimate=string(memoryEstimate(obj));
        end
    else
        if isa(obj,'rfpcb.PCBComponent')||isa(obj,'pcbComponent')||isa(obj,'rfpcb.PCBSubComponent')||isa(obj,'rfpcb.PCBVias')
            antennaInfo.PortFrequency=[];
            antennaInfo.MemoryEstimate=[];
        else
            antennaInfo.PortFrequency=[];
            antennaInfo.FieldFrequency=[];
            if~any(cellfun(@(x)isa(obj,x),{'installedAntenna','platform'}))
                antennaInfo.MemoryEstimate=[];
            end
        end
    end

    if(isfield(obj.SolverStruct,'DesignFreq'))
        antennaInfo.DesignFreq=obj.SolverStruct.DesignFreq;
    end

end
