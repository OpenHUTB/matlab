classdef SimOutputExplorer<handle



    properties(Access='public')
        Outputs;
        StructDimsMap=Simulink.sdi.Map('string','int32');
    end

    events
        VariableLoadEvent;
    end

    methods(Access='public')

        function this=SimOutputExplorer()


            Simulink.sdi.Instance.engine;
            this.ClearOutputs();
        end

        function ClearOutputs(this)
            this.Outputs=[];
        end

        function AddOutput(this,NewOutput)
            this.Outputs=[this.Outputs,NewOutput];
        end

        function[varNames,varValues]=ExploreBaseWorkspace(this)

            WhosOut=evalin('base','whos');


            interface=Simulink.sdi.internal.Framework.getFramework();
            tmpCleanup=interface.getModelCloseUtil();%#ok<NASGU>

            varNames={};
            varValues={};


            this.ClearOutputs();


            this.CheckForStreamedSignal=false;

            for i=1:length(WhosOut)

                IthVarName=WhosOut(i).name;
                IthVarValue=evalin('base',IthVarName);


                status=this.ExploreVariable(IthVarName,IthVarValue);
                if status
                    varNames=[varNames,{IthVarName}];%#ok
                    varValues=[varValues,{IthVarValue}];%#ok
                end
            end
        end

        function[varnames,varValues]=ExploreMATFile(this,filename)
            this.ClearOutputs();


            this.CheckForStreamedSignal=false;

            [varnames,varValues]=this.helperExploreMATFile(filename);
        end


        function ExploreMATFileinPWD(this,filenamestruct,varargin)






            this.CheckForStreamedSignal=false;

            if isstruct(filenamestruct)&&isfield(filenamestruct,'VarName')...
                &&isfield(filenamestruct,'BlockPath')
                filename=filenamestruct.VarName;

                if exist(filename,'file')
                    blockPath=filenamestruct.BlockPath;
                    timeVarName='';
                    modelName='';
                    numVars=length(varargin);

                    if numVars>0
                        timeVarName=varargin{1};
                    end

                    if numVars>1
                        modelName=varargin{2};
                    end
                    this.helperExploreMATFile(filename,blockPath,modelName,...
                    timeVarName);
                end
            end
        end


        function[varNames,varValues]=helperExploreMATFile(this,...
            filename,...
            varargin)

            blockPath='';
            modelName='';
            timeVarName='';
            varNames={};
            varValues={};


            interface=Simulink.sdi.internal.Framework.getFramework();
            tmpCleanup=interface.getModelCloseUtil();%#ok<NASGU>

            if length(varargin)==3
                [blockPath,modelName,timeVarName]=varargin{:};
            end

            WhosOut=whos('-file',filename);
            numVars=length(WhosOut);
            for i=1:numVars

                IthVarName=WhosOut(i).name;



                IthVarValue=load(filename,IthVarName);
                IthVarValue=IthVarValue.(IthVarName);

                if isempty(IthVarValue)
                    return;
                end

                isFirstDimensionTime=false;





                if isnumeric(IthVarValue)&&~isempty(varargin)
                    isFirstDimensionTime=true;


                    IthVarName=[IthVarName,''''];%#ok
                    IthVarValue=IthVarValue';
                end


                status=this.ExploreVariable(IthVarName,IthVarValue,...
                'timeVarName',timeVarName,...
                'modelSource',modelName,...
                'blockSource',blockPath,...
                'isFirstDimensionTime',...
                isFirstDimensionTime);

                if status
                    varNames=[varNames,IthVarName];%#ok
                    varValues=[varValues,{IthVarValue}];%#ok
                end
                notify(this,'VariableLoadEvent',Simulink.sdi.internal.VarImportEvent(numVars,i));
            end
        end

        function ExploreVariables(this,VarNames,VarValues,varargin)
            len=length(VarValues);


            interface=Simulink.sdi.internal.Framework.getFramework();
            tmpCleanup=interface.getModelCloseUtil();%#ok<NASGU>


            numVars=length(varargin);



            this.CheckForStreamedSignal=false;



            if(len==1)&&~iscell(VarValues)



                VarNamesNew{1}=VarNames;
                VarValuesNew{1}=VarValues;
                VarNames=VarNamesNew;
                VarValues=VarValuesNew;
            end

            for i=1:len


                blockPath='';
                varName=VarNames{i};

                if isfield(VarNames{i},'BlockPath')&&isfield(VarNames{i},...
                    'VarName')
                    blockPath=VarNames{i}.BlockPath;
                    varName=VarNames{i}.VarName;
                end

                try
                    switch numVars
                    case 0
                        this.ExploreVariable(varName,VarValues{i});
                    case 1

                        modelName=varargin{1};
                        this.CheckForStreamedSignal=~isempty(modelName);
                        this.ExploreVariable(varName,VarValues{i},'blockSource',...
                        blockPath,'modelSource',modelName);
                    case 2
                        modelName=varargin{1};
                        timeVarName=varargin{2};
                        this.CheckForStreamedSignal=~isempty(modelName);



                        if isfield(VarNames{i},'MetaData')&&isfield(VarNames{i},...
                            'VarName')



                            this.ExploreVariable(VarNames{i}.VarName,VarValues{i},...
                            'metaData',VarNames{i},'timeVarName',...
                            timeVarName);
                        else
                            this.ExploreVariable(varName,VarValues{i},'timeVarName',...
                            timeVarName,'modelSource',modelName,...
                            'blockSource',blockPath);
                        end
                    end
                catch me
                    warning(me.message);
                end
            end
        end



        function ExploreScopeVariables(this,VarNames,VarValues,modelName)
            len=length(VarValues);


            this.CheckForStreamedSignal=true;

            for i=1:len
                blockPath=' ';
                varName=VarNames{i};

                if isfield(VarNames{i},'BlockPath')&&isfield(VarNames{i},...
                    'VarName')
                    blockPath=VarNames{i}.BlockPath;
                    varName=VarNames{i}.VarName;
                end


                this.ExploreVariable(varName,VarValues{i},'modelSource',...
                modelName,'isFirstDimensionTime',true,...
                'blockSource',blockPath);
            end
        end

    end

    methods(Access='private')

        function isVarAdded=ExploreVariable(this,VarName,VarValue,...
            varargin)
            p=inputParser;

            p.addParamValue('blockSource','',@ischar);
            p.addParamValue('refBlkSource','',@ischar);
            p.addParamValue('modelSource','',@ischar);
            p.addParamValue('signalLabel','',@ischar);
            p.addParamValue('timeVarName','',@ischar);
            p.addParamValue('portIndex',[],@(x)(isempty(x)||isnumeric(x)));
            p.addParamValue('isFirstDimensionTime',false,@(x)(islogical(x)||...
            isscalar(x)));
            p.addParamValue('timeValue',[],@(x)(isvector(x)||isreal(x)));
            p.addParamValue('metaData',[],@(x)true);
            p.addParamValue('busesPrefixForLabel','',@ischar);
            p.parse(varargin{:});
            results=p.Results;


            blockSource=results.blockSource;
            if isempty(results.refBlkSource)
                refBlkSource=blockSource;
            else
                refBlkSource=results.refBlkSource;
            end
            modelSource=results.modelSource;
            signalLabel=results.signalLabel;
            portIndex=results.portIndex;
            timeVarName=results.timeVarName;
            isFirstDimensionTime=results.isFirstDimensionTime;
            timeValue=results.timeValue;
            metaData=results.metaData;
            isStateOrOutput=~isempty(metaData);
            busesPrefixForLabel=results.busesPrefixForLabel;


            isVarAdded=true;

            interface=Simulink.sdi.internal.Framework.getFramework();


            if this.CheckForStreamedSignal&&this.isLoggedAndVisualized(VarValue)
                isVarAdded=false;


            elseif Simulink.sdi.internal.Util.isMATLABTimeseries(VarValue)
                this.AddMATLABTimeseries(VarName,VarValue,blockSource,...
                modelSource,portIndex,signalLabel,refBlkSource,busesPrefixForLabel);


            elseif interface.isSLDVData(VarValue)
                this.AddSLDVData(VarName,VarValue);


            elseif Simulink.sdi.internal.Util.isSimulinkTimeseries(VarValue)
                this.AddSimulinkTimeseries(VarName,VarValue);


            elseif Simulink.sdi.internal.Util.isSimulationOutput(VarValue)
                this.AddSimulationOutput(VarName,VarValue,varargin{:});


            elseif Simulink.sdi.internal.Util.isStructureWithTime(VarValue)
                this.addStructureWithOrWithoutTime(VarName,VarValue,...
                busesPrefixForLabel);


            elseif Simulink.sdi.internal.Util.isStructureWithoutTime(VarValue)
                this.addStructureWithOrWithoutTime(VarName,VarValue,...
                busesPrefixForLabel,timeVarName);


            elseif Simulink.sdi.internal.Util.isSimulationDataSet(VarValue)
                this.addSimulationDataSet(VarName,VarValue);


            elseif Simulink.sdi.internal.Util.isSimulationDataElement(VarValue)
                this.addSimulationDataElement(VarName,VarValue,busesPrefixForLabel);


            elseif Simulink.sdi.internal.Util.isModelDataLogs(VarValue)...
                ||Simulink.sdi.internal.Util.isSubsysDataLogs(VarValue)...
                ||Simulink.sdi.internal.Util.isScopeDataLogs(VarValue)...
                ||Simulink.sdi.internal.Util.isTSArray(VarValue)...
                ||Simulink.sdi.internal.Util.isStateflowDataLogs(VarValue)
                this.addModelDataLogs(VarName,VarValue);


            elseif isstruct(VarValue)
                indices=find(VarName=='.',1,'last');
                if~isempty(indices)
                    rightHandSide=VarName(indices(end)+1:end);
                else
                    rightHandSide=VarName;
                end
                if~isempty(busesPrefixForLabel)
                    busesPrefixForLabel=[busesPrefixForLabel,'.',rightHandSide];
                else
                    bpath=Simulink.SimulationData.BlockPath.manglePath(blockSource);
                    pos=strfind(bpath,'/');
                    if~isempty(pos)
                        bpath=bpath(pos+1:end);
                    end
                    if~isempty(bpath)&&portIndex>0
                        busPrefix=sprintf('%s:%d',bpath,portIndex);
                        busesPrefixForLabel=[busPrefix,'.',rightHandSide];
                    else
                        busesPrefixForLabel=rightHandSide;
                    end
                end

                this.addMATLABStructure(VarName,VarValue,blockSource,modelSource,...
                portIndex,signalLabel,refBlkSource,busesPrefixForLabel);



            elseif isFirstDimensionTime
                this.addFirstDimensionTimeArrayData(VarName,VarValue,modelSource,...
                blockSource);


            elseif isStateOrOutput
                this.addStateOrOutputArrayData(VarName,timeVarName,...
                metaData);



            elseif isnumeric(VarValue)&&(~isempty(timeVarName)&&~isempty(modelSource))...
                &&~isempty(blockSource)
                this.addNumericDataWithTime(VarName,VarValue,timeVarName,...
                modelSource,blockSource,timeValue,...
                signalLabel)
            elseif Simulink.sdi.internal.Util.isCoderExecutionTime(VarValue)
                this.addCoderExecutionTime(VarName,VarValue);
            elseif Simulink.sdi.internal.Util.isCoderExecutionTimeSection(VarValue)
                this.addCoderExecutionTimeSection(VarName,VarValue);
            else
                isVarAdded=false;
            end
        end




        function addNumericDataWithTime(this,VarName,VarValue,timeVarName,...
            modelName,blockSource,timeValue,signalLabel)

            if strcmp(VarName,timeVarName)
                return;
            end


            NewOutput=Simulink.sdi.internal.SimOutputExplorerOutput;
            if isempty(timeValue)
                timeVal=evalin('base',timeVarName);
            else
                timeVal=timeValue;
            end



            if isempty(timeVal)||~isnumeric(timeVal)||~isvector(timeVal)
                return;
            end


            timeLength=length(timeVal);


            dataDim=size(VarValue);



            index=find(dataDim==timeLength,1);



            if isempty(index)||~(index==1||index==length(dataDim))
                return;
            end


            TimeDim=index;


            if index==1
                SampleDims=dataDim(2:end);
            else
                SampleDims=dataDim(1:end-1);
            end


            NewOutput.BlockSource=blockSource;
            NewOutput.ModelSource=modelName;
            if isempty(signalLabel)
                NewOutput.SignalLabel=' ';
            else
                NewOutput.SignalLabel=signalLabel;
            end


            indices=strfind(VarName,'(');
            if~isempty(indices)
                if indices(end)>1
                    NewOutput.RootSource=VarName(1:indices(end)-1);
                else
                    NewOutput.RootSource='';
                end
                NewOutput.RootSource=[NewOutput.RootSource,'.',VarName(indices(end):end)];
            else
                NewOutput.RootSource=VarName;
            end
            NewOutput.TimeSource=timeVarName;
            NewOutput.DataSource=VarName;
            NewOutput.TimeValues=timeVal;
            NewOutput.DataValues=VarValue;
            NewOutput.TimeDim=TimeDim;
            NewOutput.SampleDims=SampleDims;
            NewOutput.SID=[];


            this.AddOutput(NewOutput);
        end



        function addFirstDimensionTimeArrayData(this,varName,varValue,modelSource,...
            blockSource)

            sz=size(varValue);

            if length(sz)~=2
                return;
            end

            cols=sz(2);

            timeV=[varName,'(:,1)'];
            timeVal=varValue(:,1);
            for i=2:cols
                vName=[varName,'(:,',num2str(i),')'];
                vVal=varValue(:,i);
                this.ExploreVariable(vName,vVal,'timeVarName',timeV,...
                'modelSource',modelSource,'blockSource',...
                blockSource,'timeValue',timeVal);
            end
        end


        function addStateOrOutputArrayData(this,VarName,timeVarName,mData)

            if~isfield(mData,'MetaData')
                return;
            end
            timeVarName1=timeVarName;
            metaData=mData.MetaData;


            numSignals=length(metaData);

            VarValue=Simulink.sdi.internal.Util.baseWorkspaceValuesForNames(VarName);
            numVars=length(VarValue);
            if numVars>1



                if(numVars~=numSignals)

                end
            end


            count=1;
            varVals=VarValue{1};
            for i=1:numSignals

                width=metaData(i).Width;
                for j=1:width
                    blockPath=metaData(i).BlockPath;
                    model=strtok(blockPath,'/');
                    signalLabel=metaData(i).SignalName;



                    if numVars>1
                        tempVar=VarValue{i};
                        if isempty(tempVar)||~isnumeric(tempVar)
                            continue;
                        end
                        varValues=Simulink.sdi.internal.SimOutputExplorer.getDataColumn(tempVar,j);
                        varName=[VarName{i},'(:,',num2str(j),')'];
                    else

                        if isempty(varVals)||~isnumeric(varVals)
                            continue;
                        end
                        varValues=Simulink.sdi.internal.SimOutputExplorer.getDataColumn(varVals,count);
                        varName=[VarName{1},'(:,',num2str(count),')'];
                    end


                    count=count+1;
                    if mData.Final
                        varValues=varValues(end);
                        timeVarName1=timeVarName;
                        timeV=evalin('base',timeVarName);

                        this.ExploreVariable(varName,varValues,'timeVarName',...
                        timeVarName1,'blockSource',blockPath,...
                        'modelSource',model,'signalLabel',...
                        signalLabel,'timeValue',timeV(end));
                    else

                        this.ExploreVariable(varName,varValues,'timeVarName',...
                        timeVarName1,'blockSource',blockPath,...
                        'modelSource',model,'signalLabel',...
                        signalLabel);
                    end
                end
            end
        end

        function AddSLDVData(this,varName,varValue)
            NewOutput=Simulink.sdi.internal.SimOutputExplorerOutput;
            NewOutput.RootSource=varName;
            NewOutput.TimeSource=varName;
            NewOutput.DataSource=varName;
            NewOutput.SignalLabel=varName;
            NewOutput.rootDataSrc=varName;
            NewOutput.SLDVData=varValue;
            NewOutput.ModelSource=varValue.ModelInformation.Name;
            this.AddOutput(NewOutput);
        end

        function result=cleanDataSource(~,dataSource,signalLabel)

            [substr,sind,eind]=regexp(dataSource,'getElement\(.*?\).Values',...
            'match','start','end');%#ok
            toRemoveInds=zeros(length(eind)*7,1);
            for i=1:length(eind)
                endIndex=eind(i);
                toRemoveInds(7*i-6:7*i)=endIndex-6:endIndex;
            end

            dataSource(toRemoveInds)='';
            [substr,sind,eind]=regexp(dataSource,'getElement\(''.*?\'')',...
            'match','start','end');%#ok
            toRemoveInds=zeros(length(sind)*14,1);
            for j=1:length(sind)
                startInd=sind(j);
                endInd=eind(j);
                toRemoveInds(14*j-13:14*j)=[startInd:startInd+11,endInd-1:endInd];
            end
            dataSource(toRemoveInds)='';



            expression='getElement\((\d*)\)';
            if~isempty(signalLabel)
                replace=regexprep(signalLabel,'\n',' ');
            else
                replace='';
            end
            dataSource=regexprep(dataSource,expression,replace);

            result=dataSource;
        end

        function AddMATLABTimeseries(this,arrayName,varArray,varargin)
            numTS=length(varArray);
            for arrayIdx=1:numTS
                VarValue=varArray(arrayIdx);
                if numTS>1
                    VarName=sprintf('%s(%d)',arrayName,arrayIdx);
                else
                    VarName=arrayName;
                end


                NewOutput=Simulink.sdi.internal.SimOutputExplorerOutput;


                numOptArgs=length(varargin);


                NewOutput.BlockSource=' ';
                NewOutput.ModelSource=' ';
                NewOutput.SignalLabel=' ';




                if numOptArgs>1
                    NewOutput.BlockSource=varargin{1};
                    NewOutput.ModelSource=varargin{2};
                end

                if numOptArgs>=4
                    NewOutput.PortIndex=varargin{3};
                    NewOutput.SignalLabel=varargin{4};
                end

                if numOptArgs>=5
                    refBlkSource=varargin{5};
                else
                    refBlkSource=NewOutput.BlockSource;
                end


                if numOptArgs>=6
                    NewOutput.busesPrefixForLabel=varargin{6};
                else
                    NewOutput.busesPrefixForLabel='';
                end

                if~isempty(VarValue.Name)&&~isempty(NewOutput.busesPrefixForLabel)
                    NewOutput.busesPrefixForLabel=[NewOutput.busesPrefixForLabel,'.',VarValue.Name];
                end

                if isempty(NewOutput.SignalLabel)
                    NewOutput.SignalLabel=VarValue.Name;
                end
                NewOutput.AlwaysUseSignalLabel=true;


                [TimeDim,SampleDims]=this.GetTSDims(VarValue);


                pieces=regexp(VarName,sprintf('\n'),'split');


                if length(pieces)>1
                    varName1=pieces{2};
                else
                    varName1=VarName;
                end
                NewOutput.RootSource=varName1;
                NewOutput.TimeSource=[varName1,'.Time'];
                NewOutput.DataSource=[varName1,'.Data'];
                NewOutput.TimeValues=double(VarValue.Time);
                NewOutput.DataValues=VarValue.Data;
                NewOutput.TimeDim=TimeDim;
                NewOutput.SampleDims=SampleDims;
                NewOutput.rootDataSrc=this.cleanDataSource(VarName,NewOutput.SignalLabel);
                NewOutput.SampleTimeString=Simulink.sdi.internal.SimOutputExplorer.getSampleTimeString(VarValue);

                if ischar(VarValue.DataInfo.Units)
                    NewOutput.Unit=VarValue.DataInfo.Units;
                elseif isa(VarValue.DataInfo.Units,'Simulink.SimulationData.Unit')
                    NewOutput.Unit=VarValue.DataInfo.Units.Name;
                end


                try
                    interface=Simulink.sdi.internal.Framework.getFramework();
                    NewOutput.SID=interface.getSID(refBlkSource,true);
                catch ME %#ok
                    NewOutput.SID=[];
                end


                NewOutput.interpolation=VarValue.getinterpmethod();


                this.AddOutput(NewOutput);
            end
        end

        function AddSimulinkTimeseries(this,VarName,VarValue)
            interface=Simulink.sdi.internal.Framework.getFramework();
            NewOutput=interface.addSimulinkTimeseries(this,VarName,VarValue);


            this.AddOutput(NewOutput);
        end

        function addSimulationDataElement(this,varName,varValue,varargin)

            blockSource=' ';
            refBlkSource=' ';
            modelSource=' ';
            portIndex=[];


            if Simulink.sdi.internal.Util.isField(varValue,'BlockPath')

                len=varValue.BlockPath.getLength;








                if(len>0)
                    blockSource=Simulink.sdi.internal.SimOutputExplorer.getMdlRefBlockPath(varValue.BlockPath);
                    refBlkSource=varValue.BlockPath.getBlock(len);
                    modelSource=varValue.BlockPath.getBlock(1);

                elseif Simulink.sdi.internal.Util.isField(varValue,'DSMWriterBlockPaths')...
                    &&~isempty(varValue.DSMWriterBlockPaths)

                    modelSource=varValue.DSMWriterBlockPaths.getBlock(1);
                end


                modelSource=strtok(modelSource,'/');
            end


            if Simulink.sdi.internal.Util.isField(varValue,'PortIndex')

                portIndex=varValue.PortIndex;
            end

            busesPrefixForLabel='';
            if length(varargin)>=1
                busesPrefixForLabel=varargin{1};
            end

            varName=[varName,'.','Values'];
            varName=strrep(varName,sprintf('\n'),['.Values',sprintf('\n')]);


            signalName=varValue.Name;


            if~Simulink.sdi.internal.Util.isStateflowSimulationData(varValue)&&...
                Simulink.sdi.internal.Util.isMATLABTimeseries(varValue.Values)
                if~isempty(varValue.Values.Name)
                    signalName=varValue.Values.Name;
                end
            end

            if isempty(signalName)&&isprop(varValue,'PropagatedName')
                signalName=varValue.PropagatedName;
            end




            this.addSimulationDataIterator(varName,varValue.Values,blockSource,...
            modelSource,portIndex,signalName,...
            refBlkSource,busesPrefixForLabel);
        end

        function addSimulationDataSet(this,arrayName,varArray)

            numDatasets=length(varArray);
            for arrayIdx=1:numDatasets

                varValue=varArray(arrayIdx);
                if numDatasets>1
                    varName=sprintf('%s(%d)',arrayName,arrayIdx);
                else
                    varName=arrayName;
                end
                count=varValue.getLength;








                elementNames=varValue.getElementNames();
                for i=1:count
                    ithScopeVarValue=varValue.getElement(i);
                    if(isstruct(ithScopeVarValue)&&~isempty(elementNames{i}))
                        ithScopeVarName=elementNames{i};
                    else
                        ithScopeVarName=[varName,'.','getElement(',num2str(i),')'];
                    end



                    this.ExploreVariable(ithScopeVarName,ithScopeVarValue);
                end
            end
        end

        function addStructureWithOrWithoutTime(this,VarName,VarValue,varargin)

            timeVarName='';
            timeVarValue=[];
            if~isempty(varargin)
                busesPrefixForLabel=varargin{1};
                if length(varargin)>=2
                    timeVarName=varargin{2};
                    try
                        timeVarValue=evalin('base',timeVarName);
                    catch ME %#ok
                        return;
                    end
                end
            end

            for i=1:length(VarValue.signals)

                IthIndexStr=sprintf('%d',i);
                IthSignalSource=[VarName,'.signals(',IthIndexStr,')'];
                IthSignalValue=VarValue.signals(i);

                if(isfield(IthSignalValue,'valueDimensions')...
                    &&(~isempty(IthSignalValue.valueDimensions)))

                end


                [TimeDim,SampleDims]=this.GetStructWTimeDims(IthSignalValue);


                NewOutput=Simulink.sdi.internal.SimOutputExplorerOutput;


                NewOutput.RootSource=VarName;



                NewOutput.RootSource=[NewOutput.RootSource,'.',IthSignalValue.label];


                if isempty(timeVarName)
                    NewOutput.TimeSource=[VarName,'.time'];
                    NewOutput.TimeValues=VarValue.time;
                else
                    NewOutput.TimeSource=timeVarName;
                    NewOutput.TimeValues=timeVarValue;
                end

                NewOutput.DataSource=[IthSignalSource,'.values'];
                NewOutput.DataValues=IthSignalValue.values;


                if isfield(IthSignalValue,'blockName')
                    NewOutput.BlockSource=IthSignalValue.blockName;

                elseif isfield(VarValue,'blockName')
                    NewOutput.BlockSource=VarValue.blockName;
                end

                if isempty(NewOutput.BlockSource)
                    NewOutput.BlockSource=' ';
                end

                NewOutput.ModelSource=strtok(NewOutput.BlockSource,'/');
                NewOutput.SignalLabel=IthSignalValue.label;
                NewOutput.AlwaysUseSignalLabel=true;


                bIsState=isfield(IthSignalValue,'stateName');
                if bIsState
                    if~isempty(strtrim(IthSignalValue.stateName))
                        NewOutput.SignalLabel=IthSignalValue.stateName;
                    else
                        [~,~,blkName]=Simulink.sdi.internal.Util.helperSplitString(NewOutput.BlockSource);
                        NewOutput.SignalLabel=sprintf('%s:%s',blkName,IthSignalValue.label);
                    end


                    if strcmpi(IthSignalValue.label,'CSTATE')
                        NewOutput.interpolation='linear';
                    end
                end

                NewOutput.TimeDim=TimeDim;
                NewOutput.SampleDims=SampleDims;
                NewOutput.PortIndex=[];


                if(isfield(IthSignalValue,'inReferencedModel')&&...
                    IthSignalValue.inReferencedModel)
                    [~,remain]=strtok(NewOutput.BlockSource,'|');

                    if~isempty(remain)
                        remain(1)='';
                        NewOutput.BlockSource=remain;
                    end
                end

                try
                    interface=Simulink.sdi.internal.Framework.getFramework();
                    NewOutput.SID=interface.getSID(NewOutput.BlockSource);
                catch ME %#ok
                    NewOutput.SID=[];
                end

                if~isempty(busesPrefixForLabel)
                    NewOutput.busesPrefixForLabel=[busesPrefixForLabel,'.',NewOutput.SignalLabel];
                end


                this.AddOutput(NewOutput);
            end
        end







        function addMATLABStructure(this,varName,varValue,blockSource,modelSource,...
            portIndex,signalName,refBlkSource,busesPrefixForLabel)

            fields=fieldnames(varValue);


            count=length(fields);

            lenStructArray=numel(varValue);
            subscript=cell(1,length(size(varValue)));

            if isempty(busesPrefixForLabel)
                busesPrefixForLabel=signalName;
            end

            oldOutputs=this.Outputs;
            for j=1:lenStructArray
                [subscript{:}]=ind2sub(size(varValue),j);
                subscriptwithcomma=num2str(subscript{1});

                for s=2:length(subscript)
                    subscriptwithcomma=[subscriptwithcomma,',',num2str(subscript{s})];%#ok
                end

                if(lenStructArray>1&&~isempty(busesPrefixForLabel))
                    loc_busesPrefixForLabel=[busesPrefixForLabel,'(',subscriptwithcomma,')'];
                else
                    loc_busesPrefixForLabel=busesPrefixForLabel;
                end

                for i=1:count
                    if(lenStructArray>1)

                        ithScopeVarName=[varName,'(',subscriptwithcomma,').',fields{i}];
                    else
                        ithScopeVarName=[varName,'.',fields{i}];
                    end

                    ithScopeVarValue=varValue(j).(fields{i});


                    if~(Simulink.sdi.internal.Util.isSDISupportedType(ithScopeVarValue)||...
                        isstruct(ithScopeVarValue))
                        continue;
                    end

                    numVars=numel(ithScopeVarValue);
                    subscript1=cell(1,length(size(ithScopeVarValue)));

                    for k=1:numVars

                        if numVars==1
                            var=ithScopeVarValue;
                            scopeVarName=ithScopeVarName;
                        else
                            [subscript1{:}]=ind2sub(size(ithScopeVarValue),k);
                            subscriptwithcomma1=num2str(subscript1{1});

                            for s=2:length(subscript1)
                                subscriptwithcomma1=[subscriptwithcomma1,',',num2str(subscript1{s})];%#ok
                            end
                            var=ithScopeVarValue(k);
                            scopeVarName=[ithScopeVarName,'(',subscriptwithcomma1,')'];
                        end

                        this.ExploreVariable(scopeVarName,var,...
                        'modelSource',modelSource,...
                        'blockSource',blockSource,...
                        'refBlkSource',refBlkSource,...
                        'signalLabel',signalName,...
                        'portIndex',portIndex,...
                        'busesPrefixForLabel',loc_busesPrefixForLabel);
                    end
                end
            end
            newPlusOld=this.Outputs;
            newOutput=setdiff(newPlusOld,oldOutputs);
            if~isempty(newOutput)
                [~,idx]=find(diff(char(newOutput.rootDataSrc)),1);
                if length(varValue)==1

                    commonRoot=regexprep(newOutput(1).rootDataSrc,'\.\w*$','');

                    commonRoot=regexprep(commonRoot,'find\(''(\w+)''\)','$1');
                else

                    commonRoot=regexprep(newOutput(1).rootDataSrc(1:min(idx)-1),'(\([\d,]*)$','');
                end

                delim='#';
                commonRoot=strjoin(Simulink.sdi.internal.Util.helperConstructRootSrc(commonRoot),delim);

                this.StructDimsMap.insert(commonRoot,int32(size(varValue)));
            end

        end



        function addSimulationDataIterator(this,varName,varValue,blockSource,...
            modelSource,portIndex,signalName,refBlkSource,busesPrefixForLabel)


            if Simulink.sdi.internal.Util.isMATLABTimeseries(varValue)
                this.AddMATLABTimeseries(varName,varValue,blockSource,modelSource,...
                portIndex,signalName,refBlkSource,busesPrefixForLabel);
            elseif isstruct(varValue)
                this.addMATLABStructure(varName,varValue,blockSource,modelSource,...
                portIndex,signalName,refBlkSource,busesPrefixForLabel);
            end
        end

        function addModelDataLogs(this,VarName,VarValue)

            VarList=whos(VarValue);

            for i=1:length(VarList)

                IthScopeVar=VarList(i);


                SafeVarName=this.SafeLogFieldName(IthScopeVar.name);


                IthScopeVarName=[VarName,'.',SafeVarName];
                try
                    IthScopeVarValue=eval(['VarValue.(''',SafeVarName,''')']);
                catch
                    IthScopeVarValue=eval(['VarValue.',SafeVarName]);
                end


                this.ExploreVariable(IthScopeVarName,IthScopeVarValue);
            end
        end

        function AddSimulationOutput(this,arrayName,varArray,varargin)


            numDatasets=length(varArray);
            for arrayIdx=1:numDatasets

                VarValue=varArray(arrayIdx);
                if numDatasets>1
                    VarName=sprintf('%s(%d)',arrayName,arrayIdx);
                else
                    VarName=arrayName;
                end


                SimOutVars=VarValue.who;
                for i=1:length(SimOutVars)

                    IthVarName=SimOutVars(i);
                    IthVarSource=[VarName,'.get(''',char(IthVarName),''')'];
                    IthVarValue=VarValue.get(char(IthVarName));
                    if isfield(IthVarValue,'Name')
                        IthVarValue.Name=char(IthVarName);
                    end


                    this.ExploreVariable(IthVarSource,IthVarValue,varargin{:});
                end
            end
        end

        function addCoderExecutionTimeSection(this,varName,varValue)
            len=length(varValue);
            for i=1:len
                if varValue(i).getTraceInfo.isTask&&...
                    this.CheckForStreamedSignal


                    continue;
                end

                newOutput=Simulink.sdi.internal.SimOutputExplorerOutput;

                newOutput.ModelSource=varValue(i).getTraceInfo.getOriginalModelRef;
                newOutput.SignalLabel=varValue(i).getSignalNameForSDI;
                newOutput.AlwaysUseSignalLabel=true;
                newOutput.RootSource=varName;
                newOutput.TimeSource=[varName,'(',num2str(i),').Time'];
                newOutput.TimeValues=varValue(i).Time;
                if~isempty(newOutput.TimeValues)
                    [newOutput.DataValues,sourcePropName]=varValue(i)...
                    .getExecTimeDataForSDI;
                    newOutput.DataSource=...
                    [varName,'(',num2str(i),').',sourcePropName];
                else

                    newOutput.DataValues=[];
                    newOutput.DataSource=[];
                end
                newOutput.TimeDim=1;
                newOutput.SampleDims=[1,1];
                newOutput.rootDataSrc=varName;
                newOutput.SID=getPrimaryCallSiteSID...
                (varValue(i).getTraceInfo);
                try
                    newOutput.metaData=int2str(varValue(i).getIdUint64);
                catch me %#ok                    
                end

                try
                    interface=Simulink.sdi.internal.Framework.getFramework();
                    newOutput.BlockSource=interface.getFullName(newOutput.SID);
                catch me %#ok
                    newOutput.BlockSource=newOutput.ModelSource;
                end


                newOutput.interpolation='zoh';


                this.AddOutput(newOutput);
            end
        end

        function addCoderExecutionTime(this,varName,varValue)
            len=length(varValue);
            for i=1:len
                section=varValue(i).Sections;
                if len>1
                    varNameForSection=[varName,'(',num2str(i),').Sections'];
                else

                    varNameForSection=[varName,'.Sections'];
                end

                this.ExploreVariable(varNameForSection,section);
            end
        end

        function ret=isLoggedAndVisualized(~,varValue)
            ret=false;
            if isa(varValue,'Simulink.SimulationData.Signal')
                import Simulink.SimulationData.BlockPath;
                bpath=varValue.BlockPath;
                if getLength(bpath)
                    mdl=BlockPath.getModelNameForPath(bpath.getBlock(1));

                    eng=Simulink.sdi.Instance.engine;
                    runID=eng.getCurrentStreamingRunID(mdl);
                    if runID
                        ret=eng.sigRepository.isSignalStreamed(...
                        runID,bpath.convertToCell(),varValue.PortIndex);
                    end
                end
            end
        end

    end

    methods(Static=true)
        function ret=getSampleTimeString(ts)
            ret='';
            if~strcmpi(ts.DataInfo.Interpolation.Name,'zoh')
                ret=message('simulation_data_repository:sdr:ContinuousSampleTime').getString();
            elseif ismethod(ts.TimeInfo,'isUniform')&&ts.TimeInfo.isUniform
                ret=num2str(ts.TimeInfo.Increment);
            end
        end

        function[TimeDim,SampleDims]=GetTSDims(ts)

            tssize=size(ts.Data);


            if ts.IsTimeFirst
                TimeDim=1;
                SampleDims=tssize(2:end);

            elseif length(ts.Time)==1
                TimeDim=[];
                SampleDims=tssize;
            else

                TimeDim=ndims(ts.Data);
                SampleDims=tssize(1:end-1);
            end
        end

        function[TimeDim,SampleDims]=GetStructWTimeDims(ts)
            SampleDims=ts.dimensions;
            if isscalar(SampleDims)
                TimeDim=1;
            else
                TimeDim=ndims(ts.values);
            end
        end

        function result=SafeLogFieldName(LogFieldName)

            result=LogFieldName;


            NameLength=length(result);


            IsDynamicField=(NameLength>=2)...
            &&(result(1)=='(')...
            &&(result(2)=='''');

            if IsDynamicField

                CR=char(10);



                result=strrep(LogFieldName,CR,'\n');






                if length(LogFieldName)~=length(result)


                    result(1)='';
                    result(end)='';

                    pieces=regexp(result,'\\n','split');

                    newString=['([',pieces{1}];
                    for i=2:length(pieces)
                        newString=[newString,''' sprintf(''\n'') ''',pieces{i}];%#ok
                    end
                    result=[newString,'])'];
                end
            end
        end

        function ret=getMdlRefBlockPath(bpath)
            import Simulink.SimulationData.BlockPath;
            ret=getBlock(bpath,1);
            len=getLength(bpath);
            for idx=2:len
                refPath=getBlock(bpath,idx);
                mdl=BlockPath.getModelNameForPath(refPath);
                newStart=length(mdl)+1;
                ret=strcat(ret,refPath(newStart:end));
            end
        end

        function ret=getDataColumn(origData,idx)
            if ismatrix(origData)
                ret=origData(:,idx);
            else
                varSz=size(origData);
                sampleDims=varSz(1:end-1);
                dimIdx=cell(1,ndims(origData)-1);
                [dimIdx{:}]=ind2sub(sampleDims,idx);
                s.type='()';
                s.subs=[dimIdx,{':'}];
                ret=subsref(origData,s);
            end
        end

    end

    properties(Access='private')
        CheckForStreamedSignal=true;
    end
end



