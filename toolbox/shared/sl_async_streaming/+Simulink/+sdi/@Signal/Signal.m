classdef(CaseInsensitiveProperties=true)Signal<matlab.mixin.SetGet&matlab.mixin.CustomDisplay


















































































































    properties(GetAccess='public',SetAccess='private')
ID
    end

    properties(GetAccess='public',SetAccess='private',Dependent)
RunID
    end

    properties(Access='public',Dependent=true)
Name
    end

    properties(GetAccess='public',SetAccess='private',Dependent)
Domain
    end

    properties(Access='public',Dependent=true)
Description
DisplayUnits
DisplayScaling
DisplayOffset
    end

    properties(GetAccess='public',SetAccess='private',Dependent)
StoredUnits
DataType
Complexity
    end

    properties(Access='public',Dependent)
ComplexFormat
    end

    properties(GetAccess='public',SetAccess='public',Dependent)
SampleTime
    end

    properties(GetAccess='public',SetAccess='private',Dependent)
Model
BlockPath
FullBlockPath
BlockName
    end

    properties(GetAccess='public',SetAccess='public',Dependent)
PortIndex
    end

    properties(GetAccess='public',SetAccess='private',Dependent)
Dimensions
Channel
NumPoints
    end

    properties(Access='public',Dependent)
Checked
LineColor
LineDashed
LineWidth
InterpMethod

AbsTol
RelTol
TimeTol
OverrideGlobalTol
SyncMethod

Values
    end

    properties(GetAccess='public',SetAccess='private',Dependent)
RootSource
TimeSource
DataSource
Children
    end


    properties(GetAccess='public',Hidden,Dependent)

SignalLabel
ModelSource
BlockSource
SampleDims
DataValues


SourceType
TimeDim
SID
RootDataSource
InstrumentedSigID
SampleSizeInBytes
Units

LeadingTol
LaggingTol


Marker
    end

    properties(GetAccess='public',SetAccess='private',Hidden,Dependent)
ImageLayout
ImageColorFormat
    end


    methods


        function this=Signal(repo,signalID,bSkipValidation)

            if nargin>2&&bSkipValidation
                this.Repo_=repo;
                this.ID=signalID;
            else
                if isobject(repo)&&isprop(repo,'sigRepository')
                    repo=repo.sigRepository;
                end
                if~isa(repo,'sdi.Repository')
                    error(message('SDI:sdi:InvalidSDIEngine'));
                end
                if~repo.isValidSignal(signalID)
                    error(message('SDI:sdi:InvalidSignalID'));
                end

                this.Repo_=repo;
                this.ID=signalID;
            end
        end


        function value=get.RunID(this)
            value=this.Repo_.getSignalRunID(this.ID);
        end


        function value=get.RootSource(this)
            value=this.Repo_.getSignalRootSource(this.ID);
        end


        function value=get.SourceType(this)
            value=this.Repo_.getSignalSourceType(this.ID);
        end


        function value=get.TimeSource(this)
            value=this.Repo_.getSignalTimeSource(this.ID);
        end


        function value=get.DataSource(this)
            value=this.Repo_.getSignalDataSource(this.ID);
        end


        function ret=get.Children(this)
            ret=Simulink.sdi.Signal.empty();
            childIDs=this.Repo_.getSignalChildren(this.ID);
            for idx=1:length(childIDs)
                ret(end+1)=Simulink.sdi.Signal(this.Repo_,childIDs(idx));%#ok<AGROW>
            end
        end


        function value=get.Values(this)
            value=this.export();
        end

        function set.Values(this,value)
            validateattributes(value,{'struct','timeseries'},{'scalar'});
            valStruct.Time=value.Time;
            if isa(value,'timeseries')&&value.TimeInfo.isUniform
                valStruct.CompressedTimeInc=value.TimeInfo.Increment;
            end

            childIDs=this.Repo_.getSignalChildren(this.ID);
            if~isempty(childIDs)
                error(message('SDI:sdi:SetCompositeValues'));
            end


            this.cacheDeinterleavedData(false);


            keepDimensions=true;
            if~strcmp(this.Repo_.getSignalTmMode(this.ID),'none')
                keepDimensions=false;
            end



            id=this.ID;
            info=this.Repo_.getSignalComplexityAndLeafPath(this.ID);
            if info.IsComplex

                if isempty(this.Children)
                    id=this.Repo_.getSignalParent(this.ID);
                end
                sigWithData=Simulink.sdi.getSignal(id);
                curVal=sigWithData.getComplexDataForInterleaving();
                bSzMatch=length(curVal.Time)==length(value.Time);


                if id==this.ID||~info.IsImagPart


                    if isreal(value.Data)
                        if bSzMatch
                            value.Data=complex(value.Data,imag(curVal.Data));
                        else
                            value.Data=complex(value.Data,0);
                        end
                    end
                else

                    if bSzMatch
                        value.Data=complex(real(curVal.Data),value.Data);
                    else
                        value.Data=complex(0,value.Data);
                    end
                end


                id=sigWithData.Children(1).ID;
            end


            valStruct.Data=value.Data;
            locSetSignalDataValues(this.Repo_,id,valStruct,keepDimensions);
        end

        function value=get.DataValues(this)




            id=getIDForData(this);
            Simulink.HMI.synchronouslyFlushWorkerQueue(this.Repo_);
            value=this.Repo_.getSignalDataValues(id);
        end

        function set.DataValues(this,value)
            this.Values=value;
        end


        function value=get.BlockPath(this)
            props=this.Repo_.getSignalExportProps(this.ID);
            bpath=this.Repo_.getSignalBlockSource(this.ID);
            if~isempty(props.BlockPath)
                bpath=props.BlockPath{end};
            end
            ssid=this.Repo_.getSignalSID(this.ID);
            interface=Simulink.sdi.internal.Framework.getFramework();
            value=interface.getBlockSource(bpath,ssid);
            value=Simulink.SimulationData.BlockPath.manglePath(value);
        end

        function value=get.BlockSource(this)
            value=this.BlockPath;
        end


        function value=get.FullBlockPath(this)
            value=this.Repo_.getSignalBlockSource(this.ID);
        end


        function value=get.BlockName(this)
            value=this.Repo_.getSignalBlockName(this.ID);
        end


        function value=get.Model(this)
            value=this.Repo_.getSignalModelSource(this.ID);
        end

        function value=get.ModelSource(this)
            value=this.Model;
        end


        function value=get.Name(this)
            value=this.Repo_.getSignalLabel(this.ID);
        end

        function set.Name(this,value)
            validateattributes(value,{'string','char'},{})
            this.Repo_.setSignalLabel(this.ID,char(value));
            locOnPropChange('signalLabel',this.ID,char(value));
        end

        function value=get.SignalLabel(this)
            value=this.Name;
        end

        function set.SignalLabel(this,value)
            this.Name=value;
        end


        function value=get.Description(this)
            value=string(this.Repo_.getSignalDescription(this.ID));
        end

        function set.Description(this,value)
            validateattributes(value,{'string','char'},{})
            this.Repo_.setSignalDescription(this.ID,char(value));
            locOnPropChange('Description',this.ID,char(value));
        end


        function value=get.TimeDim(this)
            value=this.Repo_.getSignalTimeDim(this.ID);
        end


        function value=get.Dimensions(this)
            if this.Repo_.getSignalIsVarDims(this.ID)
                value='variable';
            else
                value=this.Repo_.getSignalSampleDims(this.ID);
            end
        end

        function value=get.SampleDims(this)
            value=this.Dimensions;
        end


        function value=get.PortIndex(this)
            value=this.Repo_.getSignalPortIndex(this.ID);
        end

        function set.PortIndex(this,value)
            this.Repo_.setSignalPortIndex(this.ID,value);
        end


        function value=get.Channel(this)
            value=this.Repo_.getSignalChannel(this.ID);
        end


        function value=get.Units(this)
            value=this.Repo_.getUnit(this.ID);
        end

        function set.Units(this,value)
            validateattributes(value,{'string','char'},{})
            this.Repo_.setUnit(this.ID,char(value));
            this.DisplayUnits=value;
            locOnPropChange('units',this.ID,char(value));
        end

        function value=get.DisplayUnits(this)
            value=this.Repo_.getDisplayUnit(this.ID);
        end

        function set.DisplayUnits(this,value)
            value=strtrim(value);
            validateattributes(value,{'string','char'},{})
            currStoredUnits=this.Repo_.getUnit(this.ID);
            try
                this.Repo_.setDisplayUnit(this.ID,char(value));
            catch me
                switch me.identifier
                case 'SDI:sdi:UnresolvedUnit'
                    warningMsg=getString(message('SDI:sdi:UnresolvedUnitCmdLine',value));
                    warningID=me.identifier;
                    warning(warningID,'%s',warningMsg);
                    this.Repo_.setUnit(this.ID,value);
                    locOnPropChange('units',this.ID,char(value));
                otherwise
                    throwAsCaller(me);
                end
            end
            locOnPropChange('displayUnits',this.ID,char(value));
            if isempty(currStoredUnits)

                locOnPropChange('units',this.ID,char(value));
            end
        end

        function value=get.StoredUnits(this)
            value=this.Repo_.getUnit(this.ID);
        end

        function set.StoredUnits(this,value)
            this.Units=value;
        end


        function value=get.DisplayScaling(this)
            value=this.Repo_.getDisplayScaling(this.ID);
        end

        function set.DisplayScaling(this,value)
            try
                validateattributes(value,{'numeric'},{'scalar','finite','real','nonzero'});
                locValidateAcceptableScalingAndOffsetDataType(this.DataType);
                this.Repo_.setDisplayScaling(this.ID,value);
                locOnPropChange('displayScaling',this.ID,value);
            catch me
                me.throwAsCaller();
            end
        end


        function value=get.DisplayOffset(this)
            value=this.Repo_.getDisplayOffset(this.ID);
        end

        function set.DisplayOffset(this,value)
            try
                validateattributes(value,{'numeric'},{'scalar','finite','real'});
                locValidateAcceptableScalingAndOffsetDataType(this.DataType);
                this.Repo_.setDisplayOffset(this.ID,value);
                locOnPropChange('displayOffset',this.ID,value);
            catch me
                me.throwAsCaller();
            end
        end


        function value=get.DataType(this)
            value=this.Repo_.getSignalDataTypeLabel(this.ID);
        end

        function set.DataType(this,value)
            validateattributes(value,{'string','char'},{})
            this.Repo_.setSignalDataType(this.ID,char(value));
            locOnPropChange('dataType',this.ID,char(value));
        end


        function value=get.Complexity(this)
            info=this.Repo_.getSignalComplexityAndLeafPath(this.ID);
            if info.IsComplex
                value="complex";
            else
                value="real";
            end
        end


        function value=get.ComplexFormat(this)
            info=this.Repo_.getSignalComplexityAndLeafPath(this.ID);
            switch info.IsMagPhase
            case 1
                value="magnitude-phase";
            case 2
                value="magnitude";
            case 3
                value="phase";
            otherwise
                value="real-imaginary";
            end
        end

        function set.ComplexFormat(this,val)
            try
                validateattributes(val,{'string','char'},{})
                val=char(val);

                if strcmpi(val,'magnitude-phase')||...
                    strcmpi(val,'polar')||...
                    strcmpi(val,getString(message('SDI:sdi:ComplexityFormatMPVal')))
                    magPhase=1;
                elseif strcmpi(val,'magnitude')||...
                    strcmpi(val,'mag')||...
                    strcmpi(val,getString(message('SDI:sdi:ComplexityFormatMagVal')))
                    magPhase=2;
                elseif strcmpi(val,'phase')||...
                    strcmpi(val,getString(message('SDI:sdi:ComplexityFormatPhaseVal')))
                    magPhase=3;
                else
                    magPhase=0;
                end
                this.Repo_.setSignalComplexFormat(this.ID,magPhase);


                switch magPhase
                case 1
                    actVal=getString(message('SDI:sdi:ComplexityFormatMPVal'));
                case 2
                    actVal=getString(message('SDI:sdi:ComplexityFormatMagVal'));
                case 3
                    actVal=getString(message('SDI:sdi:ComplexityFormatPhaseVal'));
                otherwise
                    actVal=getString(message('SDI:sdi:ComplexityFormatRIVal'));
                end
                locOnPropChange('complexFormat',this.ID,actVal);
            catch me
                me.throwAsCaller;
            end
        end


        function value=get.SampleTime(this)
            value=this.Repo_.getSignalSampleTimeLabel(this.ID);
        end

        function set.SampleTime(this,value)
            validateattributes(value,{'string','char'},{})
            this.Repo_.setSignalSampleTimeLabel(this.ID,char(value));
        end


        function value=get.SID(this)
            value=this.Repo_.getSignalSID(this.ID);
        end


        function value=get.AbsTol(this)
            value=this.Repo_.getSignalAbsTol(this.ID);
        end

        function set.AbsTol(this,value)
            try
                if~isscalar(value)&&prod(this.getSampleDimensions())>1



                    value=max(value,[],'all');
                end
                locValidateTolerance(value);
                this.Repo_.setSignalAbsTol(this.ID,value);
                locOnPropChange('abs',this.ID,value);
            catch me
                me.throwAsCaller();
            end
        end


        function value=get.RelTol(this)
            value=this.Repo_.getSignalRelTol(this.ID);
        end

        function set.RelTol(this,value)
            try
                if~isscalar(value)&&prod(this.getSampleDimensions())>1



                    value=max(value,[],'all');
                end
                locValidateTolerance(value);
                this.Repo_.setSignalRelTol(this.ID,value);
                locOnPropChange('rel',this.ID,value);
            catch me
                me.throwAsCaller();
            end
        end


        function value=get.TimeTol(this)
            value=this.Repo_.getSignalTimeTol(this.ID);
        end

        function set.TimeTol(this,value)
            this.Repo_.setSignalTimeTol(this.ID,value);
        end


        function value=get.LaggingTol(this)
            value=this.Repo_.getSignalBackwardTimeTol(this.ID);
        end

        function set.LaggingTol(this,value)
            this.Repo_.setSignalBackwardTimeTol(this.ID,value);
        end


        function value=get.Domain(this)
            domain=this.Repo_.getSignalDomainType(this.ID);
            value=Simulink.sdi.getDomainLabel(domain);
        end


        function value=get.LeadingTol(this)
            value=this.Repo_.getSignalForwardTimeTol(this.ID);
        end

        function set.LeadingTol(this,value)
            this.Repo_.setSignalForwardTimeTol(this.ID,value);
        end


        function value=get.OverrideGlobalTol(this)
            value=this.Repo_.getSignalOverrideGlobalTol(this.ID);
        end

        function set.OverrideGlobalTol(this,value)
            try
                validateattributes(value,{'numeric','logical'},{'scalar'});
                this.Repo_.setSignalOverrideGlobalTol(this.ID,value);
            catch me
                me.throwAsCaller();
            end
        end


        function value=get.SyncMethod(this)
            value=this.Repo_.getSignalSyncMethod(this.ID);
        end

        function set.SyncMethod(this,value)
            try
                validateattributes(value,{'string','char'},{})
                this.Repo_.setSignalSyncMethod(this.ID,char(value));
                locOnPropChange('sync',this.ID,char(value));
            catch me
                me.throwAsCaller();
            end
        end


        function value=get.InterpMethod(this)
            if this.Repo_.getSignalIsEventBased(this.ID)
                value='none';
            else
                value=this.Repo_.getSignalInterpMethod(this.ID);
            end
        end

        function set.InterpMethod(this,value)
            try
                validateattributes(value,{'string','char'},{})
                this.Repo_.setSignalInterpMethod(this.ID,char(value));
                locOnPropChange('interp',this.ID,char(value));
            catch me
                me.throwAsCaller();
            end
        end


        function value=get.LineColor(this)
            value=this.Repo_.getSignalLineColor(this.ID);
        end

        function set.LineColor(this,value)
            try
                this.Repo_.setSignalLineColor(this.ID,value);
                locOnPropChange('color',this.ID,value);
            catch me
                me.throwAsCaller;
            end
        end


        function value=get.LineDashed(this)
            value=this.Repo_.getSignalLineDashed(this.ID);
        end

        function set.LineDashed(this,value)
            try
                validateattributes(value,{'string','char'},{});
                validatestring(value,{'-','--',':','-.'});
                this.Repo_.setSignalLineDashed(this.ID,char(value));
                locOnPropChange('linestyle',this.ID,char(value));
            catch me
                me.throwAsCaller();
            end
        end


        function value=get.LineWidth(this)
            value=this.Repo_.getSignalLineWidth(this.ID);
        end

        function set.LineWidth(this,value)
            try
                validateattributes(value,{'numeric'},{'scalar','integer','>=',1,'<=',20});
                this.Repo_.setSignalLineWidth(this.ID,value);
                locOnPropChange('linewidth',this.ID,value);
            catch me
                me.throwAsCaller();
            end
        end


        function value=get.NumPoints(this)
            currId=this.ID;
            value=this.Repo_.getSignalNumberOfPoints(currId);





            while(~value)
                childIDs=this.Repo_.getSignalChildren(currId);
                if isempty(childIDs)

                    break;
                else
                    currId=childIDs(1);
                    value=this.Repo_.getSignalNumberOfPoints(currId);
                end
            end
        end


        function value=get.Checked(this)
            value=~isempty(this.Repo_.getSignalChecked(this.ID));
        end

        function set.Checked(this,value)
            try
                fw=Simulink.sdi.internal.AppFramework.getSetFramework();
                plotIdx=Simulink.sdi.getSelectedPlot(this.Repo_);
                vizType=fw.getSelectedVisual();
                this.validateCanBeChecked(vizType,plotIdx,value);
                fw.onPreSignalPlotted();
                fw.setSignalChecked(this.ID,value);
            catch me
                me.throwAsCaller;
            end
        end



        value=export(this,varargin)
        removeTimePoints(this,varargin)


        function tt=getAsTall(this)

            try
                mapreducer(0);
            catch me %#ok<NASGU>
            end

            tt=Simulink.sdi.DatasetRef.getDatastoreForSignal(this.ID,this.Repo_);
            tt=locReplaceDatastoreWithTallTable(tt.Values);
        end


        function plotOnSubPlot(this,row,col,bPlot,paramName)










            if nargin<5
                paramName='';
            end
            try
                validateattributes(this,{'Simulink.sdi.Signal'},{'size',[1,1]},'','signal');
                validateattributes(row,{'numeric'},{'scalar','integer','>',0,'<=',8});
                validateattributes(col,{'numeric'},{'scalar','integer','>',0,'<=',8});
                validateattributes(bPlot,{'logical'},{'scalar'});
                if isempty(paramName)
                    plotIdx=uint8((col-1)*8+row);
                    vizType=sdi_visuals.getVisualizationID(0,row,col);
                    this.validateCanBeChecked(vizType,plotIdx,bPlot);
                end
            catch me
                me.throwAsCaller;
            end

            fw=Simulink.sdi.internal.AppFramework.getSetFramework();
            fw.onPreSignalPlotted();

            plotIdx=uint8((col-1)*8+row);
            curPlots=this.Repo_.getSignalChecked(this.ID);
            bIsPlotted=any(curPlots==plotIdx);
            if bPlot~=bIsPlotted
                try
                    locSetBindingParam(this,row,col,bPlot,paramName);
                catch me
                    throwAsCaller(me);
                end
                if bPlot
                    curPlots(end+1)=plotIdx;
                else
                    curPlots(curPlots==plotIdx)=[];
                end

                if iscell(curPlots)
                    curPlots=cell2mat(curPlots);
                end
                curPlots=shiftdim(curPlots);
                this.Repo_.setSignalChecked(this.ID,uint8(curPlots));
                locOnPropChange('checked',this.ID,bPlot);
                fw.waitForSignalToBePlotted(this.ID,plotIdx);
            end
        end


        function convertUnits(this,dstUnits)


            validateattributes(dstUnits,{'string','char'},{})
            if isstring(dstUnits)
                dstUnits=char(dstUnits);
            end


            runID=this.RunID;
            if this.Repo_.isValidRunID(runID)&&this.Repo_.getRunIsActivelyStreaming(runID)
                error(message('SDI:sdi:UnitConvertWhileStreaming'));
            end


            me=[];
            try


                this.cacheDeinterleavedData(false);
                this.Repo_.convertUnits(this.ID,dstUnits);
            catch me
                dstUnits=this.Units;
            end

            locOnPropChange('units',this.ID,dstUnits);


            if~isempty(me)
                throwAsCaller(me);
            end
        end


        function convertDataType(this,dataType,varargin)

            validateattributes(dataType,{'string','char'},{})
            if isstring(dataType)
                dataType=char(dataType);
            end


            runID=this.RunID;
            if this.Repo_.isValidRunID(runID)&&this.Repo_.getRunIsActivelyStreaming(runID)
                error(message('SDI:sdi:DataTypeConvertWhileStreaming'));
            end



            isSrcFixedPoint=strfind(this.dataType,'sfix');
            isDstFixedPoint=strfind(dataType,'fixdt');
            if isempty(isSrcFixedPoint)
                isSrcFixedPoint=0;
            end
            if isempty(isDstFixedPoint)
                isDstFixedPoint=0;
            end
            srcCondition=~isempty(this.dataType)&&isSrcFixedPoint;
            dstCondition=~isempty(dataType)&&isDstFixedPoint;
            if srcCondition||dstCondition
                status=license('checkout','fixed_point_toolbox');
                if status==0
                    error(message('SDI:sdi:DataTypeConvertNoFixedPointLicense'));
                end
            end


            if~this.Repo_.isDataTypeSafeToConvert(this.id,dataType)


                if~isempty(varargin)&&varargin{1}
                    error(message('SDI:sdi:DataTypeDownConversionError',this.name,this.dataType,dataType));
                else
                    Simulink.sdi.internal.warning(message('SDI:sdi:DataTypeDownConversionError',this.name,this.dataType,dataType));
                end
            end

            this.Repo_.changeSignalDataType(this.id,dataType);
            locOnPropChange('dataType',this.ID,dataType);
        end


        function expand(this,varargin)
            id=this.getIDForData();
            if Simulink.sdi.expandMatrix(this.Repo_,id,varargin{:})
                runID=this.Repo_.getSignalRunID(id);
                fw=Simulink.sdi.internal.AppFramework.getSetFramework();
                fw.onSignalAdded(runID);


                plotIndices=this.Repo_.getSignalChecked(this.ID);
                if~isempty(plotIndices)
                    locUncheckSignalFromAllSubplots(this.Repo_,this.ID);
                end
            end
        end


        function collapse(this,varargin)
            try
                checkedIDs=this.getCheckedSignalIDsInThisRun();
                id=this.getIDForData();
                runID=this.Repo_.getSignalRunID(id);
                removedIDs=Simulink.sdi.collapseMatrix(this.Repo_,id,varargin{:});
                if~isempty(removedIDs)


                    DO_NOT_UPDATE_TABLE=false;
                    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
                    fw.onSignalsRemoved(runID,removedIDs,checkedIDs,DO_NOT_UPDATE_TABLE);


                    fw.onSignalAdded(runID);


                    if~any(eq(removedIDs,this.ID))
                        fw.setSignalChecked(this.ID,false);


                        for idx=1:length(this.Children)
                            childID=this.Children(idx).ID;
                            if any(eq(checkedIDs,childID))
                                locUncheckSignalFromAllSubplots(this.Repo_,childID);
                            end
                        end
                    end
                end
            catch me
                me.throwAsCaller();
            end

        end


        function convertToFrames(this,varargin)
            try


                checkedIDs=this.getCheckedSignalIDsInThisRun();
                id=this.getIDForData();
                runID=this.Repo_.getSignalRunID(id);
                firstChildID=id;
                childIDs=this.Repo_.getSignalChildren(firstChildID);
                while~isempty(childIDs)
                    firstChildID=childIDs(1);
                    childIDs=this.Repo_.getSignalChildren(firstChildID);
                end


                removedIDs=Simulink.sdi.convertToFrames(id);




                DO_NOT_UPDATE_TABLE=false;
                fw=Simulink.sdi.internal.AppFramework.getSetFramework();
                if~isempty(removedIDs)
                    fw.onSignalsRemoved(runID,removedIDs,checkedIDs,DO_NOT_UPDATE_TABLE);
                end



                fw.onSignalAdded(runID);


                if~this.Repo_.isValidSignal(this.ID)
                    this.ID=firstChildID;
                end



                plotIndices=this.Repo_.getSignalChecked(this.ID);
                if~isempty(plotIndices)
                    locUncheckSignalFromAllSubplots(this.Repo_,this.ID);
                end

            catch me
                me.throwAsCaller();
            end
        end
    end


    methods(Hidden)


        function validateCanBeChecked(this,visType,plotIdx,bPlot)
            if bPlot

                Simulink.sdi.internal.safeTransaction(...
                @locMaxSignalsPlotted,visType,plotIdx,this.Repo_);
            end


            if~strcmpi(visType,'arrayplotplugin')
                if this.Repo_.getSignalIsVarDims(this.ID)
                    error(message('SDI:sdi:PlotVarDims'));
                end
                if this.getIsCollapsedMatrix()
                    error(message('SDI:sdi:PlotMatrix'));
                end
            end


            childIDs=this.Repo_.getSignalChildren(this.ID);
            if~isempty(childIDs)
                error(message('SDI:sdi:PlotComposite'));
            end
        end


        function ret=getConvertibleUnits(this)
            try
                ret=this.Repo_.getConvertibleUnits(this.ID);
                ret=string(ret);
            catch me %#ok<NASGU>
                ret=string.empty();
            end
        end


        function setDisplayUnit(this,value)
            validateattributes(value,{'string','char'},{})
            currStoredUnits=this.Repo_.getUnit(this.ID);
            this.Repo_.setDisplayUnit(this.ID,char(value));
            if isempty(currStoredUnits)

                locOnPropChange('units',this.ID,char(value));
            end
        end


        function cacheDeinterleavedData(this,varargin)
            Simulink.sdi.cacheDeinterleavedData(this.Repo_,this.ID,varargin{:});
        end


        function ret=getMetaData(this,propName)
            if nargin<2
                propName='__METADATA__';
            end
            ret=this.Repo_.getSignalMetaData(this.ID,propName);
        end


        function setMetaData(this,v,propName)
            if nargin<3
                propName='__METADATA__';
            end
            this.Repo_.setSignalMetaData(this.ID,propName,v);
        end


        function ret=getSampleDimensions(this)
            ret=this.repo_.getSignalSampleDims(this.ID);
        end


        function[m,p]=getMagnitudeAndPhase(this)

            assert(this.Complexity=="complex");
            [m,p]=this.Repo_.getSignalMagnitudeAndPhase(this.ID);
        end


        function ret=getComplexDataForInterleaving(this)
            childIDs=this.Repo_.getSignalChildren(this.ID);
            realPart=this.Repo_.getSignalDataValues(childIDs(1));
            imgPart=this.Repo_.getSignalDataValues(childIDs(2));

            ret.Time=realPart.Time;
            if numel(realPart.Time)==numel(imgPart.Time)
                ret.Data=complex(realPart.Data,imgPart.Data);
            else
                ret.Data=complex(realPart.Data,0);
            end
        end


        function ret=getCheckedSignalIDsInThisRun(this)
            ret=this.Repo_.getAllSignalIDs(this.RunID,'checked');
        end


        function ret=getIDForData(this)
            ret=this.ID;




            if this.Repo_.isRealPartOfCompositeComplex(ret)
                parentID=this.Repo_.getSignalParent(ret);
                if parentID
                    ret=parentID;
                end
            end





            if this.Repo_.isUnexpandedMatrixLeaf(ret)
                parentID=this.Repo_.getSignalParent(ret);
                if parentID
                    ret=parentID;
                end
            end
        end


        function ret=getIsCollapsedMatrix(this)


            id=this.ID;
            if this.Repo_.isRealPartOfCompositeComplex(id)
                parentID=this.Repo_.getSignalParent(id);
                if parentID
                    id=parentID;
                end
            end
            ret=this.Repo_.isUnexpandedMatrixLeaf(id);
        end
    end


    methods


        function value=get.RootDataSource(this)
            value=this.RootSource;
        end


        function value=get.InstrumentedSigID(this)
            value=this.Repo_.getSignalInstrumentedSignalID(this.ID);
        end


        function value=get.ImageLayout(this)
            value=this.Repo_.getImageLayout(this.ID);
        end


        function value=get.ImageColorFormat(this)
            value=this.Repo_.getImageColorFormat(this.ID);
        end


        function value=get.SampleSizeInBytes(this)
            value=this.Repo_.getSignalSampleSizeInBytes(this.ID);
        end


        function value=get.Marker(this)
            value=this.Repo_.getSignalMarker(this.ID);
        end

        function set.Marker(this,value)
            this.Repo_.setSignalMarker(this.ID,value);
        end

    end


    methods(Hidden,Static)


        function ret=getInterleavedData(id,timeVals,newDataVals)



            if~isreal(newDataVals)
                ret=newDataVals;
                return
            end

            repo=sdi.Repository(1);
            info=repo.getSignalComplexityAndLeafPath(id);


            s=Simulink.sdi.getSignal(id);
            if isempty(s.Children)
                parentID=repo.getSignalParent(id);
                parentSig=Simulink.sdi.getSignal(parentID);
            else
                parentSig=s;
            end


            curVal=parentSig.getComplexDataForInterleaving();
            bSzMatch=length(curVal.Time)==length(timeVals);


            if~info.IsImagPart
                if bSzMatch
                    ret=complex(newDataVals,imag(curVal.Data));
                else
                    ret=complex(newDataVals,0);
                end
            else

                if bSzMatch
                    ret=complex(real(curVal.Data),newDataVals);
                else
                    ret=complex(0,newDataVals);
                end
            end
        end


        function preprocessForLegacySetData(id,bDeinterleave)


            repo=sdi.Repository(1);
            s=Simulink.sdi.Signal(repo,id);
            s.expand();
            if bDeinterleave
                s.cacheDeinterleavedData(false);
            end
        end


        function onSignalsExpanded(runIDs)
            fw=Simulink.sdi.internal.AppFramework.getSetFramework();
            for idx=1:numel(runIDs)
                fw.onSignalAdded(runIDs(idx));
            end
        end

        function convertMatrixSignal(id,convertType,varargin)
            try
                repo=sdi.Repository(1);
                s=Simulink.sdi.Signal(repo,id);
                switch lower(convertType)
                case 'frame'
                    s.convertToFrames();
                case 'channel'
                    s.expand();
                case 'multidim'
                    s.collapse();
                end
            catch me
                fw=Simulink.sdi.internal.AppFramework.getSetFramework();
                fw.displayError(me,varargin{:});
            end
        end
    end


    methods(Access=protected)


        function displayScalarObject(this)


            if this.Repo_.isValidSignal(this.ID)
                displayScalarObject@matlab.mixin.CustomDisplay(this)
            else

                className=matlab.mixin.CustomDisplay.getClassNameForHeader(this);
                header=getString(message('SDI:sdi:DeletedSignalHeader',className));
                disp(header);
                fprintf('\n');


                s=struct('ID',this.ID);
                disp(s);
            end
        end

    end


    properties(Access='private')
        Repo_;
    end
end


function ret=locReplaceDatastoreWithTallTable(tt)
    if isa(tt,'matlab.io.datastore.TabularDatastore')
        if isscalar(tt)
            ret=tall(tt);
        else
            ret=cell(size(tt));
            for idx=1:numel(tt)
                ret{idx}=tall(tt(idx));
            end
        end
    else
        assert(isstruct(tt));
        ret=struct;
        fnames=fieldnames(tt);
        for idx=1:numel(tt)
            for idx2=1:length(fnames)
                ret(idx).(fnames{idx2})=locReplaceDatastoreWithTallTable(...
                tt(idx).(fnames{idx2}));
            end
        end
    end
end


function locSetBindingParam(sig,row,col,bPlot,paramName)
    visParams=sdi_visuals.listVisualParams(0,row,col);
    visualName=sdi_visuals.getVisualizationName(0,row,col);
    if~isempty(visParams)

        if ismember(paramName,visParams)
            if bPlot
                sdi_visuals.setBindingParam(0,row,col,paramName,sig.ID,sig.Name);
            else
                sdi_visuals.setBindingParam(0,row,col,paramName);
            end
        else
            if isempty(paramName)
                noBindingParamException=MException(...
                'SDI:sdi:InvalidArguments',...
                message('SimulinkHMI:errors:VisualizationPlotError',...
                sig.Name,visualName));
                throwAsCaller(noBindingParamException);
            else
                invalidBindingParamException=MException(...
                'SDI:sdi:InvalidArguments',...
                message('SimulinkHMI:errors:VisualizationPlotError',...
                sig.Name,visualName));
                throwAsCaller(invalidBindingParamException);
            end
        end
    end
end


function locSetSignalDataValues(repo,id,val,keepDimensions)

    bValid=...
    (isa(val,'timeseries')&&val.length>0)||...
    (isstruct(val)&&isfield(val,'Data')&&~isempty(val.Data));
    if~bValid
        error(message('SDI:sdi:INPUT_MISMATCH_WITH_STRUCT','timeseries','structure'));
    end




    if ndims(val.Data)>=3||all(size(val.Data)>1)
        dv.Data=val.Data;
        dv.Time=val.Time;
    else
        len=length(val.Data);
        dv.Data=reshape(val.Data,len,1);
        dv.Time=reshape(val.Time,len,1);
    end

    if isfield(val,'CompressedTimeInc')
        dv.CompressedTimeInc=val.CompressedTimeInc;
    end


    repo.setSignalDataValues(id,dv,keepDimensions);
end


function locOnPropChange(propName,id,value)
    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    fw.onSignalPropChange(propName,id,value);
end


function locValidateTolerance(value)
    validateattributes(value,{'numeric'},{'scalar'});
    if isinf(value)||value<0
        error(message('SDI:sdi:InvalidTolerance'));
    end
end


function locMaxSignalsPlotted(visType,plotIdx,repo)

    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    maxSignals=fw.getMaxSigsPref();
    maxSigsExceeded=false;
    if strcmpi(visType,'')
        client=fw.getClient('inspect');
        if~isempty(client)
            for idx=1:length(client.Axes)
                curr=client.Axes(idx);
                if curr.AxisID==plotIdx&&length(curr.SignalIDs)>=maxSignals
                    maxSigsExceeded=true;
                end
            end
        else
            checkedSigs=repo.getAllCheckedSignals;
            sigCount=0;
            for idx=1:length(checkedSigs)
                curr=checkedSigs(idx);
                if nnz(ismember(repo.getSignalChecked(curr),uint8(plotIdx)))
                    sigCount=sigCount+1;
                end
            end
            if sigCount>=maxSignals
                maxSigsExceeded=true;
            end
        end
    end
    if maxSigsExceeded
        error(message('SDI:sdi:MaxSignalsExceeded',maxSignals));
    end
end

function locUncheckSignalFromAllSubplots(repo,sigID)
    repo.setSignalChecked(sigID,uint8([]));
    appEnum=Simulink.sdi.internal.PrototypeTable.getApp(sigID);
    Simulink.sdi.updateRowInTable(repo,sigID,appEnum,"checked");
end

function locValidateAcceptableScalingAndOffsetDataType(dataType)
    acceptableDataTypes={'boolean','logical','uint8','int8','uint16','int16','uint32','int32','uint64','int64','half','single','double'};
    if~ismember(dataType,acceptableDataTypes)
        error(message('SDI:sdi:InvalidScalingAndOffsetDataType'));
    end
end