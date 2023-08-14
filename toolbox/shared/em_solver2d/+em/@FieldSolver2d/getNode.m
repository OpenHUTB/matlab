function Node=getNode(obj,pulse)

    nl=obj.numLayer;
    if obj.hasTraceOnTopLayer
        epsilonR=[obj.epsilonRSub,1.0];
        lossTangent=[obj.lossTangentSub,0.0];
    else
        epsilonR=obj.epsilonRSub;
        lossTangent=obj.lossTangentSub;
    end


    Node.numNode=pulse.groundplane+1;

    for iLayer=1:nl
        for iTrace=1:obj.numTrace(iLayer)
            if obj.thickTrace{iLayer}(iTrace)>0
                Node.numNode=Node.numNode+2*(pulse.widthTrace{iLayer}(iTrace)+pulse.thickTrace{iLayer}(iTrace)+2);
            else
                Node.numNode=Node.numNode+pulse.widthTrace{iLayer}(iTrace)+1;
            end
        end



        if iLayer~=1&&(abs(epsilonR(iLayer)-epsilonR(iLayer-1))>eps||abs(lossTangent(iLayer)-lossTangent(iLayer-1))>eps)
            for iTrace=1:length(pulse.separationTrace{iLayer})
                Node.numNode=Node.numNode+pulse.separationTrace{iLayer}(iTrace)+1;
            end
            Node.numNode=Node.numNode+pulse.excessLeftWidthSub(iLayer)+1;
            if obj.numTrace(iLayer)>0
                Node.numNode=Node.numNode+pulse.excessRightWidthSub(iLayer)+1;
            end
        end
    end

    if obj.codeSub>0
        Node.numNode=Node.numNode+pulse.excessLeftWidthSub(obj.numSub+1)+1;





    elseif obj.codeSub==0&&~obj.hasTraceOnTopLayer&&...
        (abs(epsilonR(obj.numSub)-1)>eps||abs(lossTangent(obj.numSub))>eps)
        Node.numNode=Node.numNode+pulse.excessLeftWidthSub(obj.numSub+1)+1;
    end

    for iSub=1:obj.numSub
        if abs(epsilonR(iSub)-1)>eps||abs(lossTangent(iSub))>eps
            Node.numNode=Node.numNode+2*(pulse.thickSub(iSub)+1);
        end
    end

end
