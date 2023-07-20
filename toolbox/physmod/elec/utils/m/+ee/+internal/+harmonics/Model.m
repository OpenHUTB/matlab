classdef Model<handle





    properties
VariableToPlot
        VariableOption=1;
SimulationTime
        NumberOfHarmonics=30;
        DcOffset=0;
        NumberOfPeriods=12;
SignalDimension
FundamentalFrequency
HarmonicOrder
HarmonicMagnitude
Simlog
CurrentNode
TreeNodeselected
        TimeInterval=[];
    end

    properties(SetAccess=private)
Status
    end

    properties(Dependent)
SignalTimeStartValue
SignalTimeEndValue
    end

    events
ModelUpdated
StatusChanged
    end

    methods
        function obj=Model()

        end

        function initializeAppStatus(obj)


            obj.Status=getString(message('physmod:ee:harmonicAnalyzer:LoadSimulatedData'));
            notify(obj,'StatusChanged');
        end

        function[LogPath,phaseOfSignal,blockFullPath]=getPathFromTreeNode(obj)














            [LogPath,phaseOfSignal,blockFullPath]=lGetPathFromNode(obj.TreeNodeselected);
        end

        function nodeType=checkNodeType(obj)




            if~isempty(obj.CurrentNode)
                nodeDimension=obj.CurrentNode.series.dimension;
                if nodeDimension(2)&&isempty(obj.CurrentNode.childIds)
                    nodeType='Leaf Node';
                else
                    nodeType='Non Leaf Node';
                    obj.Status=getString(message('physmod:ee:harmonicAnalyzer:NonLeafNodeSelected'));
                    notify(obj,'StatusChanged');
                end
            end
        end

        function[plotTime,plotValue]=computeSignalPlot(obj)


            plotTime=obj.CurrentNode.series.time;
            plotValue=obj.CurrentNode.series.values;
            if obj.CurrentNode.series.dimension(2)>1
                if~isempty(obj.VariableOption)
                    plotValue=plotValue(:,obj.VariableOption);
                end
            end
        end

        function calculateHarmonicSpectrum(obj,blockPath)



            obj.HarmonicOrder=[];
            obj.HarmonicMagnitude=[];
            obj.FundamentalFrequency=[];
            if contains(blockPath,'.')
                blockPath=replace(blockPath,'.','/');
            end
            obj.VariableToPlot=get(obj.Simlog,blockPath);
            obj.SignalDimension=obj.VariableToPlot.series.dimension;
            try
                [obj.HarmonicOrder,obj.HarmonicMagnitude,obj.FundamentalFrequency,obj.TimeInterval]=ee_getHarmonics(...
                obj.VariableToPlot,obj.VariableOption,obj.SimulationTime,obj.NumberOfPeriods,obj.DcOffset,obj.NumberOfHarmonics);

            catch ME
                switch ME.identifier
                case 'physmod:ee:library:SimlogInsufficientValues'
                    errordlg(getString(message('physmod:ee:library:SimlogInsufficientValues',obj.VariableToPlot.id)),...
                    getString(message('physmod:ee:harmonicAnalyzer:ErrorDialogTitle')),'modal');

                case 'physmod:ee:library:SimlogNoZeroCrossing'
                    errordlg(getString(message('physmod:ee:library:SimlogNoZeroCrossing',obj.VariableToPlot.id)),...
                    getString(message('physmod:ee:harmonicAnalyzer:ErrorDialogTitle')),'modal');

                case 'physmod:ee:library:SimlogTimeFixedStepSize'
                    errordlg(getString(message('physmod:ee:library:SimlogTimeFixedStepSize')),...
                    getString(message('physmod:ee:harmonicAnalyzer:ErrorDialogTitle')),'modal');

                case 'physmod:ee:library:SimlogTimeOutsideRange'
                    errordlg(getString(message('physmod:ee:library:SimlogTimeOutsideRange',num2str(obj.SimulationTime),obj.VariableToPlot.id)),...
                    getString(message('physmod:ee:harmonicAnalyzer:ErrorDialogTitle')),'modal');

                case 'physmod:simscape:compiler:patterns:checks:LengthEqualLength'
                    errordlg(getString(message('physmod:simscape:compiler:patterns:checks:LengthEqualLength','time data',obj.VariableToPlot.id)),...
                    getString(message('physmod:ee:harmonicAnalyzer:ErrorDialogTitle')),'modal');

                case 'physmod:simscape:compiler:patterns:checks:AscendingVec'
                    errordlg(getString(message('physmod:simscape:compiler:patterns:checks:AscendingVec','time data')),...
                    getString(message('physmod:ee:harmonicAnalyzer:ErrorDialogTitle')),'modal');

                case 'physmod:ee:library:InvalidSimscapeLoggingNodeSeries'
                    errordlg(getString(message('physmod:ee:library:InvalidSimscapeLoggingNodeSeries',obj.VariableToPlot.id)),...
                    getString(message('physmod:ee:harmonicAnalyzer:ErrorDialogTitle')),'modal');

                case 'physmod:ee:library:DecreaseStepSize'
                    errordlg(getString(message('physmod:ee:library:DecreaseStepSize')),...
                    getString(message('physmod:ee:harmonicAnalyzer:ErrorDialogTitle')),'modal');

                otherwise
                    errordlg(ME.message,...
                    getString(message('physmod:ee:harmonicAnalyzer:ErrorDialogTitle')),'modal');
                end
            end
        end

        function plotHarmonicSpectrum(obj,varargin)



            if isempty(varargin)
                hAxes=axes;
            else
                hAxes=varargin{1};
            end
            ee.internal.signal.plotHarmonicBarScaled(obj.HarmonicOrder,obj.HarmonicMagnitude,obj.FundamentalFrequency,hAxes);
            obj.Status=getString(message('physmod:ee:harmonicAnalyzer:DragPanner'));
            notify(obj,'StatusChanged');
        end

        function fileContents=exportAsScript(obj,simlogId)



            [nodePath,~,~]=obj.getPathFromTreeNode;
            nodeFullPath=strcat(simlogId,'.',nodePath);
            fileContents={};
            fileContents{1,1}=sprintf('%s',...
            '% Run this script to compute and plot harmonic spectrum of the selected node');
            fileContents{2,1}=sprintf(...
            '%s = %d;','IndexIntoValue',obj.VariableOption);
            fileContents{3,1}=sprintf(...
            '%s = %0.5g;','SimulationTime',obj.SimulationTime);
            fileContents{4,1}=sprintf(...
            '%s = %d;','NumberOfPeriods',obj.NumberOfPeriods);
            fileContents{5,1}=sprintf(...
            '%s = %0.4g;','DCOffset',obj.DcOffset);
            fileContents{6,1}=sprintf(...
            '%s = %d;\n','NumberOfHarmonics',obj.NumberOfHarmonics);
            fileContents{7,1}=sprintf(...
            '%s','% ee_getHarmonics calculates the harmonic orders, magnitudes, and fundamental frequency of the selected node in the simulation data variable');
            fileContents{8,1}=sprintf(...
            '[order,magnitude,fundamentalFreq] = ee_getHarmonics(%s,%s,%s,%s,%s,%s);\n',...
            nodeFullPath,'IndexIntoValue','SimulationTime','NumberOfPeriods','DCOffset','NumberOfHarmonics');
            fileContents{9,1}=sprintf(...
            '%s','% ee_plotHarmonics plots the harmonic spectrum of selected node in the simulation data variable');
            fileContents{10,1}=sprintf(...
            'ee_plotHarmonics(%s,%s,%s,%s,%s,%s);',...
            nodeFullPath,'IndexIntoValue','SimulationTime','NumberOfPeriods','DCOffset','NumberOfHarmonics');

        end

        function setExportCompleteStatus(obj)
            obj.Status=getString(message('physmod:ee:harmonicAnalyzer:ExportCompleted'));
            notify(obj,'StatusChanged');
        end

        function fileContents=exportAsFunction(obj)



            fileContents={};
            fileContents{1,1}=sprintf(...
            '%s = %s(%s)','function [order,magnitude,fundamentalFreq]','plotHarmonicSpectrumFunction',...
            'simlogNode');
            fileContents{2,1}=sprintf(...
            '%s','% Function to explain the steps to compute and plot the harmonic spectrum of the selected node');
            fileContents{3,1}=sprintf(...
            '%s = %d;','IndexIntoValue',obj.VariableOption);
            fileContents{4,1}=sprintf(...
            '%s = %0.5g;','SimulationTime',obj.SimulationTime);
            fileContents{5,1}=sprintf(...
            '%s = %d;','NumberOfPeriods',obj.NumberOfPeriods);
            fileContents{6,1}=sprintf(...
            '%s = %0.4g;','DCOffset',obj.DcOffset);
            fileContents{7,1}=sprintf(...
            '%s = %d;\n','NumberOfHarmonics',obj.NumberOfHarmonics);
            fileContents{8,1}=sprintf(...
            '%s','% ee_getHarmonics calculates the harmonic orders, magnitudes, and fundamental frequency of the selected node in the simulation data variable');
            fileContents{9,1}=sprintf(...
            '[order,magnitude,fundamentalFreq] = ee_getHarmonics(%s,%s,%s,%s,%s,%s);\n',...
            'simlogNode','IndexIntoValue','SimulationTime','NumberOfPeriods','DCOffset','NumberOfHarmonics');
            fileContents{10,1}=sprintf(...
            '%s','% ee_plotHarmonics plots the harmonic spectrum of selected node in the simulation data variable');
            fileContents{11,1}=sprintf(...
            'ee_plotHarmonics(%s,%s,%s,%s,%s,%s);',...
            'simlogNode','IndexIntoValue','SimulationTime','NumberOfPeriods','DCOffset','NumberOfHarmonics');
            fileContents{12,1}=sprintf(...
            '%s','end');
        end

        function value=get.SignalTimeStartValue(obj)
            if(~isempty(obj.CurrentNode)&&...
                ~isempty(obj.CurrentNode.series)&&...
                ~isempty(obj.CurrentNode.series.time))
                time=obj.CurrentNode.series.time;
                value=time(1);
            end
        end

        function value=get.SignalTimeEndValue(obj)
            if(~isempty(obj.CurrentNode)&&...
                ~isempty(obj.CurrentNode.series)&&...
                ~isempty(obj.CurrentNode.series.time))
                time=obj.CurrentNode.series.time;
                value=time(end);
                if isequal(value,0)
                    errordlg(getString(message('physmod:ee:harmonicAnalyzer:EmptySimulation')));
                end
            end
        end

        function set.SignalTimeEndValue(obj,value)
            obj.SimulationTime=value;
        end
    end
end
function[logPath,phaseOfSignal,blockFullPath]=lGetPathFromNode(n)



    [nodePath,blockPath]=lGetTreePathFromNode(n);
    logPath=regexp(nodePath,'(?<=\.).*','match','once');
    blockFullPath=regexp(blockPath,'(?<=\.).*','match','once');
    searchPattern="("+digitsPattern+")";
    numericPattern=digitsPattern;
    if contains(logPath,searchPattern)
        extractphaseSequence=extract(logPath,searchPattern);
        phaseOfSignalChar=extract(extractphaseSequence{:},numericPattern);
        phaseOfSignal=str2double(phaseOfSignalChar{:});
        logPath=erase(logPath,searchPattern);
        blockFullPath=erase(blockFullPath,searchPattern);
    else
        phaseOfSignal=1;
    end

    function[simlogId,blockName]=lGetTreePathFromNode(n,simlogId,blockName)
        p=get(n,'Parent');
        if nargin==1
            simlogId=n.UserData;
            blockName=n.Text;


        else
            simlogId=[n.UserData,'.',simlogId];
            blockName=[n.Text,'.',blockName];
        end
        if isa(p,'matlab.ui.container.TreeNode')
            [simlogId,blockName]=lGetTreePathFromNode(p,simlogId,blockName);
        end
    end
end
