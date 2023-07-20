function result=isHarnessAutoGenBlock(model,obj)
    result=false;
    try
        modelH=get_param(model,'Handle');




        harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(modelH);
        if~isempty(harnessInfo)&&...
            harnessInfo.verificationMode~=0&&...
            Simulink.harness.internal.isHarnessCUT(obj.Handle)
            result=true;
            return;
        end

        autogenSSIds=Simulink.harness.internal.getHarnessAutogenSSIds(modelH);
        autogenSSIds=['|',autogenSSIds,'|'];
        objSID=Simulink.ID.getSID(obj);
        startIndex=strfind(objSID,':');
        if length(startIndex)~=1

            return;
        end
        objSIDNumber=objSID(startIndex+1:end);
        result=contains(autogenSSIds,['|',objSIDNumber,'|']);
    catch ME %#ok<NASGU>
    end
end
