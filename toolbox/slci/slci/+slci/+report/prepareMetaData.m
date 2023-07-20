




function metaData=prepareMetaData(slciConfig,dm)






    load_system(dm.getMetaData('ModelFileName'));
    metaData={};
    idx=1;


    modelFileName=dm.getMetaData('ModelFileName');
    if isempty(modelFileName)
        error('Invalid meta data');
    else
        metaData{idx,1}=DAStudio.message('Slci:report:LabelModelName');

        metaData{idx,2}=...
        slci.internal.ReportUtil.createModelLink(modelFileName,modelFileName);
        idx=idx+1;
    end


    modelVersion=dm.getMetaData('ModelVersion');
    if isempty(modelVersion)
        error('Invalid meta data');
    else
        metaData{idx,1}=DAStudio.message('Slci:report:LabelModelVersion');
        metaData{idx,2}=num2str(modelVersion);
        idx=idx+1;
    end


    simulinkVersion=dm.getMetaData('SimulinkVersion');
    if isempty(simulinkVersion)
        error('Invalid meta data');
    else
        metaData{idx,1}=DAStudio.message('Slci:report:LabelSimulinkVersion');
        metaData{idx,2}=num2str(simulinkVersion);
        idx=idx+1;
    end


    modelChecksum=dm.getMetaData('ModelChecksum');


    if isempty(modelChecksum)
        error('Invalid meta data');
    else
        modelChecksumStr=[num2str(modelChecksum(1))...
        ,' ',num2str(modelChecksum(2))...
        ,' ',num2str(modelChecksum(3))...
        ,' ',num2str(modelChecksum(4))];

        if slciConfig.getTopModel
            metaData{idx,1}=DAStudio.message('Slci:report:LabelTopChecksum');
        else
            metaData{idx,1}=DAStudio.message('Slci:report:LabelReferencedChecksum');
        end

        metaData{idx,2}=modelChecksumStr;
        idx=idx+1;
    end



    if~slciConfig.getTopModel()

        topModelChecksum=dm.getMetaData('TopModelChecksumForRef');
        if~isempty(topModelChecksum)

            topModelChecksumStr=[num2str(topModelChecksum(1))...
            ,' ',num2str(topModelChecksum(2))...
            ,' ',num2str(topModelChecksum(3))...
            ,' ',num2str(topModelChecksum(4))];

            metaData{idx,1}=DAStudio.message('Slci:report:LabelTopChecksum');
            metaData{idx,2}=topModelChecksumStr;
            idx=idx+1;
        end
    end




    modelTimeStamp=get_param(dm.getMetaData('ModelName'),'LastModifiedDate');
    modelDateFormat=get_param(dm.getMetaData('ModelName'),'ModifiedDateFormat');
    if strcmpi(modelDateFormat,'%<Auto>')


        dn=datenum(modelTimeStamp,'ddd mmm dd HH:MM:SS yyyy');
        modelTimeStamp=slci.internal.ReportUtil.setToDefaultFormat(dn);
    end
    dm.setMetaData('ModelTimeStamp',modelTimeStamp);

    metaData{idx,1}=DAStudio.message('Slci:report:LabelModelTimeStamp');
    metaData{idx,2}=modelTimeStamp;
    idx=idx+1;

    inspectedFiles=dm.getMetaData('InspectedCodeFiles');
    if isempty(inspectedFiles)||~isfield(inspectedFiles,'sourceFiles')
        error('Invalid meta data');
    else

        srcFiles=inspectedFiles.sourceFiles;
        numSources=numel(srcFiles);
        metaData{idx,1}=DAStudio.message('Slci:report:LabelInspectedCodeFiles');
        metaData{idx,2}=slci.internal.ReportUtil.createFileLink(...
        srcFiles{1},srcFiles{1});
        idx=idx+1;
        for k=2:numSources
            metaData{idx,1}='';
            metaData{idx,2}=slci.internal.ReportUtil.createFileLink(...
            srcFiles{k},srcFiles{k});
            idx=idx+1;
        end


    end


    codeChecksum=dm.getMetaData('InspectedCodeFilesChecksum');

    if isempty(codeChecksum)
        error('Invalid meta data');
    else
        metaData{idx,1}=...
        DAStudio.message('Slci:report:LabelInspectedCodeFilesChecksum');
        metaData{idx,2}=codeChecksum{1};
        idx=idx+1;
        for k=2:numel(codeChecksum)
            metaData{idx,1}='';
            metaData{idx,2}=codeChecksum{k};
            idx=idx+1;
        end
    end


    inspectionDate=dm.getMetaData('InspectionRunDate');
    if isempty(inspectionDate)
        error('Invalid meta data');
    else
        metaData{idx,1}=...
        DAStudio.message('Slci:report:LabelCodeInspectionTimeStamp');
        metaData{idx,2}=inspectionDate;
        idx=idx+1;
    end

    crData=slciConfig.getCustomerReportData;
    if~isempty(crData)
        structField=fields(crData);
        if~isempty(structField)&&iscell(structField)
            for k=1:numel(crData)
                metaData{idx,1}=crData(k).(structField{1});
                status=crData(k).(structField{2});
                if isa(status,'struct')

                    tableField=fields(status);
                    assert(iscell(tableField));

                    t_idx=1;
                    for i=1:numel(status)
                        for j=1:numel(tableField)
                            tableData{t_idx,j}=status(t_idx).(tableField{j});%#ok
                        end
                        t_idx=t_idx+1;
                    end

                    table=slci.internal.ReportUtil.genTable(tableField,tableData,0);
                    metaData{idx,2}=table;
                else
                    metaData{idx,2}=status;
                end
                idx=idx+1;
            end
        end
    end

end
