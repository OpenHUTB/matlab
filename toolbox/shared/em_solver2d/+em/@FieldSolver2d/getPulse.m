function Pulse=getPulse(obj,gp,minPulse,maxPulse,meshAccuracy,meshPower)

    nl=obj.numLayer;

    idx=obj.idxTraceAtInterface;
    s=obj.separationTraceAtInterface;
    Pulse.widthTrace=cell(1,nl);
    Pulse.thickTrace=cell(1,nl);
    Pulse.separationTrace=cell(1,nl);
    for iLayer=1:nl
        if obj.numTrace(iLayer)>0
            Pulse.widthTrace{iLayer}=getNumPulse1(obj.widthTrace{iLayer},minPulse,maxPulse,meshAccuracy,meshPower,1);
            if any(obj.thickTrace{iLayer})
                Pulse.thickTrace{iLayer}=getNumPulse1(obj.thickTrace{iLayer},minPulse,maxPulse,meshAccuracy,meshPower,1);
            else
                Pulse.thickTrace{iLayer}=zeros(1,obj.numTrace(iLayer));
            end
            Pulse.separationTrace{iLayer}=getNumPulse1(s{iLayer},minPulse,maxPulse,meshAccuracy,meshPower,1);
        end
        if iLayer==1
            continue
        elseif obj.numTrace(iLayer)>0

            if~isempty(idx{iLayer})
                xl=min(obj.xCoordTrace{iLayer}(idx{iLayer}))-gp.coordCorner(1,1);
                xr=gp.coordCorner(1,2)-max(obj.xCoordTrace{iLayer}(idx{iLayer})+obj.widthTrace{iLayer}(idx{iLayer}));
                Pulse.excessLeftWidthSub(iLayer)=getNumPulse1(xl,minPulse,maxPulse,meshAccuracy,meshPower,.7);
                Pulse.excessRightWidthSub(iLayer)=getNumPulse1(xr,minPulse,maxPulse,meshAccuracy,meshPower,.7);
            else
                Pulse.excessLeftWidthSub(iLayer)=getNumPulse2(gp.width,maxPulse,meshPower);
            end
        else
            Pulse.excessLeftWidthSub(iLayer)=getNumPulse2(gp.width,maxPulse,meshPower);
        end
    end

    if~obj.hasTraceOnTopLayer
        Pulse.excessLeftWidthSub(obj.numSub+1)=getNumPulse2(gp.width,maxPulse,meshPower);
    end

    Pulse.groundplane=getNumPulse2(gp.width,maxPulse,meshPower);

    for iSub=1:obj.numSub
        Pulse.thickSub(iSub)=getNumPulse2(obj.thickSub(iSub),maxPulse,meshPower);
    end

end

function numPulse=getNumPulse1(edge,minPulse,maxPulse,meshAccuracy,meshPower,factor)
    numPulse=zeros(1,length(edge));
    for i=1:length(edge)
        ratio=(edge(i)/minPulse)^(1/meshPower);
        if ratio>999
            ratio=999;
        end
        numPulse(i)=floor(factor*meshAccuracy*ratio+0.5);
        if numPulse(i)<1
            numPulse(i)=1;
        end
        ratio=2*edge(i)/(maxPulse*meshPower);
        if ratio>999
            ratio=999;
        end
        temp=floor(ratio+0.5);
        if numPulse(i)<temp
            numPulse(i)=temp;
        elseif numPulse(i)>99
            numPulse(i)=99;
        end
    end
end

function numPulse=getNumPulse2(edge,maxPulse,meshPower)
    ratio=2*edge/(maxPulse*meshPower);
    if ratio>999
        ratio=999;
    end
    numPulse=floor(ratio+0.5);
    if numPulse<1
        numPulse=1;
    elseif numPulse>99
        numPulse=99;
    end
end
