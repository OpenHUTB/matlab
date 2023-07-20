function dispDatabase(this)





    fprintf('---------------------------');
    fprintf('HDL Implementation database');
    fprintf('---------------------------\n');

    if isempty(this.BlockDB)
        disp('EMPTY')
    else
        blocks=sort(this.getBlockTags);
        for ii=1:length(blocks)
            dbEntry=this.getBlock(blocks{ii});
            slBlkPath=dbEntry.SimulinkPath;

            slBlkPath=regexprep(slBlkPath,'\n',' ');
            if any(slBlkPath=='.')&&...
                matlab.system.internal.isMATLABAuthoredSystemObjectName(slBlkPath)
                fprintf('SystemObject: ''%s''',slBlkPath);
            else
                fprintf('Block: ''%s''',slBlkPath);
            end

            for jj=1:length(dbEntry.Implementations)
                implName=dbEntry.Implementations{jj};
                desc=this.getDescription(implName);
                fprintf('  Implementation: ''%s''',implName);

            end
            disp(' ');
        end
    end
