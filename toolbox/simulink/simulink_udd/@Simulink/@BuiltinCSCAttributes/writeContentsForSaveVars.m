function writeContentsForSaveVars(obj,vs)







    props=Simulink.data.getPropList(obj,...
    'Hidden',false,...
    'Transient',false,...
    'SetAccess','public',...
    'GetAccess','public');

    if~isempty(props)
        props=get(props);
        names={props(:).Name}';


        if((ismember('Latching',names)&&strcmp(obj.Latching,'None'))&&...
            (slfeature('LatchingForDataObjects')<2))
            names(strcmp(names,'Latching'))=[];
        end

        for idx=1:length(names)
            thisName=names{idx};
            vs.writePropertyContents(thisName,obj.(thisName));
        end
    end


