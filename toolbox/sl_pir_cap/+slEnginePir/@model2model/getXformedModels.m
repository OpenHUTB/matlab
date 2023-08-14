function getXformedModels(this)



    mdls={this.fMdl};
    xformedLibs={};
    mdls=[mdls,this.fRefMdls];
    if this.fLibCopyOption==0
        this.fXLinkedBlks=this.fLinkedBlks;
        this.fXformedMdls=[mdls,this.fLibMdls];
        return;
    end

    xformedLibBlks={};
    for xIdx=1:length(this.fXformedBlks)
        if~strcmpi(get_param(this.fXformedBlks{xIdx},'Type'),'block_diagram')&&...
            (strcmpi(get_param(this.fXformedBlks{xIdx},'LinkStatus'),'implicit')||...
            strcmpi(get_param(this.fXformedBlks{xIdx},'LinkStatus'),'resolved'))
            refBlk=get_param(this.fXformedBlks{xIdx},'ReferenceBlock');
            xformedLibs=[xformedLibs,bdroot(refBlk)];%#ok
            xformedLibBlks=[xformedLibBlks;refBlk];%#ok
        end
        rootBd=bdroot(this.fXformedBlks{xIdx});
        if isKey(this.fMdlRefInLibMap,rootBd)
            mdlRefBlks=this.fMdlRefInLibMap(rootBd);
            for mIdx=1:length(mdlRefBlks)
                xformedLibs=[xformedLibs,bdroot(mdlRefBlks{mIdx})];
                xformedLibBlks=[xformedLibBlks;getfullname(mdlRefBlks{mIdx})];
            end
        end
    end
    xformedLibs=unique(xformedLibs);
    for ii=1:length(xformedLibBlks)
        if~strcmpi(get_param(xformedLibBlks(ii),'BlockType'),'SubSystem')&&...
            ~strcmpi(get_param(xformedLibBlks(ii),'BlockType'),'ModelReference')
            xformedLibBlks(ii)=get_param(xformedLibBlks(ii),'Parent');%#ok
        end
    end
    xformedLibBlks=unique(xformedLibBlks);


    linkedBlks=this.fLinkedBlks;
    if this.fLibCopyOption==1
        [this.fXlinkedBlks,xformedLibs]=getXformedLibsOpt1(linkedBlks,xformedLibs,xformedLibBlks);
    end
    this.fXformedMdls=unique([mdls,xformedLibs]);

end

function[linkedblkInXformedLibs,xformedLibs]=getXformedLibsOpt1(aLinkedBlks,aXformedLibs,aXformedLibBlks)
    linkedblkInXformedLibs=struct('block',{},'lib',{});
    linkedBlks=aLinkedBlks;
    xformedLibs=aXformedLibs;
    keepSearch=1;
    while~isempty(linkedBlks)&&keepSearch
        keepSearch=0;
        blks2Remove=[];
        for bIdx=1:length(linkedBlks)
            dlg=bdroot(linkedBlks(bIdx).block);
            if~isempty(find(strcmpi(xformedLibs,linkedBlks(bIdx).lib),1))
                if~bdIsLibrary(dlg)||link2xformedLibBlk(linkedBlks(bIdx).block,aXformedLibBlks)
                    linkedblkInXformedLibs=[linkedblkInXformedLibs,linkedBlks(bIdx)];%#ok
                    blks2Remove=[blks2Remove,bIdx];%#ok
                    if bdIsLibrary(dlg)
                        xformedLibs=unique([xformedLibs,dlg]);
                        aXformedLibBlks=[aXformedLibBlks;linkedBlks(bIdx).block];%#ok
                        keepSearch=1;
                    end
                end
            end
        end
        linkedBlks(blks2Remove)=[];
    end
end

function linked=link2xformedLibBlk(blk,aXformedLibBlks)
    refBlk=get_param(blk,'ReferenceBlock');
    foundStr=strfind(aXformedLibBlks,refBlk);
    idx=find(not(cellfun('isempty',foundStr)));
    linked=~isempty(find([foundStr{idx}]==1,1));%#ok
end























