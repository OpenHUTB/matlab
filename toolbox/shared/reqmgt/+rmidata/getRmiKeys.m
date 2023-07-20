function[modelName,objKey]=getRmiKeys(objH,isSf)



    if isSf
        sfRoot=Stateflow.Root;
        myObj=sfRoot.idToHandle(objH);
        if isempty(myObj)

            modelName='';
            objKey='';
            return;
        end
        parentDiagram=myObj.Machine.Name;
    else
        myObj=get_param(objH,'Object');
        parentDiagram=bdroot(objH);
    end



    if rmisl.isComponentHarness(parentDiagram)
        [modelName,objKey]=getPersistentIdsForHarnessObject(myObj);
    else

        sid=Simulink.ID.getSID(myObj);
        [modelName,objKey]=strtok(sid,':');
    end
end

function[mdlName,innerId]=getPersistentIdsForHarnessObject(obj)
    if isa(obj,'Simulink.BlockDiagram')
        [~,mdlNameAndHarnessId]=Simulink.harness.internal.sidmap.getHarnessModelUniqueName(obj.Handle);
        [mdlName,innerId]=strtok(mdlNameAndHarnessId,':');
        return;
    end




    extSid=Simulink.harness.internal.sidmap.getHarnessObjectSID(obj);



    if isempty(extSid)&&isa(obj,'Simulink.Object')
        mdlName=get_param(rmisl.getmodelh(obj),'Name');
        fprintf(1,'DEBUG: empty SID returned for "%s" in %s (%s)\n',...
        strrep(obj.Name,newline,' '),...
        strrep(obj.Parent,newline,' '),...
        mdlName);
        innerId=':0';
        return;
    end




    [mdlName,innerId]=strtok(extSid,':');
end

