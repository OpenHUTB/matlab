function rg=autoblks_cvtratiosat(rg_req,ratio_max,ratio_min)

%#codegen
    coder.allowpcode('plain')

    [rg_t1,~]=min([rg_req,ratio_max]);
    [rg_t2,~]=max([rg_t1,ratio_min]);
    rg=rg_t2;