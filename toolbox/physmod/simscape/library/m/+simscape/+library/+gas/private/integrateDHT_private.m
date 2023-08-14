function int_dh_T=integrateDHT_private(T,h)%#codegen




    coder.allowpcode('plain')

    T=T(:);
    h=h(:);

    int_dh_T=[0;cumsum(diff(h)./diff(T).*log(T(2:end)./T(1:end-1)))];

end