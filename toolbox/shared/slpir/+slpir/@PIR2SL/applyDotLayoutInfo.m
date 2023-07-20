function applyDotLayoutInfo(this,parentPath,hN)





    try
        this.genmodeldisp(sprintf('Applying Dot Layout...'),3);
        ntwkRefNum=hN.RefNum;
        numInports=hN.NumberOfPirInputPorts;
        vInports=hN.PirInputPorts;



        useDotLayout=this.renderCodeGenPIR(hN);

        for i=1:numInports
            hP=vInports(i);

            if this.isValidPort(hP)&&~useDotLayout
                srcPath=[hN.FullPath,'/',hP.Name];
                targetPath=['',parentPath,'/',hP.Name,''];
                applyLayoutForSLPort(srcPath,targetPath);
            else
                nodeName=sprintf('%s_ip%d',ntwkRefNum,i-1);
                targetPath=['',parentPath,'/',hP.Name,''];

                applyLayoutForPirBlock(this,nodeName,targetPath);
            end
        end


        vComps=hN.Components;
        numComps=length(vComps);
        for i=1:numComps
            hC=vComps(i);
            if~this.isValidComp(hC,useDotLayout)
                continue;
            end

            if~useDotLayout
                targetPath=['',parentPath,'/',hC.Name,''];

                if~hC.Synthetic
                    applyLayoutForSLBlock(hC.SimulinkHandle,targetPath);
                end
            else
                nodeName=[ntwkRefNum,'_',hC.RefNum];
                targetPath=['',parentPath,'/',hC.Name,''];

                applyLayoutForPirBlock(this,nodeName,targetPath);
            end
        end



        numOutports=hN.NumberOfPirOutputPorts;
        vOutports=hN.PirOutputPorts;
        for i=1:numOutports
            hP=vOutports(i);

            if this.isValidPort(hP)&&~useDotLayout
                srcPath=[hN.FullPath,'/',hP.Name];
                targetPath=['',parentPath,'/',hP.Name,''];

                applyLayoutForSLPort(srcPath,targetPath);
            else
                nodeName=sprintf('%s_op%d',ntwkRefNum,i-1);

                targetPath=['',parentPath,'/',hP.Name,''];
                applyLayoutForPirBlock(this,nodeName,targetPath);
            end
        end
    catch
        warnObj=message('hdlcoder:engine:AutoPlaceFailed');
        this.reportCheck('Warning',warnObj);
    end
end


function applyLayoutForSLPort(srcPath,targetPath)

    origBlockPos=get_param(srcPath,'Position');
    origBlockOr=get_param(srcPath,'Orientation');

    set_param(targetPath,'Position',origBlockPos);
    set_param(targetPath,'Orientation',origBlockOr);

end


function applyLayoutForSLBlock(slHandle,targetPath)

    origBlockPos=get_param(slHandle,'Position');
    origBlockOr=get_param(slHandle,'Orientation');

    set_param(targetPath,'Position',origBlockPos);
    set_param(targetPath,'Orientation',origBlockOr);

end


function applyLayoutForPirBlock(this,nodeId,targetPath)

    [l,t,r,b]=this.pirLayout.getSLDimensions(nodeId);
    blockPos=[l,t,r,b];

    set_param(targetPath,'Position',blockPos);
    set_param(targetPath,'Orientation','right');

end


