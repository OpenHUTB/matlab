function[reqs,target_handles]=makeReqs(target_objects)





    totalTargets=length(target_objects);
    reqs=rmi.createEmptyReqs(totalTargets);
    target_handles=zeros(1,totalTargets);
    for i=1:totalTargets
        reqs(i).reqsys='linktype_rmi_simulink';
        this_object=target_objects(i);
        type=strtok(class(this_object),'.');
        switch type
        case 'double'
            if ceil(this_object)==this_object
                sfRoot=Stateflow.Root;
                sid=Simulink.ID.getSID(sfRoot.idToHandle(this_object));
            else
                sid=Simulink.ID.getSID(this_object);
            end
            target_handles(i)=this_object;
        case 'Stateflow'
            sfRoot=Stateflow.Root;
            sid=Simulink.ID.getSID(sfRoot.idToHandle(this_object.Id));
            target_handles(i)=this_object.Id;
        case 'Simulink'
            if rmifa.isFaultInfoObj(this_object)
                reqs(i)=rmifa.makeReq(this_object);
                target_handles(i)=-i-1;
                continue;
            else
                sid=Simulink.ID.getSID(this_object);
                target_handles(i)=this_object.Handle;
            end
        otherwise
            error(message('Slvnv:reqmgt:rmi:InvalidObject',type));
        end
        [modelName,localSID]=strtok(sid,':');

        if rmisl.isComponentHarness(modelName)
            [~,modelName,~]=Simulink.harness.internal.sidmap.getHarnessModelUniqueName(modelName);






            [targetArtifact,harnessID]=strtok(modelName,':');
            targetId=[harnessID,localSID];
        else

            targetArtifact=modelName;
            targetId=localSID;
        end

        reqs(i).doc=targetArtifact;
        if isempty(targetId)
            targetId=':';
        end
        reqs(i).id=targetId;

        [~,objInfoString]=rmi.objinfo(target_objects(i));
        reqs(i).description=objInfoString;
    end


    [uniqueHandles,index]=unique(target_handles);
    if length(uniqueHandles)<totalTargets
        reqs=reqs(index);
    end

end
