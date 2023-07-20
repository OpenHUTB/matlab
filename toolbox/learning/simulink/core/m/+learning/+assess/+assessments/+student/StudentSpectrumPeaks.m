classdef StudentSpectrumPeaks<learning.assess.assessments.StudentAssessment

    properties(Constant)
        type='SpectrumPeaks';
    end

    properties
PeakList
Cfgs
    end

    methods
        function obj=StudentSpectrumPeaks(props)
            obj.validateInput(props);
            obj.PeakList=props.PeakList;
            obj.Cfgs=struct('blockHandle',{},'origEnable',{},'origNumPeaks',{},'currCfg',{});
        end

        function isCorrect=assess(obj,userModelName)
            isCorrect=false;


            saBlock=Simulink.findBlocks(userModelName,'BlockType','SpectrumAnalyzer');



            for idx=1:numel(saBlock)
                open_system(saBlock(idx));
                obj.Cfgs(idx).currCfg=get_param(saBlock(idx),'ScopeConfiguration');
                obj.Cfgs(idx).blockHandle=saBlock(idx);
                obj.Cfgs(idx).origEnable=obj.Cfgs(idx).currCfg.PeakFinder.Enable;
                obj.Cfgs(idx).origNumPeaks=obj.Cfgs(idx).currCfg.PeakFinder.NumPeaks;

                obj.Cfgs(idx).currCfg.PeakFinder.Enable=true;
                obj.Cfgs(idx).currCfg.PeakFinder.NumPeaks=length(obj.PeakList);
            end


            c=onCleanup(@()obj.resetConfigurations);


            try
                simOut=sim(userModelName,'ReturnWorkspaceOutputs','on');
                modelWarnings=simOut.SimulationMetadata.ExecutionInfo.WarningDiagnostics;
                if~isempty(modelWarnings)
                    sldiagviewer.reportSimulationMetadataDiagnostics(simOut);
                end
            catch err

                sldiagviewer.createStage('Analysis','ModelName',userModelName);
                sldiagviewer.reportError(err);
                return
            end


            for idx=1:numel(obj.Cfgs)
                data=getMeasurementsData(obj.Cfgs(idx).currCfg);

                if any(contains(data.Properties.VariableNames,'PeakFinder'))&&isfield(data.PeakFinder,'Value')
                    isCorrect=sum(abs(data.PeakFinder.Value-obj.PeakList))<1e-2;
                    break
                end
            end

        end

        function requirementString=generateRequirementString(~)
            requirementString=message('learning:simulink:genericRequirements:spectrumPeaks').getString();
        end
    end

    methods(Access=protected)
        function validateInput(~,props)

            if isempty(props.PeakList)||~isnumeric(props.PeakList)
                error(message('learning:simulink:resources:InvalidSpectrumPeaks'));
            end

        end

        function resetConfigurations(obj)

            for idx=1:numel(obj.Cfgs)
                obj.Cfgs(idx).currCfg.PeakFinder.Enable=obj.Cfgs(idx).origEnable;
                obj.Cfgs(idx).currCfg.PeakFinder.NumPeaks=obj.Cfgs(idx).origNumPeaks;
            end
        end
    end
end
