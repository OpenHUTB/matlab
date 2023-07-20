function blk=getBlockFromHierarchy(bd,varargin)
    ss=bd;
    if isempty(varargin)
        blk=Simulink.CMI.CompiledBlock.empty;
    else
        for i=1:length(varargin)
            cl=ss.getCompiledBlockList;
            blk=cl(varargin{i});
            if strcmp(blockType(blk),'SubSystem')
                ss=Simulink.CMI.Subsystem(bd.sess,blk.Handle);
            end
        end
    end
end