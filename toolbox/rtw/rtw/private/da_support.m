function support=da_support(model,daType)




    hc=get_param(model,'TargetFcnLibHandle');
    sp=hc.alignmentSupport(daType);
    support.supported=sp{1};
    support.position=sp{2};
end
