function[PortEfficiency]=calcPortEfficiency(obj,freq,calc_emb_pattern,ElemNumber,s)







    NumFeedLocations=getNumFeedLocations(obj);

    if NumFeedLocations>1
        if calc_emb_pattern==0

            if isprop(obj,'Exciter')&&isprop(obj.Exciter,'Element')


                [phaseshift,voltage]=em.internal.calculatePhaseShiftAndVoltage(obj.Exciter,obj.Exciter.SolverStruct);
            else
                [phaseshift,voltage]=em.internal.calculatePhaseShiftAndVoltage(obj,obj.SolverStruct);
            end
            [x,y]=pol2cart(phaseshift,voltage);
            V=complex(x,y);
            V=V.';


            Portin=(V')*V;

            sdim=getNumFeedLocations(obj);
            sdiff=eye(sdim)-(s')*s;


            Portout=(V')*(sdiff)*V;
            PortEfficiency=Portout/Portin;
        else
            sd=diag(s);
            s11=abs(sd(ElemNumber));
            PortEfficiency=1-s11^2;
        end
    else
        s11=abs(s);
        PortEfficiency=1-s11^2;
    end
end