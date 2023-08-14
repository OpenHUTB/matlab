function activeModel=getActiveModel(obj)









    try
        ccdRootNode=obj.root.activeTree.root;
        if~isempty(ccdRootNode)&&...
            ~isempty(ccdRootNode.data)&&...
            ~isempty(ccdRootNode.data.cvd)

            cvd=ccdRootNode.data.cvd;
            if isa(cvd,'cv.cvdatagroup')
                allCvd=cvd.getAll();
                cvd=allCvd{1};
            end

            try
                modelinfo=cvd.modelinfo;
            catch

                modelinfo=[];
            end

            if~isempty(modelinfo)
                activeModel=modelinfo.harnessModel;
                if isActive(activeModel)
                    return;
                end
                activeModel=modelinfo.ownerModel;
                if isActive(activeModel)
                    return;
                end
                activeModel=modelinfo.analyzedModel;
                if isActive(activeModel)
                    return;
                end
            end
        end

        activeModel=obj.topModelName;
        if isActive(activeModel)
            return
        end

        activeModel=[];
    catch SlCovMExc
        rethrow(SlCovMExc);
    end
end

function result=isActive(model)



    result=false;
    if~isvarname(model)||~bdIsLoaded(model)
        return
    end

    modelcovId=get_param(model,'CoverageId');
    if(modelcovId==0)||~cv('ishandle',modelcovId)
        return
    end
    result=true;
end