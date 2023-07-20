function brokenLinks=deactivateLibBlkwithCandidate(this)





    brokenLinks={};
    for bIdx=1:length(this.fXformedBlks)
        path=get_param([this.fPrefix,getfullname(this.fXformedBlks{bIdx})],'parent');
        while~strcmpi(get_param(path,'Type'),'block_diagram')&&...
            strcmpi(get_param(path,'linkstatus'),'implicit')
            path=get_param(path,'parent');
        end
        if~strcmpi(get_param(path,'Type'),'block_diagram')
            if strcmpi(get_param(path,'linkstatus'),'resolved')
                if isempty(get_param(path,'LinkData'))
                    brokenLinks=[brokenLinks,path];%#ok
                else
                    MSLDiagnostic('sl_pir_cpp:creator:BreakingLinkLibrary',path).reportAsWarning;
                end
                set_param(path,'linkstatus','inactive');
            end
        end
    end
    brokenLinks=unique(brokenLinks);
end
