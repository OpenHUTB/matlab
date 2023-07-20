classdef Link<matlabshared.satellitescenario.internal.ObjectArray %#codegen




    properties(Dependent,SetAccess=private)


Sequence
    end

    properties(Dependent,Access={?satelliteScenario,...
        ?matlabshared.satellitescenario.Viewer,...
        ?matlabshared.satellitescenario.ScenarioGraphic,...
        ?satcom.satellitescenario.Transmitter})
LinkGraphic

Simulator
SimulatorID
Parent
SequenceHandle

NodeType
TerminalNames
    end

    properties(Dependent,Access={?satelliteScenario,...
        ?matlabshared.satellitescenario.Viewer,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.ScenarioGraphic,...
        ?matlabshared.satellitescenario.internal.AssetWrapper,...
        ?matlabshared.satellitescenario.Access,...
        ?satcom.satellitescenario.Link})
Scenario
    end

    properties(Dependent)



LineWidth




LineColor
    end

    properties(Dependent,Access={?matlabshared.satellitescenario.Viewer})
pStatus
pStatusHistory
pIntervals
pNumIntervals
pEbNo
pEbNoHistory
pReceivedIsotropicPower
pReceivedIsotropicPowerHistory
pPowerAtReceiverInput
pPowerAtReceiverInputHistory
    end

    properties(Constant,Hidden)
        LightSpeed=299792458
        BoltzMann=1.3806504e-23;
    end

    methods
        function lineWidth=get.LineWidth(ac)


            handles=[ac.Handles{:}];

            if isempty(handles)
                lineWidth=[];
            else
                lineWidth=[handles.LineWidth];
            end
        end

        function lineColor=get.LineColor(ac)


            handles=[ac.Handles{:}];

            if isempty(handles)
                lineColor=[];
            else
                lineColor=[handles.LineColor];
            end
        end

        function ac=set.LineWidth(ac,lineWidth)


            handles=[ac.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).LineWidth=lineWidth;
            end
        end

        function ac=set.LineColor(ac,lineColor)


            handles=[ac.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).LineColor=lineColor;
            end
        end

        function s=get.Sequence(ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(ac,...
                {'satcom.satellitescenario.Link'},...
                {'scalar'},'get.Sequence','LINK');
                s=ac.Handles{1}.Sequence;
                return
            end

            handles=[ac.Handles{:}];

            if isempty(handles)
                s=[];
            else
                s=[handles.Sequence];
            end
        end

        function ac=set.Sequence(ac,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                ac.Handles{1}.Sequence=s;
                return
            end

            handles=[ac.Handles{:}];
            handles.Sequence=s;
        end

        function s=get.LinkGraphic(ac)


            handles=[ac.Handles{:}];

            if isempty(handles)
                s=string.empty;
            else
                s=[handles.LinkGraphic];
            end
        end

        function ac=set.LinkGraphic(ac,s)


            handles=[ac.Handles{:}];
            handles.LinkGraphic=s;
        end

        function s=get.Simulator(ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                s=ac.Handles{1}.Simulator;
                return
            end

            handles=[ac.Handles{:}];

            if isempty(handles)
                s=matlabshared.satellitescenario.internal.Simulator.empty;
            else
                s=[handles.Simulator];
            end
        end

        function ac=set.Simulator(ac,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                ac.Handles{1}.Simulator=s;
                return
            end

            handles=[ac.Handles{:}];
            handles.Simulator=s;
        end

        function s=get.SimulatorID(ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                s=ac.Handles{1}.SimulatorID;
                return
            end

            handles=[ac.Handles{:}];

            if isempty(handles)
                s=[];
            else
                s=[handles.SimulatorID];
            end
        end

        function ac=set.SimulatorID(ac,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                ac.Handles{1}.SimulatorID=s;
                return
            end

            handles=[ac.Handles{:}];
            handles.SimulatorID=s;
        end

        function s=get.Parent(ac)


            handles=[ac.Handles{:}];

            if isempty(handles)
                s=satcom.satellitescenario.Transmitter;
            else
                s=[handles.Parent];
            end
        end

        function ac=set.Parent(ac,s)


            handles=[ac.Handles{:}];
            handles.Parent=s;
        end

        function s=get.SequenceHandle(ac)


            handles=[ac.Handles{:}];

            if isempty(handles)
                s=satcom.satellitescenario.internal.CommDeviceWrapper;
            else
                s=[handles.SequenceHandle];
            end
        end

        function ac=set.SequenceHandle(ac,s)


            handles=[ac.Handles{:}];
            handles.SequenceHandle=s;
        end

        function s=get.NodeType(ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                s=ac.Handles{1}.NodeType;
                return
            end

            handles=[ac.Handles{:}];

            if isempty(handles)
                s=[];
            else
                s=[handles.NodeType];
            end
        end

        function ac=set.NodeType(ac,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                ac.Handles{1}.NodeType=s;
                return
            end

            handles=[ac.Handles{:}];
            handles.NodeType=s;
        end

        function s=get.TerminalNames(ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                s=ac.Handles{1}.TerminalNames;
                return
            end

            handles=[ac.Handles{:}];

            if isempty(handles)
                s=string.empty;
            else
                s=[handles.TerminalNames];
            end
        end

        function ac=set.TerminalNames(ac,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                ac.Handles{1}.TerminalNames=s;
                return
            end

            handles=[ac.Handles{:}];
            handles.TerminalNames=s;
        end

        function s=get.pStatus(ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                s=ac.Handles{1}.pStatus;
                return
            end

            handles=[ac.Handles{:}];

            if isempty(handles)
                s=false(0,0);
            else
                s=[handles.pStatus];
            end
        end

        function ac=set.pStatus(ac,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                ac.Handles{1}.pStatus=s;
                return
            end

            handles=[ac.Handles{:}];
            handles.pStatus=s;
        end

        function s=get.pStatusHistory(ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                s=ac.Handles{1}.pStatusHistory;
                return
            end

            handles=[ac.Handles{:}];

            if isempty(handles)
                s=false(0,0);
            else
                s=[handles.pStatusHistory];
            end
        end

        function ac=set.pStatusHistory(ac,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                ac.Handles{1}.pStatusHistory=s;
                return
            end

            handles=[ac.Handles{:}];
            handles.pStatusHistory=s;
        end

        function s=get.pIntervals(ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                s=ac.Handles{1}.pIntervals;
                return
            end

            handles=[ac.Handles{:}];

            if isempty(handles)
                t=NaT;
                t.TimeZone='UTC';
                s=struct("StartTime",t,"EndTime",t);
                s(1)=[];
            else
                s=[handles.pIntervals];
            end
        end

        function ac=set.pIntervals(ac,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                ac.Handles{1}.pIntervals=s;
                return
            end

            handles=[ac.Handles{:}];
            handles.pIntervals=s;
        end

        function s=get.pNumIntervals(ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                s=ac.Handles{1}.pNumIntervals;
                return
            end

            handles=[ac.Handles{:}];

            if isempty(handles)
                s=[];
            else
                s=[handles.pNumIntervals];
            end
        end

        function ac=set.pNumIntervals(ac,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                ac.Handles{1}.pNumIntervals=s;
                return
            end

            handles=[ac.Handles{:}];
            handles.pNumIntervals=s;
        end

        function s=get.pEbNo(ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                s=ac.Handles{1}.pEbNo;
                return
            end

            handles=[ac.Handles{:}];

            if isempty(handles)
                s=[];
            else
                s=[handles.pEbNo];
            end
        end

        function ac=set.pEbNo(ac,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                ac.Handles{1}.pEbNo=s;
                return
            end

            handles=[ac.Handles{:}];
            handles.pEbNo=s;
        end

        function s=get.pEbNoHistory(ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                s=ac.Handles{1}.pEbNoHistory;
                return
            end

            handles=[ac.Handles{:}];

            if isempty(handles)
                s=[];
            else
                s=[handles.pEbNoHistory];
            end
        end

        function ac=set.pEbNoHistory(ac,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                ac.Handles{1}.pEbNoHistory=s;
                return
            end

            handles=[ac.Handles{:}];
            handles.pEbNoHistory=s;
        end

        function s=get.pReceivedIsotropicPower(ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                s=ac.Handles{1}.pReceivedIsotropicPower;
                return
            end

            handles=[ac.Handles{:}];

            if isempty(handles)
                s=[];
            else
                s=[handles.pReceivedIsotropicPower];
            end
        end

        function ac=set.pReceivedIsotropicPower(ac,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                ac.Handles{1}.pReceivedIsotropicPower=s;
                return
            end

            handles=[ac.Handles{:}];
            handles.pReceivedIsotropicPower=s;
        end

        function s=get.pReceivedIsotropicPowerHistory(ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                s=ac.Handles{1}.pReceivedIsotropicPowerHistory;
                return
            end

            handles=[ac.Handles{:}];

            if isempty(handles)
                s=[];
            else
                s=[handles.pReceivedIsotropicPowerHistory];
            end
        end

        function ac=set.pReceivedIsotropicPowerHistory(ac,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                ac.Handles{1}.pReceivedIsotropicPowerHistory=s;
                return
            end

            handles=[ac.Handles{:}];
            handles.pReceivedIsotropicPowerHistory=s;
        end

        function s=get.pPowerAtReceiverInput(ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                s=ac.Handles{1}.pPowerAtReceiverInput;
                return
            end

            handles=[ac.Handles{:}];

            if isempty(handles)
                s=[];
            else
                s=[handles.pPowerAtReceiverInput];
            end
        end

        function ac=set.pPowerAtReceiverInput(ac,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                ac.Handles{1}.pPowerAtReceiverInput=s;
                return
            end

            handles=[ac.Handles{:}];
            handles.pPowerAtReceiverInput=s;
        end

        function s=get.pPowerAtReceiverInputHistory(ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                s=ac.Handles{1}.pPowerAtReceiverInputHistory;
                return
            end

            handles=[ac.Handles{:}];

            if isempty(handles)
                s=[];
            else
                s=[handles.pPowerAtReceiverInputHistory];
            end
        end

        function ac=set.pPowerAtReceiverInputHistory(ac,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                ac.Handles{1}.pPowerAtReceiverInputHistory=s;
                return
            end

            handles=[ac.Handles{:}];
            handles.pPowerAtReceiverInputHistory=s;
        end

        function sc=get.Scenario(obj)


            handles=[obj.Handles{:}];

            if isempty(handles)
                sc=satelliteScenario.empty;
            else
                sc=[handles.Scenario];
            end
        end

        function obj=set.Scenario(obj,sc)


            obj.Handles{1}.Scenario=sc;
        end
    end

    methods(Access={?satelliteScenario,...
        ?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.ScenarioGraphic})
        function lnk=Link(source,varargin)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                lnk.Handles={satcom.satellitescenario.internal.Link};
                lnk.Handles=cell(1,0);
            else
                lnk.Handles=cell(1,0);
            end






            if nargin>1


                handles={satcom.satellitescenario.internal.Link(...
                source,varargin{:})};


                lnk.Handles=handles;
            end
        end
    end

    methods(Access=private)
        function idx=getIdxInSimulatorStruct(lnk)



            coder.allowpcode('plain');


            simulator=lnk.Simulator;


            simID=lnk.SimulatorID;


            if simulator.NeedToMemoizeSimID
                memoizeSimID(simulator);
            end


            idx=simulator.SimIDMemo(simID);
        end

        function tf=isLastTwoNodesSameParent(lnk)





            sequence=lnk.Sequence;
            penultimateNodeID=sequence(end-1);
            penultimateNodeType=lnk.NodeType(end-1);
            finalNodeID=sequence(end);


            simulator=lnk.Simulator;



            if simulator.NeedToMemoizeSimID
                memoizeSimID(simulator);
            end



            idx=simulator.SimIDMemo(penultimateNodeID);


            if penultimateNodeType==5
                penultimateNodeGrandParentID=simulator.Transmitters(idx).GrandParentSimulatorID;
            else
                penultimateNodeGrandParentID=simulator.Receivers(idx).GrandParentSimulatorID;
            end



            idx=simulator.SimIDMemo(finalNodeID);


            finalNodeGrandParentID=simulator.Receivers(idx).GrandParentSimulatorID;



            tf=penultimateNodeGrandParentID==finalNodeGrandParentID;
        end
    end

    methods(Static,Access={?matlabshared.satellitescenario.internal.Simulator})
        [statHistory,ebnoHistory,ripHistory,rxInputPowerHistory,intervals,numIntervals]=getStatus(...
        sequence,nodeType,nodeIndex,sat,gs,tx,rx,simIDMemo,timeHistoryArray,...
        usingGaussianAntenna,numSamples,updateTaper)

        [statHistory,ebnoHistory,ripHistory,rxInputPowerHistory,intervals,numIntervals]=cg_getStatus(...
        sequence,nodeType,nodeIndex,sat,gs,tx,rx,simIDMemo,timeHistoryArray,...
        usingGaussianAntenna,numSamples,updateTaper)
    end

    methods
        [stat,time]=linkStatus(lnk,varargin)
        lnkPercent=linkPercentage(lnk)
        intvls=linkIntervals(lnk)
        [e,time]=ebno(lnk,varargin)
        [rip,rxInputPower,time]=sigstrength(lnk,varargin)
    end

    methods(Hidden)
        disp(lnk)
    end

    methods(Hidden,Static)
        function lnk=loadobj(s)


            if isa(s,'matlabshared.satellitescenario.internal.ObjectArray')


                lnk=s;
            else





                lnk=satcom.satellitescenario.Link;

                if isfield(s,'Handles')


                    lnk.Handles=s.Handles;
                else





                    lnkHandle=satcom.satellitescenario.internal.Link;
                    lnk.Handles={lnkHandle};


                    lnkHandle.Sequence=s.Sequence;
                    lnkHandle.LinkGraphic=s.LinkGraphic;
                    lnkHandle.Simulator=s.Simulator;
                    lnkHandle.SimulatorID=s.SimulatorID;
                    lnkHandle.NodeType=s.NodeType;
                    lnkHandle.TerminalNames=s.TerminalNames;
                    lnkHandle.ZoomHeight=s.ZoomHeight;
                    lnkHandle.pLineWidth=s.pLineWidth;
                    lnkHandle.pLineColor=s.pLineColor;
                    lnkHandle.ColorConverter=s.ColorConverter;

                    if~isempty(s.Parent)



                        lnkHandle.Parent=s.Parent;
                        s.Parent.Links=[s.Parent.Links,lnk];




                        ids=s.Parent.Links.SimulatorID;
                        [~,sortIdx]=sort(ids);
                        s.Parent.Links=s.Parent.Links(sortIdx);
                    end
                end
            end
        end
    end
end

