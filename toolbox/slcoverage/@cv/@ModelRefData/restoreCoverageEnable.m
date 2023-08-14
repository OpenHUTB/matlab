function restoreCoverageEnable(this)




    for i=1:length(this.override)
        modelH=this.override{i};
        if isValidBD(modelH)
            set_param(modelH,'RecordCoverageOverride','LeaveAlone');
        end
    end
    function res=isValidBD(modelH)
        try
            res=strcmpi(get_param(modelH,'Type'),'block_diagram');
        catch
            res=false;
        end
    end
end
