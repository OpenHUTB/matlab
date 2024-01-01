function[P,I,D,N,achievedPM,typeidx,formidx]=slpidwrapperFRDFunc(data,options,pidblk,TimeDomain)

    type=get_param(pidblk,'Controller');
    if contains(type,'D')&&strcmp(get_param(pidblk,'UseFilter'),'on')
        type=[type,'F'];
    end
    types={'p','i','pi','pd','pdf','pid','pidf'};
    typeidx=find(strcmpi(type,types));

    form=get_param(pidblk,'Form');
    if strcmpi(form,'parallel')
        formidx=1;
    else
        formidx=2;
    end
    if strcmpi(TimeDomain,'continuous-time')

        [P,I,D,N,achievedPM]=slpidthreepoint(typeidx,formidx,data.frequencies,data.responses,options.PhaseMargin,data.dcgain,0,1,1);
    else

        IF=find(strcmpi(get_param(pidblk,'IntegratorMethod'),{'Forward Euler','Backward Euler','Trapezoidal'}));
        DF=find(strcmpi(get_param(pidblk,'FilterMethod'),{'Forward Euler','Backward Euler','Trapezoidal'}));
        [P,I,D,N,achievedPM]=slpidthreepoint(typeidx,formidx,data.frequencies,data.responses,options.PhaseMargin,data.dcgain,data.Ts,IF,DF);
    end
