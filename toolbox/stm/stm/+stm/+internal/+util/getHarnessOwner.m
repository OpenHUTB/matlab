function[rootBD,owner]=getHarnessOwner(harnessName)


    rootBD=Simulink.harness.internal.getHarnessOwnerBD(harnessName);
    owner='';

    if(~isempty(rootBD))


        harnessInfo=sltest.harness.find(rootBD,'Name',harnessName);
        owner=harnessInfo.ownerFullPath;
    end
end

