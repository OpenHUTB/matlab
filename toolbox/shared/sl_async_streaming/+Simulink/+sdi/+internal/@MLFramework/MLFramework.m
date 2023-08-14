classdef MLFramework<Simulink.sdi.internal.AbstractFramework





    methods
        function ret=evalWksVar(~,~,str)
            ret=evalin('base',str);
        end

        function ret=createMATLABStructForBus(~,~,~)
            ret=evalin('base',str);
        end

        function registerEnginePlugins(~,~,isMainEng)

            persistent is_init
            if isempty(is_init)||~isMainEng
                is_init=true;
                exporter=Simulink.sdi.internal.export.WorkspaceExporter.getDefault();
                exporter.registerVariableExporter(...
                'Simulink.sdi.internal.export.OutportExporter');
                exporter.registerVariableExporter(...
                'Simulink.sdi.internal.export.ParamExporter');
                exporter.registerVariableExporter(...
                'Simulink.sdi.internal.export.DSMExporter');
                exporter.registerVariableExporter(...
                'Simulink.sdi.internal.export.StateflowDataExporter');
                exporter.registerVariableExporter(...
                'Simulink.sdi.internal.export.StateflowStateExporter');
                exporter.registerVariableExporter(...
                'Simulink.sdi.internal.export.StateExporter');
            end
        end

        function unregisterEnginePlugins(~)
        end

        function ret=featureCheck(~,varargin)







            ret=2;
        end

        function ret=displaySimulinkHelp(~)
            ret=false;
        end

        function ret=getHelpMapFile(~)
            ret=fullfile(docroot,'fixedpoint','fixedpoint.map');
        end

        function launchHelpAbout(~)
            Simulink.sdi.launchMATLABAboutBox();
        end

        function ret=getPCTHelpAnchor(~)
            ret='sdi_prefsHelp_Parallel';
        end

        function clearNewDataNotification(~)
        end

        function addNewDataNotification(~,~)
        end

        function createDynamicEnum(~,~,~,~,~)
        end

        function obj=getModelCloseUtil(~)
            obj=[];
        end

        function ret=highlightSignal(~,~,~,~,~)


            ret=false;
        end

        function out=getParam(~,~,~)
            out='';
        end

        function out=getLogVarNamesFromModel(~,~)
            out={};
        end


        function[runID,runIndex,varargout]=createRunFromModel(~,~,~,varargin)
            runID=[];
            runIndex=[];
            if nargout>2
                varargout{1}=0;
            end
        end


        function recordHarnessModelMetaData(~,~,~,~)
        end


        function out=getBlockSource(~,bpath,~)
            out=bpath;
        end

        function out=getReportFolder(~)
            out=fullfile(pwd,'slprj','sdi');
        end

        function out=getSID(~,varargin)


            out='';
        end

        function out=getFullName(~,~)
            out='';
        end

        function out=addSimulinkTimeseries(~,~,~,~)
            out=[];
        end

        function outputFileName=createSnapshot(~,~,~)
            outputFileName='';
        end

        function out=isSLDVData(~,~)
            out=false;
        end

        function out=addSLDVRuns(~,~)
            out=[];
        end

    end
end
