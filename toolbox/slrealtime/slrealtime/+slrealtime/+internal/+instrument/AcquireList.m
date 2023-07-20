classdef AcquireList<handle






    properties(SetAccess=protected)
        AcquireListModel;
        mf0model;
    end

    methods

        function obj=AcquireList(mldatxfile)
            if nargin==0
                obj.mf0model=0;
                obj.AcquireListModel=[];
            else
                m=mf.zero.Model;
                obj.mf0model=m;
                obj.AcquireListModel=slrealtime.internal.DataModels.AcquireListModel(m);
                obj.AcquireListModel.mldatxfile=mldatxfile;
            end
        end


        function[agi,si]=addSignal(this,isignal,varargin)


            inputs=parseAddSignalInputs(this,isignal,varargin);


            InputSignals=inputs.Signals;


            agi=[];
            si=[];
            for iis=1:length(InputSignals)
                signalStruct=InputSignals(iis);

                output=this.AcquireListModel.addSignal(signalStruct);
                agi=[agi,output.acquiregroupindex];%#ok
                si=[si,output.signalindex];%#ok
            end

        end



        function acquireIndexMap=removeSignal(this,agIndex,sIndex)
            acquireIndexMap=this.AcquireListModel.removeSignal(agIndex,sIndex);
        end


        function view(this)
            this.AcquireListModel.view();
        end


    end

    methods(Access=public,Hidden)

        function acquireList=duplicate(this)
            if isempty(this.AcquireListModel)
                acquireList=slrealtime.internal.instrument.AcquireList();
                return;
            end

            acquireList=slrealtime.internal.instrument.AcquireList(this.AcquireListModel.mldatxfile);
            for agi=1:this.AcquireListModel.nAcquireGroups
                [signalStructs]=getAcquireSignalStruct(this.AcquireListModel,agi);
                for si=1:this.AcquireListModel.AcquireGroups(agi).nSignals
                    signal=struct(...
                    'blockpath',signalStructs(si).SimulationDataBlockPath,...
                    'portindex',signalStructs(si).portIndex,...
                    'signame',signalStructs(si).signalName,...
                    'statename','',...
                    'decimation',this.AcquireListModel.AcquireGroups(agi).decimation);

                    signalStruct=this.AcquireListModel.AcquireGroups(agi).signalStructs(si);
                    xcpSignal=this.AcquireListModel.AcquireGroups(agi).xcpSignals(si);
                    output=acquireList.AcquireListModel.addSignalFromXcpSignalInfo(signalStruct,xcpSignal,signal.decimation);
                    globagi=output.acquiregroupindex;
                    globsi=output.signalindex;

                    if(this.AcquireListModel.AcquireGroups(agi).xcpSignals(si).attachMatlabObs)

                        metadata=struct(...
                        'matlabObsFcn',this.AcquireListModel.AcquireGroups(agi).xcpSignals(si).matlabObsFcn,...
                        'matlabObsParam',this.AcquireListModel.AcquireGroups(agi).xcpSignals(si).matlabObsParam,...
                        'matlabObsCallbackGroup',this.AcquireListModel.AcquireGroups(agi).xcpSignals(si).matlabObsCallbackGroup,...
                        'matlabObsFuncHandle',this.AcquireListModel.AcquireGroups(agi).xcpSignals(si).matlabObsFuncHandle,...
                        'matlabObsDropIfBusy',this.AcquireListModel.AcquireGroups(agi).xcpSignals(si).matlabObsDropIfBusy...
                        );
                        acquireList.AcquireListModel.AcquireGroups(globagi).xcpSignals(globsi).fillMATLABObserverInfo(metadata);
                    end
                end
            end
        end
    end

    methods(Static)
        function[ALadded,ALremoved]=findDifference(ALorig,ALnew)
            mldatxfile=ALorig.AcquireListModel.mldatxfile;
            ALadded=slrealtime.internal.instrument.AcquireList(mldatxfile);
            ALremoved=slrealtime.internal.instrument.AcquireList(mldatxfile);



            for agi=1:ALorig.AcquireListModel.nAcquireGroups
                tid=ALorig.AcquireListModel.AcquireGroups(agi).tid;
                discreteInterval=ALorig.AcquireListModel.AcquireGroups(agi).discreteInterval;
                sampleTimeString=ALorig.AcquireListModel.AcquireGroups(agi).sampleTimeString;
                decimation=ALorig.AcquireListModel.AcquireGroups(agi).decimation;
                ALadded.AcquireListModel.addAcquireGroup(tid,discreteInterval,sampleTimeString,decimation);
                ALremoved.AcquireListModel.addAcquireGroup(tid,discreteInterval,sampleTimeString,decimation);
            end
            for agi=1:ALnew.AcquireListModel.nAcquireGroups
                tid=ALnew.AcquireListModel.AcquireGroups(agi).tid;
                discreteInterval=ALnew.AcquireListModel.AcquireGroups(agi).discreteInterval;
                sampleTimeString=ALnew.AcquireListModel.AcquireGroups(agi).sampleTimeString;
                decimation=ALnew.AcquireListModel.AcquireGroups(agi).decimation;
                agindex=ALadded.AcquireListModel.getAcquireGroupIndex(tid,decimation);
                if agindex==-1
                    ALadded.AcquireListModel.addAcquireGroup(tid,discreteInterval,sampleTimeString,decimation);
                    ALremoved.AcquireListModel.addAcquireGroup(tid,discreteInterval,sampleTimeString,decimation);
                end
            end



            foundInOrig=zeros(ALorig.AcquireListModel.nAcquireGroups,ALorig.AcquireListModel.MaxGroupLength);
            for agi=1:ALnew.AcquireListModel.nAcquireGroups
                for si=1:ALnew.AcquireListModel.AcquireGroups(agi).nSignals
                    xcpSignal=ALnew.AcquireListModel.AcquireGroups(agi).xcpSignals(si);








                    newSignalStruct=struct(...
                    'blockpath',xcpSignal.SimulationDataBlockPath,...
                    'portindex',xcpSignal.portNumber+1,...
                    'signame','',...
                    'statename','',...
                    'decimation',ALnew.AcquireListModel.AcquireGroups(agi).decimation);


                    output=ALorig.AcquireListModel.getAcquireSignalIndex(newSignalStruct,'first',xcpSignal.instrumentUUID);
                    if output.signalindex==-1

                        signalStruct=ALnew.AcquireListModel.AcquireGroups(agi).signalStructs(si);
                        output=ALadded.AcquireListModel.addSignalFromXcpSignalInfo(signalStruct,xcpSignal,newSignalStruct.decimation);
                        globagi=output.acquiregroupindex;
                        globsi=output.signalindex;


                        if xcpSignal.attachMatlabObs

                            metadata=struct(...
                            'matlabObsFcn',xcpSignal.matlabObsFcn,...
                            'matlabObsParam',xcpSignal.matlabObsParam,...
                            'matlabObsCallbackGroup',xcpSignal.matlabObsCallbackGroup,...
                            'matlabObsFuncHandle',xcpSignal.matlabObsFuncHandle,...
                            'matlabObsDropIfBusy',xcpSignal.matlabObsDropIfBusy...
                            );
                            ALadded.AcquireListModel.AcquireGroups(globagi).xcpSignals(globsi).fillMATLABObserverInfo(metadata);
                        end
                    else
                        foundInOrig(output.acquiregroupindex,output.signalindex)=1;
                    end
                end
            end


            for agi=1:ALorig.AcquireListModel.nAcquireGroups
                decimation=ALorig.AcquireListModel.AcquireGroups(agi).decimation;
                xcpSignals=ALorig.AcquireListModel.getAcquireXcpSignal(agi);

                for si=1:ALorig.AcquireListModel.AcquireGroups(agi).nSignals
                    if foundInOrig(agi,si)

                    else









                        signalStruct=ALorig.AcquireListModel.AcquireGroups(agi).signalStructs(si);
                        signalStruct.SimulationDataBlockPath=xcpSignals(si).SimulationDataBlockPath;
                        signalStruct.blockPath=xcpSignals(si).SimulationDataBlockPath.convertToCell();
                        signalStruct.portIndex=xcpSignals(si).portNumber+1;
                        signalStruct.signalName='';
                        signalStruct.stateName='';
                        ALremoved.AcquireListModel.addSignalFromXcpSignalInfo(signalStruct,xcpSignals(si),decimation);
                    end
                end
            end
        end
    end

    methods(Access=private)


        function inputs=parseAddSignalInputs(obj,signal,argin)

            defaults=obj.optionalAddSignalInputDefaults;

            parser=inputParser;
            parser.FunctionName=mfilename;

            parser.addRequired('obj',@(x)(isa(x,'slrealtime.internal.instrument.AcquireList')));
            parser.addOptional('Decimation',defaults.Decimation);
            parser.addOptional('MetaData',defaults.MetaData);

            parser.CaseSensitive=true;
            parser.KeepUnmatched=true;

            if mod(length(argin),2)==1


                [signals]=slrealtime.internal.instrument.Util.checkAndFormatSignalArgs(signal,argin{1});
                parse(parser,obj,argin{2:end})
            else

                [signals]=slrealtime.internal.instrument.Util.checkAndFormatSignalArgs(signal);
                parse(parser,obj,argin{:})
            end


            inputs=parser.Results;


            for i=1:length(signals)
                signals(i).decimation=inputs.Decimation;
                signals(i).metadata=inputs.MetaData;
            end


            inputs.Signals=signals;

        end
    end


    methods(Access=private,Static)

        function defaults=optionalAddSignalInputDefaults
            defaults=struct(...
            'Decimation',1,...
            'MetaData',[]);
        end
    end





end

