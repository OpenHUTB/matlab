



function out=jsonencode(retMessage)
    if isstruct(retMessage)
        names=fieldnames(retMessage.data);
        for i=1:numel(names)
            if isa(retMessage.data.(names{i}),'matlab.lang.OnOffSwitchState')
                retMessage.data.(names{i})=char(retMessage.data.(names{i}));
            end
        end
        out=jsonencode(retMessage);
    else
        if isa(retMessage,'matlab.lang.OnOffSwitchState')
            retMessage=char(retMessage);
        end
        out=jsonencode(retMessage);
    end
end