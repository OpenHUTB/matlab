function adjustCoverageEnable(this,enable_rules)




    for idx=1:length(enable_rules)
        crule=enable_rules{idx};
        cs=crule{1};
        recordCoverage=crule{2};
        if recordCoverage
            set_param(cs,'RecordCoverageOverride','ForceOn');
            this.recordingModels{end+1}=cs;
        else
            set_param(cs,'RecordCoverageOverride','ForceOff');
        end
        this.override{end+1}=cs;
    end
end
