function result=algebraicLoopCheck(slConnection)






    result=1;
    mdlObj=slConnection.Model;
    blocklist=getCompiledBlockList(mdlObj);
    blocklistnames=getfullname(blocklist);
    mdlName=mdlObj.Name;
    startNodePath=slConnection.System;

    for i=1:size(blocklistnames,1)
        obj=get_param(blocklist(i),'ObjectAPI_FP');
        if(obj.isSynthesized)
            blklistname=blocklistnames{i};
            isAlgLoop=~isempty(regexp(blklistname,sprintf('^%s',[mdlName,'/<< Synthesized_Atomic_Subsystem_For_Alg_Loop']),'once'));
            if isAlgLoop


                subblocklist=getCompiledBlockList(get_param(blklistname,'ObjectAPI_FP'));
                subblocklistname=getfullname(subblocklist);
                if~iscell(subblocklistname)
                    subblocklistname={subblocklistname};
                end
                for j=1:size(subblocklist,1)

                    if~isempty(regexp(subblocklistname{j},sprintf('^%s',startNodePath),'once'))

                        result=0;
                        return;
                    end
                end
            end
        end
    end


