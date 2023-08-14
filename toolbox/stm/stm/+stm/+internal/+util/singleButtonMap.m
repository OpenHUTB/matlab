function out=singleButtonMap(srcId,model,harnessName,fullPath,inputType,...
    mappingMode,retryWithCompileOff,customFunction,mapIndividual,compileMdl)

















    if inputType==0
        error(message('stm:InputsView:UnknownInputFile'));
    end


    isExcel=(inputType==2);


    isMappable=(inputType==int32(1)||isExcel);



    if~isMappable
        s=warning('off','backtrace');
        warning(message('stm:general:SLDVInputsAlreadyMapped'));
        warning(s.state,'backtrace');
        out.error=getString(message('stm:general:SLDVInputsAlreadyMapped'));
        return;
    end

    dataSource=fullPath;

    if(isExcel)

        [sheets,ranges,model,tcpID]=stm.internal.getSheetRangeInfo(srcId,int32(stm.internal.SourceSelectionTypes.Input));
        if(isempty(sheets))
            out.error=getString(message('stm:general:NoSheetsSelected'));
            return;
        end

        load_system(model);

        simIndex=stm.internal.getTcpProperty(tcpID,'SimIndex');
        varsLoaded=stm.internal.util.loadExcelFileWithOptions(...
        fullPath,sheets,ranges,model,...
        xls.internal.SourceTypes.Input,false,simIndex);
        dataSource=[tempname,'.mat'];


        if(mapIndividual==1)
            varNames=fieldnames(varsLoaded);
            frstSheet.(varNames{1})=varsLoaded.(varNames{1});
            save(dataSource,'-struct','frstSheet');
        else
            save(dataSource,'-struct','varsLoaded');
        end

        deleteTempFile=onCleanup(@()delete(dataSource));
    end

    switch(mappingMode)
    case 1
        mode={'BlockPath',''};
    case 2
        mode={'SignalName',''};
    case 3
        mode={'PortOrder',''};
    case 4
        mode={'Custom',customFunction};
    otherwise
        mode={'BlockName',''};
    end

    try
        [modelToUse,deactivateHarness,currHarness,oldHarness,~,wasHarnessOpen]=stm.internal.util.resolveHarness(model,harnessName);

        [inputSpec,valStruct]=loc_mapInputs(modelToUse,dataSource,mode,compileMdl);



        if compileMdl&&retryWithCompileOff&&~isempty(valStruct.errorMsg)
            [inputSpec,valStruct]=loc_mapInputs(modelToUse,dataSource,mode,false);
        end
        out.status=1;
        out.inputstring='';


        if~isempty(currHarness)
            close_system(currHarness.name,0);

            if(deactivateHarness)
                stm.internal.util.loadHarness(oldHarness.ownerFullPath,oldHarness.name,wasHarnessOpen);
            end
        end


        if isprop(inputSpec,'InputString')
            out.inputstring=inputSpec.InputString;
        end



        failedSigIndx=[];
        if~isempty(valStruct.diagnostics)

            failedSigIndx=find(~[valStruct.diagnostics.status],1);
        end
        if~isempty(valStruct.errorMsg)



            out.error=valStruct.errorMsg;
        elseif~isempty(failedSigIndx)
            diagnosticStruct=valStruct.diagnostics(failedSigIndx);
            if~isempty(diagnosticStruct.portspecific)
                out.error=diagnosticStruct.portspecific;
            else
                out.error=diagnosticStruct.modeldiagnostic;
            end
        else

            out=stm.internal.util.parseInputSpecification(inputSpec,modelToUse);
        end
    catch me
        out.error=me.message;
    end

end

function[inputSpec,valStruct]=loc_mapInputs(modelToUse,dataSource,mode,compileMdl)
    [inputSpec,valStruct]=Simulink.sta.util.singleButtonMap('MODEL',modelToUse,...
    'DATASOURCE',dataSource,...
    'MAPPINGMODE',mode,...
    'AllowPartialBusSpecification',true,...
    'CompileIfNeeded',logical(compileMdl));
end
