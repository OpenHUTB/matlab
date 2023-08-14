function[impl2blkmap,blockList]=dispNFPImplementations(this,dumpToFile,showBlks)












    impl2blkmap=containers.Map();
    if nargin<2
        showBlocks=false;
        dumpToFile=false;
    elseif nargin==2
        dumpToFile=true;
        showBlocks=false;
    else
        dumpToFile=true;
        if ischar(showBlks)&&strcmp(showBlks,'showblocks')
            showBlocks=true;
        else
            error(message('hdlcoder:engine:invalidDisplayArgument'));
        end
    end

    disp(' ')
    blockList={};

    if isempty(this.DescriptionDB)
        disp('NONE')
    else
        if~dumpToFile
            if~showBlocks
                disp('Implementations:')
                disp(' ')
            end
        end


        impls=sort(this.getDescriptionTags);
        for ii=1:length(impls)
            dbEntry=this.getDescription(impls{ii});
            implName=dbEntry.ClassName;
            blocks=sort(dbEntry.SupportedBlocks);

            is_nfp_compat=false;
            try
                obj=eval([implName,'()']);
                settings=obj.get_validate_settings([]);
                is_nfp_compat=~settings.checknfp;
            catch mEx

            end


            if~is_nfp_compat
                continue;
            end

            impl2blkmap(implName)=blocks;


            if showBlocks&&dumpToFile
                disp(sprintf('Implementation: ''%s''',implName))
                disp('  Supported blocks:')
                disp(blocks);
                for index=1:numel(blocks)
                    blockList{end+1}=blocks{index};
                end
            elseif showBlocks==0&&dumpToFile==0
                disp(sprintf('    ''%s''',implName));
            elseif showBlocks==0&&dumpToFile==1

                for index=1:numel(blocks)
                    blockList{end+1}=blocks{index};
                end
            else
                disp(sprintf('Implementation: ''%s''',implName))
                disp('  Supported blocks:')
                disp(blocks);
            end
        end
    end

    disp(' ')


