function result=apiObjToIdsStruct(arg)















    if isa(arg,'slreq.data.Requirement')||isa(arg,'slreq.BaseItem')
        result=arg.toStruct();

    elseif isa(arg,'char')||...
        isa(arg,'double')||...
        isa(arg,'Simulink.Object')||...
        (isa(arg,'Stateflow.Object')&&rmisf.isSupportedObject(arg))
        result=slreq.utils.getRmiStruct(arg);

    elseif sysarch.isSysArchObject(arg)
        result=sysarch.getRmiStruct(arg);

    elseif isa(arg,'Simulink.DDEAdapter')
        result.domain='linktype_rmi_data';
        [result.id,result.artifact]=rmide.getGuid(arg);

    elseif isa(arg,'sltest.testmanager.TestCase')
        tCaseStruct=stm.internal.getTestProperty(arg.getID(),'testcase');
        if strcmp(arg.TestType,'MATLABUnit')
            result.domain='linktype_rmi_matlab';
            result.id=rmiml.RmiMUnitData.getBookmarkForTest(tCaseStruct.testFilePath,tCaseStruct.name);
        else
            result.domain='linktype_rmi_testmgr';
            result.id=tCaseStruct.uuid;
        end
        result.artifact=tCaseStruct.testFilePath;

    elseif isa(arg,'sltest.testmanager.TestSuite')||isa(arg,'sltest.testmanager.TestFile')

        tCaseStruct=stm.internal.getTestProperty(arg.getID(),'testsuite');
        [~,isSTMMunit]=rmiml.RmiMUnitData.isMUnitFile(tCaseStruct.testFilePath);
        if isa(arg,'sltest.testmanager.TestFile')&&isSTMMunit
            result.domain='linktype_rmi_matlab';
            result.id=rmiml.RmiMUnitData.getBookmarkForTest(tCaseStruct.testFilePath);
        else
            result.id=tCaseStruct.uuid;
            result.domain='linktype_rmi_testmgr';
        end
        result.artifact=tCaseStruct.testFilePath;

    elseif isa(arg,'sltest.testmanager.TestIteration')
        result.domain='linktype_rmi_testmgr';
        tIterStruct=arg.saveobj();
        result.id=tIterStruct.IterUUID;
        result.artifact=tIterStruct.Path;

    elseif isa(arg,'Simulink.data.dictionary.Entry')
        result.domain='linktype_rmi_data';
        [result.id,result.artifact]=rmide.getGuid(arg.DataSource,'',arg.Name);

    elseif isa(arg,'Simulink.fault.Fault')||isa(arg,'Simulink.fault.Conditional')
        result.domain='linktype_rmi_simulink';
        result.id=[rmifa.itemIDPref,arg.Uuid];
        result.artifact=arg.getTopModelName();

    elseif isa(arg,'slreq.TextRange')
        result.domain=arg.Domain;
        result.artifact=arg.Artifact;
        result.id=arg.Id;
        result.parent=arg.Parent;

    elseif isa(arg,'sm.internal.SafetyManagerNode')
        result.domain='linktype_rmi_safetymanager';
        result.id=arg.uuid;
        result.artifact=arg.getFileName();
    else
        error(message('Slvnv:slreq:ErrorInvalidType','slreq.utils.apiObjToIdsStruct()',class(arg)));
    end

end


