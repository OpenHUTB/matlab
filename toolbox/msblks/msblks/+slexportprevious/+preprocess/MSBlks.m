function MSBlks(obj)










    if isR2018bOrEarlier(obj.ver)

        libs=dir(fullfile(matlabroot,'toolbox/msblks/msblks/*.slx'));
        [~,libnames]=slfileparts({libs.name});
        blocks={};
        for i=1:numel(libs)

            if~bdIsLoaded(libnames{i})
                load_system(libnames{i});
                closelib=onCleanup(@()close_system(libnames{i}));
            end
            libBlocks=find_system(libs(i).name(1:end-4),'SearchDepth',1);
            blocks(end+1:end+numel(libBlocks))=libBlocks;
        end
        cellfun(@(s)obj.removeLibraryLinksTo(s),blocks);
        obj.removeBlocksOfType('Discrete2Continuous');
        obj.removeBlocksOfType('LogicDecision');
        obj.removeBlocksOfType('VarPlsDelay');
    end
end