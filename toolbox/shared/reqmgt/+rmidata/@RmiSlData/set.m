function set(this,objH,newData,varargin)
    [modelH,objH,isSf]=rmisl.resolveObj(objH,true);

    [host,id]=rmidata.getRmiKeys(objH,isSf);
    if~rmisl.isHarnessIdString(host)&&isSf
        [isInLib,libSid]=rmisf.isLibObject(objH,host);
        if isInLib
            [libName,id]=strtok(libSid,':');
            modelH=get_param(libName,'Handle');
        end
    end

    if~isempty(varargin)
        id=sprintf('%s.%d',id,varargin{1});
    end
    this.repository.setData(modelH,id,newData);
    this.statusMap(modelH)=true;
    this.notify('RmiSlDataUpdate',rmidata.RmiSlDataEvent(modelH,id));

    if rmisl.isComponentHarness(modelH)
        mainModel=Simulink.harness.internal.getHarnessOwnerBD(modelH);
        mainModelH=get_param(mainModel,'Handle');
        this.statusMap(mainModelH)=true;
    end
end
