function xformSpecificPostProc(this)



    for ii=1:length(this.fCopyLib)
        if strcmp(get_param(this.fCopyLib{ii},'linkstatus'),'resolved')
            set_param(bdroot(this.fCopyLib{ii}),'locklinkstolibrary','off')
            set_param(this.fCopyLib{ii},'linkstatus','propagatehierarchy');
        end
    end
end
