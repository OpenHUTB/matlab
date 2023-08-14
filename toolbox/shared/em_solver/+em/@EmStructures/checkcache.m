function[calculate_static_soln,calculate_dynamic_soln,calculate_load]...
    =checkcache(obj,frequency,ElemNumber,~,addtermination,Termination)

    calculate_static_soln=1;
    calculate_dynamic_soln=1;
    if~obj.MesherStruct.HasMeshChanged
        calculate_static_soln=0;
        if~isempty(obj.SolverStruct.Solution)&&...
            obj.SolverStruct.HasSourceChanged==0

            if isempty(ElemNumber)&&addtermination~=1
                idxf=find(obj.SolverStruct.Solution.Frequency==...
                frequency,1);
                if~isempty(idxf)
                    calculate_dynamic_soln=0;
                end
                if strcmpi(class(obj),'infiniteArray')
                    if~isequal(obj.SolverStruct.Solution.ScanElevation,...
                        obj.ScanElevation)||~isequal(obj.ScanAzimuth,...
                        obj.SolverStruct.Solution.ScanAzimuth)
                        calculate_dynamic_soln=1;
                    end
                elseif isa(obj,'em.Array')
                    if obj.MesherStruct.HasTaperChanged
                        calculate_dynamic_soln=1;
                        obj.SolverStruct.Solution.Frequency=[];
                        obj.SolverStruct.Solution.I=[];
                        obj.SolverStruct.Solution.Iperport=[];
                        obj.SolverStruct.Solution.Dirfreq=[];
                        obj.SolverStruct.Solution.Directivity=[];
                        obj.SolverStruct.Solution.Radfreq=[];
                        obj.SolverStruct.Solution.RadiatedPower=[];
                        obj.MesherStruct.HasTaperChanged=0;
                        obj.SolverStruct.Solution.ARfreq=[];
                        obj.SolverStruct.Solution.AR=[];
                    end
                end

            elseif isscalar(ElemNumber)&&addtermination
                if isequal(obj.SolverStruct.Solution.Embfreq,frequency)...
                    &&all(obj.SolverStruct.Solution.EmbTermination==Termination)
                    calculate_dynamic_soln=0;
                end

            else
                idxf=find(obj.SolverStruct.Solution.YPFrequency...
                ==frequency,1);
                if~isempty(idxf)
                    calculate_dynamic_soln=0;
                end
            end
        end
    end

    calculate_load=0;
    saveLoad(obj);
    if isfield(obj.MesherStruct,'Load')&&isfield(obj.SolverStruct,'Load')
        if~isequal(obj.SolverStruct.Load,obj.MesherStruct.Load)
            calculate_load=1;
            obj.SolverStruct.Load=obj.MesherStruct.Load;
        end
    end

    if isfield(obj.SolverStruct.Solution,'loaderror')&&...
        (obj.SolverStruct.Solution.loaderror==1)
        calculate_load=1;
        obj.SolverStruct.Solution.loaderror=0;
    end



    if strcmpi(class(obj),'planeWaveExcitation')
        if getSourceChanged(obj)
            obj.SolverStruct.Solution.Sfrequency=[];
            obj.SolverStruct.Solution.SI=[];
            setSourceChanged(obj,false);
        end
        if isfield(obj.SolverStruct.Solution,'Sfrequency')
            idxf=find(obj.SolverStruct.Solution.Sfrequency==frequency,1);
            if~isempty(idxf)
                calculate_dynamic_soln=0;
            end
        end
    end

    if isfield(obj.SolverStruct,'HasSolverChanged')&&obj.SolverStruct.HasSolverChanged


        recompute=1;
    else
        recompute=0;
    end
    if calculate_static_soln||calculate_load||recompute



        calculate_dynamic_soln=1;
        calculate_load=1;
        obj.SolverStruct.Solution.Frequency=[];
        obj.SolverStruct.Solution.I=[];
        obj.SolverStruct.Solution.Iperport=[];
        obj.SolverStruct.Solution.Sfrequency=[];
        obj.SolverStruct.Solution.SI=[];
        obj.SolverStruct.Solution.Dirfreq=[];
        obj.SolverStruct.Solution.Directivity=[];
        obj.SolverStruct.Solution.EmbDirectivity=[];
        obj.SolverStruct.Solution.Embfreq=[];
        obj.SolverStruct.Solution.EmbElement=[];
        obj.SolverStruct.Solution.EmbTermination=[];
        obj.SolverStruct.Solution.Radfreq=[];
        obj.SolverStruct.Solution.RadiatedPower=[];
        obj.SolverStruct.Solution.ArrayFrequency=[];
        obj.SolverStruct.Solution.ArrayI=[];
        obj.SolverStruct.Solution.YPFrequency=[];
        obj.SolverStruct.Solution.yparam=[];
        obj.SolverStruct.Solution.ScanElevation=[];
        obj.SolverStruct.Solution.ScanAzimuth=[];
        obj.SolverStruct.Solution.LoadZ=[];
        obj.SolverStruct.Solution.ZL=[];
        obj.SolverStruct.Solution.frq=[];
        obj.SolverStruct.Solution.loadedge=0;
        obj.SolverStruct.Solution.ARfreq=[];
        obj.SolverStruct.Solution.AR=[];
    end

end