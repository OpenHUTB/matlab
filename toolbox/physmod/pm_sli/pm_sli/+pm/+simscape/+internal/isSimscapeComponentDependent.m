function result=isSimscapeComponentDependent(hBlock)









    result=false;

    if isa(hBlock,'Simulink.Block')||isa(hBlock,'Simulink.BlockDiagram')
        hBlock=hBlock.handle;
    end

    if strcmpi(get_param(hBlock,'Type'),'block')
        blkLibPath=get_param(hBlock,'ReferenceBlock');
        result=~isempty(blkLibPath)&&(strncmpi(blkLibPath,'simrfV2',7)||...
        strncmp(blkLibPath,'nesl_utility_internal',21));
    end

end