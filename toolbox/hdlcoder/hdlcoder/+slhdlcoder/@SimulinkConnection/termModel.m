function termModel(this)



    if~isempty(this.Model)

        if this.isModelCompiled
            try
                prevEVCGFeature=slfeature('EVCGEnableSimThruCGXENPSS',0);
                oc=onCleanup(@()slfeature('EVCGEnableSimThruCGXENPSS',prevEVCGFeature));

                term(this.Model);
            catch me %#ok<NASGU>

            end
            if strcmp(this.initMode,'HDL')
                set_param(this.ModelName,'HDLCodeGenStatus','Idle');
            end
        end
    end
end