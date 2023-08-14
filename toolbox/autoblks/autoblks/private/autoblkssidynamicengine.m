function varargout=autoblkssidynamicengine(varargin)
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


    IconInfo.ImageName='engine_spark_ignition.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,80,10,'white');

end

