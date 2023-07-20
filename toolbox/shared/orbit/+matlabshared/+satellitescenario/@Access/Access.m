classdef Access<matlabshared.satellitescenario.internal.ObjectArray %#codegen




    properties(Dependent,SetAccess=private)




Sequence
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

    properties(Dependent,Access={?satelliteScenario,?matlabshared.satellitescenario.Viewer,?matlabshared.satellitescenario.ScenarioGraphic})
AccessGraphic

Simulator
SimulatorID
Parent
SequenceHandle

NodeType
TerminalNames
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
                {'matlabshared.satellitescenario.Access'},...
                {'scalar'},'get.Sequence','AC');
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

        function s=get.AccessGraphic(ac)


            handles=[ac.Handles{:}];

            if isempty(handles)
                s=cell(0,0);
            else
                s=[handles.AccessGraphic];
            end
        end

        function ac=set.AccessGraphic(ac,s)


            handles=[ac.Handles{:}];
            handles.AccessGraphic=s;
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
                s=matlabshared.satellitescenario.internal.AssetWrapper;
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
                s=matlabshared.satellitescenario.internal.AssetWrapper;
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
                s=strings(0,0);
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
        function ac=Access(source,varargin)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                ac.Handles={matlabshared.satellitescenario.internal.Access};
                ac.Handles=cell(1,0);
            else
                ac.Handles=cell(1,0);
            end






            if nargin>1


                handles={matlabshared.satellitescenario.internal.Access(...
                source,varargin{:})};


                ac.Handles=handles;
            end
        end
    end

    methods(Access=private)
        function idx=getIdxInSimulatorStruct(ac)



            coder.allowpcode('plain');


            simulator=ac.Simulator;


            simID=ac.SimulatorID;


            if simulator.NeedToMemoizeSimID
                memoizeSimID(simulator);
            end


            idx=simulator.SimIDMemo(simID);
        end
    end

    methods(Static,Hidden)
        [statHistory,intervals,numIntervals]=getStatus(...
        sequence,nodeType,nodeIndex,sat,gs,sensor,simIDMemo,timeHistoryArray,numSamples)
        [statHistory,intervals,numIntervals]=cg_getStatus(...
        sequence,nodeType,nodeIndex,sat,gs,sensor,simIDMemo,timeHistoryArray,numSamples)
    end

    methods
        [stat,time]=accessStatus(ac,varargin)
        acPercent=accessPercentage(ac)
        intvls=accessIntervals(ac)
    end

    methods(Hidden)
        disp(ac)
    end

    methods(Hidden,Static)
        function ac=loadobj(s)


            coder.allowpcode('plain');

            if isa(s,'matlabshared.satellitescenario.internal.ObjectArray')


                ac=s;
            else





                ac=matlabshared.satellitescenario.Access;

                if isfield(s,'Handles')


                    ac.Handles=s.Handles;
                else





                    acHandle=matlabshared.satellitescenario.internal.Access;
                    ac.Handles={acHandle};


                    acHandle.Sequence=s.Sequence;
                    acHandle.AccessGraphic=s.AccessGraphic;
                    acHandle.Simulator=s.Simulator;
                    acHandle.SimulatorID=s.SimulatorID;
                    acHandle.NodeType=s.NodeType;
                    acHandle.TerminalNames=s.TerminalNames;
                    acHandle.ZoomHeight=s.ZoomHeight;
                    acHandle.pLineWidth=s.pLineWidth;
                    acHandle.pLineColor=s.pLineColor;
                    acHandle.ColorConverter=s.ColorConverter;

                    if~isempty(s.Parent)



                        acHandle.Parent=s.Parent;
                        s.Parent.Accesses=[s.Parent.Accesses,ac];




                        ids=s.Parent.Accesses.SimulatorID;
                        [~,sortIdx]=sort(ids);
                        s.Parent.Accesses=s.Parent.Accesses(sortIdx);
                    end
                end
            end
        end
    end
end

