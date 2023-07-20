
function out=externaldatahandler(action,varargin)











    out={action};

    switch(action)
    case 'csv'
        out=readCSV(action,varargin{1});
    case 'excel'
        out=readExcel(action,varargin{1});
    case 'sas'
        out=readSAS(action,varargin{1});
    case 'matfile'
        out=readMATFile(action,varargin{1});
    case 'matfileVariable'
        out=readMATFileVariable(action,varargin{1});
    case 'workspace'
        out=readWorkspace(action);
    case 'workspaceVariable'
        out=readWorkspaceVariable(action,varargin{1});
    case 'project'
        out=readProject(action,varargin{:});
    case 'storeData'
        out=storeData(action,varargin{1});
    case 'storeDataSets'
        out=storeDataSets(action,varargin);
    end

end

function[nonmem,nonmemData]=readNONMEMFormattedData(data,nonmemClassification)


    w=warning('off','all');

    try

        [msg,id]=lastwarn('');


        nonmemData=[];
        nonmem='';

        def=sbionmfiledef(nonmemClassification);
        [nonmemData,pdata]=sbionmimport(data,def);
        [dataout,headers]=convertDataSetToDouble(pdata.DataSet);


        nonmem=struct;
        nonmem.headers=headers;
        nonmem.columnData=dataout;
        nonmem.messages=nonmemData.Properties.Description;
        nonmem.warnings=lastwarn;
        nonmem.error='';
        nonmem.pkdata=pdata;


        nonmemData=groupedData2table(nonmemData);


        lastwarn(msg,id);
    catch ex
        nonmem.error=SimBiology.web.internal.errortranslator(ex);
    end


    warning(w);

end

function[out,data]=readCSV(action,input)

    data=[];


    out=fileExists(input.filename);
    if out.error
        out={action,out};
        return;
    end

    pvpairs={'File',input.filename,'ReadVarNames',input.hasHeader};


    if strcmp(input.separator,'semicolon')
        input.separator='semi';
    end

    if~isempty(input.separator)
        pvpairs{end+1}='Delimiter';
        pvpairs{end+1}=input.separator;
    end

    if input.treat
        pvpairs{end+1}='TreatAsEmpty';
        pvpairs{end+1}=input.treatChar;
    end

    if input.ignoreLines&&input.numLinesToIgnore>0
        pvpairs{end+1}='HeaderLines';
        pvpairs{end+1}=input.numLinesToIgnore;
    end


    w=warning('off','all');


    logfile=[SimBiology.web.internal.desktopTempname(),'.xml'];
    matlab.internal.diagnostic.log.open(logfile);
    fileCleanup=onCleanup(@()deleteFile(logfile));

    info=struct('errors','','warnings','');

    try
        data=dataset2table(dataset(pvpairs{:}));


        info.input=input;





        [dataout,headers]=converTableToDouble(data);
        info.headers=headers;
        info.columnData=dataout;
        info.dataLength=height(data);


        if input.nonmemInterpretation
            [info.nonmem,data]=readNONMEMFormattedData(data,input.nonmemClassification);
            if~isempty(data)
                [dataout,headers]=converTableToDouble(data);
                info.nonmem.headers=headers;
                info.nonmem.columnData=dataout;
                info.dataLength=height(data);
            end
        else
            info.nonmem='';
        end

    catch ex
        info.errors=SimBiology.web.internal.errortranslator(ex);
    end


    warning(w);


    warnings=matlab.internal.diagnostic.log.load(logfile);
    info.warnings=getWarningStructs(warnings);


    matlab.internal.diagnostic.log.close(logfile);


    out={action,info};

end

function[out,data]=readExcel(action,input)

    data=[];


    out=fileExists(input.filename);
    if out.error
        out={action,out};
        return;
    end

    try

        logfile=[SimBiology.web.internal.desktopTempname(),'.xml'];
        matlab.internal.diagnostic.log.open(logfile);
        fileCleanup=onCleanup(@()deleteFile(logfile));

        warningID='MATLAB:table:ModifiedAndSavedVarnames';
        originalWarning=warning('query',warningID);
        warning('off',warningID);


        data=readtable(input.filename,'Format','auto','FileType','spreadsheet','ReadVariableNames',input.hasHeader);


        info.input=input;


        warnings=matlab.internal.diagnostic.log.load(logfile);
        warnings=getWarningStructs(warnings);


        for i=1:numel(warnings)
            if strcmp(warnings(i).identifier,warningID)
                warnings(i).message='Table variable names were modified to make them valid MATLAB identifiers';
            end
        end

        info.warnings=warnings;


        matlab.internal.diagnostic.log.close(logfile);





        [dataout,headers]=converTableToDouble(data);
        info.headers=headers;
        info.columnData=dataout;
        info.dataLength=height(data);


        if input.nonmemInterpretation
            [info.nonmem,data]=readNONMEMFormattedData(data,input.nonmemClassification);
            if~isempty(data)
                [dataout,headers]=converTableToDouble(data);
                info.nonmem.headers=headers;
                info.nonmem.columnData=dataout;
                info.dataLength=height(data);
            end
        else
            info.nonmem='';
        end

        out={action,info};
    catch ex
        out={action,SimBiology.web.internal.errortranslator(ex)};
    end


    warning(originalWarning.state,warningID);

end

function[out,data]=readSAS(action,input)

    data=[];


    out=fileExists(input.filename);
    if out.error
        out={action,out};
        return;
    end


    logfile=[SimBiology.web.internal.desktopTempname(),'.xml'];
    matlab.internal.diagnostic.log.open(logfile);
    fileCleanup=onCleanup(@()deleteFile(logfile));

    warningID='stats:xptread:InvalidObsnames';
    originalWarning=warning('query',warningID);
    warning('off',warningID);

    info=struct('warnings','','errors','');

    try
        data=xptread(input.filename,'ReadObsNames',input.treatAsNames);


        info.input=input;





        [dataout,headers]=converTableToDouble(data);
        info.headers=headers;
        info.columnData=dataout;
        info.dataLength=height(data);


        if input.nonmemInterpretation
            [info.nonmem,data]=readNONMEMFormattedData(data,input.nonmemClassification);
            if~isempty(data)
                [dataout,headers]=converTableToDouble(data);
                info.nonmem.headers=headers;
                info.nonmem.columnData=dataout;
                info.dataLength=height(data);
            end
        else
            info.nonmem='';
        end
    catch ex
        info.errors=SimBiology.web.internal.errortranslator(ex);
    end


    warning(originalWarning.state,warningID);


    warnings=matlab.internal.diagnostic.log.load(logfile);
    info.warnings=getWarningStructs(warnings);


    matlab.internal.diagnostic.log.close(logfile);


    out={action,info};

end

function out=readMATFile(action,input)


    out=fileExists(input.filename);
    if out.error
        out={action,out};
        return;
    end


    filepath=fileparts(input.filename);
    if isempty(filepath)
        input.filename=which(input.filename);
    end

    data=SimBiology.internal.getVariableInfoFromMatFile(input.filename);
    data=fixWhosOutputFromMATFile(data,input.filename);

    out={action,data};

end

function out=readWorkspace(action)

    data=evalin('base','whos');
    data=localFixWhosOutputFromWorkspace(data);
    out={action,data};

end

function out=readProject(action,input)


    out=fileExists(input.filename);
    if out.error
        out={action,out};
        return;
    end


    version='';
    sbioprojectObj=SimBiology.internal.sbioproject(input.filename,true);
    xmlName=sbioprojectObj.loadFilesMatchingRegexp('sbiotp\w*.xml');
    if~isempty(xmlName)
        xmlName=xmlName{1};
        version='v1';
    else
        xmlName=sbioprojectObj.loadFilesMatchingRegexp('externalDataLookup.mat');
        if~isempty(xmlName)
            xmlName=xmlName{1};
            version='v2';
        end
    end

    names={};
    sources={};
    variableNames={};

    switch version
    case 'v1'
        xmlObj=readstruct(xmlName);
        projectNode=getField(xmlObj,'Project');

        dataNodes=[];
        if~isempty(projectNode)
            externalDataNode=getField(projectNode,'ExternalData');
            if~isempty(externalDataNode)
                dataNodes=getField(externalDataNode,'IndData');
            end
        end

        names=cell(1,numel(dataNodes));
        variableNames=cell(1,numel(dataNodes));
        sources=cell(1,numel(dataNodes));

        for i=1:numel(dataNodes)
            names{i}=getAttribute(dataNodes(i),'Name');
            variableNames{i}=names{i};
            sources{i}=getAttribute(dataNodes(i),'OriginalSource');
        end

    case 'v2'

        dataInfo=load(xmlName);

        names={dataInfo.externalDataLookup.name};
        sources={dataInfo.externalDataLookup.source};
        variableNames={dataInfo.externalDataLookup.matfileVariableName};
    end


    deleteFile(xmlName);
    delete(sbioprojectObj);

    info.input=input;
    info.names=names;
    info.sources=sources;
    info.variableNames=variableNames;

    out={action,info};

end

function data=readProjectVariable(input)

    newDataName='';
    sbioprojectObj=SimBiology.internal.sbioproject(input.filename,true);
    dataFileName=sbioprojectObj.loadFilesMatchingRegexp('externaldata\w*.mat');
    if iscell(dataFileName)&&length(dataFileName)>=1
        newDataName=dataFileName{1};
    else
        dataFileName=sbioprojectObj.loadFilesMatchingRegexp('externalDataLookup.mat');
        if~isempty(dataFileName)
            dataInfo=load(dataFileName{1});
            newDataName=sbioprojectObj.loadFilesMatchingRegexp(dataInfo.matfileName);
            if~isempty(newDataName)
                newDataName=newDataName{1};
            end
        end
    end

    if~isempty(newDataName)
        data=load(newDataName,input.variableNames);
        data=convertDataToTable(data.(input.variableNames));


        deleteFile(newDataName);
    else
        data=[];
    end

    delete(sbioprojectObj);

end

function[out,data]=readMATFileVariable(action,input)

    data=getDataFromMATFile(input.filename,input.variableNames);
    warnings='';
    classifications={};

    if isa(data,'double')
        [dataout,headers,datasize]=convertDoubleForPreview(data);
    elseif isa(data,'dataset')
        [dataout,headers,datasize]=convertDataSetToDoubleForPreview(data);
    elseif isa(data,'table')
        [dataout,headers,datasize,warnings,classifications]=convertDataTableToDoubleForPreview(data);
    elseif isa(data,'groupedData')
        [dataout,headers,datasize,warnings,classifications]=convertGroupedDataToDoubleForPreview(data);
    elseif isa(data,'timeseries')
        [dataout,headers,datasize]=convertTimeSeriesToDoubleForPreview(data);
    elseif isa(data,'SimData')
        [dataout,headers,datasize]=convertSimDataToDoubleForPreview(data);
    elseif isa(data,'PKData')
        data=data.DataSet;
        [dataout,headers,datasize]=convertDataSetToDoubleForPreview(data);
    elseif isa(data,'SimBiology.fit.OptimResults')||isa(data,'SimBiology.fit.NLINResults')
        paramEstimates=vertcat(data.ParameterEstimates);
        [dataout,headers,datasize,warnings]=convertTableToDoubleForPreview(paramEstimates);
    elseif isa(data,'SimBiology.fit.NLMEResults')
        paramEstimates=vertcat(data.IndividualParameterEstimates);
        [dataout,headers,datasize,warnings]=convertTableToDoubleForPreview(paramEstimates);
    elseif isa(data,'SimBiology.fit.ParameterConfidenceInterval')
        paramCI=vertcat(data.Results);
        [dataout,headers,datasize,warnings]=convertTableToDoubleForPreview(paramCI);
    elseif isa(data,'SimBiology.fit.PredictionConfidenceInterval')
        predCI=vertcat(data.Results);
        [dataout,headers,datasize,warnings]=convertTableToDoubleForPreview(predCI);
    elseif isa(data,'SimBiology.Scenarios')
        try
            samplingData=data.generate;
            [dataout,headers,datasize,warnings]=convertTableToDoubleForPreview(samplingData,samplingData.Properties.VariableDescriptions');
        catch ex
            headers={};
            dataout=[];
            datasize=0;
            msg=SimBiology.web.internal.errortranslator(ex);
            warnings=struct('message',message('SimBiology:sbiodesktoperrortranslator:CANNOT_PREVIEW_SCENARIOS',msg).getString);
        end
    elseif isa(data,'SimBiology.gsa.Sobol')||isa(data,'SimBiology.gsa.MPGSA')||isa(data,'SimBiology.gsa.ElementaryEffects')
        gsaOut=SimBiology.web.gsahandler('convertTableToDoubleForPreview',data);
        dataout=gsaOut.dataout;
        headers=gsaOut.headers;
        datasize=gsaOut.datasize;
        warnings=gsaOut.warnings;
    else
        headers={};
        dataout=[];
        datasize=0;
    end

    data=convertDataToTable(data);
    if~isempty(classifications)&&(size(data,2)==numel(classifications))
        data.Properties.VariableDescriptions=classifications;
    end


    info.headers=headers;
    info.columnData=dataout;
    info.dataLength=datasize;
    info.input=input;
    info.nonmem='';


    if input.nonmemInterpretation
        [info.nonmem,data]=readNONMEMFormattedData(data,input.nonmemClassification);
        if~isempty(data)
            [dataout,headers]=converTableToDouble(data);
            info.nonmem.headers=headers;
            info.nonmem.columnData=dataout;
            info.dataLength=height(data);
        end
    end


    if~isempty(warnings)
        info.warnings=warnings;
    end

    out={action,info};

end

function[out,data]=readWorkspaceVariable(action,input)

    data=loadDataFromWorkspace(input.variableNames);
    warnings='';
    classifications={};

    if isa(data,'double')
        [dataout,headers,datasize]=convertDoubleForPreview(data);
    elseif isa(data,'dataset')
        [dataout,headers,datasize]=convertDataSetToDoubleForPreview(data);
    elseif isa(data,'table')
        [dataout,headers,datasize,warnings,classifications]=convertDataTableToDoubleForPreview(data);
    elseif isa(data,'groupedData')
        [dataout,headers,datasize,warnings,classifications]=convertGroupedDataToDoubleForPreview(data);
    elseif isa(data,'timeseries')
        [dataout,headers,datasize]=convertTimeSeriesToDoubleForPreview(data);
    elseif isa(data,'SimData')
        [dataout,headers,datasize]=convertSimDataToDoubleForPreview(data);
    elseif isa(data,'PKData')
        data=data.DataSet;
        [dataout,headers,datasize]=convertDataSetToDoubleForPreview(data);
    elseif isa(data,'SimBiology.fit.OptimResults')||isa(data,'SimBiology.fit.NLINResults')
        paramEstimates=vertcat(data.ParameterEstimates);
        [dataout,headers,datasize,warnings]=convertTableToDoubleForPreview(paramEstimates);
    elseif isa(data,'SimBiology.fit.NLMEResults')
        paramEstimates=vertcat(data.IndividualParameterEstimates);
        [dataout,headers,datasize,warnings]=convertTableToDoubleForPreview(paramEstimates);
    elseif isa(data,'SimBiology.fit.ParameterConfidenceInterval')
        paramCI=vertcat(data.Results);
        [dataout,headers,datasize,warnings]=convertTableToDoubleForPreview(paramCI);
    elseif isa(data,'SimBiology.fit.PredictionConfidenceInterval')
        predCI=vertcat(data.Results);
        [dataout,headers,datasize,warnings]=convertTableToDoubleForPreview(predCI);
    elseif isa(data,'SimBiology.gsa.Sobol')||isa(data,'SimBiology.gsa.MPGSA')||isa(data,'SimBiology.gsa.ElementaryEffects')
        gsaOut=SimBiology.web.gsahandler('convertTableToDoubleForPreview',data);
        dataout=gsaOut.dataout;
        headers=gsaOut.headers;
        datasize=gsaOut.datasize;
        warnings=gsaOut.warnings;
    else
        headers={};
        dataout=[];
        datasize=0;
    end

    data=convertDataToTable(data);
    if~isempty(classifications)&&(size(data,2)==numel(classifications))
        data.Properties.VariableDescriptions=classifications;
    end


    info.headers=headers;
    info.columnData=dataout;
    info.dataLength=datasize;
    info.input=input;
    info.nonmem='';


    if input.nonmemInterpretation
        [info.nonmem,data]=readNONMEMFormattedData(data,input.nonmemClassification);
        if~isempty(data)
            [dataout,headers]=converTableToDouble(data);
            info.nonmem.headers=headers;
            info.nonmem.columnData=dataout;
            info.dataLength=height(data);
        end
    end


    if~isempty(warnings)
        info.warnings=warnings;
    end

    out={action,info};

end

function dataIn=fixWhosOutputFromMATFile(dataIn,matfile)

    for i=1:length(dataIn)
        dataIn(i).Accepted=true;
        dataIn(i).Dosed='';
        dataIn(i).Rate='';
        dataIn(i).Units={};
        dataIn(i).Covariates='';
        dataIn(i).Group='';
        dataIn(i).Time='';

        type=dataIn(i).class;
        if strcmp(type,'timeseries')
            next=dataIn(i).name;
            temp=load(matfile,next);
            value=temp.(next);
            data=squeeze(value.Data);
            sizeInfo=size(data);
            sizeInfo(2)=sizeInfo(2)+1;
            dataIn(i).size=sizeInfo;
            dataIn(i).Accepted=(ndims(data)==2);%#ok<ISMAT>
        elseif strcmp(type,'PKData')
            next=dataIn(i).name;
            temp=load(matfile,next);
            dsValue=temp.(next);
            value=dsValue.DataSet;
            sizeInfo=size(value);
            dataIn(i).size=sizeInfo;
            dataIn(i).Dosed=dsValue.DoseLabel;
            dataIn(i).Rate=dsValue.RateLabel;
            containsInvalid=dataSetContainsInvalidTypes(value);
            dataIn(i).Accepted=~containsInvalid;
            dataIn(i).Units=get(value,'Units');
            dataIn(i).Covariates=dsValue.CovariateLabels;

        elseif strcmp(type,'dataset')
            next=dataIn(i).name;
            temp=load(matfile,next);
            value=temp.(next);
            sizeInfo=size(value);
            dataIn(i).size=sizeInfo;
            dataIn(i).Units=get(value,'Units');


            containsInvalid=dataSetContainsInvalidTypes(value);
            dataIn(i).Accepted=~containsInvalid;

        elseif strcmp(type,'table')
            next=dataIn(i).name;
            temp=load(matfile,next);
            value=temp.(next);
            sizeInfo=size(value);
            dataIn(i).size=sizeInfo;
            dataIn(i).Units=value.Properties.VariableUnits;


            containsInvalid=tableContainsInvalidTypes(value);
            dataIn(i).Accepted=~containsInvalid;

        elseif strcmp(type,'groupedData')
            next=dataIn(i).name;
            temp=load(matfile,next);
            value=temp.(next);
            sizeInfo=size(value);
            dataIn(i).size=sizeInfo;
            dataIn(i).Units=value.Properties.VariableUnits;
            dataIn(i).Group=value.Properties.GroupVariableName;
            dataIn(i).Time=value.Properties.IndependentVariableName;


            containsInvalid=tableContainsInvalidTypes(groupedData2table(value));
            dataIn(i).Accepted=~containsInvalid;

        elseif strcmp(type,'SimData')
            next=dataIn(i).name;
            temp=load(matfile,next);
            x=temp.(next);

            if length(x)==1
                sizeInfo=size(x.Data);
                sizeInfo(2)=sizeInfo(2)+1;
                dataIn(i).size=sizeInfo;
            else

                dataIn(i).size=size(x);
            end
        elseif strcmp(type,'SimBiology.fit.ParameterConfidenceInterval')||strcmp(type,'SimBiology.fit.PredictionConfidenceInterval')
            dataIn(i).Accepted=dataIn(i).size(2)==1;
        end
    end

end

function dataIn=localFixWhosOutputFromWorkspace(dataIn)

    for i=1:length(dataIn)
        dataIn(i).Accepted=true;
        dataIn(i).Dosed='';
        dataIn(i).Rate='';
        dataIn(i).Units={};
        dataIn(i).Covariates='';
        dataIn(i).Group='';
        dataIn(i).Time='';

        type=dataIn(i).class;
        if strcmp(type,'timeseries')
            x=evalin('base',dataIn(i).name);
            data=squeeze(x.Data);
            sizeInfo=size(data);
            sizeInfo(2)=sizeInfo(2)+1;
            dataIn(i).size=sizeInfo;
            dataIn(i).Accepted=(ndims(data)==2);

        elseif strcmp(type,'PKData')
            dsValue=evalin('base',dataIn(i).name);
            value=dsValue.DataSet;
            sizeInfo=size(value);
            dataIn(i).size=sizeInfo;
            dataIn(i).Dosed=dsValue.DoseLabel;
            dataIn(i).Rate=dsValue.RateLabel;
            containsInvalid=dataSetContainsInvalidTypes(value);
            dataIn(i).Accepted=~containsInvalid;
            dataIn(i).Units=get(value,'Units');
            dataIn(i).Covariates=dsValue.CovariateLabels;

        elseif strcmp(type,'dataset')
            x=evalin('base',dataIn(i).name);
            sizeInfo=size(x);
            dataIn(i).size=sizeInfo;


            containsInvalid=dataSetContainsInvalidTypes(x);
            dataIn(i).Accepted=~containsInvalid;
            dataIn(i).Units=get(x,'Units');

        elseif strcmp(type,'table')
            x=evalin('base',dataIn(i).name);
            sizeInfo=size(x);
            dataIn(i).size=sizeInfo;


            containsInvalid=tableContainsInvalidTypes(x);
            dataIn(i).Accepted=~containsInvalid&&sizeInfo(1)>0;
            dataIn(i).Units=x.Properties.VariableUnits;

        elseif strcmp(type,'groupedData')
            x=evalin('base',dataIn(i).name);
            sizeInfo=size(x);
            dataIn(i).size=sizeInfo;


            containsInvalid=tableContainsInvalidTypes(groupedData2table(x));
            dataIn(i).Accepted=~containsInvalid;
            dataIn(i).Units=x.Properties.VariableUnits;
            dataIn(i).Group=x.Properties.GroupVariableName;
            dataIn(i).Time=x.Properties.IndependentVariableName;

        elseif strcmp(type,'SimData')
            x=evalin('base',dataIn(i).name);

            if isvalid(x)
                if length(x)==1
                    sizeInfo=size(x.Data);
                    sizeInfo(2)=sizeInfo(2)+1;
                    dataIn(i).size=sizeInfo;
                else

                    dataIn(i).size=size(x);
                end
            else
                dataIn(i).Accepted=false;
            end
        elseif strcmp(type,'SimBiology.fit.ParameterConfidenceInterval')||strcmp(type,'SimBiology.fit.PredictionConfidenceInterval')

            dataIn(i).Accepted=dataIn(i).size(2)==1;
        end
    end

end

function out=dataSetContainsInvalidTypes(data)


    names=get(data,'VarNames');
    out=acceptedDataTypes(names,data);

end

function out=tableContainsInvalidTypes(data)


    names=data.Properties.VariableNames;
    out=acceptedDataTypes(names,data);

end

function out=acceptedDataTypes(names,data)

    acceptedDataSetTypes={'double','char','cell','string','categorical','duration','datetime','logical'};
    out=false;

    if isempty(data)
        return;
    end

    for j=1:length(names)
        temp=data(1,names{j});
        classname=class(temp.(names{j}));

        if~any(strcmp(classname,acceptedDataSetTypes))
            out=true;
            break;
        elseif strcmp(classname,'cell')%#ok<*ISCEL>
            if~iscellstr(temp.(names{j}))
                out=true;
                break;
            end
        elseif strcmp(classname,'double')%#ok<*STISA>

            rawdata=double(temp.(names{j}));
            out=(size(rawdata,2)~=1);
        end
    end

end

function data=getDataFromMATFile(matfile,variables)

    data=[];

    for i=1:length(variables)
        next=variables{i};
        temp=load(matfile,next);
        value=temp.(next);
        sizeValue=size(value);

        if(sizeValue(1)==1&&isnumeric(value))
            value=value';
        end

        if isempty(data)
            data=value;
        else
            if size(data,1)==size(value,1)
                try
                    data=horzcat(data,value);%#ok<AGROW>
                catch
                    data=[];
                    return;
                end
            else
                data=[];
                return;
            end
        end
    end

end

function data=loadDataFromWorkspace(variables)

    data=[];

    for i=1:length(variables)
        next=variables{i};
        value=evalin('base',next);
        sizeValue=size(value);

        if(sizeValue(1)==1&&sizeValue(2)~=1&&isnumeric(value))
            value=value';
        end

        if isempty(data)
            data=value;
        else
            if size(data,1)==size(value,1)
                try
                    data=horzcat(data,value);%#ok<AGROW>
                catch
                    data=[];
                    return;
                end
            else
                data=[];
                return;
            end
        end
    end




end

function out=storeDataSets(action,inputArgs)

    numDataSets=numel(inputArgs);
    info=cell(numDataSets,1);



    for i=1:numDataSets
        retVal=storeData('storeData',inputArgs{i});
        info{i}=retVal{2};
    end

    out={action,info};

end

function out=storeData(action,input)

    name=input.name;
    matfileVariableName=input.matfileVariableName;
    matfileName=input.matfileName;
    inputArgs=input.input;
    type=inputArgs.type;
    data=[];




    path=fileparts(matfileName);
    if isempty(path)
        matfileName=[SimBiology.web.internal.desktopTempdir,filesep,matfileName];
    end

    if strcmp(type,'csv')
        [readInfo,data]=readCSV('',inputArgs);
    elseif strcmp(type,'excel')
        [readInfo,data]=readExcel('',inputArgs);
    elseif strcmp(type,'sas')
        [readInfo,data]=readSAS('',inputArgs);
    elseif strcmp(type,'matfile')
        [readInfo,data]=readMATFileVariable('',inputArgs);
    elseif strcmp(type,'workspace')
        [readInfo,data]=readWorkspaceVariable('',inputArgs);
    elseif strcmp(type,'project')
        data=readProjectVariable(inputArgs);
    elseif strcmp(type,'rawdata')
        data=convertDataToTable(inputArgs.data);
    elseif strcmp(type,'rawdataWithLabels')
        data=convertDataToTable(inputArgs.data);
        data.Properties.VariableNames=inputArgs.labels;
    end


    tableType='externaldata';

    if~isempty(data)
        supportsExclusions=false;


        if isa(data,'table')



            if isfield(input,'columnNames')&&~isempty(input.columnNames)&&(numel(input.columnNames)==numel(data.Properties.VariableNames))
                data.Properties.VariableNames=input.columnNames;
            end


            pkdata=[];
            if input.input.nonmemInterpretation
                pkdata=readInfo{2}.nonmem.pkdata;
                data.Properties.VariableNames=readInfo{2}.nonmem.headers;
            end


            inputs.next=data;
            inputs.name=name;
            inputs.nonmem=struct('nonmemInterpretation',input.input.nonmemInterpretation,'pkdata',pkdata);

            dataInfo=SimBiology.web.datahandler('getExternalDataInfo',inputs);


            data.Properties.VariableUnits={dataInfo.columnInfo.units};
            data.Properties.VariableDescriptions={dataInfo.columnInfo.classification};


            SimBiology.web.datahandler('saveDataToMATFile',data,matfileVariableName,matfileName);


            supportsExclusions=true;

        elseif isa(data,'SimData')


            names=vertcat({'time'},data(1).DataNames);
            [t,values]=getdata(data);
            columns=cell(1,length(names));


            if numel(data)>1
                multirundata=SimBiology.web.datahandler('getMultiRunData',data);
                columns={multirundata(:).value};
            else
                columns{1}=t;
                for i=2:length(names)
                    columns{i}=values(:,i-1);
                end
            end


            inputs.next=data;
            inputs.name=name;
            inputs.nonmem=struct('nonmemInterpretation',false,'pkdata',{});

            dataInfo=SimBiology.web.datahandler('getExternalDataInfo',inputs);


            SimBiology.web.datahandler('saveDataToMATFile',data,matfileVariableName,matfileName);


            tableType='SimData';


            data=table(columns{:});
        elseif isa(data,'SimBiology.fit.OptimResults')||isa(data,'SimBiology.fit.ParameterConfidenceInterval')||isa(data,'SimBiology.fit.PredictionConfidenceInterval')||...
            isa(data,'SimBiology.fit.NLINResults')||isa(data,'SimBiology.fit.NLMEResults')||isa(data,'SimBiology.Scenarios')
            inputs.next=data;
            inputs.name=name;
            inputs.nonmem=struct('nonmemInterpretation',false,'pkdata',{});

            dataInfo=SimBiology.web.datahandler('getExternalDataInfo',inputs);


            SimBiology.web.datahandler('saveDataToMATFile',data,matfileVariableName,matfileName);
        elseif isa(data,'SimBiology.gsa.Sobol')||isa(data,'SimBiology.gsa.MPGSA')||isa(data,'SimBiology.gsa.ElementaryEffects')
            inputs.next=data;
            inputs.name=name;
            dataInfo=SimBiology.web.datahandler('getExternalDataInfo',inputs);


            SimBiology.web.datahandler('saveDataToMATFile',data,matfileVariableName,matfileName);
        end




        datasheetColumnInfo=dataInfo.columnInfo;
        if~isempty(dataInfo.columnInfo)
            props=data.Properties.VariableNames;

            for i=1:numel(dataInfo.columnInfo)

                datasheetColumnInfo(i).data=data.(props{i});
                datasheetColumnInfo(i).data=SimBiology.web.datahandler('scrubData',datasheetColumnInfo(i).data);
            end
        end


        info.dataName=name;
        info.fullDataName=input.fullDataName;
        info.matfileVariableName=matfileVariableName;
        info.matfileName=matfileName;
        info.options=input.options;
        info.dataInfo=dataInfo;
        info.matfileDerivedVariableName=input.matfileDerivedVariableName;

        tableDataInfo=struct('sourceType','externaldata','sourceName',name,'dataName',name,'variableName','');


        if isa(data,'SimBiology.fit.OptimResults')
            variables=struct('StructFieldName','results','type','optimResults');

            variables=SimBiology.web.fitdatahandler('getData',{data,{},variables});
            tableMetaData=variables.data.tableMetaData;
            tables=[variables.data.tables];

        elseif isa(data,'SimBiology.fit.NLINResults')
            variables=struct('StructFieldName','results','type','nlinResults');

            variables=SimBiology.web.fitdatahandler('getData',{data,{},variables});
            tableMetaData=variables.data.tableMetaData;
            tables=[variables.data.tables];

        elseif isa(data,'SimBiology.fit.NLMEResults')
            variables=struct('StructFieldName','results','type','nlmeResults');

            variables=SimBiology.web.fitdatahandler('getData',{data,{},variables});
            tableMetaData=variables.data.tableMetaData;
            tables=[variables.data.tables];

        elseif isa(data,'SimBiology.fit.ParameterConfidenceInterval')
            variables=struct('StructFieldName','results','type','parameterConfidenceInterval');

            variables=SimBiology.web.fitdatahandler('getData',{data,{},variables});
            tableMetaData=variables.data.tableMetaData;
            tables=[variables.data.tables];

        elseif isa(data,'SimBiology.fit.PredictionConfidenceInterval')
            variables=struct('StructFieldName','results','type','predictionConfidenceInterval');

            variables=SimBiology.web.fitdatahandler('getData',{data,{},variables});
            tableMetaData=variables.data.tableMetaData;
            tables=[variables.data.tables];

        elseif isa(data,'SimBiology.gsa.Sobol')
            variables=struct('StructFieldName','results','type','sobolResults');

            variables=SimBiology.web.gsahandler('getData',{data,{},variables});
            tableMetaData=variables.data.tableMetaData;
            tables=[variables.data.tables];

        elseif isa(data,'SimBiology.gsa.MPGSA')
            variables=struct('StructFieldName','results','type','mpgsaResults');

            variables=SimBiology.web.gsahandler('getData',{data,{},variables});
            tableMetaData=variables.data.tableMetaData;
            tables=[variables.data.tables];

        elseif isa(data,'SimBiology.gsa.ElementaryEffects')
            variables=struct('StructFieldName','results','type','elementaryEffectsResults');

            variables=SimBiology.web.gsahandler('getData',{data,{},variables});
            tableMetaData=variables.data.tableMetaData;
            tables=[variables.data.tables];

        elseif isa(data,'SimBiology.Scenarios')

            samples=data.generate;


            names=samples.Properties.VariableDescriptions';

            datasheetColumnInfo=struct('name','','data','','isExpression',false);
            datasheetColumnInfo=repmat(datasheetColumnInfo,numel(names),1);


            props=samples.Properties.VariableNames;
            for i=1:length(names)
                datasheetColumnInfo(i).name=names{i};
                x=samples.(props{i});

                if isa(x,'SimBiology.Variant')
                    datasheetColumnInfo(i).name=sprintf('%s (%s)',names{i},'variant');
                    variantNames=get(x,'Name');
                    variantNames=reshape(variantNames,size(x));
                    datasheetColumnInfo(i).data=convertToOneDimensional(variantNames);
                elseif isa(x,'SimBiology.RepeatDose')||isa(x,'SimBiology.Dose')||isa(x,'SimBiology.ScheduleDose')
                    datasheetColumnInfo(i).name=sprintf('%s (%s)',names{i},'dose');
                    doseNames=get(x,'Name');
                    doseNames=reshape(doseNames,size(x));
                    datasheetColumnInfo(i).data=convertToOneDimensional(doseNames);
                else
                    datasheetColumnInfo(i).data=x;
                end
            end

            tableMetaData=struct('dataType','data','supportsExclusions',false);
            tables=struct('name',name,'tableType','rawdata','columnInfo',datasheetColumnInfo);
            tables.tablePosition=struct('x','','y','');
            tables.tableSize=struct('width','','height','');

        else
            tableMetaData=struct('dataType','data','supportsExclusions',supportsExclusions);
            tables=struct('name',name,'tableType',tableType,'columnInfo',datasheetColumnInfo);
            tables.tablePosition=struct('x','','y','');
            tables.tableSize=struct('width','','height','');
        end




        if(numel(tables(1).columnInfo)*numel(tables(1).columnInfo(1).data))<200000
            datasheetInfo=struct('dataInfo',tableDataInfo,'tableMetaData',tableMetaData,'tables',tables);
            info.datasheetInfo=datasheetInfo;
        else
            info.datasheetInfo='';
        end

        out={action,info};
    else
        info.dataName=name;
        info.names={};
        info.columnData={};
        info.options=input.options;

        out={action,info};
    end

end

function out=convertDataToTable(data)

    if isa(data,'double')
        out=convertDoubleToTable(data);
    elseif isa(data,'dataset')
        out=dataset2table(data);
    elseif isa(data,'table')
        out=data;
    elseif isa(data,'groupedData')
        out=groupedData2table(data);
    elseif isa(data,'timeseries')
        out=convertTimeSeriesToTable(data);
    elseif isa(data,'PKData')
        out=dataset2table(data.DataSet);
    elseif isa(data,'SimData')||isa(data,'SimBiology.fit.OptimResults')||isa(data,'SimBiology.fit.NLINResults')||isa(data,'SimBiology.fit.NLMEResults')...
        ||isa(data,'SimBiology.fit.ParameterConfidenceInterval')||isa(data,'SimBiology.fit.PredictionConfidenceInterval')...
        ||isa(data,'SimBiology.Scenarios')||isa(data,'SimBiology.gsa.Sobol')||isa(data,'SimBiology.gsa.MPGSA')||isa(data,'SimBiology.gsa.ElementaryEffects')
        out=data;
    else
        out=[];
    end

end

function t=convertDoubleToTable(data)

    t=table;
    for i=1:size(data,2)
        t.(['Column',num2str(i)])=data(:,i);
    end

end

function t=convertTimeSeriesToTable(data)

    t=table;
    t.Time=data.Time;

    columns=data.Data;
    for i=1:size(columns,2)
        t.(['Column',num2str(i)])=columns(:,i);
    end

end

function[dataout,headers]=convertDataSetToDouble(data)

    headers=get(data,'VarNames');

    dataout=cell(1,length(headers));
    for i=1:length(headers)
        dataout{i}=SimBiology.web.datahandler('scrubData',data.(headers{i}));
    end


end

function[dataout,headers]=converTableToDouble(data)

    headers=data.Properties.VariableNames;

    dataout=cell(1,length(headers));
    for i=1:length(headers)
        dataout{i}=SimBiology.web.datahandler('scrubData',data.(headers{i}));
    end

end

function[dataout,headers,datasize]=convertDoubleForPreview(data)

    numRows=size(data,1);
    numColumns=size(data,2);
    datasize=numRows;

    headers=cell(1,numColumns);
    dataout=cell(1,numColumns);
    maxLength=min(numRows,20);

    for i=1:length(headers)
        headers{i}=['Column',num2str(i)];
        dataout{i}=data((1:maxLength),i);
    end

end

function[dataout,headers,datasize]=convertDataSetToDoubleForPreview(data)

    headers=get(data,'VarNames');
    dataout=cell(1,length(headers));
    datasize=length(data);
    maxLength=min(datasize,20);

    for i=1:length(headers)
        x=data.(headers{i});
        x=x(1:maxLength);

        if isa(x,'categorical')||isa(x,'duration')||isa(x,'datetime')
            x=string(x);
        end
        dataout{i}=SimBiology.web.datahandler('scrubData',x);
    end

end

function[dataout,headers,datasize]=convertTimeSeriesToDoubleForPreview(data)

    time=data.Time;
    dataToAdd=squeeze(data.Data);
    numCols=size(dataToAdd,2)+1;
    headers=cell(1,numCols);

    headers{1}='Time';
    for i=1:numCols-1
        headers{i+1}=['Column',num2str(i)];
    end

    datasize=length(time);
    dataout=cell(1,length(headers));
    for i=1:length(headers)
        if(i==1)
            x=time;
        else
            x=dataToAdd(:,i-1);
        end
        if length(x)>20
            x=x(1:20);
        end
        if isa(x,'categorical')||isa(x,'duration')||isa(x,'datetime')
            x=string(x);
        end
        dataout{i}=SimBiology.web.datahandler('scrubData',x);
    end

end

function[dataout,headers,datasize]=convertSimDataToDoubleForPreview(data)

    if(length(data)>1)
        [dataout,headers,datasize]=convertMultiRunSimDataToDoubleForPreview(data);
    else
        time=data.Time;
        dataToAdd=data.Data;
        names=data.DataNames;
        headers={'time',names{:}};

        datasize=length(time);
        dataout=cell(1,length(headers));
        for i=1:length(headers)
            if(i==1)
                x=time;
            else
                x=dataToAdd(:,i-1);
            end
            if length(x)>20
                x=x(1:20);
            end
            dataout{i}=SimBiology.web.datahandler('scrubData',x);
        end
    end

end

function[dataout,headers,datasize]=convertMultiRunSimDataToDoubleForPreview(data)

    names=unique(vertcat(data.DataNames),'stable');
    headers=vertcat('run','time',names);
    dataout=cell(1,length(headers));
    numCols=length(headers);

    for i=1:numCols
        nextCol=[];
        for j=1:length(data)
            if(i==1)
                time=data(j).Time;
                value=j*ones(length(time),1);
            elseif(i==2)
                value=data(j).Time;
            else
                simDataContains=contains(data(j),headers{i});
                if simDataContains{1}
                    d=selectbyname(data(j),headers{i});
                    value=d.Data;
                else
                    value=nan(numel(data(j).Time),1);
                end
            end

            nextCol=[nextCol;value];%#ok<AGROW>

            if length(nextCol)>20
                nextCol=nextCol(1:20,:);
                break;
            end
        end

        dataout{i}=SimBiology.web.datahandler('scrubData',nextCol);
    end

    datasize=0;
    for i=1:length(data)
        datasize=datasize+length(data(i).Time);
    end

end

function[dataout,headers,datasize,warnings,classifications]=convertGroupedDataToDoubleForPreview(data,varargin)
    varNames=data.Properties.VariableNames;
    classifications=repmat({''},size(varNames));

    idx=arrayfun(@(v)strcmp(v,data.Properties.GroupVariableName),varNames);
    if any(idx)
        classifications{idx}='group';
    end

    idx=arrayfun(@(v)strcmp(v,data.Properties.IndependentVariableName),varNames);
    if any(idx)
        classifications{idx}='independent';
    end

    data=groupedData2table(data);
    data.Properties.VariableDescriptions=classifications;

    [dataout,headers,datasize,warnings,classifications]=convertDataTableToDoubleForPreview(data);

end

function[dataout,headers,datasize,warnings,classifications]=convertDataTableToDoubleForPreview(data,varargin)
    classifications=data.Properties.VariableDescriptions;
    [dataout,headers,datasize,warnings]=convertTableToDoubleForPreview(data);

end

function[dataout,headers,datasize,warnings]=convertTableToDoubleForPreview(data,varargin)


    if nargin>1
        headers=varargin{1};
    else
        headers=data.Properties.VariableNames;
    end

    warnings=[];


    if~all(cellfun(@isvarname,headers))
        warnings=struct('message','Variable names were modified to make them valid MATLAB identifiers.');
        headers=SimBiology.internal.makeValidVariableNames(headers);
    end

    props=data.Properties.VariableNames;
    datasize=height(data);
    dataout=cell(1,length(props));
    for i=1:length(props)
        x=data.(props{i});

        if length(x)>20
            x=x(1:20,:);
        end


        if isa(x,'datetime')||isa(x,'duration')
            x=string(x);
        elseif isa(x,'SimBiology.Variant')
            headers{i}=sprintf('%s (%s)',headers{i},'variant');
            variantNames=get(x,'Name');
            variantNames=reshape(variantNames,size(x));
            x=convertToOneDimensional(variantNames);
        elseif isa(x,'SimBiology.RepeatDose')||isa(x,'SimBiology.Dose')||isa(x,'SimBiology.ScheduleDose')
            headers{i}=sprintf('%s (%s)',headers{i},'dose');
            doseNames=get(x,'Name');
            doseNames=reshape(doseNames,size(x));
            x=convertToOneDimensional(doseNames);
        else


            if size(x,2)>1
                xMod=cell(size(x,1),1);
                for j=1:size(x,1)
                    val=x(j,:);
                    if isnumeric(val)
                        val=sprintf('%d, ',x(j,:));
                        val=val(1:end-2);
                        val=sprintf('[%s]',val);
                    else
                        val=sprintf('%s',x(j,:));
                    end
                    xMod{j}=val;
                end

                x=xMod;
            elseif ischar(x)
                x=num2cell(x);
            end
        end

        dataout{i}=SimBiology.web.datahandler('scrubData',x);
    end

end

function deleteFile(name)

    if exist(name,'file')
        oldState=recycle;
        recycle('off');
        delete(name)
        recycle(oldState);
    end

end

function out=fileExists(name)





    for i=1:10

        if~exist(name,'file')
            out.error=true;
            out.filename=name;
            pause(0.5);
        else
            out.error=false;
            out.filename=name;
            break;
        end
    end

end

function out=getWarningStructs(warnings)


    [~,indexes]=unique({warnings.identifier},'stable');
    warnings=warnings(indexes);

    out=struct('identifier','','message','');
    out=repmat(out,numel(warnings),1);


    for i=1:numel(warnings)
        out(i).identifier=warnings(i).identifier;
        out(i).message=SimBiology.web.internal.errortranslator(warnings(i));
    end

end

function out=convertToOneDimensional(x)

    numRows=size(x,1);
    numCols=size(x,2);

    if numCols==1
        out=x;
        return;
    end

    out=cell(numRows,1);
    for i=1:numRows
        out{i}=strjoin(x(i,:),', ');
    end

end

function out=getAttribute(node,attribute,varargin)

    out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});

end

function out=getField(node,field)

    out=SimBiology.web.internal.converter.utilhandler('getField',node,field);
end
