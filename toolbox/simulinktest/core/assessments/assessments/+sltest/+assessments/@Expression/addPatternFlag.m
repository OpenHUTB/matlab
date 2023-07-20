function addPatternFlag(self,context,metadata,flag)
















    if self.internal.hasMetadata(metadata)
        contextFlagList=self.internal.metadata(metadata);
        if(isfield(contextFlagList,context))
            flagList=contextFlagList.(context);
            assert(iscellstr(flagList),'unexpected metadata type');
            if isempty(find(strcmp(flagList,flag),1))
                flagList{end+1}=flag;
                contextFlagList.(context)=flagList;
                self.internal.setMetadata(metadata,contextFlagList);
            end
        else
            contextFlagList.(context)={flag};
            self.internal.setMetadata(metadata,contextFlagList);
        end
    else
        contextFlagList.(context)={flag};
        self.internal.setMetadata(metadata,contextFlagList)
    end
end

