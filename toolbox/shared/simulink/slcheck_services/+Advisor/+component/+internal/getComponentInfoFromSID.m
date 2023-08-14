function[objectSID,contextSID,isLibrarySID,isSF,libBDName]=...
    getComponentInfoFromSID(sid)










    contextSID='';
    objectSID='';
    isLibrarySID=false;
    isSF=false;
    libBDName='';

    objectIn=Simulink.ID.getHandle(sid);
    if isa(objectIn,'double')
        objectIn=get_param(objectIn,'Object');
    end


    parentObject=Advisor.component.internal.Object2ComponentID.getParentComponentObject(objectIn);


    [Object,contextObject]=Advisor.component.internal.Object2ComponentID.resolveObject(parentObject);




    if~isempty(contextObject)&&bdIsLibrary(bdroot(contextObject.Path))
        contextObject=[];
    end


    while~isempty(Object)&&loc_isInsideMWSubsystem(Object)
        Object=Object.getParent();
    end

    if~isempty(Object)
        if isempty(contextObject)
            objectSID=Simulink.ID.getSID(Object);



            bdName=Simulink.ID.getModel(sid);

            if bdIsLibrary(bdName)
                libBDName=bdName;
                isLibrarySID=true;
            end
        else






            if isa(Object,'Stateflow.Object')
                objectSID=Simulink.ID.getStateflowSID(Object);
            else
                objectSID=Simulink.ID.getLibSID(Object);
            end


            isLibrarySID=true;
        end

        if isa(Object,'Stateflow.Object')||slprivate('is_stateflow_based_block',Object.Handle)
            isSF=true;
        end
    end

    if~isempty(contextObject)
        contextSID=Simulink.ID.getSID(contextObject);
    end
end

function status=loc_isInsideMWSubsystem(ObjIn)
    status=false;

    if isa(ObjIn,'Simulink.SubSystem')&&...
        (strcmpi(ObjIn.LinkStatus,'resolved')||strcmpi(ObjIn.LinkStatus,'implicit'))

        libName=strtok(ObjIn.ReferenceBlock,'/');

        if Advisor.component.isMWFile(sls_resolvename(libName))
            status=true;
        end
    end
end