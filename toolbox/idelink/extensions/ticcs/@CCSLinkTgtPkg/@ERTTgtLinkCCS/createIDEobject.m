function cs=createIDEobject(h,boardNum,procNum)




    cs=ticcs('boardnum',boardNum,'procnum',procNum,'timeout',h.ideObjTimeout);
    cs.set('buildtimeout',h.ideObjBuildTimeout);
