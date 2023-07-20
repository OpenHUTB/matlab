function bss=createBlockSupportSetting(varargin)


    template=struct(...
    'BlockType','',...
    'MaskType','',...
    'NumDims','',...
    'Table',''...
    );
    template.Axes={};

    if nargin==1
        bss=repmat(template,varargin{1});
    else
        bss=template;
        bss.BlockType=char(varargin{1});
        bss.MaskType=char(varargin{2});
        bss.NumDims=char(varargin{3});
        bss.Table=char(varargin{4});
        if isstring(varargin{5})
            bss.Axes=arrayfun(@(axis)char(axis),varargin{5},'UniformOutput',false);
        else
            bss.Axes=cellfun(@(axis)char(axis),varargin{5},'UniformOutput',false);
        end
    end
end
