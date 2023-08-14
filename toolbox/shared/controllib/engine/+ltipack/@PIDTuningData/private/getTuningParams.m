function TuningParams=getTuningParams(wc,Ts,DesignReqs)





















































    ONEDEG=0.0175;
    HALFDEG=0.00875;
    PHASEINC=0.0785;


    if Ts>0








        wcTs=wc*Ts;
        IF=DesignReqs.IFormula;
        DF=DesignReqs.DFormula;

        PHIZMIN=wcTs/2;

        ALPHAMIN=wcTs/2+HALFDEG;

        PHIZMAX=(wcTs+pi)/2-ONEDEG;
        BETAMAX=(wcTs+pi)/2-HALFDEG;
        if DesignReqs.Form=='S'

            switch DesignReqs.Type
            case 'pi'
                if IF=='B'
                    PHIZMIN=1.01*wcTs;
                elseif IF=='T'
                    PHIZMIN=1.01*PHIZMIN;
                end
            case 'pd'
                if DF=='B'
                    PHIZMIN=wcTs;
                end
            case 'pdf'
                if DF=='B'


                    ALPHAMIN=1.01*wcTs;
                end
            case 'pid'
                switch DF
                case 'F'
                    if IF=='B'

                        PHIZMIN=1.01*PHIZMIN;
                    end
                case 'B'
                    if IF=='B'


                        PHIZMIN=1.01*wcTs;
                    else
                        PHIZMIN=wcTs;
                    end
                case 'T'

                    if IF=='B'

                        PHIZMIN=PHIZMIN+atan(2*tan(wcTs/2));
                    elseif IF=='T'


                        PHIZMIN=1.01*PHIZMIN;
                    end
                end
            case 'pidf'
                if IF=='T'
                    PHIZMIN=1.01*PHIZMIN;
                end
                if DF=='B'


                    ALPHAMIN=1.01*wcTs;
                    if IF=='B'
                        PHIZMIN=1.01*wcTs;
                    end
                end
            end
        else

            if DF=='B'&&DesignReqs.Type(end)=='f'
                ALPHAMIN=1.01*wcTs;
            end
        end
    else
        if DesignReqs.Form=='S'&&any(DesignReqs.Type=='i')
            PHIZMIN=1e-4;
        else
            PHIZMIN=0;
        end
        PHIZMAX=pi/2-ONEDEG;
        ALPHAMIN=HALFDEG;
        BETAMAX=pi/2-HALFDEG;
    end

    TuningParams=struct(...
    'PHIZMIN',PHIZMIN,...
    'PHIZMAX',PHIZMAX,...
    'ALPHAMIN',ALPHAMIN,...
    'BETAMAX',BETAMAX,...
    'PHASEINC',PHASEINC);
end