function highlightSubsystem(h,block)



    if~h.FeatureSubsysHighlight
        return
    end

    if~strcmp(get_param(block,'Type'),'block_diagram')&&...
        ~strcmp(get_param(block,'BlockType'),'SubSystem')
        DAStudio.error('RTW:utility:invalidInputArgs',block);
    end

    subSysFullName='';
    if~isempty(h.SourceSystem)
        subSysFullName=getfullname(h.SourceSystem);
    end
    if~isempty(subSysFullName)&&isempty(strfind(block,subSysFullName))
        DAStudio.error('RTW:traceInfo:blockOutsideSystem',block);
    end

    blockpath=getfullname(block);
    if strcmp(blockpath,h.Model)
        rtwSysName='<Root>';
    else
        rtwSysName=locRtwSysName(h,blockpath);
    end

    len=length(rtwSysName);
    idx=arrayfun(@(x)strncmp(x.rtwname,rtwSysName,len),h.Registry);
    if any(idx)
        regs=h.Registry(idx);
        idx=arrayfun(@(x)isempty(x.location),regs);
        untraceable=regs(idx);
        traceable=regs(~idx);
        rtwprivate('rtwctags_hilite',{untraceable.pathname},'-fade');
        rtwprivate('rtwctags_hilite',{traceable.pathname},'-find','-cont');
        h.highlightCodeLocations({traceable.location});
    else
        rtwprivate('rtwctags_hilite',blockpath,'-fade');
        MSLDiagnostic('RTW:traceInfo:notTraceable',blockpath).reportAsWarning;
    end

    function out=locRtwSysName(h,blockpath)


        out=[];
        blockpath(end+1)='/';
        len=length(blockpath);
        num=length(h.Registry);
        for k=1:num
            if strncmp(h.Registry(k).pathname,blockpath,len)
                out=strtok(h.Registry(k).rtwname,'/');
                return
            end
        end