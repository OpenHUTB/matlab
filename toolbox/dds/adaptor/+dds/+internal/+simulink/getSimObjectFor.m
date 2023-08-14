function simObj=getSimObjectFor(mdl,mf0Object,release,withBase)




    simObj=[];
    if nargin<4
        withBase=true;
    end

    if nargin<3
        release='';
    end
    simObjVisitor=dds.internal.simulink.GetSimObjectsVisitor(release,withBase);
    status=simObjVisitor.visitModelForOnlyElements(mdl,{mf0Object.UUID});
    if status
        fullName=dds.internal.getFullNameForType(mf0Object);
        if simObjVisitor.ObjectMap.isKey(fullName)
            entry=simObjVisitor.ObjectMap(fullName);
            simObj=entry.Obj;
        end
    end
