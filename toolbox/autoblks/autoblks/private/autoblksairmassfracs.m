function[varargout]=autoblksairmassfracs(varargin)






    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        varargout{1}=Initialization(Block);
    end

end


function M=Initialization(Block)
    AirObj=autoblkssetupengflwmassfrac(Block,'AirObj');
    if~isempty(AirObj)
        M.AirO2MassFrac=AirObj.MassFracStruct.O2MassFrac;
        M.AirN2MassFrac=AirObj.MassFracStruct.N2MassFrac;
    else
        M=[];
    end
end
