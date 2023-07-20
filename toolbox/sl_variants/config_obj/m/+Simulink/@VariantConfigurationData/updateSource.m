function updateSource(this,newSource,varargin)





    if numel(varargin)>0
        oldSource=varargin{1};
    else
        oldSource='';
    end
    for j=1:numel(this.VariantConfigurations)
        for k=1:numel(this.VariantConfigurations(j).ControlVariables)
            if isempty(oldSource)||strcmp(this.VariantConfigurations(j).ControlVariables(k).Source,oldSource)
                this.VariantConfigurations(j).ControlVariables(k).Source=newSource;
            end
        end
    end
end
