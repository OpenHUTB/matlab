function sources=getSourcesOfControlVars(this)




    sources={};
    for j=1:numel(this.VariantConfigurations)
        for k=1:numel(this.VariantConfigurations(j).ControlVariables)
            if isfield(this.VariantConfigurations(j).ControlVariables(k),'Source')
                sources=[sources,this.VariantConfigurations(j).ControlVariables(k).Source];%#ok<AGROW>
            end
        end
    end
    sources=unique(sources);
end
