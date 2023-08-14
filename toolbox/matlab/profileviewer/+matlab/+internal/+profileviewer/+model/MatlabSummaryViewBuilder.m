classdef MatlabSummaryViewBuilder<matlab.internal.profileviewer.model.SummaryViewPayloadBuilder




    methods
        function obj=MatlabSummaryViewBuilder(profileInterface)
            summaryTablePayloadBuilder=matlab.internal.profileviewer.model.MatlabSummaryTableBuilder(profileInterface);
            obj@matlab.internal.profileviewer.model.SummaryViewPayloadBuilder(profileInterface,summaryTablePayloadBuilder);
            mlock;
        end
    end
end
