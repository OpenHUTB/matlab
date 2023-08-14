
function result=discardReqSet(this,reqSet)






    slreq.utils.assertValid(reqSet);





    quiet=false;

    if~isa(reqSet,'slreq.data.RequirementSet')
        error('Invalid argument: expected slreq.data.RequirementSet');
    end

    result=false;

    modelReqSet=reqSet.getModelObj();

    if~isempty(modelReqSet)


        needNotify=false;
        filepath=reqSet.filepath;
        if~any(strcmp(filepath,{'default.slreqx','clipboard.slreqx','slinternal_scratchpad.slreqx'}))

            if~quiet
                needNotify=true;
                this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Before ReqSet Discarded',reqSet));
            end

        end

        modelReqSet.destroy();
        reqSet.clearModelObj();

        if needNotify
            this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('ReqSet Discarded',filepath));
        end


        result=true;

    end
end
