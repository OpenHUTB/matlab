function varargout=autoblkscidynamicengine(varargin)
    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    end

end


function IconInfo=DrawCommands(Block)

    AliasNames={};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='engine_compression_ignition.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,120,20,'white');

end

