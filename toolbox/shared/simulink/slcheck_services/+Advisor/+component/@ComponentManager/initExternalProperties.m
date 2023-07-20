function initExternalProperties(this)
    if~isempty(this.ExternalPropertyNames)
        compIDs=this.getComponentIDs();
        numComps=length(compIDs);
        numProps=length(this.ExternalPropertyNames);

        defaultPropCell=cell(numComps,numProps);

        for n=1:numProps
            prop=this.ExternalPropertyNames{n};
            defaultValue=this.ExternalPropertiesDefaultValues.(prop);
            if ischar(defaultValue)
                defaultPropCell(:,n)=cellstr(repmat(defaultValue,numComps,1));
            elseif isnumeric(defaultValue)||islogical(defaultValue)
                defaultPropCell(:,n)=num2cell(repmat(defaultValue,numComps,1));
            end
        end

        this.ExternalProperties=cell2table(defaultPropCell,...
        'VariableNames',this.ExternalPropertyNames,'RowNames',compIDs);
    end
end