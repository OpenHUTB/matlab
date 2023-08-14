function throttle=TorqueTransitionControl(V,Rhrz)

%#codegen
    coder.allowpcode('plain');





    persistent hysteresisMemory


    hysDelta=0.03;


    Vtar=VfromR(Rhrz);

    val1=Vtar*(1-hysDelta);
    val2=Vtar;
    val3=Vtar*(1+hysDelta);




    if isempty(hysDelta)
        hysteresisMemory=+1;
    else

        if V>val3
            hysteresisMemory=-1;
        elseif V<val1
            hysteresisMemory=1;
        else
            hysteresisMemory=1;
        end
    end

    k=1./(Vtar*hysDelta);
    thRampUp=min(max(-k*(V-val2)+1,0),1);
    thRampLo=min(max(-k*(V-val1)+1,0),1);

    throttle=0.*(V>val3)...
    +1.*(V<val1)...
    +((hysteresisMemory==1).*((V<=val2).*1+(V>val2).*thRampUp)+(hysteresisMemory==-1).*((V<=val2).*thRampLo+(V>val2).*0))...
    .*(V>=val1).*(V<=val3);

end
function Vss=VfromR(Rhrz)





    p=[-0.0041,0.4597,2.8441];

    Vss=p(1).*Rhrz.^2+p(2).*Rhrz+p(3);

end