function out=CustomUserTokenStringValue(hSrc,name,direction,widgetVals)



    cs=hSrc.getConfigSet;

    if~isempty(cs)&&strcmp(cs.get_param('SystemTargetFile'),'mdx.tlc')
        target=2;
    else
        target=1;
    end

    if direction==0
        value=hSrc.get_param(name);
        out={value,value};
    elseif direction==1
        out=widgetVals{target};
    end

