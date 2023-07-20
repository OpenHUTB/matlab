function y=autoblkssmoothstep(x,ll,ul)
%#codegen
    coder.allowpcode('plain')


    x(x<ll)=ll;
    x(x>ul)=ul;
    x=(x-ll)./(ul-ll);
    y=x.*x.*(3-2.*x);
end