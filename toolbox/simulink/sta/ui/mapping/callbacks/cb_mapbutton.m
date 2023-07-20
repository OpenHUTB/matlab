function[cellOfStructs,props,inputSpecID,threwErrDlg,errMsg]=cb_mapbutton(modelName,mappingMode,dbIds,compile,strongDatatyping,allowPartial,customFileName,inputSpecID,appID,varargin)


    threwErrDlg=false;
    errMsg='';
    repo=starepository.RepositoryUtility();


    cellOfStructs={};
    props.dataProps=[];
    props.inportProps=[];


    subChannel='sta/mainui/diagnostic/request';
    fullChannel=sprintf('/sta%s/%s',appID,subChannel);



    SET_HIGHLIGHT=true;
    SET_VAR_IN_WS=true;
    SET_EXT_INPUT=true;
    SCENARIO_SESSION_ID=[];

    if~isempty(varargin)
        SET_HIGHLIGHT=varargin{1};

        if length(varargin)>1
            SET_VAR_IN_WS=varargin{2};
        end

        if length(varargin)>2
            SET_EXT_INPUT=varargin{3};
        end

        if length(varargin)>3
            SCENARIO_SESSION_ID=varargin{4};
        end

        if length(varargin)>4
            aSLBuildUtility=varargin{5};
        else
            aSLBuildUtility=Simulink.inputmap.util.SimulinkBuildUtility;
        end

    else
        aSLBuildUtility=Simulink.inputmap.util.SimulinkBuildUtility;
    end


    if isempty(modelName)||~ischar(modelName)

        slwebwidgets.errordlgweb(fullChannel,...
        'sl_inputmap:inputmap:modelNotOpenTitle',...
        DAStudio.message('sl_inputmap:inputmap:modelNotOpen'));
        threwErrDlg=true;
        errMsg=DAStudio.message('sl_inputmap:inputmap:modelNotOpen');
        return;
    end


    [~,modelName,~]=fileparts(modelName);


    if~bdIsLoaded(modelName)

        slwebwidgets.errordlgweb(fullChannel,...
        'sl_inputmap:inputmap:modelNotOpenTitle',...
        DAStudio.message('sl_inputmap:inputmap:modelNotOpen'));
        threwErrDlg=true;
        errMsg=DAStudio.message('sl_inputmap:inputmap:modelNotOpen');
        return;
    end


    if isempty(dbIds)

        slwebwidgets.errordlgweb(fullChannel,...
        'sl_inputmap:inputmap:selectValidSignalsTitle',...
        DAStudio.message('sl_inputmap:inputmap:selectValidSignals'));
        threwErrDlg=true;
        errMsg=DAStudio.message('sl_inputmap:inputmap:selectValidSignals');
        return;
    end

    aInputSpec=Simulink.iospecification.InputSpecification(mappingMode);
    aInputSpec.Verify=compile;
    aInputSpec.AllowPartial=allowPartial;


    if strcmpi(mappingMode,'custom')

        errTitle=DAStudio.message('sl_inputmap:inputmap:mappingFailedTitle');

        if isempty(customFileName)
            errMsg=DAStudio.message('sl_iospecification:iostrategy:errorInSpecNoCustomFile');

            slwebwidgets.errordlgweb(fullChannel,...
            'sl_inputmap:inputmap:mappingFailedTitle',...
            errMsg);

            threwErrDlg=true;
            return;
        end


        if exist(customFileName,'file')==0
            errMsg=DAStudio.message('sl_iospecification:iostrategy:customFileNotOnPath');

            slwebwidgets.errordlgweb(fullChannel,...
            'sl_inputmap:inputmap:mappingFailedTitle',...
            errMsg);

            threwErrDlg=true;
            return;
        end

        [~,customFileName,~]=fileparts(customFileName);
        aInputSpec.CustomSpecFile=customFileName;
    end

    if SET_HIGHLIGHT

        clearHighlightState(modelName);
    end

    aFactory=starepository.repositorysignal.Factory;

    Signals.Data={};
    Signals.Names={};

    for k=1:length(dbIds)

        repoUtil=starepository.RepositoryUtility;
        fileName=repoUtil.getMetaDataByName(dbIds(k),'LastKnownFullFile');

        if iscell(fileName)
            fileName=fileName{1};
        end
        LastModifiedDate=repoUtil.getMetaDataByName(dbIds(k),'LastModifiedDate');
        signame=repoUtil.getSignalLabel(dbIds(k));
        [~,~,ext]=fileparts(fileName);



        if strcmp(ext,'.mat')&&exist(fileName,'file')&&strcmp(getLastModifiedFromFile(fileName),LastModifiedDate)
            tmpIn=load(fileName,signame);
            Signals.Data{k}=tmpIn.(signame);
            Signals.Names{k}=signame;
        else

            concreteExtractor=aFactory.getSupportedExtractor(dbIds(k));
            concreteExtractor.castData=false;
            [Signals.Data{k},Signals.Names{k}]=concreteExtractor.extractValue(dbIds(k));
        end


        if Simulink.sdi.internal.Util.isSimulationDataSet(Signals.Data{k})||...
            isDataArrayModelContainer(Signals.Data{k},modelName)

            Signals.Data=Signals.Data(k);
            Signals.Names=Signals.Names(k);
            dbIds=dbIds(k);
            Signals.DatasetID=dbIds;
            break;

        end
    end


    if strcmpi(mappingMode,'index')||strcmpi(mappingMode,'portorder')

        Signals=checkMixedDataTypes(Signals,modelName);


        if isempty(Signals.Data)

            slwebwidgets.warndlgweb(fullChannel,...
            'sl_inputmap:inputmap:selectValidSignalsTitle',...
            DAStudio.message('sl_inputmap:inputmap:containerNotExact'));
            threwErrDlg=true;
            errMsg=DAStudio.message('sl_inputmap:inputmap:containerNotExact');
            return;
        end
    end




    if~isempty(Signals.Data)



        clearInportsOfSelected(modelName);



        [inputMap,inportProps,dataProps,status,threwErrDlg,errMsg,diagnosticstruct]=mapAndValidate(...
        modelName,Signals,allowPartial,strongDatatyping,aInputSpec,compile,false,appID,aSLBuildUtility);

        if threwErrDlg

            aInputSpec.LastModelUsed=modelName;
            aInputSpec.InputString='';
        end


        props.dataProps=dataProps;
        props.inportProps=inportProps;

        if~isempty(aInputSpec.InputString)
            inputString=aInputSpec.InputString;
        else
            inputString='';
            aInputSpec.InputString='';
        end


        repoSpec=writeMappingToRepository(repo,inputSpecID,aInputSpec,dbIds,Signals,SCENARIO_SESSION_ID);

        inputSpecID=repoSpec.ID;

        if~isempty(inputMap)


            cellOfStructs=tableStructFromInputSpecID(repoSpec.ID);

            for kCell=1:length(cellOfStructs)
                cellOfStructs{kCell}.diagnostics=diagnosticstruct(kCell);
            end



            nInputMap=length(inputMap);



            [shadowH,~,~,~,shadowPortNum]=...
            Simulink.iospecification.InportProperty.getInportShadowProperties(modelName);


            for k=1:nInputMap
                idxArray=strfind(inputMap(k).DataSourceName,'(:');

                if~isempty(idxArray)
                    dataName=inputMap(k).DataSourceName(1:idxArray-1);
                else
                    dataName=inputMap(k).DataSourceName;
                end

                if SET_HIGHLIGHT

                    applyPortHighlightByStatus(inputMap(k),shadowH,shadowPortNum,status(k));
                end

                if SET_VAR_IN_WS

                    assignVarToWorkspace(Signals,dataName);
                end
            end

            if SET_EXT_INPUT

                setExternalInput(modelName,aInputSpec.InputString);
            end
        else

            if isempty(errMsg)


                errMsg=throwEmptyMappingDialog(mappingMode,modelName,fullChannel);
            end

            threwErrDlg=true;
        end
    end
end

function lastTimeModified=getLastModifiedFromFile(fileName)
    lastTimeModified='';

    whichFiles=which(fileName);

    if iscell(whichFiles)
        whichFiles='';
    end

    x=dir(whichFiles);
    if~isempty(x)
        lastTimeModified=x.date;
    end
end


