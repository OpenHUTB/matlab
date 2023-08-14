function fCtrl=getFeatureCtrl(this,featureName)
    if isfield(this.ClientFeatureCtrl,featureName)
        fCtrl=this.ClientFeatureCtrl.(featureName);
    else
        fCtrl=0;
    end
end

