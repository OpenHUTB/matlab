function[ENBW,winFcn,winParam]=getENBW(obj,L,Win,sideLobeAttn)




    if strcmp(obj.Method,'Filter bank')

        ENBW=1;
        return;
    end

    if nargin<3
        Win=obj.Window;
    end
    if isempty(L)

        L=1000;
    end
    winParam=[];
    switch Win
    case 'Rectangular'
        ENBW=1;
        winFcn=@dsp.scopes.SpectralEstimator.rectwin;
    case 'Hann'
        w=dsp.scopes.SpectralEstimator.hann(L);
        ENBW=(sum(w.^2)/sum(w)^2)*L;
        winFcn=@dsp.scopes.SpectralEstimator.hann;
    case 'Hamming'
        w=hamming(L,'periodic');
        ENBW=(sum(w.^2)/sum(w)^2)*L;
        winFcn=@(x)hamming(x,'periodic');
    case 'Flat Top'
        w=flattopwin(L,'periodic');
        ENBW=(sum(w.^2)/sum(w)^2)*L;
        winFcn=@(x)flattopwin(x,'periodic');
    case 'Chebyshev'
        if nargin<4
            SLA=obj.SidelobeAttenuation;
        else
            SLA=sideLobeAttn;
        end
        w=chebwin(L,SLA);
        ENBW=(sum(w.^2)/sum(w)^2)*L;
        winFcn=@chebwin;
        winParam=SLA;
    case 'Kaiser'
        if nargin<4
            SLA=obj.SidelobeAttenuation;
        else
            SLA=sideLobeAttn;
        end
        if SLA>50
            winParam=0.1102*(SLA-8.7);
        elseif SLA<21
            winParam=0;
        else
            winParam=(0.5842*(SLA-21)^0.4)+0.07886*(SLA-21);
        end
        w=kaiser(L,winParam);
        ENBW=(sum(w.^2)/sum(w)^2)*L;
        winFcn=@kaiser;
    case 'Blackman-Harris'
        w=blackmanharris(L,'periodic');
        ENBW=(sum(w.^2)/sum(w)^2)*L;
        winFcn=@(x)blackmanharris(x,'periodic');
    case 'Custom'
        customWindow=obj.CustomWindow;
        switch customWindow
        case{'blackman','blackmanharris','flattopwin','hamming','hann','nuttallwin'}


            w=feval(customWindow,L,'periodic');
            ENBW=(sum(w.^2)/sum(w)^2)*L;
            winFcn=str2func(['@(x)',customWindow,'(x,''periodic'')']);
        otherwise
            w=double(feval(customWindow,L));
            ENBW=(sum(w.^2)/sum(w)^2)*L;
            winFcn=str2func(['@(x)',customWindow,'(x)']);
        end
    end
end
