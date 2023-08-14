function container=createServiceInterface(fileName)












    slRoot=slroot;
    if slRoot.isValidSlObject(fileName)
        DAStudio.error('SimulinkCoderApp:sdp:CannotCreateServiceInterfaceInModel');
    end
    hlp=coder.internal.CoderDataStaticAPI.getHelper;
    dd=hlp.openDD(fileName);


    if~dd.isEmpty
        hlp.deleteAll(dd);
    end

    txn=[];
    try
        txn=hlp.beginTxn(dd);
        container=dd.owner;
        m=mf.zero.getModel(dd);
        pC=coderdictionary.softwareplatform.FunctionPlatform(m);
        pC.init();
        pC.Name="Untitled";
        pC.Description='A component-based software platform architecture.';
        pC.ServicesHeaderFileName='services.h';

        while dd.owner.SoftwarePlatforms.Size>0
            dd.owner.SoftwarePlatforms.remove(dd.owner.SoftwarePlatforms(1));
        end
        dd.owner.SoftwarePlatforms.add(pC);
        coder.internal.CoderDataStaticAPI.createExampleStorageClassesForSI(pC);
        SignalStructRef=coderdictionary.data.SlCoderDataClient.getElementByNameOfCoderDataTypeInPlatform(dd.owner,pC.Name,'StorageClass','MeasurementStruct');
        SignalStruct=SignalStructRef.getCoderDataEntry;
        ParamStructRef=coderdictionary.data.SlCoderDataClient.getElementByNameOfCoderDataTypeInPlatform(dd.owner,pC.Name,'StorageClass','ParamStruct');
        ParamStruct=ParamStructRef.getCoderDataEntry;
        service=hlp.createEntry(dd,'DataReceiverService','ReceiverExample1');
        service.DataCommunicationMethod='OutsideExecution';
        service=hlp.createEntry(dd,'DataReceiverService','ReceiverExample2');
        service.DataCommunicationMethod='DuringExecution';
        service=hlp.createEntry(dd,'DataReceiverService','ReceiverExample3');
        service.DataCommunicationMethod='DirectAccess';
        service.StorageClass=SignalStruct;
        service=hlp.createEntry(dd,'DataSenderService','SenderExample1');
        service.DataCommunicationMethod='OutsideExecution';
        service=hlp.createEntry(dd,'DataSenderService','SenderExample2');
        service.DataCommunicationMethod='DuringExecution';
        service=hlp.createEntry(dd,'DataSenderService','SenderExample3');
        service.DataCommunicationMethod='DirectAccess';
        service.StorageClass=SignalStruct;
        service=hlp.createEntry(dd,'DataTransferService','DataTransferExample1');
        service.DataCommunicationMethod='OutsideExecution';
        service=hlp.createEntry(dd,'DataTransferService','DataTransferExample2');
        service.DataCommunicationMethod='DuringExecution';
        service=hlp.createEntry(dd,'TimerService','TimerServiceExample1');
        service.DataCommunicationMethod='OutsideExecution';
        hlp.createEntry(dd,'IRTFunction','InitTerm');
        hlp.createEntry(dd,'PeriodicAperiodicFunction','PeriodicAperiodicExample1');
        hlp.createEntry(dd,'SubcomponentEntryFunction','SubcomponentEntryFunctionExample1');
        hlp.createEntry(dd,'SharedUtilityFunction','SharedUtilityExample1');
        hlp.createEntry(pC,'MemorySection','DataMemorySectionExample1');
        hlp.createEntry(pC,'FunctionMemorySection','FunctionMemorySectionExample1');
        hlp.createEntry(dd,'DataTypeCustomizationService','ExportDataTypesToModelTypesHeader');
        pts=hlp.createEntry(dd,'ParameterTuningInterface','ParameterTuningExample1');
        pts.StorageClass=ParamStruct;
        pats=hlp.createEntry(dd,'ParameterArgumentTuningInterface','ParameterArgumentTuningExample1');
        pats.StorageClass=ParamStruct;
        ms=hlp.createEntry(dd,'MeasurementInterface','MeasurementExample1');
        ms.StorageClass=SignalStruct;
        hlp.commitTxn(txn);
    catch me
        if~isempty(txn)
            hlp.rollbackTxn(txn);
        end
        rethrow(me);
    end


