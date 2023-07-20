function buff=createmstr_struct(this,varargin)














































    props=createmstr(this,varargin{:});




    props=strrep(props,'{','{{');
    props=strrep(props,'}','}}');


    buff=sprintf('struct( ...\n');

    for indx=1:length(props)-1
        buff=sprintf('%s    %s, ...\n',buff,props{indx});
    end

    if~isempty(props)
        buff=sprintf('%s    %s);',buff,props{end});
    else
        buff=sprintf('%s    );',buff);
    end


