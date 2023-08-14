
function checkCumDataConsistency(this)




    if this.isCvCmdCall
        return;
    end
    if~this.resultSettings.enableCumulative
        return;
    end
    allModelcovIds=this.getAllModelcovIds;
    resetIt=false;
    if~isempty(this.oldModelcovIds)&&~isequal(this.oldModelcovIds,allModelcovIds)
        resetIt=true;
    end
    rootIds=[];

    for currModelcovId=allModelcovIds(:)'
        currentTest=cv('get',currModelcovId,'.currentTest');
        if currentTest==0
            continue;
        end
        testObj=cvdata(currentTest);
        rootIds(end+1)=testObj.rootID;%#ok<AGROW>
        if resetIt
            continue
        end
        rt=cv('get',testObj.rootID,'.runningTotal');
        if rt~=0
            rtd=cvdata(rt);
            if~strcmpi(rtd.filter,testObj.filter)
                resetIt=true;
                continue
            end
            if rtd.simMode~=testObj.simMode
                resetIt=true;
                continue
            end
            if~cvi.SLCustomCodeCov.checkDataConsistency(testObj,rtd)
                resetIt=true;
                continue
            end
        end
    end
    if~resetIt

        rt=cv('get',rootIds,'.runningTotal');

        resetIt=~all(rt)&&any(rt);
    end

    if resetIt
        for cr=rootIds(:)'
            cv('set',cr,'.runningTotal',0);
            cv('set',cr,'.prevRunningTotal',0);
        end
    end
