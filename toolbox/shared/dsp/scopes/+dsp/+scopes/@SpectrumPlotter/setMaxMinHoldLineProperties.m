function setMaxMinHoldLineProperties(this,lineNum,props,lineType)




    if isempty(this.([lineType,'HoldTraceLines']))

        cacheLineProperties(this,lineNum,props);
    else

        if isfield(props,'DisplayName')
            set(this.([lineType,'HoldTraceLines'])(lineNum),rmfield(props,'DisplayName'));
        else
            set(this.([lineType,'HoldTraceLines'])(lineNum),props);
        end
        cacheMaxMinHoldLineProperties(this,lineNum,props,true,lineType);
    end
end
