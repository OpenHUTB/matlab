function blockInfo=getSysObjInfo(this,hC,sysObjImpl)%#ok<INUSL>




    blockInfo.desc='';


    blockInfo.numDelays=sysObjImpl.Length;


    if~hdlissignalvector(hC.PirInputSignals(1))
        numChan=1;
    else
        numChan=hC.PirInputSignals(1).Type.Dimensions;
    end


    blockInfo.initVal=getInitValue(sysObjImpl,numChan);


    hdlImpl=hC.getHDLImplParams;
    rambasedDelay=false;
    if~isempty(hdlImpl)
        mapToRAMs=hdlImpl.MapPersistentVarsToRAM;
        if mapToRAMs
            ramThreshold=hdlImpl.RAMThreshold;
            delayNumber=sysObjImpl.Length;
            rambasedDelay=all(blockInfo.initVal==0)&&pirelab.getMapDelayToRam(hC.PirInputSignals(1),delayNumber,ramThreshold);
        end
    else
    end

    blockInfo.rambased=rambasedDelay;

end

function initVal=getInitValue(sysObj,numChan)

    s=sysObj.getAdaptorRunTimeData();
    dWorks=s.DWorks;
    initVal=0;
    if isfield(dWorks,'IC_BUFF')
        initVal=dWorks.IC_BUFF;
    end





    l=sysObj.Length;
    if all(l==l(1))...
        &&numChan>1...
        &&(numel(initVal)==l(1)*numChan)
        l=l(1);

        rval=reshape(initVal,l,numChan);

        initVal=reshape(rval.',l*numChan,1);
    end
end
