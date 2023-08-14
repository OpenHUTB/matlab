function dumpCompiledBlockList(bd,varargin)
    if nargin<2
        count=0;
    else
        count=varargin{1};
    end
    bl=bd.getCompiledBlockList;
    for i=1:length(bl)
        for j=1:count
            fprintf('\t');
        end
        if~bl(i).isSynthesized
            fprintf('%d <a href="matlab:coder.internal.code2model(''%s'')">%s</a>\n',...
            i,bl(i).SID,getFullpathName(bl(i)));
        else
            fprintf('%d %s\n',i,getFullpathName(bl(i)));
        end
        if strcmp(blockType(bl(i)),'SubSystem')
            ss=Simulink.CMI.Subsystem(bd.sess,bl(i).Handle);
            Simulink.CMI.util.dumpCompiledBlockList(ss,count+1);
        end
    end
end