function ids2=expandAndCheckMarkerName(p,ids)



















    isPeak=strncmpi(ids,'p',1);
    if any(isPeak)
        iPk=find(isPeak);
        for j=1:numel(iPk)
            p_j=ids{iPk(j)};
            jDot=strfind(p_j,'.');
            if~any(jDot)

                ids{iPk(j)}=[p_j,'.1'];
            end
        end
    end


    m=[p.hCursorAngleMarkers;p.hPeakAngleMarkers];
    ids2=upper(ids);
    isPresent=ismember(ids2,{m.ID});
    if any(~isPresent)
        msg='';
        for j=find(~isPresent)

            msg=sprintf('%s, %s',msg,ids{j});
        end
        msg=['Invalid ID specified: ',msg(3:end)];
        error(msg);
    end
