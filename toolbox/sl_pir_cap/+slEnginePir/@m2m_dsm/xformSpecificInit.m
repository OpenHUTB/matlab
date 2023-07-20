function xformSpecificInit(this)



    for ii=1:length(this.fXlinkedBlks)
        linkedBlk=this.fXlinkedBlks(ii).block;
        blkName=get_param(linkedBlk,'name');
        refBlk=get_param(linkedBlk,'ReferenceBlock');
        parent=get_param(linkedBlk,'parent');
        while~isempty(parent)
            if isprop(get_param(parent,'handle'),'linkstatus')
                parentLinkStatus=get_param(parent,'linkstatus');
                if strcmp(parentLinkStatus,'resolved')
                    parentRefBlk=get_param(parent,'ReferenceBlock');
                    this.fCopyLib{end+1}=[this.fPrefix,parentRefBlk,'/',blkName];
                    this.fCopyLibRef{end+1}=[this.fPrefix,refBlk];
                end
            end
            parent=get_param(parent,'parent');
        end
    end



end
