function validateForEachPortTypes(this,hN)





    hComps=hN.Components;
    for jj=1:numel(hComps)
        if hComps(jj).isNetworkInstance&&hComps(jj).ReferenceNetwork.isForEachSubsystem
            portSigs=hComps(jj).PirInputSignals;
            for ii=1:numel(portSigs)
                checkPortType(this,hN,hComps(jj),portSigs(ii));
            end

            portSigs=hComps(jj).PirOutputSignals;
            for ii=1:numel(portSigs)
                checkPortType(this,hN,hComps(jj),portSigs(ii));
            end
        end
    end
end

function checkPortType(this,hN,hC,hS)
    hT=hS.Type;
    dims=numel(hT.getDimensions());

    if dims>2
        blkPath=[hN.FullPath,'/',hC.Name];
        msg=message('hdlcoder:matrix:blocknotsupported',blkPath);
        this.updateChecks(blkPath,'block',msg,'Error');
    end
    if hT.isMatrix
        if~strcmp(hdlfeature('ForEachMatrix'),'on')
            msg=message('hdlcoder:matrix:ForEachUnsupported');
            blkPath=[hN.FullPath,'/',hC.Name];
            this.updateChecks(blkPath,'block',msg,'Error')
        elseif hT.isArrayOfRecords
            msg=message('hdlcoder:matrix:ForEachArrayOfRecordsUnsupported');
            blkPath=[hN.FullPath,'/',hC.Name];
            this.updateChecks(blkPath,'block',msg,'Error')
        end
    end
end
