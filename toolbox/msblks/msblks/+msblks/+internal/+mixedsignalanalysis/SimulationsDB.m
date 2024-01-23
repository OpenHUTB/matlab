classdef SimulationsDB<handle

    properties
sourceType
matFileName
fullPathMatFileName

SimulationResultsNames
SimulationResultsObjects

        analysisNodeNames=[];
        analysisWaveforms=[];
        analysisWfAnswers=[];

        analysisMetricNames=[];
        analysisMetricData=[];
        analysisMetricCorners=[];
        analysisMetricValues=[];
        analysisMetricAnswers=[];
    end


    methods
        function obj=SimulationsDB(varargin)

            narginchk(0,2)
            if nargin>=2
                obj.SimulationResultsNames=varargin{1};
                obj.SimulationResultsObjects=varargin{2};
            end
        end


        function setSimulationResults(obj,name,simResults)
            [~,index]=obj.getSimulationResults(name);
            if index>0
                obj.SimulationResultsObjects{index}=simResults;
            else
                index=length(obj.SimulationResultsNames)+1;
                obj.SimulationResultsNames{index}=name;
                obj.SimulationResultsObjects{index}=simResults;
            end
        end

        function[simResults,index]=getSimulationResults(obj,name)
            if~isempty(obj.SimulationResultsNames)&&...
                length(obj.SimulationResultsNames)==length(obj.SimulationResultsObjects)
                for index=1:length(obj.SimulationResultsNames)
                    if strcmp(obj.SimulationResultsNames{index},name)
                        simResults=obj.SimulationResultsObjects{index};
                        return;
                    end
                end
            end
            simResults=[];
            index=0;
        end


        function out=NewSimulationResults(~,varargin)
            out=msblks.internal.mixedsignalanalysis.SimulationResults(varargin{:});
        end


        function structCopy=get(obj)
            structCopy.sourceType=obj.sourceType;
            structCopy.matFileName=obj.matFileName;
            structCopy.fullPathMatFileName=obj.fullPathMatFileName;
            structCopy.SimulationResultsNames=obj.SimulationResultsNames;
            structCopy.SimulationResultsObjects=obj.SimulationResultsObjects;
            structCopy.analysisNodeNames=obj.analysisNodeNames;
            structCopy.analysisWaveforms=obj.analysisWaveforms;
            structCopy.analysisWfAnswers=obj.analysisWfAnswers;
            structCopy.analysisMetricNames=obj.analysisMetricNames;
            structCopy.analysisMetricData=obj.analysisMetricData;
            structCopy.analysisMetricCorners=obj.analysisMetricCorners;
            structCopy.analysisMetricValues=obj.analysisMetricValues;
            structCopy.analysisMetricAnswers=obj.analysisMetricAnswers;
        end


        function put(obj,structCopy)
            obj.sourceType=structCopy.sourceType;
            obj.matFileName=structCopy.matFileName;
            obj.fullPathMatFileName=structCopy.fullPathMatFileName;
            obj.SimulationResultsNames=structCopy.SimulationResultsNames;
            obj.SimulationResultsObjects=structCopy.SimulationResultsObjects;
            obj.analysisNodeNames=structCopy.analysisNodeNames;
            obj.analysisWaveforms=structCopy.analysisWaveforms;
            obj.analysisWfAnswers=structCopy.analysisWfAnswers;
            obj.analysisMetricNames=structCopy.analysisMetricNames;
            obj.analysisMetricData=structCopy.analysisMetricData;
            obj.analysisMetricCorners=structCopy.analysisMetricCorners;
            obj.analysisMetricValues=structCopy.analysisMetricValues;
            obj.analysisMetricAnswers=structCopy.analysisMetricAnswers;
        end


        function out=clone(obj)
            out=msblks.internal.mixedsignalanalysis.SimulationsDB;
            out.sourceType=obj.sourceType;
            out.matFileName=obj.matFileName;
            out.fullPathMatFileName=obj.fullPathMatFileName;
            out.SimulationResultsNames=obj.SimulationResultsNames;
            out.SimulationResultsObjects=obj.SimulationResultsObjects;
            out.analysisNodeNames=obj.analysisNodeNames;
            out.analysisWaveforms=obj.analysisWaveforms;
            out.analysisWfAnswers=obj.analysisWfAnswers;
            out.analysisMetricNames=obj.analysisMetricNames;
            out.analysisMetricData=obj.analysisMetricData;
            out.analysisMetricCorners=obj.analysisMetricCorners;
            out.analysisMetricValues=obj.analysisMetricValues;
            out.analysisMetricAnswers=obj.analysisMetricAnswers;
        end


        function waveform=getAnalysisWaveform(obj,waveformName)
            if~isempty(obj.analysisNodeNames)&&length(obj.analysisNodeNames)==length(obj.analysisWaveforms)
                for i=1:length(obj.analysisNodeNames)
                    if strcmp(obj.analysisNodeNames{i},waveformName)
                        waveform=obj.analysisWaveforms{i};
                        return;
                    end
                end
            end
            waveform=[];
        end
    end
end
