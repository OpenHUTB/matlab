function[phaseshift,voltage]=calculatePhaseShiftAndVoltage(obj,SolverStruct)
    if isfield(SolverStruct.Source,'phaseshift')
        phaseshift=SolverStruct.Source.phaseshift;
    elseif isprop(obj,'Exciter')
        phaseshift=obj.Exciter.FeedPhase*pi/180;
    else
        phaseshift=obj.Element.PhaseShift*pi/180;
    end
    voltage=SolverStruct.Source.voltage;
    if any(strcmpi(class(obj),{'conformalArray','installedAntenna'}))
        [phaseshift,voltage]=em.internal.calcPhaseShiftAndVoltageForConformal(obj.Element,obj.ElementPosition,voltage,phaseshift);
    elseif isprop(obj,'Element')
        [element,exciter,ps,fv]=em.internal.dipoleCrossedLocation(obj.Element);
        if element==1||exciter==1
            Size=prod(obj.ArraySize);
            for i=1:Size
                phaseShift{1,i}=ps.*pi/180+repmat(phaseshift(i),1,numel(ps));%#ok<AGROW>
                VOLTAGE{1,i}=fv.*(repmat(voltage(i),1,numel(ps)));%#ok<AGROW>
            end
            phaseshift=cell2mat(phaseShift);
            voltage=cell2mat(VOLTAGE);
            if isa(obj.Element,'em.Array')
                ps=obj.Element.PhaseShift.*pi/180;
                if isscalar(ps)
                    ps=repmat(ps,1,prod(obj.Element.ArraySize));
                end
                vol=obj.Element.AmplitudeTaper;
                if isscalar(vol)
                    vol=repmat(vol,1,prod(obj.Element.ArraySize));
                end
                Size=prod(obj.ArraySize);
                phaseshift2=repmat(ps,1,2*Size);
                voltage2=repmat(vol,1,2*Size);
                phaseshift=phaseshift+phaseshift2;
                voltage=voltage.*voltage2;
            end
        elseif isa(obj.Element,'em.Array')
            ps=obj.Element.PhaseShift.*pi/180;
            if isscalar(ps)
                ps=repmat(ps,1,prod(obj.Element.ArraySize));
            end
            vol=obj.Element.AmplitudeTaper;
            if isscalar(vol)
                vol=repmat(vol,1,prod(obj.Element.ArraySize));
            end
            Size=prod(obj.ArraySize);
            phaseshift1=repmat(ps,1,Size);
            voltage1=repmat(vol,1,Size);
            Size=prod(obj.Element.ArraySize);
            phaseshift2=repmat(phaseshift,1,Size);
            voltage2=repmat(voltage,1,Size);
            phaseshift=phaseshift1+phaseshift2;
            voltage=voltage1.*voltage2;
        end
    end
end