function[FeedPower]=calcFeedpowerArray(obj,freq,calc_emb_pattern,...
    ElemNumber)








































    if isprop(obj,'Exciter')&&isprop(obj.Exciter,'Element')


        [phaseshift,voltage]=em.internal.calculatePhaseShiftAndVoltage(obj.Exciter,obj.Exciter.SolverStruct);
    else
        [phaseshift,voltage]=em.internal.calculatePhaseShiftAndVoltage(obj,obj.SolverStruct);
    end
    [x,y]=pol2cart(phaseshift,voltage);

    V=complex(x,y);
    Vabs=abs(V);
    Vindex=find(Vabs);
    Vabs=Vabs(Vindex);

    Zin=impedance(obj,freq);
    Zin=Zin(Vindex);
    Pantenna=real((Vabs.^2)./conj(Zin));
    if calc_emb_pattern==0
        FeedPower=0.5*abs(sum(Pantenna));
    else
        FeedPower=0.5*abs(real(Pantenna(ElemNumber)));
    end
end
