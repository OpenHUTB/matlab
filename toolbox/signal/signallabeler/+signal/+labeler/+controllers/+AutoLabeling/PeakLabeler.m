

classdef PeakLabeler<signal.labeler.controllers.AutoLabeling.LabelerActionBase


    methods(Hidden)

        function nameValuePairCellArray=getLabelerSettingsArguments(this)
            nameValuePairCellArray={};
            nameValuePairCellArray{end+1}='FindLocal';
            nameValuePairCellArray{end+1}=this.LabelerSettings.FindLocalMethod;
            if isfield(this.LabelerSettings,'MaxNumPeak')
                nameValuePairCellArray{end+1}='MaxNumExtrema';
                nameValuePairCellArray{end+1}=this.LabelerSettings.MaxNumPeak;
            end
            if isfield(this.LabelerSettings,'MinSeperation')
                nameValuePairCellArray{end+1}='MinSeparation';
                nameValuePairCellArray{end+1}=str2double(this.LabelerSettings.MinSeperation);
            end

            if isfield(this.LabelerSettings,'ProminenceAtLeast')
                nameValuePairCellArray{end+1}='MinProminence';
                nameValuePairCellArray{end+1}=str2double(this.LabelerSettings.ProminenceAtLeast);
            end

            if isfield(this.LabelerSettings,'ProminenceWindow')
                nameValuePairCellArray{end+1}='ProminenceWindow';
                nameValuePairCellArray{end+1}=str2double(this.LabelerSettings.ProminenceWindow);
            end

            if isfield(this.LabelerSettings,'FlatRegionPoint')
                nameValuePairCellArray{end+1}='FlatSelection';
                nameValuePairCellArray{end+1}=this.LabelerSettings.FlatRegionPoint;
            end
        end

        function y=getFunctionHandle(~)
            y=@signal.internal.labeler.peakLabeler;
        end
    end
end

