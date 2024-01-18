function[navcmd,dispstr,bitmap]=targetInfo(target,type)

    switch type
    case 'simulink'
        if ischar(target)&&any(target=='|')&&rmisl.isSidString(target)

            [navcmd,dispstr,bitmap]=rmiml.bookmarkInfo(target);
        else
            [navcmd,dispstr,bitmap]=rmi.objinfo(target);
        end
    case 'data'

        [navcmd,dispstr,bitmap]=rmi.objinfo(target);
    case 'matlab'
        [navcmd,dispstr,bitmap]=rmiml.bookmarkInfo(target);
    case 'testmgr'
        [navcmd,dispstr,bitmap]=rmitm.testCaseInfo(target);
    otherwise
        navcmd='';
        dispstr='TARGET NOT SUPPORTED';
        bitmap='';
    end
end

