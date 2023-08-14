function callbacks=getAncesterCallbacks(testId,nodeIdMap)




    callbacks={};

    pp=stm.internal.getTestProperty(testId,'testcase');
    parentId=pp.parentId;
    while(1)
        if(nargin==2)
            if(~nodeIdMap.isKey(parentId))
                break;
            end
        end
        pp=stm.internal.getTestProperty(parentId,'testsuite');
        if(~isempty(pp.setupScript))
            callbacks{end+1}=pp.setupScript;
        end
        if(pp.parentId<0)
            break;
        end
        parentId=pp.parentId;
    end
    callbacks=fliplr(callbacks);
end
