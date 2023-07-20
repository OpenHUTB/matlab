function updateBackend(this)






    exclusionsObj=CloneDetector.Exclusions();
    manager=exclusionsObj.getCloneDetectionFilterManager(this.model);
    manager.clear();


    if(this.GlobalExclusionsData.ExcludeModelReferences)
        manager.addCloneDetectionFilterSpecification('ModelReference',...
        slcheck.getFilterTypeEnum('BlockType'),...
        slcheck.getFilterModeEnum('Exclude'),...
        'Exclude model references');
    end

    if(this.GlobalExclusionsData.ExcludeLibraryLinks)
        manager.addCloneDetectionFilterSpecification('LibraryLinks',...
        slcheck.getFilterTypeEnum('Library'),...
        slcheck.getFilterModeEnum('Exclude'),...
        'Exclude library links');
    end

    if(this.GlobalExclusionsData.ExcludeInactiveRegions)
        manager.addCloneDetectionFilterSpecification('InactiveRegions',...
        slcheck.getFilterTypeEnum('BlockType'),...
        slcheck.getFilterModeEnum('Exclude'),...
        'Exclude inactive and commented out regions');
    end


    for idx=1:numel(this.TableData)

        item=this.TableData{idx};
        id=item{1}.sid;
        type=item{2};
        reason=item{3};

        manager.addCloneDetectionFilterSpecification(slcheck.getsid(id),...
        slcheck.getFilterTypeEnum(type),...
        slcheck.getFilterModeEnum('Exclude'),...
        reason);
    end
end


