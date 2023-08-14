function dispImplementations(this,showBlks)













    if nargin<2
        showBlocks=false;
    else
        if ischar(showBlks)&&strcmp(showBlks,'showblocks')
            showBlocks=true;
        else
            error(message('hdlcoder:engine:invalidDisplayArgument'));
        end
    end

    disp(' ')

    if isempty(this.DescriptionDB)
        disp('NONE')
    else
        if~showBlocks
            disp('Implementations:')
            disp(' ')
        end

        impls=sort(this.getDescriptionTags);
        for ii=1:length(impls)
            dbEntry=this.getDescription(impls{ii});
            implName=dbEntry.ClassName;
            blocks=sort(dbEntry.SupportedBlocks);
            if showBlocks
                disp(sprintf('Implementation: ''%s''',implName))
                disp('  Supported blocks:')
                disp(blocks);
            else
                disp(sprintf('    ''%s''',implName));
            end
        end
    end

    disp(' ')
