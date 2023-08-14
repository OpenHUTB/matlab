classdef Instrument<handle&matlab.mixin.CustomDisplay&matlab.mixin.Copyable








    properties(Access=public)











        AxesTimeSpan=slrealtime.Instrument.AxesTimeSpanDefault;
        AxesTimeSpanOverrun=slrealtime.Instrument.AxesTimeSpanOverrunDefault;
    end

    properties(SetAccess=protected,NonCopyable)



















        Application=''



        ModelName=''







        CodeDescriptor=[]
        TaskInfo=[]
        SLRTApp=[]
    end

    properties(Hidden,SetAccess=protected,NonCopyable)
        AcquireList(1,1)slrealtime.internal.instrument.AcquireList



        Checksum=''




        nLine(1,1)=0




        hObjects={}







Map
    end

    properties(Hidden)


        UUID=-1
    end

    properties(Hidden,SetAccess=protected)
        signals=[]
        hCallbacks={}
    end

    properties(Hidden,Access=public)






        MLObsDropIfBusy(1,1)logical=true












        RemoveOnStop(1,1)logical=false;







        StreamingOnly(1,1)logical=true;












        BufferData(1,1)logical=false;
    end

    properties(Hidden,SetAccess={?slrealtime.Target,?slrealtime.internal.NormalModeTarget},NonCopyable)







        LockedByTarget=[];
    end

    properties(Hidden,Constant)
        DecimationDefault=1;
        PropertyNameDefault='Value';

        AxesTimeSpanDefault=Inf;
        AxesTimeSpanOverrunDefault='scroll';
    end

    properties(Access=private)
        BufferedData=[]
    end
    methods(Access=private)
        function bufferData(this,evnt)
            this.BufferedData=[this.BufferedData,evnt];
        end
    end
    methods(Access=public)
        function data=getBufferedData(this)
            bufferedData=this.BufferedData;
            this.BufferedData=[];

            data=containers.Map('KeyType','char','ValueType','any');
            for nData=1:length(bufferedData)
                evnt=bufferedData(nData);
                keys=evnt.Map.keys;
                for i=1:length(keys)
                    [t,d]=this.getCallbackDataForSignal(evnt,keys{i});
                    if isempty(t)||isempty(d),continue;end

                    if~isempty(d)&&iscell(d)&&ischar(d{1})
                        d=string(d);
                    end

                    old_t=[];
                    old_d=[];
                    if data.isKey(keys{i})
                        old_t=data(keys{i}).time;
                        old_d=data(keys{i}).data;
                    end

                    if isstruct(d)
                        if length(t)>1
                            StructArray=[];
                            for nTimePt=1:length(t)
                                f=fields(d);
                                temp=this.copyStruct(d,nTimePt);
                                for nField=1:length(f)
                                    StructArray(nTimePt).(f{nField})=temp.(f{nField});
                                end
                            end
                            d=StructArray';
                        end
                    end

                    if numel(size(d))>2

                        data(keys{i})=struct(...
                        'time',[old_t;t],...
                        'data',cat(numel(size(d)),old_d,d));
                    else

                        data(keys{i})=struct(...
                        'time',[old_t;t],...
                        'data',[old_d;d]);
                    end


                end
            end
        end
    end

    events


internalTimer
    end

    methods



        function obj=Instrument(application)
            obj.Map=containers.Map;

            if nargin<1||isempty(application)
                application='';
            else
                [application,~]=slrealtime.Instrument.findApplicationMLDATXFile(application);
            end

            obj.UUID=Simulink.HMI.AsyncQueueObserverAPI.getUUIdFromString(char(matlab.lang.internal.uuid));

            if~isempty(application)
                obj.Application=application;
                obj.AcquireList=slrealtime.internal.instrument.AcquireList(application);
                [obj.CodeDescriptor,obj.TaskInfo,obj.SLRTApp]=slrealtime.internal.streamingSignalInfoUtil.getCodeDescriptorFromMLDATX(application);
                obj.ModelName=obj.SLRTApp.ModelName;
                reader=Simulink.loadsave.SLXPackageReader(application);
                obj.Checksum=reader.readPartToString('/misc/UUID','US-ASCII');
            end
        end




        function delete(this)
            try
                if~isempty(this.LockedByTarget)
                    tg=this.LockedByTarget;
                    tg.removeInstrument(this);
                end
            catch
            end
            this.deleteObjects();
            this.deleteCallbacks();
        end
    end

    methods
        function set.StreamingOnly(this,val)




            validate=(this.StreamingOnly~=val)&&~isempty(this.AcquireList)&&~isempty(this.AcquireList.AcquireListModel);%#ok
            this.StreamingOnly=val;
            if validate
                this.validate(this.Application);%#ok
            end
        end

        function set.BufferData(this,val)
            if~isempty(this.LockedByTarget)%#ok
                slrealtime.internal.throw.Error('slrealtime:instrument:LockedByTarget');
            end
            this.BufferData=val;
            if val&&this.StreamingOnly %#ok
                this.StreamingOnly=false;%#ok
            end
        end
    end

    methods(Access=protected)



        function displayScalarObject(this)
            disp(matlab.mixin.CustomDisplay.getDetailedHeader(this));
            matlab.mixin.CustomDisplay.displayPropertyGroups(this,this.getPropertyGroups());

            addSignals=this.signals(arrayfun(@(x)x.type==slrealtime.internal.instrument.SignalTypes.ForCallback||...
            x.type==slrealtime.internal.instrument.SignalTypes.Badged,this.signals));
            connectScalars=this.signals(arrayfun(@(x)x.type==slrealtime.internal.instrument.SignalTypes.Scalar,this.signals));
            connectLine=this.signals(arrayfun(@(x)x.type==slrealtime.internal.instrument.SignalTypes.Line,this.signals));

            function dispSignals(signals)
                for i=1:length(signals)
                    signal=signals(i);
                    str=sprintf('\t%s',this.getSignalStringToDisplay(signal));

                    if isfield(signal.inputs,'Decimation')&&signal.inputs.Decimation~=this.DecimationDefault
                        str=sprintf('%s (decimation = %d)',str,signal.inputs.Decimation);
                    end
                    fprintf(1,'%s\n',str);
                end
            end

            disp('Signals added by addSignal():');
            dispSignals(addSignals);

            fprintf(1,'\n');

            disp('Signals added by connectScalar():');
            dispSignals(connectScalars);

            fprintf(1,'\n');

            disp('Signals added by connectLine():');
            dispSignals(connectLine);

            fprintf(1,'\n');

            disp('Callbacks added by connectCallback():');
            for nCB=1:length(this.hCallbacks)
                fprintf(1,'\t%s\n',func2str(this.hCallbacks{nCB}.Callback));
            end
        end
    end

    methods
        function set.AxesTimeSpan(this,value)
            function resetXLim(x)
                if isa(x,'slrealtime.internal.instrument.Line')
                    x.hAxes.XLimMode='auto';
                end
            end
            cellfun(@(x)resetXLim(x),this.hObjects);%#ok

            this.AxesTimeSpan=value;
        end

        function set.AxesTimeSpanOverrun(this,value)
            validatestring(value,{'scroll','wrap'});
            this.AxesTimeSpanOverrun=value;
        end
    end




    methods(Access=public)

        function[agi,si]=addSignal(this,signal,varargin)
            [agi,si]=this.addSignalWork(slrealtime.internal.instrument.SignalTypes.ForCallback,signal,varargin{:});





            if nargout<2,clear si;end
            if nargout<1,clear agi;end
        end


        function addInstrumentedSignals(this)







            if~isempty(this.LockedByTarget)
                slrealtime.internal.throw.Error('slrealtime:instrument:LockedByTarget');
            end

            if isempty(this.Application)
                slrealtime.internal.throw.Error('slrealtime:instrument:CannotAddInstrumentedSignals');
            end

            modelBlockPath=Simulink.SimulationData.BlockPath;
            [codeDescriptor,~,app]=slrealtime.internal.streamingSignalInfoUtil.getCodeDescriptorFromMLDATX(this.Application);%#ok
            try
                this.addInstrumentedSignalsForModel(codeDescriptor,modelBlockPath);
            catch
                codeDescriptor=[];%#ok
                app=[];%#ok
            end
            codeDescriptor=[];%#ok
            app=[];%#ok
        end


        function connectScalar(this,hDisp,signal,varargin)





            if~isempty(this.LockedByTarget)
                slrealtime.internal.throw.Error('slrealtime:instrument:LockedByTarget');
            end



            if mod(length(varargin),2)==1

                sigs=slrealtime.internal.instrument.Util.checkAndFormatSignalArgs(signal,varargin{1});
                args=varargin(2:end);
            else

                sigs=slrealtime.internal.instrument.Util.checkAndFormatSignalArgs(signal);
                args=varargin(:);
            end



            if length(sigs)>1
                slrealtime.internal.throw.Error('slrealtime:instrument:ScalarControlMultipleSignals');
            end
            signal=sigs;
            clear sigs;



            parser=inputParser;
            parser.FunctionName=mfilename;
            parser.addRequired('obj',@(x)(isa(x,'slrealtime.Instrument')));
            parser.addRequired('hDisp',@(x)(isscalar(x)));
            parser.addParameter('Decimation',this.DecimationDefault,@(x)(isnumeric(x)&&isscalar(x)&&x>0&&x==floor(x)));
            parser.addParameter('PropertyName',this.PropertyNameDefault,@(x)(ischar(x)||isstring(x)));
            parser.addParameter('BusElement',[],@(x)(ischar(x)||isstring(x)));
            parser.addParameter('ArrayIndex',[],@(x)(isnumeric(x)));
            parser.addParameter('Callback',[],@(x)(isa(x,'function_handle')));
            parser.addOptional('MetaData',[]);
            parser.CaseSensitive=true;
            parser.KeepUnmatched=true;
            parser.parse(this,hDisp,args{:});
            inputs=parser.Results;



            if~isempty(fields(parser.Unmatched))
                slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
            end




            if~isempty(inputs.BusElement)
                if isempty(signal.metadata)
                    signal.metadata=struct('busElement',inputs.BusElement);
                else
                    signal.metadata.BusElement=inputs.BusElement;
                end
            end



            inputs.PropertyName=convertStringsToChars(inputs.PropertyName);
            if~isprop(hDisp,inputs.PropertyName)
                slrealtime.internal.throw.Error('slrealtime:instrument:ScalarControlInvalidProperty',class(hDisp),inputs.PropertyName);
            end




            function v=hDispCheck(sigInputs)
                v=false;
                if isfield(sigInputs,'hDisp')&&...
                    sigInputs.hDisp==inputs.hDisp&&...
                    strcmp(sigInputs.PropertyName,inputs.PropertyName)
                    v=true;
                end
            end
            if~isempty(this.signals)&&any(cellfun(@hDispCheck,{this.signals(:).inputs}))
                slrealtime.internal.throw.Error('slrealtime:instrument:ScalarControlAlreadyConnected',inputs.PropertyName);
            end

            if this.StreamingOnly
                this.StreamingOnly=false;
            end



            signal.decimation=inputs.Decimation;
            signal.type=slrealtime.internal.instrument.SignalTypes.Scalar;
            signal.inputs=inputs;
            signal.metadata=signal.metadata;

            this.signals=[this.signals,signal];



            if~isempty(this.Application)
                try
                    this.validateScalarSignal(signal);
                catch ME
                    str=slrealtime.Instrument.getSignalStringToDisplay(signal);
                    slrealtime.internal.throw.Warning('slrealtime:instrument:CannotInstrument',str,ME.message);
                end
            end
        end


        function connectLine(this,hAxes,signal,varargin)





            if~isempty(this.LockedByTarget)
                slrealtime.internal.throw.Error('slrealtime:instrument:LockedByTarget');
            end



            if mod(length(varargin),2)==1

                sigs=slrealtime.internal.instrument.Util.checkAndFormatSignalArgs(signal,varargin{1});
                args=varargin(2:end);
            else

                sigs=slrealtime.internal.instrument.Util.checkAndFormatSignalArgs(signal);
                args=varargin(:);
            end



            defaultLineStyle=slrealtime.instrument.LineStyle;
            parser=inputParser;
            parser.FunctionName=mfilename;
            parser.addRequired('obj',@(x)(isa(x,'slrealtime.Instrument')));
            parser.addRequired('hAxes',@(x)(isscalar(x)&&isa(x,'matlab.graphics.axis.Axes')));
            parser.addParameter('LineStyle',defaultLineStyle,@(x)(isa(x,'slrealtime.instrument.LineStyle')));
            parser.addParameter('Decimation',this.DecimationDefault,@(x)(isnumeric(x)&&isscalar(x)&&x>0&&x==floor(x)));
            parser.addParameter('BusElement',[],@(x)(ischar(x)||isstring(x)));
            parser.addParameter('ArrayIndex',[],@(x)(isnumeric(x)));
            parser.addParameter('Callback',[],@(x)(isa(x,'function_handle')));
            parser.addOptional('MetaData',[]);
            parser.CaseSensitive=true;
            parser.KeepUnmatched=true;
            parser.parse(this,hAxes,args{:});
            inputs=parser.Results;



            if~isempty(fields(parser.Unmatched))
                slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
            end

            if this.StreamingOnly
                this.StreamingOnly=false;
            end



            for i=1:length(sigs)



                if~isempty(inputs.BusElement)
                    if isempty(sigs(i).metadata)
                        sigs(i).metadata=struct('busElement',inputs.BusElement);
                    else
                        sigs(i).metadata.BusElement=inputs.BusElement;
                    end
                end

                sigs(i).decimation=inputs.Decimation;
                sigs(i).type=slrealtime.internal.instrument.SignalTypes.Line;
                sigs(i).inputs=inputs;
                sigs(i).metadata=sigs(i).metadata;

                this.signals=[this.signals,sigs(i)];

                if~isempty(this.Application)
                    try
                        this.validateLineSignal(sigs(i));
                    catch ME
                        str=slrealtime.Instrument.getSignalStringToDisplay(sigs(i));
                        slrealtime.internal.throw.Warning('slrealtime:instrument:CannotInstrument',str,ME.message);
                    end
                end
            end
        end


        function connectCallback(this,hCallback)





            if~isempty(this.LockedByTarget)
                slrealtime.internal.throw.Error('slrealtime:instrument:LockedByTarget');
            end



            parser=inputParser;
            parser.FunctionName=mfilename;
            parser.addRequired('obj',@(x)(isa(x,'slrealtime.Instrument')));
            parser.addRequired('hCallback',@(x)(isa(x,'function_handle')));
            parser.CaseSensitive=true;
            parser.KeepUnmatched=true;
            parser.parse(this,hCallback);
            inputs=parser.Results;



            if~isempty(fields(parser.Unmatched))
                slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
            end



            if~isempty(this.hCallbacks)&&any(cellfun(@(x)strcmp(func2str(inputs.hCallback),func2str(x.Callback)),this.hCallbacks))
                return;
            end

            if this.StreamingOnly
                this.StreamingOnly=false;
            end



            lh=addlistener(this,'internalTimer',inputs.hCallback);
            if isempty(this.hCallbacks)
                this.hCallbacks={lh};
            else
                this.hCallbacks{end+1}=lh;
            end
        end


        function clearScalarAndLineData(this)
            for i=1:length(this.hObjects)
                hobj=this.hObjects{i};
                hobj.clearData;
            end
        end


        function unavailSignals=validate(this,application)
            unavailSignals=slrealtime.Instrument;








            if isempty(application)





                this.AcquireList=slrealtime.internal.instrument.AcquireList;
                this.nLine=0;
                this.Application='';
                this.ModelName='';
                this.CodeDescriptor=[];
                this.TaskInfo=[];
                this.SLRTApp=[];
                this.Checksum='';
                this.Map=containers.Map;
                this.deleteObjects();
                return;
            end

            try
                validateattributes(application,{'char','string'},{'scalartext'});
                application=convertStringsToChars(application);
            catch
                slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
            end

            if~startsWith(application,"MODEL:")




                [application,~]=slrealtime.Instrument.findApplicationMLDATXFile(application);
                [this.CodeDescriptor,this.TaskInfo,this.SLRTApp]=slrealtime.internal.streamingSignalInfoUtil.getCodeDescriptorFromMLDATX(application);
                this.ModelName=this.SLRTApp.ModelName;
                reader=Simulink.loadsave.SLXPackageReader(application);
                this.Checksum=reader.readPartToString('/misc/UUID','US-ASCII');
            else
                this.ModelName=extractAfter(application,"MODEL:");
                this.CodeDescriptor=[];
                this.TaskInfo=[];
                this.SLRTApp=[];
            end

            this.Application=application;
            this.AcquireList=slrealtime.internal.instrument.AcquireList(application);



            this.deleteObjects();



            for nSig=1:length(this.signals)
                signal=this.signals(nSig);

                try
                    switch signal.type
                    case slrealtime.internal.instrument.SignalTypes.Line
                        this.validateLineSignal(signal);
                    case slrealtime.internal.instrument.SignalTypes.Scalar
                        this.validateScalarSignal(signal);
                    case{slrealtime.internal.instrument.SignalTypes.ForCallback,...
                        slrealtime.internal.instrument.SignalTypes.Badged}
                        this.validateSignal(signal);
                    otherwise
                        assert(false);
                    end
                catch ME
                    str=slrealtime.Instrument.getSignalStringToDisplay(signal);
                    slrealtime.internal.throw.Warning('slrealtime:instrument:CannotInstrument',str,ME.message);
                    unavailSignals.addSignal(signal);
                end
            end
        end


        function removeSignal(this,signal,varargin)


            if~isempty(this.LockedByTarget)
                slrealtime.internal.throw.Error('slrealtime:instrument:LockedByTarget');
            end

            if nargin==2&&isstruct(signal)



                sigs=signal;
            else


                if mod(length(varargin),2)==1

                    sigs=slrealtime.internal.instrument.Util.checkAndFormatSignalArgs(signal,varargin{1});
                    args=varargin(2:end);
                else

                    sigs=slrealtime.internal.instrument.Util.checkAndFormatSignalArgs(signal);
                    args=varargin(:);
                end



                parser=inputParser;
                parser.FunctionName=mfilename;
                parser.addRequired('this',@(x)(isa(x,'slrealtime.Instrument')));
                parser.addOptional('Decimation',-2,@(x)(isnumeric(x)&&isscalar(x)&&x>0&&x==floor(x)));
                parser.CaseSensitive=true;
                parser.KeepUnmatched=true;
                parser.parse(this,args{:});
                inputs=parser.Results;



                if~isempty(fields(parser.Unmatched))
                    slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
                end

                for i=1:length(sigs)
                    sigs(i).decimation=inputs.Decimation;
                end
            end



            for i=1:length(sigs)


                if~isempty(sigs(i).signame)
                    indices=find(arrayfun(@(x)strcmp(sigs(i).signame,x.signame),[this.signals]));
                else
                    bp=Simulink.SimulationData.BlockPath(sigs(i).blockpath);
                    if sigs(i).portindex~=-1
                        indices=find(arrayfun(@(x)bp.isequal(x.blockpath)&&sigs(i).portindex==x.portindex,[this.signals]));
                    else
                        indices=find(arrayfun(@(x)bp.isequal(x.blockpath)&&strcmp(sigs(i).statename,x.statename),[this.signals]));
                    end
                end


                if sigs(i).decimation~=-2
                    dec_indices=find(arrayfun(@(x)sigs(i).decimation==x.decimation,[this.signals]));
                    indices=intersect(indices,dec_indices);
                end


                this.signals(indices)=[];
            end



            if~isempty(this.Application)
                this.validate(this.Application);
            end
        end


        function removeCallback(this,hCallback)







            parser=inputParser;
            parser.FunctionName=mfilename;
            parser.addRequired('obj',@(x)(isa(x,'slrealtime.Instrument')));
            parser.addRequired('hCallback',@(x)(isa(x,'function_handle')));
            parser.CaseSensitive=true;
            parser.KeepUnmatched=true;
            parser.parse(this,hCallback);
            inputs=parser.Results;



            if~isempty(fields(parser.Unmatched))
                slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
            end



            if~isempty(this.hCallbacks)
                idx=find(cellfun(@(x)strcmp(func2str(inputs.hCallback),func2str(x.Callback)),this.hCallbacks));
                if~isempty(idx)
                    this.hCallbacks(idx)=[];
                end
            end
        end


        function[time,data]=getCallbackDataForSignal(this,evnt,signal,varargin)
            time=[];%#ok
            data=[];



            if mod(length(varargin),2)==1

                sigs=slrealtime.internal.instrument.Util.checkAndFormatSignalArgs(signal,varargin{1});
                args=varargin(2:end);
            else

                sigs=slrealtime.internal.instrument.Util.checkAndFormatSignalArgs(signal);
                args=varargin(:);
            end



            if length(sigs)>1
                slrealtime.internal.throw.Error('slrealtime:instrument:TooManySignals');
            end
            signal=sigs;
            clear sigs;



            parser=inputParser;
            parser.FunctionName=mfilename;
            parser.addRequired('this',@(x)(isa(x,'slrealtime.Instrument')));
            parser.addRequired('evnt',@(x)(isa(x,'event.EventData')));
            parser.addOptional('Decimation',this.DecimationDefault,@(x)(isnumeric(x)&&isscalar(x)&&x>0&&x==floor(x)));
            parser.addOptional('BusElement',[],@(x)(ischar(x)||isstring(x)));
            parser.CaseSensitive=true;
            parser.KeepUnmatched=true;
            parser.parse(this,evnt,args{:});
            inputs=parser.Results;



            if~isempty(fields(parser.Unmatched))
                slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
            end

            [str,isDup]=this.getSignalStringForMap(...
            signal,inputs.Decimation,inputs.BusElement,[]);





            if isDup
                str=slrealtime.Instrument.getSignalStringToDisplay(signal);
                slrealtime.internal.throw.Error('slrealtime:instrument:DoubleResolves',str);
            end

            if~this.Map.isKey(str)
                str=slrealtime.Instrument.getSignalStringToDisplay(signal);
                slrealtime.internal.throw.Error('slrealtime:instrument:SignalDoesNotExist',str);
            end



            idx=evnt.Map(str);
            agi=idx(1);
            si=idx(2);
            time=evnt.AcquireGroupData(agi).Time;
            if~isempty(evnt.AcquireGroupData(agi).Data)
                if~isempty(evnt.AcquireGroupData(agi).Data(si))
                    data=evnt.AcquireGroupData(agi).Data(si);
                    data=data{1};
                end
            end
        end


        function textOut=generateScript(this,varargin)
            function str=convertBlockpathToStr(blockpath)
                cellArray=blockpath.convertToCell();
                numEls=length(cellArray);
                str='{';
                for i=1:numEls
                    str=[str,'''',cellArray{i},''''];%#ok
                    if i~=numEls
                        str=[str,','];%#ok
                    end
                end
                str=[str,'}'];
            end

            nargs=length(varargin);
            usingGUI=false;
            if nargs>0

                usingGUI=varargin{1};
            end

            Text=cell(0,1);



            comment='Create the Instrument';
            Text=controllib.internal.codegen.appendMATLABCode(Text,['%% ',comment]);
            appfileStr=[];
            if~isempty(this.Application)
                appfileStr=['''',this.Application,''''];
            end
            Code=['hInst = slrealtime.Instrument(',appfileStr,');'];
            Text=controllib.internal.codegen.appendMATLABCode(Text,Code);

            if this.AxesTimeSpan~=this.AxesTimeSpanDefault
                Code=['hInst.AxesTimeSpan = ',num2str(this.AxesTimeSpan),';'];
                Text=controllib.internal.codegen.appendMATLABCode(Text,Code);
            end
            if~strcmp(this.AxesTimeSpanOverrun,this.AxesTimeSpanOverrunDefault)
                Code=['hInst.AxesTimeSpanOverrun = ''',this.AxesTimeSpanOverrun,''';'];
                Text=controllib.internal.codegen.appendMATLABCode(Text,Code);
            end

            Text=controllib.internal.codegen.appendMATLABCode(Text,' ');







            if isempty(this.signals)
                numScalars=0;
                numAxes=0;
            else
                numScalars=length(find(cellfun(@(x)isfield(x,'hDisp'),{this.signals(:).inputs})));
                numAxes=length(find(cellfun(@(x)isfield(x,'hAxes'),{this.signals(:).inputs})));
            end
            if~usingGUI&&(numScalars>0||numAxes>0)
                comment='Create objects for Instrument connections';
                Text=controllib.internal.codegen.appendMATLABCode(Text,['%% ',comment]);
                Code='hUIFigure = uifigure;';
                Text=controllib.internal.codegen.appendMATLABCode(Text,Code);

                if numScalars
                    Code='hGauges = [];';
                    Text=controllib.internal.codegen.appendMATLABCode(Text,Code);
                    Code='hGaugeCntr = 1;';
                    Text=controllib.internal.codegen.appendMATLABCode(Text,Code);
                    Code=['for nGauge=1:',num2str(numScalars)];
                    Text=controllib.internal.codegen.appendMATLABCode(Text,Code);
                    Code='    hGauges(nGauge) = uigauge(hUIFigure,''linear''); %#ok';
                    Text=controllib.internal.codegen.appendMATLABCode(Text,Code);
                    Code='end';
                    Text=controllib.internal.codegen.appendMATLABCode(Text,Code);
                end

                if numAxes>0
                    Code='hAxes = uiaxes(hUIFigure);';
                    Text=controllib.internal.codegen.appendMATLABCode(Text,Code);
                end

                Text=controllib.internal.codegen.appendMATLABCode(Text,' ');
            end



            comment='Add signals and connections';
            Text=controllib.internal.codegen.appendMATLABCode(Text,['%% ',comment]);
            for nSig=1:length(this.signals)
                signal=this.signals(nSig);






                if isfield(signal.inputs,'hDisp')
                    if usingGUI
                        sigStr=['hInst.connectScalar(app.',signal.inputs.MetaData.ControlName,', '];
                    else
                        sigStr='hInst.connectScalar(hGauges(hGaugeCntr), ';
                    end
                elseif isfield(signal.inputs,'hAxes')



                    if isfield(signal.inputs,'LineStyle')&&~signal.inputs.LineStyle.isDefault()
                        styleStr='ls = slrealtime.instrument.LineStyle();';
                        Text=controllib.internal.codegen.appendMATLABCode(Text,styleStr);

                        if~signal.inputs.LineStyle.isWidthSetToDefault()
                            styleStr=['ls.Width = ',num2str(signal.inputs.LineStyle.Width),';'];
                            Text=controllib.internal.codegen.appendMATLABCode(Text,styleStr);
                        end
                        if~signal.inputs.LineStyle.isStyleSetToDefault()
                            styleStr=['ls.Style = ''',signal.inputs.LineStyle.Style,''';'];
                            Text=controllib.internal.codegen.appendMATLABCode(Text,styleStr);
                        end
                        if~signal.inputs.LineStyle.isColorSetToDefault()
                            if isnumeric(signal.inputs.LineStyle.Color)
                                styleStr=['ls.Color = [',num2str(signal.inputs.LineStyle.Color),'];'];
                            else
                                styleStr=['ls.Color = ''',signal.inputs.LineStyle.Color,''';'];
                            end
                            Text=controllib.internal.codegen.appendMATLABCode(Text,styleStr);
                        end
                        if~signal.inputs.LineStyle.isMarkerSetToDefault()
                            styleStr=['ls.Marker = ''',signal.inputs.LineStyle.Marker,''';'];
                            Text=controllib.internal.codegen.appendMATLABCode(Text,styleStr);
                        end
                        if~signal.inputs.LineStyle.isMarkerSizeSetToDefault()
                            styleStr=['ls.MarkerSize = ',num2str(signal.inputs.LineStyle.MarkerSize),';'];
                            Text=controllib.internal.codegen.appendMATLABCode(Text,styleStr);
                        end
                    end

                    if usingGUI
                        sigStr=['hInst.connectLine(app.',signal.inputs.MetaData.ControlName,', '];
                    else
                        sigStr='hInst.connectLine(hAxes, ';
                    end
                else
                    sigStr='hInst.addSignal(';
                end




                if~isempty(signal.signame)
                    sigStr=[sigStr,'''',signal.signame,''''];%#ok
                else
                    if signal.portindex~=-1
                        sigStr=[sigStr,convertBlockpathToStr(signal.blockpath),', ',num2str(signal.portindex)];%#ok
                    else
                        sigStr=[sigStr,convertBlockpathToStr(signal.blockpath),', ''',signal.statename,''''];%#ok
                    end
                end



                if isfield(signal.inputs,'Decimation')&&signal.inputs.Decimation~=this.DecimationDefault
                    sigStr=[sigStr,sprintf(', ''Decimation'', %s',num2str(signal.inputs.Decimation))];%#ok
                end



                if isfield(signal.inputs,'ArrayIndex')&&~isempty(signal.inputs.ArrayIndex)
                    if numel(signal.inputs.ArrayIndex)==1
                        openStr='';
                        closeStr='';
                    else
                        openStr='[';
                        closeStr=']';
                    end
                    str=sprintf(', ''ArrayIndex'', %s%s%s',openStr,num2str(signal.inputs.ArrayIndex),closeStr);
                    sigStr=[sigStr,str];%#ok
                end



                if~isempty(signal.metadata)&&isfield(signal.metadata,'busElement')
                    str=sprintf(', ''BusElement'', ''%s''',signal.metadata.busElement);
                    sigStr=[sigStr,str];%#ok
                end



                if isfield(signal.inputs,'Callback')&&~isempty(signal.inputs.Callback)
                    cbStr=func2str(signal.inputs.Callback);
                    if cbStr(1)~='@'
                        cbStr=['@',cbStr];%#ok
                    end
                    str=sprintf(', ''Callback'', %s',cbStr);
                    sigStr=[sigStr,str];%#ok
                end



                postSigStr=[];
                if isfield(signal.inputs,'hDisp')





                    if~usingGUI
                        postSigStr=sprintf('hGaugeCntr = hGaugeCntr + 1;');
                    end



                    if isfield(signal.inputs,'PropertyName')&&~strcmp(signal.inputs.PropertyName,this.PropertyNameDefault)
                        str=sprintf(', ''PropertyName'', ''%s''',signal.inputs.PropertyName);
                        sigStr=[sigStr,str];%#ok
                    end

                elseif isfield(signal.inputs,'hAxes')







                    if isfield(signal.inputs,'LineStyle')&&~signal.inputs.LineStyle.isDefault()
                        str=', ''LineStyle'', ls';
                        sigStr=[sigStr,str];%#ok
                    end
                end
                sigStr=[sigStr,');'];%#ok
                Text=controllib.internal.codegen.appendMATLABCode(Text,sigStr);

                if~isempty(postSigStr)
                    Text=controllib.internal.codegen.appendMATLABCode(Text,postSigStr);
                end
            end
            Text=controllib.internal.codegen.appendMATLABCode(Text,' ');



            comment='Add callbacks';
            Text=controllib.internal.codegen.appendMATLABCode(Text,['%% ',comment]);
            for nCB=1:length(this.hCallbacks)
                str=sprintf('hInst.connectCallback(%s);',func2str(this.hCallbacks{nCB}.Callback));
                Text=controllib.internal.codegen.appendMATLABCode(Text,str);
            end
            Text=controllib.internal.codegen.appendMATLABCode(Text,' ');

            if nargout>0

                textOut=Text;
            else

                controllib.internal.codegen.showGeneratedMATLABCode(Text,false);
            end
        end
    end




    methods(Hidden,Access={?slrealtime.Target,?slrealtime.internal.NormalModeTarget})
        function registerObserversWithTarget(this,tg)
            if this.StreamingOnly

                return;
            end






            if isempty(this.Map)
                this.Map=containers.Map;
            end
            this.Map.remove(this.Map.keys);

            for agi=1:this.AcquireList.AcquireListModel.nAcquireGroups
                acquireGroup=this.AcquireList.AcquireListModel.AcquireGroups(agi);
                for si=1:acquireGroup.nSignals

                    busElement=[];
                    idxs=strfind(acquireGroup.xcpSignals(si).signalName,'.');
                    if~isempty(idxs)

                        busElement=acquireGroup.xcpSignals(si).signalName(idxs(1)+1:end);
                    end



                    str=this.getSignalStringForMap(...
                    acquireGroup.signalStructs(si),...
                    acquireGroup.decimation,...
                    busElement,...
                    acquireGroup.xcpSignals(si));




                    this.Map(str)=[agi,si];
                end
            end



            for agi=1:this.AcquireList.AcquireListModel.nAcquireGroups
                acquireGroup=this.AcquireList.AcquireListModel.AcquireGroups(agi);

                for si=1:acquireGroup.nSignals
                    if~this.AcquireList.AcquireListModel.canAttachMATLABObserver(acquireGroup.signalStructs(si),acquireGroup.xcpSignals(si))

                        continue
                    end


                    mlodata=struct(...
                    'matlabObsFcn','slrealtime.internal.instrument.StreamingCallBack.NewData',...
                    'matlabObsParam',num2str(si),...
                    'matlabObsCallbackGroup',uint32(agi),...
                    'matlabObsFuncHandle',@tg.dataAvailableFromObserver,...
                    'matlabObsDropIfBusy',this.MLObsDropIfBusy);
                    acquireGroup.xcpSignals(si).fillMATLABObserverInfo(mlodata);



                    if acquireGroup.decimation==1
                        acquireGroup.xcpSignals(si).sampleTimeStringToDisplay=acquireGroup.xcpSignals(si).sampleTimeString;
                    else
                        str=sprintf('%s (decimation = %d)',acquireGroup.xcpSignals(si).sampleTimeString,acquireGroup.decimation);
                        acquireGroup.xcpSignals(si).sampleTimeStringToDisplay=str;
                    end
                end
            end
        end

        function dataAvailableFromObserverViaTarget(this,acquireSignalDatas)


            availableData=[];
            for agi=1:this.AcquireList.AcquireListModel.nAcquireGroups
                acquireGroup=this.AcquireList.AcquireListModel.AcquireGroups(agi);
                acquireGroupDatas=acquireSignalDatas(agi,1:acquireGroup.nSignals);


                L=arrayfun(@(x)length(x.Time),acquireGroupDatas);
                if any(L~=L(1))




                    Time=[];
                    Data=cell(1,acquireGroup.nSignals);
                else
                    Time=acquireGroupDatas(1).Time;
                    Time=Time(:);
                    Data=arrayfun(@(x)x.Data,acquireGroupDatas,'UniformOutput',false);
                end

                availableData(agi).Time=Time;%#ok
                availableData(agi).Data=Data;%#ok
            end
            if isempty(availableData)
                return;
            end

            callDrawnow=false;



            for i=1:length(this.hObjects)
                hobj=this.hObjects{i};
                agi=hobj.acquireGroupIndex;
                si=hobj.acquireSignalIndex;

                if~isempty(availableData(agi).Time)
                    hobj.update(availableData(agi).Time,availableData(agi).Data{si});
                    callDrawnow=true;
                end
            end



            if~isempty(this.hCallbacks)||this.BufferData
                timeVecs=arrayfun(@(x)x.Time,availableData,'UniformOutput',false);
                timeVecs=timeVecs(cellfun(@(x)~isempty(x),timeVecs));
                if~isempty(timeVecs)
                    currTime=max(cellfun(@(x)x(end),timeVecs));

                    evtdata=slrealtime.internal.instrument.AcquireGroupDataEvent(currTime,availableData,this.Map);
                    if this.BufferData
                        this.bufferData(evtdata);
                    end
                    if~isempty(this.hCallbacks)
                        notify(this,'internalTimer',evtdata)
                        callDrawnow=true;
                    end
                end
            end

            if callDrawnow
                drawnow limitrate;
            end
        end
    end

    methods(Access=private)
        function deleteObjects(this)
            if~isempty(this.hObjects)
                N=length(this.hObjects);
                for i=N:-1:1
                    delete(this.hObjects{i});
                end
                this.hObjects={};
            end
        end

        function deleteCallbacks(this)
            if~isempty(this.hCallbacks)
                N=length(this.hCallbacks);
                for i=N:-1:1
                    delete(this.hCallbacks{i});
                end
                this.hCallbacks={};
            end
        end

        function[agi,si]=addSignalWork(this,signalType,signal,varargin)




            agi=-1;
            si=-1;


            if~isempty(this.LockedByTarget)
                slrealtime.internal.throw.Error('slrealtime:instrument:LockedByTarget');
            end



            if mod(length(varargin),2)==1

                sigs=slrealtime.internal.instrument.Util.checkAndFormatSignalArgs(signal,varargin{1});
                args=varargin(2:end);
            else

                sigs=slrealtime.internal.instrument.Util.checkAndFormatSignalArgs(signal);
                args=varargin(:);
            end



            parser=inputParser;
            parser.FunctionName=mfilename;
            parser.addRequired('this',@(x)(isa(x,'slrealtime.Instrument')));
            parser.addParameter('Decimation',this.DecimationDefault,@(x)(isnumeric(x)&&isscalar(x)&&x>0&&x==floor(x)));
            parser.addParameter('BusElement',[],@(x)(ischar(x)||isstring(x)));
            parser.addParameter('MetaData',sigs(1).metadata);
            parser.CaseSensitive=true;
            parser.KeepUnmatched=true;
            parser.parse(this,args{:});
            inputs=parser.Results;



            if~isempty(fields(parser.Unmatched))
                slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
            end


















            skipDecimation=isa(signal,'slrealtime.Instrument')&&any(strcmp(parser.UsingDefaults,'Decimation'));




            if~isempty(inputs.BusElement)
                if isempty(inputs.MetaData)
                    inputs.MetaData=struct('busElement',inputs.BusElement);
                else
                    inputs.MetaData.BusElement=inputs.BusElement;
                end
            end

            function index=findExistingSignal(signal)
                blockpath=signal.blockpath;
                portindex=signal.portindex;
                statename=signal.statename;
                signame=signal.signame;
                decimation=signal.decimation;
                buselement=signal.inputs.BusElement;

                addSignals=this.signals(arrayfun(@(x)x.type==slrealtime.internal.instrument.SignalTypes.ForCallback,this.signals));

                if~isempty(signame)
                    index=find(arrayfun(@(x)strcmp(signame,x.signame)&&x.decimation==decimation&&...
                    (strcmp(buselement,x.inputs.BusElement)||isequal(buselement,x.inputs.BusElement)),addSignals));
                else
                    bp=Simulink.SimulationData.BlockPath(blockpath);

                    if portindex~=-1
                        index=find(arrayfun(@(x)bp.isequal(x.blockpath)&&portindex==x.portindex&&x.decimation==decimation&&...
                        (strcmp(buselement,x.inputs.BusElement)||isequal(buselement,x.inputs.BusElement)),addSignals));
                    else
                        index=find(arrayfun(@(x)bp.isequal(x.blockpath)&&strcmp(statename,x.statename)&&x.decimation==decimation&&...
                        (strcmp(buselement,x.inputs.BusElement)||isequal(buselement,x.inputs.BusElement)),addSignals));
                    end
                end
                assert(isempty(index)||length(index)==1);
            end



            for i=1:length(sigs)
                if~skipDecimation
                    sigs(i).decimation=inputs.Decimation;
                else
                    inputs.Decimation=sigs(i).decimation;
                end
                sigs(i).type=signalType;
                sigs(i).inputs=inputs;
                sigs(i).metadata=inputs.MetaData;

                if~isempty(findExistingSignal(sigs(i)))

                    continue;
                end

                this.signals=[this.signals,sigs(i)];

                if~isempty(this.Application)
                    try
                        [agi,si]=this.validateSignal(sigs(i));
                    catch ME
                        str=slrealtime.Instrument.getSignalStringToDisplay(sigs(i));
                        slrealtime.internal.throw.Warning('slrealtime:instrument:CannotInstrument',str,ME.message);
                    end
                else
                    agi=-1;
                    si=-1;
                end
            end
        end

        function addInstrumentedSignalsForModel(this,codeDescriptor,modelBlockPath)

            taqBlocks=codeDescriptor.getTAQBlocks;
            for nTAQBlk=1:double(taqBlocks.Size)
                taqBlock=taqBlocks(nTAQBlk);

                if~taqBlock.IsLiveStreaming
                    continue;
                end





                if taqBlock.IsVirtualBus








                    leafs=taqBlock.LeafElements;
                    for nLeaf=1:double(leafs.Size)
                        leaf=leafs(nLeaf);
                        c=modelBlockPath.convertToCell();
                        actBlkPath=[c(:)',leaf.ActSrcBlockPath];
                        grBlkPath=[c(:)',leaf.BlockPath];

                        if codeDescriptor.getBlockHierarchyMap.ClientInfo.isPathWithinSubsystemWithHiddenContents(leaf.ActSrcBlockPath)
                            isPathWithinSubsystemWithHiddenContents=true;
                        else
                            isPathWithinSubsystemWithHiddenContents=false;
                        end

                        dims=[];
                        for nDim=1:leaf.Dimensions.Size
                            dims(nDim)=leaf.Dimensions(nDim);%#ok
                        end





                        signalNameTokens=split(leaf.SignalName,'.');

                        metadata=struct(...
                        'leafSignalNameToken',signalNameTokens{end},...
                        'name',leaf.SignalName,...
                        'grBlockPath',{grBlkPath},...
                        'grPortNumber',leaf.PortNumber,...
                        'startEl',leaf.ActSrcStartElement,...
                        'dimensions',dims,...
                        'signalSourceUUID',leaf.SignalSourceUUID,...
                        'signalSourceUUIDasInteger',leaf.SignalSourceUUIDasInteger,...
                        'isMessageLine',leaf.IsMessageLine,...
                        'isFrame',leaf.IsFrame,...
                        'sampleTimeString',leaf.SampleTimeString,...
                        'domainType',leaf.DomainType,...
                        'maxPoints',leaf.MaxPoints,...
                        'isPathWithinSubsystemWithHiddenContents',isPathWithinSubsystemWithHiddenContents,...
                        'loggedName',leaf.LoggedName,...
                        'propagatedName',leaf.PropagatedName...
                        );

                        args={};
                        if taqBlock.Decimation~=1
                            args{1}='Decimation';
                            args{2}=double(leaf.Decimation);
                        end

                        this.addSignalWork(slrealtime.internal.instrument.SignalTypes.Badged,actBlkPath,leaf.ActSrcPortNumber+1,'MetaData',metadata,args{:});
                    end
                else
                    if codeDescriptor.getBlockHierarchyMap.ClientInfo.isPathWithinSubsystemWithHiddenContents(taqBlock.ActSrcBlockPath)
                        isPathWithinSubsystemWithHiddenContents=true;
                    else
                        isPathWithinSubsystemWithHiddenContents=false;
                    end
                    c=modelBlockPath.convertToCell();
                    actBlkPath=[c(:)',taqBlock.ActSrcBlockPath];
                    grBlkPath=[c(:)',taqBlock.BlockPath];

                    dims=[];
                    for nDim=1:taqBlock.Dimensions.Size
                        dims(nDim)=taqBlock.Dimensions(nDim);%#ok
                    end

                    metadata=struct(...
                    'name',taqBlock.SignalName,...
                    'grBlockPath',{grBlkPath},...
                    'grPortNumber',taqBlock.PortNumber,...
                    'startEl',taqBlock.ActSrcStartElement,...
                    'dimensions',dims,...
                    'signalSourceUUID',taqBlock.SignalSourceUUID,...
                    'signalSourceUUIDasInteger',taqBlock.SignalSourceUUIDasInteger,...
                    'isMessageLine',taqBlock.IsMessageLine,...
                    'isFrame',taqBlock.IsFrame,...
                    'sampleTimeString',taqBlock.SampleTimeString,...
                    'domainType',taqBlock.DomainType,...
                    'maxPoints',taqBlock.MaxPoints,...
                    'loggedName',taqBlock.LoggedName,...
                    'propagatedName',taqBlock.PropagatedName,...
                    'isPathWithinSubsystemWithHiddenContents',isPathWithinSubsystemWithHiddenContents...
                    );

                    args={};
                    if taqBlock.Decimation~=1
                        args{1}='Decimation';
                        args{2}=double(taqBlock.Decimation);
                    end

                    this.addSignalWork(slrealtime.internal.instrument.SignalTypes.Badged,actBlkPath,taqBlock.ActSrcPortNumber+1,'MetaData',metadata,args{:});
                end
            end

            bhm=codeDescriptor.getBlockHierarchyMap();





            sfBlks=bhm.getBlocksByType('Stateflow');
            for nSfBlk=1:length(sfBlks)
                sfBlk=sfBlks(nSfBlk);
                sfInfoArray=sfBlk.StateflowLoggingMap.toArray;

                c=modelBlockPath.convertToCell();
                blkPath={c{:},sfBlk.Path};%#ok

                for nSfBlkLoggingInfo=1:sfBlk.LoggingInfo.Size()
                    li=sfBlk.LoggingInfo(nSfBlkLoggingInfo);
                    if li.IsLogged
                        ssid=li.SSId;
                        if strcmp(li.Mode,'Self')
                            mode=coder.descriptor.LoggingModeEnum.SELF_ACTIVITY;
                            desc=':IsActive';
                        elseif strcmp(li.Mode,'Child')
                            mode=coder.descriptor.LoggingModeEnum.CHILD_ACTIVITY;
                            desc=':ActiveChild';
                        elseif strcmp(li.Mode,'Leaf')
                            mode=coder.descriptor.LoggingModeEnum.LEAF_ACTIVITY;
                            desc=':ActiveLeaf';
                        else
                            mode=coder.descriptor.LoggingModeEnum.LOCAL_DATA;
                            desc='';
                        end

                        sfInfo=sfInfoArray(arrayfun(@(x)(x.StateflowLoggingTuple.LoggingMode==mode&&x.StateflowLoggingTuple.Ssid==ssid),sfInfoArray));
                        if~isempty(sfInfo)
                            metadata=struct(...
                            'ssid',ssid,...
                            'loggingMode',mode...
                            );







                            this.addSignalWork(slrealtime.internal.instrument.SignalTypes.Badged,blkPath,[sfInfo(1).StateflowLoggingTuple.SourceObjectName,desc],'MetaData',metadata);
                        end
                    end
                end
            end





            mdlBlks=bhm.getBlocksByType('ModelReference');
            for nMdlBlk=1:length(mdlBlks)
                mdlBlk=mdlBlks(nMdlBlk);
                if mdlBlk.IsProtectedModelBlock
                    continue;
                end

                try
                    subCodeDescriptor=codeDescriptor.getReferencedModelCodeDescriptor(mdlBlk.ReferencedModelName);
                catch
                    subCodeDescriptor=[];
                end
                if isempty(subCodeDescriptor)
                    continue;
                end

                c=modelBlockPath.convertToCell();
                modelBlockPath=Simulink.SimulationData.BlockPath([c(:)',{mdlBlk.Path}]);
                this.addInstrumentedSignalsForModel(subCodeDescriptor,modelBlockPath);
                modelBlockPath=Simulink.SimulationData.BlockPath(c);
            end
        end

        function[agi,si]=validateSignal(this,signalstruct)
            agi=-1;
            si=-1;
            if signalstruct.type~=slrealtime.internal.instrument.SignalTypes.Badged


                output=this.AcquireList.AcquireListModel.getAcquireSignalIndex(signalstruct);
                agi=output.acquiregroupindex;
                si=output.signalindex;
            end

            if si==-1








                if this.StreamingOnly
                    signalType=slrealtime.internal.instrument.SignalTypes.Badged;
                else
                    signalType=slrealtime.internal.instrument.SignalTypes.ForCallback;
                end

                output=this.AcquireList.AcquireListModel.addSignal(...
                signalstruct,signalType,this.CodeDescriptor,this.TaskInfo);
                agi=output.acquiregroupindex;
                si=output.signalindex;

                if si==-1


                    return;
                end


                for nSig=1:numel(agi)
                    sig_agi=agi(nSig);
                    sig_si=si(nSig);
                    if sig_si==-1,continue;end
                    this.AcquireList.AcquireListModel.AcquireGroups(sig_agi).xcpSignals(sig_si).instrumentUUID=this.UUID;
                    this.AcquireList.AcquireListModel.AcquireGroups(sig_agi).xcpSignals(sig_si).displayInSDI=this.StreamingOnly;
                end
            end
        end

        function validateScalarSignal(this,signalstruct)
            hDisp=signalstruct.inputs.hDisp;
            arrayIndex=signalstruct.inputs.ArrayIndex;

            output=this.AcquireList.AcquireListModel.getAcquireSignalIndex(signalstruct);
            agi=output.acquiregroupindex;
            si=output.signalindex;

            if si==-1

                output=this.AcquireList.AcquireListModel.addSignal(...
                signalstruct,signalstruct.type,this.CodeDescriptor,this.TaskInfo);
                agi=output.acquiregroupindex;
                si=output.signalindex;

                if si==-1


                    return;
                end


                for nSig=1:numel(agi)
                    sig_agi=agi(nSig);
                    sig_si=si(nSig);
                    if sig_si==-1,continue;end
                    this.AcquireList.AcquireListModel.AcquireGroups(sig_agi).xcpSignals(sig_si).instrumentUUID=this.UUID;
                    this.AcquireList.AcquireListModel.AcquireGroups(sig_agi).xcpSignals(sig_si).displayInSDI=this.StreamingOnly;
                end
            end



            if length(si)>1
                sigStr=slrealtime.Instrument.getSignalStringToDisplay(signalstruct);
                controlStr=class(hDisp);
                slrealtime.internal.throw.Error('slrealtime:instrument:ScalarControlTooManySignals',sigStr,controlStr);
            end

            sig=this.AcquireList.AcquireListModel.AcquireGroups(agi).xcpSignals(si);



            if length(sig.dimensions)>2
                str=slrealtime.Instrument.getSignalStringToDisplay(sig);
                slrealtime.internal.throw.Error('slrealtime:instrument:ScalarControlMoreThanTwoDims',str,num2str(length(sig.dimensions)));
            end



            if~isempty(arrayIndex)
                if length(arrayIndex)~=length(sig.dimensions)
                    str=slrealtime.Instrument.getSignalStringToDisplay(sig);
                    slrealtime.internal.throw.Error('slrealtime:instrument:ScalarControlArrayIndexWrongDims',num2str(length(sig.dimensions)),str);
                end
                if any(arrayIndex>sig.dimensions)
                    str=slrealtime.Instrument.getSignalStringToDisplay(sig);
                    slrealtime.internal.throw.Error('slrealtime:instrument:ScalarControlArrayIndexInvalidValue',num2str(sig.dimensions),str);
                end
            end

            sigIndexInfo=struct(...
            'acquiregroupindex',agi,...
            'signalindex',si,...
            'arrayindex',arrayIndex);

            options=struct(...
            'PropertyName',signalstruct.inputs.PropertyName,...
            'Callback',signalstruct.inputs.Callback);

            this.hObjects{end+1}=slrealtime.internal.instrument.Scalar(this,hDisp,sigIndexInfo,options);
        end

        function validateLineSignal(this,signalstruct)
            hAxes=signalstruct.inputs.hAxes;
            arrayIndex=signalstruct.inputs.ArrayIndex;

            output=this.AcquireList.AcquireListModel.getAcquireSignalIndex(signalstruct);
            agis=output.acquiregroupindex;
            sis=output.signalindex;

            if sis==-1

                output=this.AcquireList.AcquireListModel.addSignal(...
                signalstruct,signalstruct.type,this.CodeDescriptor,this.TaskInfo);
                agis=output.acquiregroupindex;
                sis=output.signalindex;


                for nSig=1:numel(agis)
                    sig_agi=agis(nSig);
                    sig_si=sis(nSig);
                    if sig_si==-1,continue;end
                    this.AcquireList.AcquireListModel.AcquireGroups(sig_agi).xcpSignals(sig_si).instrumentUUID=this.UUID;
                    this.AcquireList.AcquireListModel.AcquireGroups(sig_agi).xcpSignals(sig_si).displayInSDI=this.StreamingOnly;
                end
            end

            function addLineLocal(agi,si,arrayi,options)
                index=struct(...
                'acquiregroupindex',agi,...
                'signalindex',si,...
                'arrayindex',arrayi);

                if isnumeric(options.LineStyle.Color)&&all(options.LineStyle.Color==[-1,-1,-1])
                    ls=slrealtime.instrument.LineStyle(options.LineStyle);
                    options.LineStyle=ls;
                    colors=lines(this.nLine+1);
                    options.LineStyle.Color=colors(this.nLine+1,:);
                end

                hline=slrealtime.internal.instrument.Line(this,hAxes,index,options);
                this.hObjects{end+1}=hline;
                this.nLine=this.nLine+1;
            end

            for nSig=1:length(sis)
                agi=agis(nSig);
                si=sis(nSig);

                if si==-1


                    continue;
                end

                sig=this.AcquireList.AcquireListModel.AcquireGroups(agi).xcpSignals(si);



                if length(sig.dimensions)>2
                    str=slrealtime.Instrument.getSignalStringToDisplay(sig);
                    slrealtime.internal.throw.Error('slrealtime:instrument:AxesControlMoreThanTwoDims',str,num2str(length(sig.dimensions)));
                end



                if~isempty(arrayIndex)
                    if length(arrayIndex)~=length(sig.dimensions)
                        str=slrealtime.Instrument.getSignalStringToDisplay(sig);
                        slrealtime.internal.throw.Error('slrealtime:instrument:AxesControlArrayIndexWrongDims',num2str(length(sig.dimensions)),str);
                    end
                    if any(arrayIndex>sig.dimensions)
                        str=slrealtime.Instrument.getSignalStringToDisplay(sig);
                        slrealtime.internal.throw.Error('slrealtime:instrument:AxesControlArrayIndexInvalidValue',num2str(sig.dimensions),str);
                    end
                end

                if sig.isArraySignal
                    if~isempty(arrayIndex)
                        addLineLocal(agi,si,arrayIndex,signalstruct.inputs);
                    else
                        if numel(sig.dimensions)==1
                            for i=1:sig.dimensions
                                addLineLocal(agi,si,i,signalstruct.inputs);
                            end
                        else
                            for i=1:sig.dimensions(1)
                                for j=1:sig.dimensions(2)
                                    addLineLocal(agi,si,[i,j],signalstruct.inputs);
                                end
                            end
                        end
                    end
                else
                    addLineLocal(agi,si,1,signalstruct.inputs);
                end
            end
        end

        function res=copyStruct(this,d,nTimePt)


            res=[];
            f=fields(d);
            for nField=1:length(f)
                if isstruct(d.(f{nField}))
                    res.(f{nField})=this.copyStruct(d.(f{nField}),nTimePt);
                else
                    if numel(size(d.(f{nField})))>2
                        otherdims=repmat({':'},1,ndims(d.(f{nField}))-1);
                        res.(f{nField})=d.(f{nField})(otherdims{:},nTimePt);
                    else
                        res.(f{nField})=d.(f{nField})(nTimePt);
                    end
                end
            end
        end
    end

    methods(Hidden,Access=public)
        function[str,isDup]=getSignalStringForMap(this,signalStruct,decimation,busElement,xcpSignal)
            isDup=false;
            [sigStr,bppi,sn]=slrealtime.Instrument.getSignalStringToDisplay(signalStruct);
            if strcmp(sigStr,sn)

                if decimation==1
                    str=sn;
                else
                    str=sprintf('%s (decimation = %d)',sn,decimation);
                end

                if~isempty(busElement)
                    str=[str,' (',busElement,')'];
                end

                if this.Map.isKey(str)&&~isempty(xcpSignal)

















                    isDup=true;
                    [~,loc_bppi,~]=slrealtime.Instrument.getSignalStringToDisplay(xcpSignal);
                    str=sprintf('%s [%s]',str,loc_bppi);
                end

            else


                if decimation==1
                    str=bppi;
                else
                    str=sprintf('%s (decimation = %d)',bppi,decimation);
                end

                if~isempty(busElement)
                    str=[str,' (',busElement,')'];
                end
            end
        end

        function removeSignalByIndex(this,indices)


            this.signals(indices)=[];



            if~isempty(this.Application)
                this.validate(this.Application);
            end
        end
    end

    methods(Hidden,Static,Access=public)





        function[appfullpath,appname]=findApplicationMLDATXFile(application)
            in_app=application;

            appfullpath='';%#ok
            appname='';%#ok

            try
                validateattributes(application,{'char','string'},{'scalartext'});
                application=convertStringsToChars(application);
            catch
                slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
            end

            [filepath,fname,~]=fileparts(application);
            if isempty(filepath)
                application=which([fname,'.mldatx']);
            else
                application=fullfile(filepath,[fname,'.mldatx']);
            end

            if~exist(application,'file')
                slrealtime.internal.throw.Error('slrealtime:instrument:NoAppFile',in_app);
            end

            appfullpath=application;
            appname=fname;
        end

        function names=getSignalNames(instSignals)
            names=cell(length(instSignals),1);
            for i=1:length(instSignals)
                names{i}=slrealtime.Instrument.getSignalStringToDisplay(instSignals(i));
            end
        end

        function[bpstr]=blockPathObj2str(blockpath)
            signalCell=blockpath.convertToCell();
            if length(signalCell)>1
                bpstr=signalCell{1};
                for j=2:length(signalCell)
                    bpstr=strcat(bpstr,'/',extractAfter(signalCell{j},'/'));
                end
            else
                bpstr=signalCell{1};
            end
        end

        function[str,bppi,sn]=getSignalStringToDisplay(signal)

            if isa(signal,'slrealtime.internal.DataModels.SignalStruct')
                sn=signal.signalName;
                bpstr=slrealtime.Instrument.blockPathObj2str(signal.SimulationDataBlockPath);
                if signal.portIndex~=-1
                    bppi=strcat(bpstr,':',num2str(signal.portIndex));
                else
                    bppi=strcat(bpstr,':',signal.stateName);
                end

                if~isempty(signal.signalName)
                    str=sn;
                else
                    str=bppi;
                end

            elseif isa(signal,'slrealtime.internal.DataModels.XcpSignal')
                sn=signal.signalName;
                bpstr=slrealtime.Instrument.blockPathObj2str(signal.SimulationDataBlockPath);
                if signal.portNumber~=-1
                    bppi=strcat(bpstr,':',num2str(signal.portNumber+1));
                else
                    bppi=strcat(bpstr,':',signal.signalName);
                end

                if~isempty(signal.signalName)
                    str=sn;
                else
                    str=bppi;
                end

            else
                sn=signal.signame;
                bpstr=slrealtime.Instrument.blockPathObj2str(signal.blockpath);
                if signal.portindex~=-1
                    bppi=strcat(bpstr,':',num2str(signal.portindex));
                else
                    bppi=strcat(bpstr,':',signal.statename);
                end

                if~isempty(signal.signame)
                    str=sn;
                else
                    str=bppi;
                end

                if~isempty(signal.metadata)&&isfield(signal.metadata,'busElement')
                    str=[str,' (bus element ''',signal.metadata.busElement,''')'];

                end
            end
        end
    end
end
