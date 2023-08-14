function flagList=getPatternFlag(self,context,metadata)




    flagList={};
    if self.internal.hasMetadata(metadata)
        contextFlagList=self.internal.metadata(metadata);
        if(isfield(contextFlagList,context))
            flagList=contextFlagList.(context);
        end
    end
end

