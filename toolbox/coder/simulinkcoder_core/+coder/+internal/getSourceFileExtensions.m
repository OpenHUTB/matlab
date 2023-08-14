function src_exts=getSourceFileExtensions(lToolchainInfo)






    if isempty(lToolchainInfo)
        src_exts={'*.c*'};
    else
        inputExts=lToolchainInfo.getBuildTool('C Compiler')...
        .getIOFileExtensions('input');
        CSRC_EXT=cell(size(inputExts));
        CPPSRC_EXT={};
        ASMSRC_EXT={};
        for ii=1:numel(inputExts)
            CSRC_EXT{ii}=['*',inputExts{ii}];
        end
        if lToolchainInfo.BuildTools.isKey('C++ Compiler')
            inputExts=lToolchainInfo.getBuildTool('C++ Compiler')...
            .getIOFileExtensions('input');
            CPPSRC_EXT=cell(size(inputExts));
            for ii=1:numel(inputExts)
                CPPSRC_EXT{ii}=['*',inputExts{ii}];
            end
        end
        if lToolchainInfo.BuildTools.isKey('Assembler')
            inputExts=lToolchainInfo.getBuildTool('Assembler')...
            .getIOFileExtensions('input');
            ASMSRC_EXT=cell(size(inputExts));
            for ii=1:numel(inputExts)
                ASMSRC_EXT{ii}=['*',inputExts{ii}];
            end
        end
        src_exts=[CSRC_EXT(:);CPPSRC_EXT(:);ASMSRC_EXT(:)];
    end
