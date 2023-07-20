function dispIRImplementations(this)


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
    pirmcosblks={};
    recruseblks={};
    deblks={};

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

            blkImpl=eval(implName);
            if isa(blkImpl,'hdlbuiltinimpl.EmlImplBase')||...
                isa(blkImpl,'hdldefaults.abstractBlackBox')
                emlblks{end+1}=implName;%#ok<*AGROW>
            elseif isa(blkImpl,'hdlimplbase.HDLRecurseIntoSubsystem')||...
                isa(blkImpl,'hdlbuiltinimpl.HDLRecurseIntoSubsystem')
                recruseblks{end+1}=implName;%#ok<*AGROW>
            elseif isa(blkImpl,'hdlimplbase.EmlImplBase')||...
                isa(blkImpl,'hdldefaults.abstractBBox')||...
                isa(blkImpl,'hdldefaults.Subsystem')
                mcosblks{end+1}=implName;%#ok<*AGROW>
            elseif isa(blkImpl,'hdlimplbase.HDLDirectCodeGen')
                pirmcosblks{end+1}=implName;
            else
                deblks{end+1}=implName;
            end

        end

        emlblks=sort(emlblks);
        mcosblks=sort(mcosblks);
        pirmcosblks=sort(pirmcosblks);
        recruseblks=sort(recruseblks);
        deblks=sort(deblks);


        nd=length(deblks);
        ne=length(emlblks);
        nm=length(mcosblks);
        np=length(pirmcosblks);
        nr=length(recruseblks);


        barh([np,nm,ne,nd,nr]);
        colormap(summer(6));
        ylabel('Technology');
        xlabel('Number of Blocks');
        text(np+1,5,sprintf('Recurse SS (%d)',nr));
        text(nd+1,4,sprintf('DE (%d)',nd));
        text(ne+1,3,sprintf('eMLA (%d)',ne));
        text(nm+1,2,sprintf('MCOS eMLA (%d)',nm));
        text(np+1,1,sprintf('MCOS PIR (%d)',np));
        set(gca,'xlim',[1,250]);
        set(gca,'xTick',[]);
        set(gca,'yTick',[]);

        displayBlks(recruseblks,'Recurse Subsystem Implementations');
        displayBlks(deblks,'DirectEmit Implementations');
        displayBlks(emlblks,'eMLA Implementations');
        displayBlks(mcosblks,'MCOS eMLA Implementations');
        displayBlks(pirmcosblks,'MCOS PIR Implementations');
    end
end

function displayBlks(blks,headerStr)
    disp(sprintf('%s (%d)',headerStr,length(blks)));
    for ii=1:length(blks)
        disp(sprintf('    ''%s''',blks{ii}));%#ok<*DSPS>
    end
    disp(' ')
end


