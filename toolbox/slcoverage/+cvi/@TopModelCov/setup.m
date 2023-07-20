function[coveng,modelcovId]=setup(modelH,topModelcovId,isAccelOrSimMode)




    try
        if(nargin<3)||isempty(isAccelOrSimMode)
            simMode=SlCov.CovMode.Normal;
        elseif islogical(isAccelOrSimMode)
            if isAccelOrSimMode
                simMode=SlCov.CovMode.Accel;
            else
                simMode=SlCov.CovMode.Normal;
            end
        else
            simMode=isAccelOrSimMode;
        end
        if nargin<2
            topModelcovId=[];
        end

        modelcovId=cvmodel(modelH,simMode);



        if isempty(topModelcovId)
            coveng=cvi.TopModelCov.getInstance(modelH);
            if isempty(coveng)||coveng.topModelH~=modelH
                coveng=cvi.TopModelCov(modelH);
                SlCov.CoverageAPI.safe_set_cv_object(modelcovId,'.topModelCov',coveng);

                disassociateRefModelCvIdFromTopModel(modelcovId);

            else
                coveng.oldModelcovIds=coveng.getAllModelcovIds;
                if~isempty(coveng.oldModelcovIds)
                    for cm=coveng.oldModelcovIds(:)'
                        if~cv('ishandle',cm)
                            coveng.oldModelcovIds=[];
                        end
                    end
                end

                disassociateRefModelCvIdFromTopModel(modelcovId);

            end
            topModelcovId=modelcovId;
            coveng.isSimulationOutput=[];
            coveng.multiInstanceNormaModeSf=[];
            coveng.coderCov=SlCov.CoderCov.createInstance(coveng);
            coveng.slccCov=cvi.SLCustomCodeCov.createInstance(coveng);
        end
        cv('set',modelcovId,'.topModelcovId',topModelcovId);


    catch MEx
        rethrow(MEx);
    end



    function id=cvmodel(slHandle,simMode)
        id=get_param(slHandle,'CoverageId');
        modelName=get_param(slHandle,'Name');
        if strcmpi(get_param(slHandle,'SimulationMode'),'accelerator')
            simMode=SlCov.CovMode.Accel;
        end

        modelNameMangled=SlCov.CoverageAPI.mangleModelcovName(modelName,simMode);
        if id~=0&&cv('ishandle',id)&&...
            strcmpi(modelNameMangled,SlCov.CoverageAPI.getModelcovMangledName(id))
            return;
        end
        oldModelId=SlCov.CoverageAPI.findModelcovMangled(modelNameMangled);

        if SlCov.CovMode.isGeneratedCode(simMode)

            badIdx=false(size(oldModelId));
            for ii=1:numel(oldModelId)
                cob=cv('get',oldModelId(ii),'.ownerBlock');
                if~isempty(cob)
                    badIdx(ii)=true;
                end
            end
            oldModelId(badIdx)=[];
        end

        if numel(oldModelId)>1
            error(message('Slvnv:simcoverage:cvmodel:MoreThanOneId'));
        end

        set_param(slHandle,'CoverageId',0);

        if isempty(oldModelId)
            id=SlCov.CoverageAPI.createModelcov(modelName,slHandle,simMode);
        else
            id=oldModelId;
            cv('set',id,'modelcov.handle',slHandle);
        end
        set_param(slHandle,'CoverageId',id);



        function disassociateRefModelCvIdFromTopModel(modelcovId)


            refModelCvId=cv('get',modelcovId,'.refModelcovIds');
            refModelCvId=refModelCvId(refModelCvId~=modelcovId);
            for refModel=refModelCvId(:)'
                if cv('ishandle',refModel)&&isequal(cv('get',refModel,'.isa'),cv('get','default','modelcov.isa'))
                    cv('set',refModel,'.topModelcovId',0);
                end
            end


            cv('set',modelcovId,'.refModelcovIds',[]);
