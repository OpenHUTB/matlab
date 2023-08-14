function pv=parsePolarLineStyleString(s)




























    vals={'-:','bgrcmykw','ox+*sdv^<>ph.'};
    params={'LineStyle','Color','Marker'};
    c=cat(2,vals{:});
    N=cellfun(@numel,vals);
    ptype_vec=[zeros(1,N(1))+1,zeros(1,N(2))+2,zeros(1,N(3))+3];
    pv={};
    i=1;
    Ns=numel(s);
    while i<=Ns
        dblChar=false;
        j=find(s(i)==c);
        if isempty(j)
            error('smithplot:InvalidLineStyle',...
            'Invalid line style string "%s".',s);
        end
        if j==1&&i<Ns
            if any(s(i+1)=='.-')
                dblChar=true;
                p_i=params{1};
                v_i=s(i:i+1);
                i=i+1;
            end
        end
        if~dblChar
            p_i=params{ptype_vec(j)};
            v_i=s(i);
        end
        i=i+1;
        pv=[pv,p_i,v_i];%#ok<AGROW>
    end
    index=find(strcmpi(pv,'LineStyle'),1,'last');
    if isempty(index)
        pv=[pv,'LineStyle','none'];
    else
        r_index=strcmpi(pv,'LineStyle');
        pv=[pv,'LineStyle',pv(index+1)];
        pv(r_index|circshift(r_index,1))=[];
    end
    index=find(strcmpi(pv,'Marker'),1,'last');
    if isempty(index)
        pv=[pv,'Marker','none'];
    else
        r_index=strcmpi(pv,'Marker');
        pv=[pv,'Marker',pv(index+1)];
        pv(r_index|circshift(r_index,1))=[];
    end
