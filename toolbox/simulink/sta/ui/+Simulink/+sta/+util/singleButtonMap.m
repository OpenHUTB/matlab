function[inputSpec,validation]=singleButtonMap(varargin)








































    inputSpec=[];
    mappingMode={'BlockName',''};%#ok<NASGU>
    validation=struct('inportProps',cell(1),'dataProps',cell(1),'errorMsg','','diagnostics',[]);
    inputSpecID=[];


    PVPairResults=Simulink.sta.util.parseInput(varargin{:});

    allowPartial=PVPairResults.AllowPartialBusSpecification;
    compile=PVPairResults.CompileIfNeeded;



    if~isempty(PVPairResults.Model)

        [filePath,model,modelExt]=fileparts(PVPairResults.Model);
    else
        return;
    end


    setappdata(0,'enableEngineCheckVersion1_0',1);


    try
        isLoaded=bdIsLoaded(model);
    catch
        isLoaded=false;
    end

    if~isLoaded

        error(message('sl_sta:sta:singleClickModelNotLoaded',model));
    end


    if isempty(PVPairResults.DataSource)
        return;
    end

    if iscell(PVPairResults.DataSource)
        fileName=PVPairResults.DataSource{1};
        variable=PVPairResults.DataSource(2:end);
    else
        fileName=PVPairResults.DataSource;
        variable='';
    end

    [~,~,ext]=fileparts(fileName);



    ScenarioRepo=sta.Scenario();
    ScenarioRepo.APPid='1234';
    ScenarioRepo.Description='A singlebutton map run.';


    sigIds=[];
    Signals=[];

    if strcmpi(ext,'.mat')

        if~isempty(variable)
            downselectstruct=struct('name',[],'children',[]);
            for id=1:length(variable)
                downselectstruct(id).name=variable{id};
                downselectstruct(id).children='all';
            end

            try
                aFile=iofile.STAMatFile(fileName);
                Signals=import(aFile);

                Signals=downSelectSignals(Signals,downselectstruct);


                if isempty(Signals.Names)
                    return;
                end

            catch ME
                throw(ME);
            end

        else
            aFile=iofile.STAMatFile(fileName);

            whos(aFile);
            Signals=import(aFile);
        end

        for kSig=1:length(Signals.Names)
            if Simulink.sdi.internal.Util.isSimulationDataSet(Signals.Data{kSig})||...
                isDataArrayModelContainer(Signals.Data{kSig},model)||...
                Simulink.sdi.internal.Util.isStructureWithTime(Signals.Data{kSig})||...
                Simulink.sdi.internal.Util.isStructureWithoutTime(Signals.Data{kSig})

                Signals.Data=Signals.Data(kSig);
                Signals.Names=Signals.Names(kSig);
                break;

            end
        end

    else

        try

            excelReader=sl_iofile.ExcelReader(fileName);
        catch ME
            excelErrorStruct=jsondecode(ME.message);
            if isequal(excelErrorStruct.ErrorId,'pcsupportonly')



                return;
            end
            error(sprintf('sl_iofile:excelfile:%s',excelErrorStruct.ErrorId),excelErrorStruct.ErrorMessage);
        end

        try

            if~isempty(variable)
                jsonReturned=excelReader.import(variable{:});
            else
                jsonReturned=excelReader.importAll();
            end
            Simulink.sdi.internal.flushStreamingBackend();
        catch ME
            Simulink.sdi.internal.flushStreamingBackend();
            excelErrorStruct=jsondecode(ME.message);
            error(sprintf('sl_iofile:excelfile:%s',excelErrorStruct.ErrorId),excelErrorStruct.ErrorMessage);
        end

        if isempty(jsonReturned)

            return;
        end

        json2str=jsondecode(jsonReturned);

        sigIds=str2num(json2str.arrayOfListItems(1).ID);


        aFactory=starepository.repositorysignal.Factory;
        concreteExtractor=...
        aFactory.getSupportedExtractor(sigIds);
        [Signals.Data{1},Signals.Names{1}]=...
        concreteExtractor.extractValue(sigIds);
        Signals.DatasetID=sigIds;
    end


    if isempty(Signals)||isempty(Signals.Data)
        return;
    end


    if strcmpi(PVPairResults.MappingMode{1},'index')||strcmpi(PVPairResults.MappingMode{1},'portorder')

        Signals=checkMixedDataTypes(Signals,model);


        if isempty(Signals.Data)

            DAStudio.error('sl_inputmap:inputmap:containerNotExact');

        end
    end



    inputSpec=Simulink.iospecification.InputSpecification(PVPairResults.MappingMode{1});

    if strcmpi(PVPairResults.MappingMode{1},'Custom')

        [~,customFileName,~]=fileparts(PVPairResults.MappingMode{2});

        inputSpec.CustomSpecFile=customFileName;
    end


    inputSpec.Verify=compile;
    inputSpec.AllowPartial=allowPartial;
    strongDataType=true;







    [inputMap,inportProps,dataProps,~,~,errMsg,diagnosticStruct]=mapAndValidate(...
    model,Signals,allowPartial,strongDataType,inputSpec,compile,true,'');


    validation.inportProps=inportProps;
    validation.dataProps=dataProps;
    validation.errorMsg=errMsg;
    validation.diagnostics=diagnosticStruct;

    function Signals=downSelectSignals(Signals,downselectstruct)

        if~isempty(Signals.Data)


            idxChar=cellfun(@ischar,Signals.Data);


            if any(idxChar)


                Signals.Data(idxChar)=[];
                Signals.Names(idxChar)=[];
            end


            if isempty(Signals.Data)
                return;
            end

            indicesToRemove=[];
            for kSig=1:length(Signals.Names)


                chkIfSignalNameExistsInDownSelect=strcmp(Signals.Names{kSig},{downselectstruct(:).name});

                if~any(chkIfSignalNameExistsInDownSelect)
                    indicesToRemove=[indicesToRemove,kSig];
                end


            end

            Signals.Names(indicesToRemove)=[];
            Signals.Data(indicesToRemove)=[];

        end
