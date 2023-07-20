function varargout=who(h)








    nameStruct=get(h,'Members');
    s=[];
    names={};

    num=length(nameStruct);



    for i=1:num
        name=nameStruct(i).name;
        if~isvarname(name)
            names{i}=['(''',name,''')'];
        else
            names{i}=name;
        end
    end

    if nargout>0,
        varargout{1}=names';
    else,

        [s,err]=sprintf('\nYour logs for ''%s'' are:\n',h.Name);
        disp(s);

        for(i=1:num),
            if(i==1),
                s=names{i};
            else,
                s=[s,'  ',names{i}];
            end
        end
        disp(s);


        disp(sprintf('\n'));
    end