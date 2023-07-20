%#codegen
function y=hdleml_signum(u,outtp_ex)


    coder.allowpcode('plain')

    y=hdleml_init(outtp_ex);

    for ii=1:length(u)
        if(u(ii)>0)
            y(ii)=1;
        elseif(u(ii)<0)
            y(ii)=-1;
        else
            y(ii)=0;
        end
    end
