function[name,size]=hdlsignaltypeconvert(name,size,signed,vtype,resultsigned,forceslv)


















    if nargin==5
        forceslv=false;
    end

    if size==0
        if strcmp(vtype(1:4),'wire')
            name=['$bitstoreal(',name,')'];
        else
            name=name;
        end

    elseif size==1
        if resultsigned&&hdlgetparameter('isvhdl')
            name=['"0" & ',name];
            size=size+1;
        else
            name=name;
        end

    elseif forceslv||(length(vtype)>16&&strcmp(vtype(1:16),'std_logic_vector'))
        if signed==1&&resultsigned==1
            name=['signed(',name,')'];
        elseif signed==1&&resultsigned==0
            name=['signed(',name,')'];
        elseif signed==0&&resultsigned==1
            size=size+1;
            if hdlgetparameter('isvhdl')
                name=['signed( ''0'' & ',name,')'];
            elseif hdlgetparameter('isverilog')
                name=['$signed({1''b0, ',name,'})'];
            end
        else
            name=['unsigned(',name,')'];
            if hdlgetparameter('isverilog')
                name=['$',name];
            end
        end

    elseif signed==1
        if resultsigned==1
            name=name;
        else
            name=['unsigned(',name,')'];
            if hdlgetparameter('isverilog')
                name=['$',name];
            end
        end

    else
        if resultsigned==1
            size=size+1;
            if hdlgetparameter('isvhdl')
                name=['signed( ''0'' & ',name,')'];
            elseif hdlgetparameter('isverilog')
                name=['$signed({1''b0, ',name,'})'];
            end
        else
            name=name;
        end
    end



