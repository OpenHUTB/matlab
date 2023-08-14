function h=Target(varargin)






    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    h=RTWConfiguration.Target;


    h.inactiveList=RTWConfiguration.ListHead;
    h.connect(h.inactiveList,'down');

    switch nargin
    case 0

    case 2
        switch varargin{1}
        case 'new'
            h.activeList=RTWConfiguration.ListHead;
            h.connect(h.activeList,'down');
            h.block=varargin{2};
        otherwise
            TargetCommon.ProductInfo.error('common','InputArgNInvalid','First','string new');
        end
    otherwise
        TargetCommon.ProductInfo.error('common','NInputArgsRequired',2);

    end


    h.registered_blocks={};






