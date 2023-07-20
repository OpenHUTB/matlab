function addAdditionalInformation(rpt,varargin)







    if(length(varargin)==1)
        AdditionalInformation=varargin{1};
        if(isfield(AdditionalInformation,'title')&&isfield(AdditionalInformation,'message'))
            rpt.AdditionalInformation=[rpt.AdditionalInformation,varargin{1}];
        else
            error(message('MATLAB:noSuchMethodOrField',varargin{1},class(rpt)));
        end
    else
        rpt.AdditionalInformation=[rpt.AdditionalInformation,struct('title',varargin{1},'message',varargin{2})];

    end
end
