function sldvData=generateDataForLogging(obj)




    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    LoggedTestUnitInfo=[];

    TestUnitModel.Name=get_param(bdroot(obj.TestUnitBlockH),'Name');
    TestUnitModel.SubsystemPath=getfullname(obj.TestUnitBlockH);


    designModelH=get_param(TestUnitModel.Name,'Handle');
    if strcmp(get_param(designModelH,'isHarness'),'on')
        TestUnitModel.HarnessOwnerModel=Simulink.harness.internal.getHarnessOwnerBD(designModelH);
    end



    model=get(obj.TopLevelModelH,'Name');
    if isempty(obj.subsystemIO)...
        ||(isfield(obj.subsystemIO,'Handle')&&obj.subsystemIO.Handle~=obj.TestUnitBlockH)
        try
            str=evalc('feval(model,[],[],[],''compileForSizes'');');%#ok<NASGU>

            Sldv.SubsystemLogger.checkUnsupportedSystem(obj.TestUnitBlockH,false);
            obj.subsystemIO=Sldv.SubsystemLogger.deriveSubsystemPortInfo(obj.TestUnitBlockH);

            feval(model,[],[],[],'term')
        catch Mex
            if~strcmp(get_param(model,'SimulationStatus'),'stopped')
                feval(model,[],[],[],'term')
            end
            rethrow(Mex);
        end
    end


    TestUnitModel.InputPortInfo=obj.subsystemIO.InputPortInfo;
    TestUnitModel.OutputPortInfo=obj.subsystemIO.OutputPortInfo;
    TestUnitModel.SampleTimes=obj.subsystemIO.SampleTimes;
    obj.PortHsToLog=obj.subsystemIO.PortHsToLog;
    obj.dsmHsToLog=obj.subsystemIO.dsmHsToLog;

    LoggedTestUnitInfo.SubsystemLogging.TestSubsystem=TestUnitModel;
    defaultTestCase=Sldv.DataUtils.createDefaultTC(...
    obj.TopLevelModelH,obj.subsystemIO.flatInfo.InportCompInfo,true);

    sldvData.LoggedTestUnitInfo=LoggedTestUnitInfo;
    sldvData.TestCases=defaultTestCase;

    obj.checkForComplexType(Sldv.DataUtils.convertLoggedSldvDataToHarnessDataFormat(sldvData,[],false));

end



