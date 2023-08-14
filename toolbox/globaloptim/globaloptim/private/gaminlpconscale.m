function hdls=gaminlpconscale
























    NonIneqScale=[];
    NonEqScale=[];
    LinIneqScale=[];
    LinEqScale=[];


    hdls.evaluate=@updateConstrScales;

    function scale=updateConstrScales(c,ceq,lineq,leq)








        NonIneqScale=max([NonIneqScale;abs(c)],[],1);
        NonEqScale=max([NonEqScale;abs(ceq)],[],1);
        LinIneqScale=max([LinIneqScale;abs(lineq)],[],1);
        LinEqScale=max([LinEqScale;abs(leq)],[],1);



        scale=[NonIneqScale,NonEqScale,LinIneqScale,LinEqScale];
        scale=max(scale,1);
    end
end