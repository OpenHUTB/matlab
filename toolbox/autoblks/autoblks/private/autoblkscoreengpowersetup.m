function varargout=autoblkscoreengpowersetup(varargin)
    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        Initialization(Block);
    end

end


function Initialization(Block)


    TorqueOption={'autolibcoreengcommon/Simple Torque Model PwrNotTrnsfrd','Simple Torque Model PwrNotTrnsfrd';...
    'autolibcoreengcommon/Torque Structure PwrNotTrnsfrd','Torque Structure PwrNotTrnsfrd'};

    switch get_param(Block,'TrqMdlType')
    case 'Simple Torque Lookup'
        autoblksreplaceblock(Block,TorqueOption,1);
    case 'Torque Structure'
        autoblksreplaceblock(Block,TorqueOption,2);
    end
end