function registerMFBChecks(checkIDList)


    mdladvRoot=ModelAdvisor.Root;
    for i=1:numel(checkIDList)
        checkID=checkIDList{i};
        rec=Advisor.Utils.getDefaultCheckObject(['mathworks.maab.',checkID],false,@CheckAlgo,'None');
        rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
        rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});
        rec.setLicense({styleguide_license});
        rec.PreCallbackHandle=@Advisor.MATLABFileDependencyService.initialize;
        rec.PostCallbackHandle=@Advisor.MATLABFileDependencyService.reset;


        rec.setInputParametersLayoutGrid([2,4]);
        inputParamList=Advisor.Utils.Eml.getEMLStandardInputParams(1);
        rec.setInputParameters(inputParamList);




        if strcmp(checkID,'na_0021')
            mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
        else
            mdladvRoot.publish(rec,{sg_maab_group});
        end
    end
end


function ResultDescription=CheckAlgo(system)

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    checkIDStr=strsplit(mdlAdvObj.ActiveCheck.getID,'.');
    checkID=checkIDStr{3};

    inputParams=mdlAdvObj.getInputParameters;
    checkExternalMLFiles=inputParams{1}.Value;
    fl_val=inputParams{2}.Value;
    lum_val=inputParams{3}.Value;

    mlObjs=Advisor.Utils.getAllMATLABFunctionBlocks(system,fl_val,lum_val);
    mlObjs=mdlAdvObj.filterResultWithExclusion(mlObjs);

    if checkExternalMLFiles
        allMLObjs=Advisor.MATLABFileDependencyService.getInstance.getRelevantEMLObjs();
        extMLFiles=allMLObjs(cellfun(@(x)isa(x,'struct'),allMLObjs));
        allMLObjs=[mlObjs;extMLFiles];
    end

    violations=runCheck(checkID,allMLObjs);


    ResultDescription=violations;
end


function conflictDetails=runCheck(checkID,fcnBlocks)


    switch checkID
    case 'na_0019'
        conflictDetails=styleguide_na_0019(fcnBlocks);
    case 'na_0021'
        conflictDetails=styleguide_na_0021(fcnBlocks);
    case 'na_0022'
        conflictDetails=styleguide_na_0022(fcnBlocks);
    otherwise
        conflictDetails={};
    end
end
