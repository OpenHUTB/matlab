function lineHandle=getLine(path)




















    pattern='(?<sys>[^/].*)/(?<srcblock>[^:]*):(?<srcport>[^:]*):(?<dstblock>[^:]*):(?<dstport>[^:]*)';
    matches=regexp(path,pattern,'names');
    srcblock=slxmlcomp.internal.line.unescape(matches.srcblock);
    srcport=slxmlcomp.internal.line.unescape(matches.srcport);
    dstblock=slxmlcomp.internal.line.unescape(matches.dstblock);
    dstport=slxmlcomp.internal.line.unescape(matches.dstport);

    if~isempty(srcblock)
        args={'SrcBlock',srcblock,'SrcPort',srcport};
    else

        args={'SrcBlock',''};
    end
    if~isempty(dstblock)
        args=[args,{'DstBlock',dstblock,'DstPort',dstport}];
    else

        args=[args,{'DstBlock',dstblock}];
    end

    lineHandle=find_system(matches.sys,'findAll','on','SearchDepth',1,...
    'LookUnderMasks','on',args{:});
end
