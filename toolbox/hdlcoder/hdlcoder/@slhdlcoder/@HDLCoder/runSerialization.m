function runSerialization(this,gp)




    serialFactor=this.getParameter('serializemodel');
    serialIOFactor=this.getParameter('serializeio');

    if(serialFactor>0)
        hTopN=gp.getTopNetwork;
        hTopN.setStreamingFactor(serialFactor);
        serialIOFactor=serialFactor;
    end

    serializationOccurred=0;
    if gp.doSerialization
        serializationOccurred=1;
    end

    if serialIOFactor>0
        if gp.doIOSerialization(serialIOFactor)
            serializationOccurred=1;
        end
    end

    if serializationOccurred
        updateInitVals(gp);
        checks=doSolverChecksForOverclocking(this,[],'Error');
        if~isempty(checks)
            for i=1:length(checks)
                this.addCheckCurrentDriver('Warning',message(checks(i).MessageID));
            end
        end
    end
end

function updateInitVals(gp)

    vNic=gp.getSharedSubsystems;
    for i=1:length(vNic)
        hN=vNic(i).ReferenceNetwork;
        if true
            vComps=hN.Components;
            numComps=length(vComps);

            for j=1:numComps
                hC=vComps(j);
                if strcmp(hC.ClassName,'integerdelay_comp')
                    ic=hC.getInitialValue;
                    if~isscalar(ic)
                        [dimlen,~]=pirelab.getVectorTypeInfo(hC.PirOutputSignals(1));
                        delaylen=hC.getNumDelays;
                        total=dimlen*delaylen;

                        icsize=size(ic);
                        iclen=prod(icsize);

                        if iclen>total
                            error(message('hdlcoder:engine:IntDelayIC'));
                        elseif iclen<total
                            if mod(total,iclen)~=0
                                error(message('hdlcoder:engine:IntDelayIC'));
                            end
                            factor=total/iclen;
                            if icsize(1)>1
                                newIc=repmat(ic,factor,1);
                            else
                                newIc=repmat(ic,1,factor);
                            end
                            hC.setInitialValue(newIc);
                        end
                    end
                end
            end
        end
    end
end



