function[A_liq,A_vap]=clipCriticalRegion(p,p_crit,p_crit_fraction,A_liq,A_vap)%#codegen






    m_liq=size(A_liq,1);
    m_vap=size(A_vap,1);

    p=p(:)';
    logp=log10(p*1e6);
    logp_crit=log10(p_crit*1e6);



    p_clip_min=max(p_crit*(1-p_crit_fraction),p(1));
    p_clip_max=min(p_crit*(1+p_crit_fraction),p(end));
    logp_clip_min=log10(p_clip_min*1e6);
    logp_clip_max=log10(p_clip_max*1e6);


    idx=find((p>=p_crit)&(p<p_clip_max));
    i_max=m_liq*ones(1,length(p));
    i_last=m_liq;
    for j=idx
        [~,i_max(j)]=findPeak([A_liq(:,j);A_vap(:,j)],m_liq+m_vap,i_last);
        i_last=i_max(j);
    end


    A_at_p_clip=[
    interp2(logp,(1:m_liq)',A_liq,logp_clip_max*ones(m_liq,1),(1:m_liq)','linear');
    interp2(logp,(1:m_vap)',A_vap,logp_clip_max*ones(m_vap,1),(1:m_vap)','linear')];



    A_max_sup=findPeak(A_at_p_clip,m_liq+m_vap,i_last);


    for j=idx
        A_sup=[A_liq(:,j);A_vap(:,j)];

        for i=i_max(j):m_liq+m_vap-1

            if A_sup(i+1)>A_sup(i)
                break
            end

            if A_sup(i)>=A_max_sup
                A_sup(i)=A_max_sup;
            else
                break
            end
        end

        for i=i_max(j)-1:-1:2

            if A_sup(i-1)>A_sup(i)
                break
            end

            if A_sup(i)>=A_max_sup
                A_sup(i)=A_max_sup;
            else
                break
            end
        end

        A_liq(:,j)=A_sup(1:m_liq);
        A_vap(:,j)=A_sup(m_liq+1:end);
    end



    A_clip_liq=interp1(logp,A_liq(m_liq,:),logp_clip_min,'linear','extrap');
    A_clip_vap=interp1(logp,A_vap(1,:),logp_clip_min,'linear','extrap');


    for j=find((p<p_crit)&(p>p_clip_min))

        A_max_vap=(A_max_sup-A_clip_vap)/(logp_crit-logp_clip_min)*(logp(j)-logp_clip_min)+A_clip_vap;

        for i=1:m_vap-1

            if A_vap(i+1,j)>A_vap(i,j)
                break
            end

            if A_vap(i,j)>=A_max_vap
                A_vap(i,j)=A_max_vap;
            else
                break
            end
        end


        A_max_liq=(A_max_sup-A_clip_liq)/(logp_crit-logp_clip_min)*(logp(j)-logp_clip_min)+A_clip_liq;

        for i=m_liq:-1:2

            if A_liq(i-1,j)>A_liq(i,j)
                break
            end

            if A_liq(i,j)>=A_max_liq
                A_liq(i,j)=A_max_liq;
            else
                break
            end
        end
    end

end



function[A_max,i_max]=findPeak(A,m,i_start)

    A_max=A(i_start);
    i_max=i_start;


    for i=i_start+1:m
        if A(i)>=A_max
            A_max=A(i);
            i_max=i;
        else
            break
        end
    end


    if i_max==m
        A_max=A(i_start);
        i_max=i_start;
    end


    for i=i_start-1:-1:1
        if A(i)>=A_max
            A_max=A(i);
            i_max=i;
        else
            break
        end
    end


    if i_max==1
        A_max=A(i_start);
        i_max=i_start;
    end

end