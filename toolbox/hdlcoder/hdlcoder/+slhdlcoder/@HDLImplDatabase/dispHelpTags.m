function dispHelpTags(this)





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

            name=regexprep(slBlkPath,'\n',' ');
            if any(name=='.')&&...
                matlab.system.internal.isMATLABAuthoredSystemObjectName(name)
                fprintf('SystemObject: ''%s''',name);
            else
                fprintf('Block: ''%s''',name);
            end

            for jj=1:length(dbEntry.Implementations)
                implName=dbEntry.Implementations{jj};
                if~strcmpi(implName,'none')
                    fprintf('\n  HelpTopicID: %s',hdlgethelptagname(slBlkPath,implName));
                end
            end
            disp(' ');
        end
    end
