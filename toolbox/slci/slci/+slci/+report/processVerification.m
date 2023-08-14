












function verData=processVerification(dm,reportConfig)


    verData=struct('interface',[],'model',[],'tempVar',[],...
    'typeReplacement',[],'code',[]);


    resultTableReader=dm.getReader('RESULTS');


    if resultTableReader.hasObject('ModelInspectionStatus')&&...
        ~strcmp(resultTableReader.getObject('ModelInspectionStatus'),'UNKNOWN')
        try
            verData.model=...
            slci.report.getModelVerification(dm,reportConfig);

        catch exception

            m='Slci:report:ModelVerDataError';
            DAStudio.error(m);

        end
    else
        verData.model=[];
    end


    functionInterfaceReader=dm.getReader('FUNCTIONINTERFACE');
    fnList=functionInterfaceReader.getKeys();

    if resultTableReader.hasObject('InterfaceInspectionStatus')&&...
        ~strcmp(resultTableReader.getObject('InterfaceInspectionStatus'),'UNKNOWN')
        try
            verData.interface=...
            slci.report.getInterfaceVerification(fnList,dm,reportConfig);

        catch exception

            m='Slci:report:InterfaceVerDataError';
            DAStudio.error(m);

        end
    else
        verData.interface=[];
    end


    if resultTableReader.hasObject('CodeInspectionStatus')&&...
        ~strcmp(resultTableReader.getObject('CodeInspectionStatus'),'UNKNOWN')
        try
            verData.code=...
            slci.report.getCodeVerification(fnList,dm,reportConfig);

        catch exception

            m='Slci:report:CodeVerDataError';
            DAStudio.error(m);
        end
    else
        verData.code=[];
    end


    if resultTableReader.hasObject('TempVarInspectionStatus')&&...
        ~strcmp(resultTableReader.getObject('TempVarInspectionStatus'),'UNKNOWN')

        try
            verData.tempVar=...
            slci.report.getTempVerification(fnList,dm,reportConfig);

        catch exception

            disp(exception.message)
            disp(exception.stack(1))

            m='Slci:report:TempVarVerDataError';
            DAStudio.error(m);

        end
    else
        verData.tempVar=[];
    end



    try
        verData.typeReplacement=...
        slci.report.getTypeReplacementVerification(dm,reportConfig);

    catch exception

        disp(exception.message)
        disp(exception.stack(1))

        DAStudio.error('Slci:report:TypeReplVerDataError');

    end

end
