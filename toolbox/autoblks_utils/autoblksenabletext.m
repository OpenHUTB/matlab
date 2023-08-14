function autoblksenabletext(varargin)


    if nargin>3
        return
    end

    if ischar(varargin{1})
        MaskObject=get_param(varargin{1},'MaskObject');
        for i=1:length(varargin{2})
            EnTextList=MaskObject.getDialogControl(varargin{2}{i});
            if(~isempty(EnTextList))
                EnTextList.Visible='on';
            end
        end

        for i=1:length(varargin{3})
            DisTextList=MaskObject.getDialogControl(varargin{3}{i});
            if(~isempty(DisTextList))
                DisTextList.Visible='off';
            end
        end
    end
