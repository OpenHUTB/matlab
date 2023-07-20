function[]=autolibseteditparamval(block,param,val)



    p=get_param(block,param);
    [~,status]=str2num(p);%#ok<ST2NM>

    if status
        if isequal(size(val),[1,1])
            set_param(block,param,num2str(val));
        else
            set_param(block,param,mat2str(val));
        end
    else
        autoblkssetval('base',p,block,val);
    end
end

function val=autoblkssetval(ws,p,block,val)

    switch ws
    case 'base'
        try
            tmp=evalin('base',p);
        catch
            error(message('autoblks:autoerrEditParam:invalidFind',block,p));
        end
    end

    if isa(tmp,'mpt.Parameter')||isa(tmp,'Simulink.Parameter')
        switch tmp.DataType
        case{'double'}
            tmp.Value=val;
        case 'single'
            tmp.Value=single(val);
        otherwise
            error(message('autoblks:autoerrEditParam:invalidType',block,p));
        end
    else
        switch class(tmp)
        case{'double'}
            tmp=val;
        case 'single'
            tmp=single(val);
        otherwise
            error(message('autoblks:autoerrEditParam:invalidType',block,p));
        end
    end

    assignin('base',p,tmp);

end


