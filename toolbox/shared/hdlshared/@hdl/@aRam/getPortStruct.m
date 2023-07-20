function hdlports=getPortStruct(this,hdlSig,hdlPortName)

















    if isempty(hdlSig)
        error(message('HDLShared:directemit:emptysignal'));
    end

    if isempty(hdlPortName)

        s=hdlsignalname(hdlSig);
        if iscell(s)
            hdlports=cell2struct(s,'Name',1);
        else
            hdlports.Name=s;
        end
    elseif length(hdlSig)==1
        if~ischar(hdlPortName)
            error(message('HDLShared:directemit:noncharportname'));
        end
    elseif~iscell(hdlPortName)
        error(message('HDLShared:directemit:noncellportname'));
    elseif length(hdlSig)~=length(hdlPortName)
        error(message('HDLShared:directemit:portnamelengtherror'));
    end

    siz=hdlsignalsizes(hdlSig);

    for n=1:length(hdlSig)

        if~isempty(hdlPortName)
            if~iscell(hdlPortName)
                hdlports(n).Name=hdlPortName;
            elseif isempty(hdlPortName{n})
                hdlports(n).Name=hdlsignalname(hdlSig(n));
            else
                hdlports(n).Name=hdlPortName{n};
            end
        end

        hdlports(n).Width=siz(n,1);
        c=hdlsignalsltype(hdlSig(n));

        if hdlports(n).Width==1
            p=hdlgetparameter('base_data_type');
            hdlports(n).PortComment=char(10);
        else
            p=hdlsignalvtype(hdlSig(n));
            hdlports(n).PortComment=hdlformatcomment(c,2);
        end

        hdlports(n).PortType=regexprep(p,'wire ?','');
    end


