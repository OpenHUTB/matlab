function[harness,owner]=componentHarnessMgr(method,varargin)
    harness='';
    owner='';

    switch method

    case 'close'
        Simulink.harness.close(varargin{1});

    case 'open'
        modelH=varargin{1};
        harnessName=varargin{2};
        harnessInfo=Simulink.harness.find(modelH,'Name',harnessName);
        if~isempty(harnessInfo)
            harness=harnessInfo.name;
            owner=harnessInfo.ownerFullPath;
            Simulink.harness.open(owner,harnessName);
        end

    case 'active'
        mdlName=varargin{1};
        harness=Simulink.harness.internal.getActiveHarness(mdlName);

    case 'sid'
        ownerObj=varargin{1};
        harness=Simulink.harness.internal.sidmap.getOwnerObjectSIDInHarness(ownerObj);

    otherwise
        error('Illegal first argument in a call to rmisl.componentHanressMgr()');
    end
end

