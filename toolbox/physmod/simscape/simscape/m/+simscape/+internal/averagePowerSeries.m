function averagedLosses=averagePowerSeries(losses,tStart,tEnd,tInterval)














    averagedLosses=cell(size(losses,1),2);
    for ii=1:size(losses,1)
        averagedLosses{ii,1}=losses{ii,1};
        t=losses{ii,2}(:,1);
        powerValues=losses{ii,2}(:,2);
        if~isempty(tStart)&&~isempty(tEnd)
            if tStart<t(1)||tEnd>t(end)||tEnd<=tStart
                pm_error('physmod:simscape:simscape:internal:powerDissipated:InvalidTimeRange');
            end
        end
        if isempty(tStart)
            t0=t(1);
        else
            t0=tStart;
        end
        if isempty(tEnd)
            tf=t(end);
        else
            tf=tEnd;
        end
        if isempty(tInterval)||tInterval>abs(tf-t0)
            dt=abs(tf-t0);
        else
            dt=tInterval;
        end
        if dt~=0
            tsamp=sort(tf:-dt:t0);
            psamp=interp1(t,powerValues,tsamp);
            for jj=2:length(tsamp)
                idx1=find(t>tsamp(jj-1),1);
                idx2=find(t<tsamp(jj),1,'last');
                if isempty(idx2)
                    pm_error('physmod:simscape:simscape:internal:powerDissipated:InvalidTimeRange')
                end
                tlocal=[tsamp(jj-1),t(idx1:idx2).',tsamp(jj)];
                plocal=[psamp(jj-1),powerValues(idx1:idx2).',psamp(jj)];
                cumulativeEnergy=trapz(tlocal,plocal);
                averagedLosses{ii,2}(jj-1,:)=[tsamp(jj-1),tsamp(jj),cumulativeEnergy/dt];
            end
        else
            tsamp=[t0,tf];
            psamp=interp1(t,powerValues,tsamp);
            idx1=find(t>tsamp(1),1);
            idx2=find(t<tsamp(end),1,'last');
            tlocal=[tsamp(1),t(idx1:idx2).',tsamp(end)];
            plocal=[psamp(1),powerValues(idx1:idx2).',psamp(end)];
            averagedLosses{ii,2}=[tlocal(:),tlocal(:),plocal(:)];
        end
    end