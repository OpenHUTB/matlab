function initChecks(cgo)



    cgo.TaskMap=containers.Map('keyType','char','ValueType','double');

    cgo.cgirCheckIdx=[];
    cgo.cgirCheckIds={};

    for i=1:cgo.CGONum
        checkid=['com.mathworks.cgo.',num2str(i)];
        checkObj=cgo.MAObj.getTaskObj(checkid);

        if~isempty(checkObj)
            if~strcmp(cgo.runMode,'rtwgen')
                checkObj.updateStates('None');
            end
            checkObj.changeSelectionStatus(true,false);
            if~isempty(cgo.runMode)&&...
                strcmp(cgo.MAObj.getCheckObj(checkObj.MAC).callbackContext,'CGIR')
                cgo.cgirCheckIdx=[cgo.cgirCheckIdx,checkObj.Index];
                cgo.cgirCheckIds{end+1}=checkObj.MAC;
                if~strcmp(cgo.runMode,'rtwgen')
                    checkObj.changeSelectionStatus(false);
                else
                    checkObj.changeSelectionStatus(true,false);
                end
            end
            cgo.TaskMap(checkid)=checkObj.Index;
        end
    end


