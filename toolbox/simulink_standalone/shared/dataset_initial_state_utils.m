function varargout=dataset_initial_state_utils(iCmd,varargin)





    switch(iCmd)
    case 'validateBlockPath'
        [varargout{1:nargout}]=validateBlockPath(varargin{:});

    case 'validateStateName'
        [varargout{1:nargout}]=validateStateName(varargin{:});

    case 'validateLabel'
        [varargout{1:nargout}]=validateLabel(varargin{:});

    case 'validateValues'
        [varargout{1:nargout}]=validateValues(varargin{:});

    case 'validateRefModelField'
        [varargout{1:nargout}]=validateRefModelField(varargin{:});

    case 'logDatasetToFile'
        [varargout{1:nargout}]=logDatasetToFile(varargin{:});

    case 'warnAboutRapidNotLogging'
        [varargout{1:nargout}]=warnAboutRapidNotLogging(varargin{:});

    case 'getDatasetInitialState'
        [varargout{1:nargout}]=getDatasetInitialState(varargin{:});

    case 'save_template_dataset'
        [varargout{1:nargout}]=save_template_dataset(varargin{:});

    case 'add_template_dataset'
        [varargout{1:nargout}]=add_template_dataset(varargin{:});

    otherwise
        assert(false,['Invalid Command',iCmd]);
    end
end



function validateBlockPath(index,blockPath,mdl)
    if isempty(blockPath)...
        ||~ischar(blockPath)
        error(message(...
        'Simulink:Engine:InvElementInInitStateStruct',...
        mdl,index));
    end
end



function validateStateName(index,stateName,mdl)
    if~ischar(stateName)
        error(message(...
        'Simulink:Engine:InvLabelInInitStateStruct',...
        mdl,'stateName',index));
    end
end



function validateLabel(index,label,mdl)
    if~ischar(label)&&...
        ~isa(label,'Simulink.SimulationData.StateType')
        error(message(...
        'Simulink:Engine:InvLabelInInitStateStruct',...
        mdl,'label',index));
    end
end



function validateValues(index,values)

    if~isnumeric(values)...
        &&~islogical(values)
        error(message('Simulink:Engine:InvValuesInInitState',...
        index));
    end


    if isenum(values)
        error(message('SimulinkExecution:InitialState:EnumLoadingNotSupportedInRaccel',...
        index));
    end



    if isa(values,'half')
        error(message('Simulink:Engine:InvValuesInInitStateRaccelHalf',...
        index));
    end

    if isa(values,'embedded.fi')
        error(message('Simulink:Engine:InvValuesInInitStateRaccelFixedPt',...
        index));
    end
end



function validateRefModelField(index,inReferencedModel,mdl)
    if~isscalar(inReferencedModel)...
        ||~isa(inReferencedModel,'logical')
        error(message(...
        'Simulink:Engine:InvMdlRefFieldInInitStateStruct',...
        mdl,'signals',index,'inReferencedModel'));
    end
end




function logVars=logDatasetToFile(logVars,buildData,loggedStates,loggingFilePtr)


    finalStateName=buildData.logging.FinalStateName;
    if(Simulink.isRaccelDeployed)


        loggingFileName=get_param(buildData.mdl,'LoggingFileName');
        tempStruct.(finalStateName)=loggedStates;
        save(loggingFileName,'-struct','tempStruct','-append');
    else
        sigstream_mapi(...
        'saveMxArrayToOpenMatFile',...
        loggedStates,...
        finalStateName,...
        loggingFilePtr);
    end
    logVars=rmfield(logVars,finalStateName);
end



function warnAboutRapidNotLogging(templateDataset)
    if(isempty(templateDataset)&&isequal(class(templateDataset),'double'))

        warning('backtrace','off');
        DAStudio.warning('SimulinkExecution:InitialState:NotLoggingFinalStatesRapidAccel');
        warning('backtrace','on');
    end
end




function[templateDataset,initialStateInvalidFields]=parseInitialState(xInitial,initialStateInvalidFields,buildData)
    templateDatasetObject=load(fullfile(buildData.buildDir,'template_dataset'));
    templateDataset=templateDatasetObject.templateDataset;
    if isempty(templateDataset)




        templateDataset=xInitial;
        return;
    end

    blockPathValuesTemplateDataset=containers.Map;
    [blockPathValuesTemplateDataset,signalPathSignalIndexMap]=populate_block_path_values(templateDataset,false,buildData.mdl);


    blockPathValuesxInitialState=containers.Map;
    [blockPathValuesxInitialState,~]=populate_block_path_values(xInitial,true,buildData.mdl);




    [templateDataset,initialStateInvalidFields]=fill_template_and_get_invalid_states(templateDataset,...
    blockPathValuesTemplateDataset,...
    blockPathValuesxInitialState,...
    initialStateInvalidFields,...
    signalPathSignalIndexMap);
end











function[templateDataset,initialStateInvalidFieldsStruct]=fill_template_and_get_invalid_states(templateDataset,...
    blockPathValuesTemplateDataset,...
    blockPathValuesxInitialState,...
    initialStateInvalidFieldsStruct,...
    signalPathSignalIndexMap)

    invalidFieldsStructIndex=1;
    templateDatasetMapIndex=1;
    blockIdentifierVector=keys(blockPathValuesTemplateDataset);
    numElementsTemplateDatasetMap=length(blockPathValuesTemplateDataset);

    while templateDatasetMapIndex<=numElementsTemplateDatasetMap
        if isKey(blockPathValuesxInitialState,blockIdentifierVector{templateDatasetMapIndex})

            stateInfoTemplateDataset=blockPathValuesTemplateDataset(blockIdentifierVector{templateDatasetMapIndex});
            signalPathValuesMapTemplateDataset=stateInfoTemplateDataset.signalPathValuesMap;
            stateInfoxInitial=blockPathValuesxInitialState(blockIdentifierVector{templateDatasetMapIndex});
            signalPathValuesMapxInitial=stateInfoxInitial.signalPathValuesMap;
            signalPathVector=keys(signalPathValuesMapTemplateDataset);
            blockIndexInDataset=stateInfoTemplateDataset.blockIndexInDataset;
            blockPath=get_blockpath_from_dataset(templateDataset,blockIndexInDataset);
            if~isequal(stateInfoxInitial.Label,stateInfoTemplateDataset.Label)
                error(message(...
                'SimulinkExecution:InitialState:LabelMismatchDataset',...
                blockPath,...
                char(stateInfoxInitial.Label),...
                char(stateInfoTemplateDataset.Label)));
            end

            if~isequal(stateInfoxInitial.Name,stateInfoTemplateDataset.Name)
                error(message(...
                'SimulinkExecution:InitialState:StateNameMismatchDataset',...
                blockPath,...
                stateInfoxInitial.Name,...
                stateInfoTemplateDataset.Name));
            end

            for j=1:length(signalPathValuesMapTemplateDataset)
                if signalPathValuesMapxInitial.isKey(signalPathVector{j})
                    signalPath=cell2mat(signalPathVector(j));
                    timeSeriesObj=signalPathValuesMapxInitial(signalPath);


                    eval(['templateDataset{ ',int2str(blockIndexInDataset),' }.Values',signalPath,'= timeSeriesObj;']);
                else


                    initialStateInvalidFieldsStruct(invalidFieldsStructIndex).blockPath=blockIdentifierVector{templateDatasetMapIndex};
                    initialStateInvalidFieldsStruct(invalidFieldsStructIndex).index=signalPathSignalIndexMap(signalPathVector{j});
                    invalidFieldsStructIndex=invalidFieldsStructIndex+1;
                end
            end
        else


            initialStateInvalidFieldsStruct(invalidFieldsStructIndex).blockPath=blockIdentifierVector{templateDatasetMapIndex};
            initialStateInvalidFieldsStruct(invalidFieldsStructIndex).index=0;
            invalidFieldsStructIndex=invalidFieldsStructIndex+1;
        end
        templateDatasetMapIndex=templateDatasetMapIndex+1;
    end
end





function[completeBlockPathValuesMap,signalPathSignalIndexMap]=populate_block_path_values(datasetObj,...
    validateFields,...
    mdl)
    completeBlockPathValuesMap=containers.Map;



    signalPathSignalIndexMap=containers.Map('KeyType','char','ValueType','int16');
    dsIdx=1;

    while dsIdx<=datasetObj.numElements
        diagnosticInfo.dsIdx=dsIdx;
        diagnosticInfo.validateFields=validateFields;
        blockPath=get_blockpath_from_dataset(datasetObj,dsIdx);

        stateInfo.Label=datasetObj{dsIdx}.Label;
        stateInfo.Name=datasetObj{dsIdx}.Name;


        stateInfo.blockIndexInDataset=dsIdx;

        if validateFields
            validateBlockPath(dsIdx,blockPath,mdl);
            validateStateName(dsIdx,stateInfo.Name,mdl);
            validateLabel(dsIdx,stateInfo.Label,mdl);
        end

        signalPathValuesMap=containers.Map;
        signalIndex=0;
        [signalPathValuesMap,signalPathSignalIndexMap,~]=create_block_signal_path_map(datasetObj{dsIdx}.Values,...
        signalPathValuesMap,...
        '',...
        '',...
        signalPathSignalIndexMap,...
        signalIndex,...
        diagnosticInfo);


        stateInfo.signalPathValuesMap=signalPathValuesMap;

        blockIdentifier=strcat(blockPath,stateInfo.Name);
        completeBlockPathValuesMap(blockIdentifier)=stateInfo;
        dsIdx=dsIdx+1;
    end
end





function[signalPathValuesMap,signalPathSignalIndexMap,indexOfSignalInPath]=create_block_signal_path_map(tempDatasetElement,...
    signalPathValuesMap,...
    signalsPath,...
    element,...
    signalPathSignalIndexMap,...
    indexOfSignalInPath,...
    diagnosticInfo)
    if isstruct(tempDatasetElement)


        signalsPath=[signalsPath,char(element),'.'];
        fields=fieldnames(tempDatasetElement);

        for idx=1:length(fields)
            [signalPathValuesMap,signalPathSignalIndexMap,indexOfSignalInPath]=create_block_signal_path_map(tempDatasetElement.(char(fields(idx))),...
            signalPathValuesMap,...
            signalsPath,...
            char(fields(idx)),...
            signalPathSignalIndexMap,...
            indexOfSignalInPath,...
            diagnosticInfo);
        end

    elseif isequal(class(tempDatasetElement),'timeseries')
        signalsPath=[signalsPath,char(element)];


        if diagnosticInfo.validateFields
            validateValues(diagnosticInfo.dsIdx,tempDatasetElement.Data);
        end
        signalPathValuesMap(signalsPath)=tempDatasetElement;



        signalPathSignalIndexMap(signalsPath)=indexOfSignalInPath;
        indexOfSignalInPath=indexOfSignalInPath+1;
    end
end




function blockPath=get_blockpath_from_dataset(dataset,index)
    blockPath='';
    numModels=dataset{index}.BlockPath.getLength();
    blockPath=strcat(blockPath,dataset{index}.BlockPath.getBlock(1));
    for modelIndex=2:numModels
        blockPath=strcat(blockPath,'|',dataset{index}.BlockPath.getBlock(modelIndex));
    end
end




function[initialState]=getDatasetInitialState(xInitial,buildData)
    initialStateInvalidFields=struct('blockPath',{},'index',{});

    if xInitial.numElements>0
        [xInitial,initialStateInvalidFields]=parseInitialState(xInitial,initialStateInvalidFields,buildData);
    end

    initialState.loggedStates=xInitial.toStructForSimState(true);

    initialState.IsInitialStateDataset=true;

    initialState.InitialStateInvalidFields=initialStateInvalidFields;
end



function save_template_dataset(buildData,templateDataset)
    templateDatasetFileName=fullfile(buildData.buildDir,'template_dataset');
    save(templateDatasetFileName,'-v7',...
    'templateDataset');
end



function buildData=add_template_dataset(buildData)
    templateDatasetFileName=fullfile(buildData.buildDir,'template_dataset');
    templateDatasetFileContents=load(templateDatasetFileName);


    assert(isfield(templateDatasetFileContents,'templateDataset'));
    templateDataset=templateDatasetFileContents.templateDataset;






    assert((isempty(templateDataset)&&isequal(class(templateDataset),'double'))||...
    isequal(class(templateDataset),'Simulink.SimulationData.Dataset'));
    buildData.templateDataset=templateDatasetFileContents.templateDataset;
end


