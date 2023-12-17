function Mesh=createMesh(obj)

    meshAccuracy=2;
    meshPower=2;
    nl=obj.numLayer;
    s=obj.separationTraceAtInterface;

    if obj.codeSub==0
        if obj.numTrace(nl)>0
            ttmax=max(obj.thickTrace{nl});
        else
            ttmax=0;
        end
    else
        ttmax=0;
    end


    htot=ttmax+sum(obj.thickSub);
    excessWidthSub=(meshAccuracy+2)*htot;
    if obj.codeSub>0&&excessWidthSub>3*htot
        excessWidthSub=3*htot;
    end


    le=[obj.xCoordTrace{:}];
    re=le+[obj.widthTrace{:}];
    minX=min(le);
    maxX=max(re);

    groundplane.coordCorner=obj.groundPlaneCorner;
    groundplane.width=obj.groundPlaneWidth;

    minPulse=1e15;
    y0=0;
    for iSub=1:obj.numSub
        if obj.thickSub(iSub)<minPulse
            minPulse=obj.thickSub(iSub);
        end
        if obj.numTrace(iSub)>0
            for iTrace=1:obj.numTrace(iSub)
                if abs(obj.yCoordTrace{iSub}(iTrace)-y0)>eps&&...
                    obj.yCoordTrace{iSub}(iTrace)-y0<minPulse
                    minPulse=obj.yCoordTrace{iSub}(iTrace)-y0;
                end
                if y0+obj.thickSub(iSub)-(obj.yCoordTrace{iSub}(iTrace)+obj.thickTrace{iSub}(iTrace))<minPulse
                    minPulse=y0+obj.thickSub(iSub)-(obj.yCoordTrace{iSub}(iTrace)+obj.thickTrace{iSub}(iTrace));
                end
            end
        end
        y0=y0+obj.thickSub(iSub);
    end

    maxPulse=minPulse/meshAccuracy;

    minWidthTrace=min(cellfun(@min,obj.widthTrace(~cellfun(@isempty,obj.widthTrace))));
    minSeparationTrace=min(cellfun(@min,s(~cellfun(@isempty,s))));
    if isempty(minSeparationTrace)||0.25*minWidthTrace<minSeparationTrace
        if minPulse>0.25*minWidthTrace
            minPulse=0.25*minWidthTrace;
        end
    else
        if minPulse>minSeparationTrace
            minPulse=minSeparationTrace;
        end
    end

    if minPulse>excessWidthSub
        minPulse=excessWidthSub;
    end

    ttmin=minPulse;
    ttmax=0;
    minThickTrace=min(cellfun(@min,obj.thickTrace(~cellfun(@isempty,obj.thickTrace))));
    if ttmin>0.25*minThickTrace
        ttmin=0.25*minThickTrace;
    end
    if ttmax<0.25*minThickTrace
        ttmax=minThickTrace;
    end
    if ttmin>0.1*minPulse
        minPulse=ttmin;
    elseif ttmax>0
        minPulse=0.1*minPulse;
    end

    if(abs(groundplane.coordCorner(1)-minX)<eps||abs(groundplane.coordCorner(2)-maxX)<eps)
        groundplane.width=groundplane.width+2*minPulse;
        groundplane.coordCorner(1)=groundplane.coordCorner(1)-minPulse;
        groundplane.coordCorner(2)=groundplane.coordCorner(2)+minPulse;
        if strcmp(obj.Name,'custom')
            str='GroundPlaneLength';
        else
            str='GroundPlaneWidth';
        end
        warning(message('rfpcb:rfpcberrors:TraceEdgeAlignedGroundPlane',str,num2str(obj.groundPlaneWidth)));
    end
    Mesh.GP=groundplane;


    Mesh.Pulse=getPulse(obj,groundplane,minPulse,maxPulse,meshAccuracy,meshPower);
    Mesh.Node=getNode(obj,Mesh.Pulse);
end