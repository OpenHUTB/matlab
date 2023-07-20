function visualizeFile(filePath,name,sheetNames,ranges,sourceType,model,tcpID)


    newRun=[];
    Simulink.sdi.Instance.open;

    [~,~,extension]=fileparts(filePath);

    if strcmpi(extension,'.mat')
        s=load(filePath);
        if isfield(s,'sldvData')

            strs=strsplit(name,':');
            if(length(strs)>1)
                index=str2double(strs{2});
                data=sldvsimdata(s.sldvData,index);
            else
                data=s.sldvData;
            end
            newRun=Simulink.sdi.createRun(data);
        else





            flds=fieldnames(s);
            vars=cellfun(@(x)s.(x),flds,'UniformOutput',false);
            newRun=Simulink.sdi.createRun(name,'vars',vars{:});
        end
    elseif strcmpi(extension,'.mldatx')
        stm.internal.util.launchExternalFileEditor(filePath);
    elseif any(strcmpi(extension,[xls.internal.WriteTable.SpreadsheetExts,".csv"]))

        modelCloseObj=Simulink.SimulationData.ModelCloseUtil();
        if(~isempty(model)&&~bdIsLoaded(model))
            try
                load_system(model);
            catch

                model='';
            end
        end


        simIndex=stm.internal.getTcpProperty(tcpID,'SimIndex');
        varsStruct=stm.internal.util.loadExcelFileWithOptions(filePath,...
        sheetNames,ranges,model,sourceType,false,simIndex);
        delete(modelCloseObj);

        field=fieldnames(varsStruct);
        count=length(field);
        vars=cell(count,1);
        for j=1:count
            vars{j}=varsStruct.(field{j});
        end

        if~isempty(vars)
            newRun=Simulink.sdi.createRun(name,'vars',vars{:});
        end
    end

    engine=Simulink.sdi.Instance.engine;
    if~strcmpi(extension,'.mldatx')
        if isempty(newRun)||~engine.isValidRunID(newRun(1))||(engine.getSignalCount(newRun(1))==0)
            error(message('stm:InputsView:FileCouldNotBeLoaded'));
        end
    end
end
