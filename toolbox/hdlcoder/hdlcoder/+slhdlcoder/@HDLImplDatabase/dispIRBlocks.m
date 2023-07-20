function dispIRBlocks(this)


    if nargin<2
        showBlocks=false;
    else
        if ischar(showBlks)&&strcmp(showBlks,'showblocks')
            showBlocks=true;
        else
            error(message('hdlcoder:engine:invalidDisplayArgument'));
        end
    end

    this.buildDatabase;

    disp(' ')

    emlblks={};
    mcosblks={};
    recruseblks={};
    deblks={};
    nopblks={};

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
            blocks=sort(dbEntry.SupportedBlocks);
            implName=dbEntry.ClassName;

            blkImpl=eval(implName);
            if isa(blkImpl,'hdlbuiltinimpl.EmlImplBase')||...
                isa(blkImpl,'hdldefaults.SubSystem')
                for jj=1:length(blocks)
                    emlblks{end+1}=blocks{jj};%#ok<*AGROW>
                end
            elseif isa(blkImpl,'hdlimplbase.HDLRecurseIntoSubsystem')||...
                isa(blkImpl,'hdlbuiltinimpl.HDLRecurseIntoSubsystem')
                for jj=1:length(blocks)
                    recruseblks{end+1}=blocks{jj};%#ok<*AGROW>   recruseblks
                end
            elseif isa(blkImpl,'hdlimplbase.EmlImplBase')
                for jj=1:length(blocks)
                    mcosblks{end+1}=blocks{jj};%#ok<*AGROW>
                end
            elseif isa(blkImpl,'hdldefaults.NoHDLEmission')||...
                isa(blkImpl,'hdldefaults.PassThroughHDLEmission')
                for jj=1:length(blocks)
                    nopblks{end+1}=blocks{jj};%#ok<*AGROW>
                end
            else
                for jj=1:length(blocks)
                    deblks{end+1}=blocks{jj};%#ok<*AGROW>
                end
            end

        end

        emlblks=sort(unique(emlblks));
        mcosblks=sort(unique(mcosblks));
        recruseblks=sort(unique(recruseblks));
        deblks=sort(unique(deblks));
        nopblks=sort(unique(nopblks));

        displayBlks(recruseblks,'Recurse SS Implementations');
        displayBlks(mcosblks,'MCOS MATLAB Implementations');
        displayBlks(emlblks,'MATLAB Implementations');
        displayBlks(deblks,'DirectEmit Implementations');
        displayBlks(nopblks,'DirectEmit Noops');

        nr=length(recruseblks);
        nm=length(mcosblks);
        ne=length(emlblks);
        nd=length(deblks);
        nn=length(nopblks);


        barh([nn,nm,ne,nd,nr]);
        colormap(summer(6));
        ylabel('Technology');
        xlabel('Number of Blocks');
        text(nn+1,1,sprintf('nop (%d)',nn));
        text(nn+1,2,sprintf('MCOS eMLA (%d)',nm));
        text(ne+1,3,sprintf('UDD eMLA (%d)',ne));
        text(nd+1,4,sprintf('DE (%d)',nd));
        text(nd+1,5,sprintf('Recurse SS (%d)',nr));
        xmax=1.25*max([nn,nm,ne,ne,nd,nr]);
        set(gca,'xlim',[1,xmax]);
        set(gca,'xTick',1:25:xmax);
        set(gca,'xTickLabel',0:25:xmax);
        set(gca,'yTick',[]);

    end
end

function displayBlks(blks,headerStr)
    disp(sprintf('%s (%d)',headerStr,length(blks)));
    for ii=1:length(blks)
        disp(sprintf('    ''%s''',blks{ii}));%#ok<*DSPS>
    end
    disp(' ')
end


