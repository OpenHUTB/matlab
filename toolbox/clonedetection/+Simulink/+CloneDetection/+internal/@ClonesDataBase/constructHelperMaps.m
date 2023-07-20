function constructHelperMaps(this)









    this.metrics=struct('overAllPotentialReuse',0,'exactPotentialReuse',0,'similarPotentialReuse',0);
    if~isempty(this.m2mObj.cloneresult.exact)
        populateMaps(this,this.m2mObj.cloneresult.exact,'Exact');
    end

    if~isempty(this.m2mObj.cloneresult.similar)
        populateMaps(this,this.m2mObj.cloneresult.similar,'Similar');
    end

    function populateMaps(this,cloneResultStruct,cloneCategory)
        for cloneGroupIndex=1:length(cloneResultStruct)
            numblk=this.m2mObj.cloneresult.NumberBlks(cloneResultStruct{cloneGroupIndex}.index);
            if this.enableClonesAnywhere
                nodeChildrenArray=this.m2mObj.cloneresult.Before(cloneResultStruct{cloneGroupIndex}.index);
                numClonesAfterExclusions=length(nodeChildrenArray.Region);
            else
                nodeChildrenArray=this.m2mObj.cloneresult.Before{cloneResultStruct{cloneGroupIndex}.index};
                numClonesAfterExclusions=length(nodeChildrenArray);
            end
            if strcmp(cloneCategory,'Exact')
                groupNameKey=['Exact-CloneGroup-',num2str(cloneGroupIndex)];
                message=[DAStudio.message('sl_pir_cpp:creator:sysclonedetc_PrefixExact'),' ',...
                DAStudio.message('sl_pir_cpp:creator:sysclonedetc_Subsystemclonegroup',cloneGroupIndex)];
            else
                groupNameKey=['Similar-CloneGroup-',num2str(cloneGroupIndex)];
                message=[DAStudio.message('sl_pir_cpp:creator:sysclonedetc_PrefixSimilar'),' ',...
                DAStudio.message('sl_pir_cpp:creator:sysclonedetc_Subsystemclonegroup',cloneGroupIndex)];
            end
            childrenArray=cell(length(nodeChildrenArray),1);
            if~this.enableClonesAnywhere
                for j=1:length(nodeChildrenArray)
                    childrenArray{j}=struct('sid',{Simulink.ID.getSID(nodeChildrenArray{j})},...
                    'name',nodeChildrenArray{j});
                    this.blockPathCategoryMap(nodeChildrenArray{j})=struct('CloneGroupKey',groupNameKey,...
                    'CloneGroupName',message);
                    if isKey(this.m2mObj.excluded_sysclone,nodeChildrenArray{j})&&~strcmp(this.m2mObj.excluded_sysclone(),'unchecked')
                        numClonesAfterExclusions=numClonesAfterExclusions-1;
                    end
                end
            else
                l=1;
                for j=1:length(nodeChildrenArray.Region)
                    for k=1:length(nodeChildrenArray.Region(j).Candidates)
                        childrenArray{l}=struct('sid',{Simulink.ID.getSID(nodeChildrenArray.Region(j).Candidates(k))},...
                        'name',nodeChildrenArray.Region(j).Candidates(k));
                        this.blockPathCategoryMap(char(nodeChildrenArray.Region(j).Candidates(k)))=struct('CloneGroupKey',groupNameKey,...
                        'CloneGroupName',message);
                        if isKey(this.m2mObj.excluded_sysclone,nodeChildrenArray.Region(j).Candidates(k))&&~strcmp(this.m2mObj.excluded_sysclone(),'unchecked')
                            numClonesAfterExclusions=numClonesAfterExclusions-1;
                        end
                        l=l+1;
                    end
                end
            end



            if strcmp(cloneCategory,'Exact')
                this.cloneGroupSidListMap(groupNameKey)=struct('cloneIndex',cloneGroupIndex,...
                'CloneGroupName',message);

                updateMetrics(this,numblk,numClonesAfterExclusions,1);
            else
                this.cloneGroupSidListMap(groupNameKey)=struct('cloneIndex',cloneGroupIndex,...
                'CloneGroupName',message);

                updateMetrics(this,numblk,numClonesAfterExclusions,0);
            end
        end

        function updateMetrics(this,numblk,numClonesAfterExclusions,isExact)
            numBlocksPerGroup=numblk*(numClonesAfterExclusions-1);

            this.metrics.overAllPotentialReuse=this.metrics.overAllPotentialReuse+numBlocksPerGroup;
            if isExact
                this.metrics.exactPotentialReuse=this.metrics.exactPotentialReuse+numBlocksPerGroup;
            else
                this.metrics.similarPotentialReuse=this.metrics.similarPotentialReuse+numBlocksPerGroup;
            end


