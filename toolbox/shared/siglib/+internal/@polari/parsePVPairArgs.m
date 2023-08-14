function[args,pre_pv,post_pv]=parsePVPairArgs(p,args)











    is_char=cellfun(@ischar,args);
    idx=find(is_char,1,'first');
    if isempty(idx)

        pv={};
    else


        pv=args(idx:end);
        is_char=is_char(idx:end);
        args=args(1:idx-1);
    end
    Npv=numel(pv);
    if rem(Npv,2)~=0







        if numel(is_char)<2||all(is_char(2:2:end))











            lstr_old=pv{1};
            lstr_pv=parsePolarLineStyleString(lstr_old);
            pv=[lstr_pv,pv(2:end)];
            Npv=Npv+1;
        else

            error(message('siglib:polarpattern:PVPairsSameSize'));

        end
    end










    post_p=p.DeferredProperties;
    mv_idx=[];
    for i=1:2:Npv
        if any(strcmpi(pv{i},post_p))
            mv_idx=[mv_idx;i;i+1];%#ok<AGROW>
        end
    end
    post_pv=pv(mv_idx);
    pre_pv=pv;
    pre_pv(mv_idx)=[];
