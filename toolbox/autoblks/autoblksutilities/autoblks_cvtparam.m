function[Cdist,L0,r0,ratio_max,ratio_min]=autoblks_cvtparam(rp_max,rp_min,rs_max,rs_min,rgap)

%#codegen
    coder.allowpcode('plain')


    Cdist=rp_max+rs_max+rgap;


    c_mx=rp_max-rs_min;
    b_mx=sqrt(Cdist^2-c_mx^2);
    theta_mx=atan(c_mx/b_mx);
    L0_mx=2*b_mx+(pi-2*theta_mx)*rs_min+(pi+2*theta_mx)*rp_max;

    c_mn=rp_min-rs_max;
    b_mn=sqrt(Cdist^2-c_mn^2);
    theta_mn=atan(c_mn/b_mn);
    L0_mn=2*b_mn+(pi-2*theta_mn)*rs_max+(pi+2*theta_mn)*rp_min;

    Lmat=[L0_mn,L0_mx];
    [L0,Lidx]=min(Lmat);
    r0=(L0-2*Cdist)/(2*pi);

    rp_mat=[rp_max,rp_min];
    rs_mat=[rs_min,rs_max];
    theta_mat=[theta_mx,theta_mn];
    b_mat=[b_mx,b_mn];

    if Lidx==1
        rp_maxn=(L0-(pi-2*theta_mat(Lidx))*rs_mat(Lidx)-2*b_mat(Lidx))/...
        (pi+2*theta_mat(Lidx));
        rs_maxn=rs_max;
    else
        rp_maxn=rp_max;
        rs_maxn=(L0-(pi+2*theta_mat(Lidx))*rp_mat(Lidx)-2*b_mat(Lidx))/...
        (pi-2*theta_mat(Lidx));
    end
    ratio_max=rs_maxn/rp_min;
    ratio_min=rs_min/rp_maxn;
