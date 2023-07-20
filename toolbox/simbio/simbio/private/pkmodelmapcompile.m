function compiledMM=pkmodelmapcompile(modelMap,modelObj,dimensionalAnalysis,unitConversion,allowDuplicateTargets,allowEmptyObserved,baseObjectName)





























    if~exist('allowDuplicateTargets','var')
        allowDuplicateTargets=false;
    end

    if~exist('allowEmptyObserved','var')
        allowEmptyObserved=false;
    end

    if~exist('baseObjectName','var')
        baseObjectName='PKModelMap';
    end

    assert(isa(modelMap,'PKModelMap'));
    assert(isa(modelObj,'SimBiology.Model'));


    compiledMM=struct('DosingType',[],'Dosed',[],'Estimated',[],'Observed',[],'ObservedUnits',[]);


    dosedNames=modelMap.Dosed;
    dosedObjectCell=SimBiology.internal.getObjectFromPQN(modelObj,dosedNames);
    for i=1:numel(dosedNames)
        dosedObject=dosedObjectCell{i};
        if~isscalar(dosedObject)||~isa(dosedObject,'SimBiology.Species')
            nextDosedName=dosedNames{i};
            error(message('SimBiology:PKModelMapCompile:DOSEDFAILEDTORESOLVE',nextDosedName));
        end
    end
    dosedObjects=[dosedObjectCell{:}];
    if~allowDuplicateTargets&&numel(unique(dosedObjects))~=numel(dosedObjects)
        error(message('SimBiology:PKModelMapCompile:DUPLICATE_DOSED'));
    end
    compiledMM.Dosed=dosedObjects;


    if numel(dosedObjects)~=numel(modelMap.DosingType)
        error(message('SimBiology:PKModelMapCompile:INVALID_DOSINGTYPE'));
    end





    durationParameter=modelMap.ZeroOrderDurationParameter;
    if isempty(durationParameter)
        durationParameter=repmat({''},1,numel(modelMap.DosingType));
    elseif numel(durationParameter)~=numel(modelMap.DosingType)


        error(message('SimBiology:PKModelMapCompile:INVALID_ZEROORDERDURATIONPARAMETER'));
    end

    durationParameterObjCell=SimBiology.internal.getObjectFromPQN(modelObj,durationParameter);
    for i=1:numel(durationParameter)
        if~isempty(durationParameter{i})


            if isscalar(durationParameterObjCell{i})

                if~isa(durationParameterObjCell{i},'SimBiology.Parameter')
                    error(message('SimBiology:PKModelMapCompile:DURATIONPARAMETERFAILEDTORESOLVE',durationParameter{i}));
                elseif(~durationParameterObjCell{i}.ConstantValue)
                    error('SimBiology:PKModelMapCompile:DURATIONPARAMETERFAILEDTORESOLVE',...
                    getString(message('SimBiology:PKModelMapCompile:DURATIONPARAMETERFAILEDTORESOLVE_CONSTANT',durationParameter{i})));
                elseif~isa(durationParameterObjCell{i}.Parent,'SimBiology.Model')
                    error('SimBiology:PKModelMapCompile:DURATIONPARAMETERFAILEDTORESOLVE',...
                    getString(message('SimBiology:PKModelMapCompile:DURATIONPARAMETERFAILEDTORESOLVE_SCOPE',durationParameter{i})));
                end
            else

                error(message('SimBiology:PKModelMapCompile:DURATIONPARAMETERFAILEDTORESOLVE',durationParameter{i}));
            end
        end
    end
    compiledMM.ZeroOrderDurationParameter=durationParameterObjCell;



    doseType=modelMap.DosingType;
    for i=1:numel(doseType)
        if strcmpi(doseType{i},'ZeroOrder')&&isempty(durationParameter{i})
            error(message('SimBiology:PKModelMapCompile:INVALID_ZEROORDER_SPECIFICATION'));
        end

        if~isempty(durationParameter{i})&&~strcmpi(doseType{i},'ZeroOrder')
            error('SimBiology:PKModelMapCompile:INVALID_ZEROORDER_SPECIFICATION',...
            getString(message('SimBiology:PKModelMapCompile:INVALID_ZEROORDER_SPECIFICATION_DOSINGTYPE')));
        end
    end

    compiledMM.DosingType=doseType;





    lagParameter=modelMap.LagParameter;
    if isempty(lagParameter)
        lagParameter=repmat({''},1,numel(modelMap.DosingType));
    elseif numel(lagParameter)~=numel(modelMap.DosingType)


        error(message('SimBiology:PKModelMapCompile:INVALID_LAGPARAMETER'));
    end

    lagParameterObjCell=SimBiology.internal.getObjectFromPQN(modelObj,lagParameter);
    for i=1:numel(lagParameter)
        if~isempty(lagParameter{i})


            if isscalar(lagParameterObjCell{i})

                if~isa(lagParameterObjCell{i},'SimBiology.Parameter')
                    error(message('SimBiology:PKModelMapCompile:LAGPARAMETERFAILEDTORESOLVE',lagParameter{i}));
                elseif(~lagParameterObjCell{i}.ConstantValue)
                    error('SimBiology:PKModelMapCompile:LAGPARAMETERFAILEDTORESOLVE',...
                    getString(message('SimBiology:PKModelMapCompile:LAGPARAMETERFAILEDTORESOLVE_CONSTANT',lagParameter{i})));
                elseif~isa(lagParameterObjCell{i}.Parent,'SimBiology.Model')
                    error('SimBiology:PKModelMapCompile:LAGPARAMETERFAILEDTORESOLVE',...
                    getString(message('SimBiology:PKModelMapCompile:LAGPARAMETERFAILEDTORESOLVE_SCOPE',lagParameter{i})));
                end
            else

                error(message('SimBiology:PKModelMapCompile:LAGPARAMETERFAILEDTORESOLVE',lagParameter{i}));
            end
        end
    end
    compiledMM.LagParameter=lagParameterObjCell;


    estObjs=SimBiology.internal.getObjectFromPQN(modelObj,modelMap.Estimated);
    Nestimated=numel(estObjs);
    if~allowEmptyObserved&&(Nestimated==0)
        error(message('SimBiology:PKModelMapCompile:INVALIDESTIMATED'));
    end
    for c=1:Nestimated
        eobj=estObjs{c};
        if~isscalar(eobj)||~isa(eobj,'SimBiology.Species')&&~isa(eobj,'SimBiology.Parameter')&&~isa(eobj,'SimBiology.Compartment')
            error(message('SimBiology:PKModelMapCompile:ESTIMATEDFAILEDTORESOLVE',modelMap.Estimated{c}));
        end
    end
    compiledMM.Estimated=cat(1,estObjs{:});


    obsObjCell=SimBiology.internal.getObjectFromPQN(modelObj,modelMap.Observed);
    invalidObserved=~cellfun(@isscalar,obsObjCell);
    if any(invalidObserved)

        invalidNames=sprintf('''%s'', ',modelMap.Observed{invalidObserved});

        invalidNames=invalidNames(1:end-2);
        error(message('SimBiology:PKModelMapCompile:OBSERVEDFAILEDTORESOLVE',invalidNames));
    end
    obsObj=cat(1,obsObjCell{:});
    Nobserved=numel(obsObj);
    if Nobserved==0
        error(message('SimBiology:PKModelMapCompile:INVALIDOBSERVED'));
    end
    compiledMM.ObservedUnits=cell(1,Nobserved);
    for i=1:Nobserved
        obsObjI=obsObj(i);
        compiledMM.ObservedUnits{i}=obsObjI.Units;
    end
    if numel(unique(obsObj))~=numel(obsObj)
        warning(message('SimBiology:PKModelMapCompile:DUPLICATE_OBSERVED'));
    end
    compiledMM.Observed=obsObj;


    if dimensionalAnalysis

        SimBiology.internal.validateTimeUnitsOnParameter(compiledMM.ZeroOrderDurationParameter,'ZeroOrderDurationParameter',baseObjectName,unitConversion);
        SimBiology.internal.validateTimeUnitsOnParameter(compiledMM.LagParameter,'LagParameter',baseObjectName,unitConversion);
    end
end