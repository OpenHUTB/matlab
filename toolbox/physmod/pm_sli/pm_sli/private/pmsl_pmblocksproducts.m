function[pmBlockHandles,topLevelPmBlocksFlags,products]=pmsl_pmblocksproducts(mdl,includeInactive)






    narginchk(1,2);

    if nargin==1
        includeInactive=false;
    end


    if~isa(mdl,'Simulink.BlockDiagram')
        mdl=get_param(mdl,'Object');
    end








    if nargout==3
        [pmBlockHandles,topLevelPmBlocksFlags,products]=lFindPmBlocks(mdl,includeInactive);
    else
        [pmBlockHandles,topLevelPmBlocksFlags]=lFindPmBlocks(mdl,includeInactive);
    end
end

function[pmBlockHandles,topLevelPmBlocksFlags,products]=lFindPmBlocks(mdl,includeInactive)







    getProducts=false;
    if nargout==3
        getProducts=true;
    end

    pmLibraries={};
    blocks=sort(pmsl_toplevelblocks(mdl,includeInactive));
    libDb=PmSli.LibraryDatabase;
    libraryBlocks=get_param(blocks,'ReferenceBlock');


    regexpPattern='^([^/]+)(/.+)';
    libraryNames=regexprep(libraryBlocks,regexpPattern,'$1');
    if~iscell(libraryNames)
        libraryNames={libraryNames};
    end
    pmBlockIdx=libDb.containsEntry(libraryNames);
    pmBlocks=blocks(pmBlockIdx);
    pmLibraries={pmLibraries{:},libraryNames{pmBlockIdx}};


    unknownBlocks=blocks(~pmBlockIdx);



    possiblePmBlocks=unknownBlocks;
    pmSsIdx=false(1,numel(possiblePmBlocks));
    blockTypesRegex=lGetBlockTypesRegex;
    for idx=1:numel(possiblePmBlocks)














        childBlocks=find_system(possiblePmBlocks(idx),'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','on','regexp','on','LinkStatus','resolved',...
        'BlockType',blockTypesRegex);

        childReferenceBlocks=get_param(childBlocks,'ReferenceBlock');


        childLibraryNames=regexprep(childReferenceBlocks,regexpPattern,'$1');
        childLibraryIdx=libDb.containsEntry(childLibraryNames);
        pmSsIdx(idx)=any(childLibraryIdx);
        if pmSsIdx(idx)
            pmLibraries={pmLibraries{:},childLibraryNames{childLibraryIdx}};
        end
    end

    pmSubsystemBlocks=possiblePmBlocks(pmSsIdx);


    pmBlockHandles=[pmBlocks;pmSubsystemBlocks];
    topLevelPmBlocksFlags=[true(numel(pmBlocks),1);false(numel(pmSubsystemBlocks),1)];


    products={};

    if getProducts



        pmLibraries=unique(pmLibraries);
        pmLibraryEntries=libDb.getLibraryEntry(pmLibraries);
        numLibraries=numel(pmLibraries);
        products=cell(1,numLibraries);
        for idx=1:numLibraries
            products{idx}=pmLibraryEntries(idx).Product;
        end

        products=unique(products);
        if isempty(products)


            products={'Simscape'};
        end
    end



end

function blockTypesRegex=lGetBlockTypesRegex()



    blockTypesRegex=char(join(["SubSystem";string(pmsl_getblocktypes())],"|"));

end


