function reset(this,keepCustomTypes)






    if nargin==1
        keepCustomTypes=true;
    end

    if keepCustomTypes

        cachedReqTypes=cacheCustomTypes(this.repository.requirementTypes);
        cachedLinkTypes=cacheCustomTypes(this.repository.linkTypes);
    end

    rsets=this.getLoadedReqSets;
    for i=1:numel(rsets)
        this.discardReqSet(rsets(i));
    end

    reqSet=this.findRequirementSet('clipboard.slreqx');
    if~isempty(reqSet)
        this.discardReqSet(this.wrap(reqSet));
    end
    reqSet=this.findRequirementSet('default.slreqx');
    if~isempty(reqSet)
        this.discardReqSet(this.wrap(reqSet));
    end
    reqSet=this.findRequirementSet('slinternal_scratchpad.slreqx');
    if~isempty(reqSet)
        this.discardReqSet(this.wrap(reqSet));
    end

    lsets=this.getLoadedLinkSets;
    for i=1:numel(lsets)
        if rmi.isInstalled()&&endsWith(lsets(i).artifact,'.m','IgnoreCase',true)



            rmiml.notifyEditor(lsets(i).artifact,'');
        end
        this.discardLinkSet(lsets(i));
    end

    slreq.data.ReqData.initialTime(true);


    slreq.cpputils.resetRequirementData('#SLReqsMF0#');
    if~isempty(this.repository)
        this.repository.destroy();
        this.repository=[];
    end

    if~isempty(this.model)
        this.model.destroy();
        this.model=[];
    end


    this.init();

    if keepCustomTypes

        for n=1:length(cachedReqTypes)
            this.addCustomRequirementType(cachedReqTypes(n).name,cachedReqTypes(n).superType,cachedReqTypes(n).description);
        end
        for n=1:length(cachedLinkTypes)
            this.addCustomLinkType(cachedLinkTypes(n).typeName,cachedLinkTypes(n).superType,cachedLinkTypes(n).forwardName,...
            cachedLinkTypes(n).backwardName,cachedLinkTypes(n).description);
        end
    end
end


function types=cacheCustomTypes(mfTypeRegs)
    keys=mfTypeRegs.keys;
    types=struct([]);
    rank=[];
    for n=1:length(keys)
        thisType=mfTypeRegs{keys{n}};
        if~thisType.isBuiltin
            typedef=struct('description',thisType.description);
            rk=countSuperClasses(thisType);
            if isa(thisType,'slreq.datamodel.RequirementType')
                typedef.name=thisType.name;
                typedef.superType=thisType.superType.name;
            elseif isa(thisType,'slreq.datamodel.LinkType')
                typedef.typeName=thisType.typeName;
                typedef.forwardName=thisType.forwardName;
                typedef.backwardName=thisType.backwardName;
                typedef.superType=thisType.superType.typeName;

            else
                assert(false,'Unexpected case occured for custom type caching on ReqData.reset');
            end
            if isempty(types)
                types=typedef;
                rank=rk;
            else
                types(end+1)=typedef;%#ok<AGROW>
                rank(end+1)=rk;%#ok<AGROW> 
            end
        end
    end
    if numel(types)>1



        [~,idx]=sort(rank);
        types=types(idx);
    end

    function out=countSuperClasses(thisType)

        out=0;
        while true
            if thisType.isBuiltin
                return;
            end
            out=out+1;
            thisType=thisType.superType;
        end
    end
end

