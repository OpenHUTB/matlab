



function mapModelToCode(this,traceInfoMat,traceInfoBuilder,cvdOrRootId)

    slModel=this.CodeTr.getSLModel();
    if~isempty(slModel)
        this.refreshModelCovIds(cvdOrRootId);
        return
    end

    if isa(cvdOrRootId,'cvdata')


        if cvdOrRootId.isAtomicSubsystemCode()
            analyzedModel=cvdOrRootId.getAnalyzedModelForATS();
        else
            analyzedModel=cvdOrRootId.modelinfo.analyzedModel;
        end
    else
        analyzedModel=SlCov.CoverageAPI.getModelcovName(cv('get',cvdOrRootId,'.modelcov'));
    end

    defaultModelElements=struct(...
    'modelCovId',{0},...
    'origin',{1},...
    'SID',{{analyzedModel}},...
    'name',{{analyzedModel}},...
    'title',{{''}},...
    'depth',{0},...
    'blocksIdx',{{zeros(0,1)}},...
    'covIds',{{zeros(0,1,'int64')}},...
    'nodes',{{internal.cxxfe.instrum.ProgramNode.empty}});

    try

        res=mapModelElementsToCovIds(this.CodeTr,analyzedModel,traceInfoMat,traceInfoBuilder);

        if~isstruct(res)
            this.CodeTr.setSLModel(defaultModelElements);
            return
        end

        this.TraceInfo=res.traceInfo;


        if nargin<4||isempty(cvdOrRootId)
            cvId=0;
        else
            isCvd=isa(cvdOrRootId,'cvdata');
            if isCvd
                rootId=cvdOrRootId.rootId;
            else
                rootId=cvdOrRootId;
            end
            cvId=cv('get',rootId,'.topSlsf');
        end

        model2CodeTrCovIds=res.covIds;
        model2CodeTrNodes=res.nodes;

        if cvId==0||~cv('ishandle',cvId)

            sysCvIds=0;
            blockCvIds=zeros(1,numel(res.SID)-1);
            depths=0;
            allCvIds=cat(1,sysCvIds(:),blockCvIds(:));
            allSIDs=res.SID;
            allTitles=cell(size(allCvIds));
            model2CodeTrIdx=1:numel(allSIDs);
        else

            [sysCvIds,blockCvIds,depths]=cv('DfsOrder',cvId);
            allCvIds=cat(1,sysCvIds(:),blockCvIds(:));
            allSIDs=cell(size(allCvIds));
            for ii=1:numel(allCvIds)
                try
                    allSIDs{ii}=cvi.TopModelCov.getSID(allCvIds(ii));
                catch ME

                    if codeinstrumprivate('feature','disableErrorRecovery')
                        rethrow(ME);
                    end

                    fprintf(1,'%s\n',getString(message('Slvnv:codecoverage:CodeMappingGetSidFailed',allCvIds(ii))));
                    allSIDs{ii}='';
                end
            end

            [goodIdx,model2CodeTrIdx]=ismember(allSIDs,res.SID);

            allTitles=cell(size(allCvIds));
            for ii=find(goodIdx)'
                try
                    allTitles{ii}=cvi.ReportScript.object_titleStr_and_link(allCvIds(ii));
                catch ME

                    if codeinstrumprivate('feature','disableErrorRecovery')
                        rethrow(ME);
                    end
                    fprintf(1,'%s\n',getString(message('Slvnv:codecoverage:CodeMappingGetTitleFailed',allSIDs{ii})));
                    goodIdx(ii)=false;
                end
            end





            unmatchedIdx=~ismember(res.SID,allSIDs);
            for ii=find(unmatchedIdx)'
                parentSID=res.SID{ii};
                try
                    jj=[];
                    while isempty(jj)
                        h=Simulink.ID.getHandle(parentSID);
                        if isa(h,'Stateflow.Object')
                            h=h.getParent();
                        elseif~isempty(h)&&isnumeric(h)&&strcmp(get_param(h,'Type'),'block')
                            h=get_param(get_param(h,'Parent'),'Handle');
                        else
                            h=[];
                        end
                        if isempty(h)
                            parentSID=allSIDs{1};
                        else
                            parentSID=Simulink.ID.getSID(h);
                        end
                        jj=find(strcmp(parentSID,allSIDs),1,'first');
                    end
                catch ME

                    if codeinstrumprivate('feature','disableErrorRecovery')
                        rethrow(ME);
                    end

                    fprintf(1,'%s\n',getString(message('Slvnv:codecoverage:CodeMappingGetCovIdFailed',res.SID{ii})));
                    jj=1;
                end
                kk=model2CodeTrIdx(jj);
                if kk==0
                    goodIdx(jj)=true;
                    model2CodeTrIdx(jj)=ii;
                else
                    model2CodeTrCovIds{kk}=cat(1,model2CodeTrCovIds{kk},model2CodeTrCovIds{ii});
                    model2CodeTrNodes{kk}=cat(1,model2CodeTrNodes{kk},model2CodeTrNodes{ii});
                end
            end


            badIdx=~goodIdx;

            blocksCvIds=cell(numel(sysCvIds),1);
            for ii=1:numel(sysCvIds)

                children=cv('ChildrenOf',sysCvIds(ii));
                children(children==sysCvIds(ii))=[];
                children=children(:);
                isLeaf=(cv('get',children,'.treeNode.child')==0);
                children(~isLeaf,:)=[];
                b=ismember(children,allCvIds(goodIdx));
                blocksCvIds{ii}=children(b);


                badIdx(ii)=badIdx(ii)&&all(isLeaf)&&~any(b);

                if(ii>1)&&cv('get',sysCvIds(ii-1),'.refClass')==-99

                    jj=ii;
                    while(jj<=numel(sysCvIds))&&(depths(ii-1)<depths(jj))
                        jj=jj+1;
                    end
                    idx=ii:jj-1;
                    if~isempty(idx)
                        depths(idx)=depths(idx)-1;
                        blockCvIds=[blocksCvIds{ii-1};blocksCvIds{ii}];
                        idx=(cv('get',blockCvIds,'.refClass')==sf('get','default','transition.isa'));
                        blockCvIds(idx,:)=[];
                        blocksCvIds{ii-1}=blockCvIds;
                        badIdx(ii)=true;
                    end
                end
            end

            badSysIdx=badIdx(1:numel(sysCvIds));

            sysCvIds(badSysIdx)=[];
            allCvIds(badIdx)=[];
            allSIDs(badIdx)=[];
            allTitles(badIdx)=[];
            depths(badSysIdx)=[];
            blocksCvIds(badSysIdx)=[];
            model2CodeTrIdx(badIdx)=[];
        end

        numSubSystems=numel(sysCvIds);
        numModelElements=numel(allCvIds);

        allOrigins=zeros(size(allCvIds));
        goodIdx=(allCvIds~=0);
        allOrigins(goodIdx)=cv('get',allCvIds(goodIdx),'.origin');

        arr=cell(numModelElements,1);
        arr(:)={zeros(0,1,'int64')};
        modelElements=struct(...
        'modelCovId',allCvIds,...
        'origin',allOrigins(:),...
        'SID',{allSIDs},...
        'name',{cell(numModelElements,1)},...
        'title',{allTitles},...
        'depth',depths(:),...
        'blocksIdx',{cell(numSubSystems,1)},...
        'covIds',{arr},...
        'nodes',{arr});

        for ii=1:numModelElements
            if cvId==0

                if ii==1
                    modelElements.name{1}=analyzedModel;
                end
                if ii<=numSubSystems
                    modelElements.blocksIdx{ii}=(2:numel(allCvIds))';
                end
            else

                name=cv('GetSlsfName',allCvIds(ii));
                if allOrigins(ii)==2
                    name=['SF: ',name];%#ok<AGROW>
                end
                modelElements.name{ii}=name;

                if ii<=numel(sysCvIds)
                    [~,modelElements.blocksIdx{ii}]=ismember(blocksCvIds{ii},allCvIds);
                end
            end

            jj=model2CodeTrIdx(ii);
            if jj~=0

                modelElements.covIds{ii}=model2CodeTrCovIds{jj};
                modelElements.nodes{ii}=model2CodeTrNodes{jj};
            end
        end

        if cvId==0

            modelElements.name(:)={''};
            modelElements.title(:)={''};
        end





        numModelCovId=numel(modelElements.modelCovId);
        if(numel(modelElements.origin)~=numModelCovId)||...
            (numel(modelElements.SID)~=numModelCovId)||...
            (numel(modelElements.name)~=numModelCovId)||...
            (numel(modelElements.title)~=numModelCovId)

            if codeinstrumprivate('feature','disableErrorRecovery')
                throw(MException('Slvnv:codecoverage:CodeMappingFailed'));
            else
                fprintf(1,'%s\n',getString(message('Slvnv:codecoverage:CodeMappingFailed')));
                modelElements=defaultModelElements;
            end
        end

        this.CodeTr.setSLModel(modelElements);

    catch Me

        if codeinstrumprivate('feature','disableErrorRecovery')
            rethrow(Me);
        end
        fprintf(1,'%s\n',getString(message('Slvnv:codecoverage:CodeMappingFailed')));
        this.CodeTr.setSLModel(defaultModelElements);
    end



