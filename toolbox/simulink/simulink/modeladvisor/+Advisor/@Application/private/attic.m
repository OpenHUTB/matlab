


function attic(method,ID,varargin)

    persistent data;%#ok<PUSE>
    persistent key;
    switch(method)
    case 'add'
        if isempty(key)
            index=1;
        else
            index=length(key)+1;
            for i=1:length(key)
                if isempty(key{i})
                    index=i;
                    break
                end
            end
        end
        key{index}=ID;
        data{index}=varargin{1};
    case 'remove'
        for i=1:length(key)
            if strcmp(key{i},ID)
                data{i}=[];
                key{i}='';
                break
            end
        end
    end










end