function str=toString(this,val,propName)




    if(nargin<3)
        propName='<unspecified>';
    end



    if ischar(val)

        warnState=warning;
        warning('off');
        [oldWarnMsg,oldWarnId]=lastwarn;


        tmp=str2double(val);

        warning(warnState);
        lastwarn(oldWarnMsg,oldWarnId);




        if~isempty(tmp)&&isa(tmp,'numeric')&&~isnan(tmp)
            str=val;
        else
            str=['''',val,''''];
        end

    elseif iscellstr(val)







        str='{';
        N=numel(val);
        for i=1:N
            str=sprintf('%s''%s''',str,val{i});
            if i<N
                str=sprintf('%s,',str);
            end
        end
        str=sprintf('%s}',str);

    elseif isnumeric(val)

        str=mat2str(val);
    else


        try
            str=char(val);
        catch me
            me2=MException(message('HDLShared:CLI:datatypemismatch',class(val),propName));
            throw(me2.addCause(me));
        end
    end
