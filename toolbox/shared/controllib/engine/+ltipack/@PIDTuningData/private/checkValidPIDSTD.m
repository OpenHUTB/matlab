function Valid=checkValidPIDSTD(phi,alpha,beta,wc,Ts,DesignReqs)






    Valid=true;
    if Ts==0

        switch DesignReqs.Type
        case 'pidf'
            Valid=(alpha==beta||alpha<=phi);
        end
    else








        switch DesignReqs.Type
        case 'pid'
            if DesignReqs.DFormula=='T'&&DesignReqs.IFormula=='B'
                wcTs2=wc*Ts/2;
                Valid=(tan(phi-wcTs2)+tan(beta-wcTs2)>tan(wcTs2));
            end
        case 'pidf'
            Valid=(alpha==beta||alpha<=phi);
            if DesignReqs.DFormula~='B'&&DesignReqs.IFormula=='B'
                wcTs2=wc*Ts/2;
                Valid=Valid&&(tan(phi-wcTs2)+tan(beta-wcTs2)>tan(alpha-wcTs2)+tan(wcTs2));
            end
        end
    end