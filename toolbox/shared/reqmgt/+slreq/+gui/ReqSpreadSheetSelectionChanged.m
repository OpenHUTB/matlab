
classdef ReqSpreadSheetSelectionChanged<event.EventData


    properties


        selection;


    end

    methods


        function this=ReqSpreadSheetSelectionChanged()
        end

        function isReqSet=isReqSetSelected(this)
            isReqSet=~isempty(this.selection)&&isa(this.selection{1},'slreq.das.RequirementSet');
        end
    end
end
