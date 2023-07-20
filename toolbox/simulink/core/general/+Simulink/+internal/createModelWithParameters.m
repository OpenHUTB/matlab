function mdlH=createModelWithParameters(mdlName,params)



    mdlH=new_system(mdlName);
    try
        locCreateModelParameters(mdlH,params);
        locCreateModelMask(mdlH,params);

        save_system(mdlName);
    catch

    end

    close_system(mdlName);

end

function locCreateModelParameters(mdlH,params)
    mdlWks=get_param(mdlH,'ModelWorkspace');
    paramNames="";
    for i=1:numel(params)
        prm=params{i};
        if isstruct(prm.Value)
            value=prm.Value;
        else
            value=double(prm.Value);
        end
        po=Simulink.Parameter(value);
        po.DataType=prm.DataType;
        po.Min=prm.Min;
        po.Max=prm.Max;
        po.Unit=prm.Unit;


        assignin(mdlWks,prm.Name,po);

        paramNames=paramNames.append(prm.Name+",");
    end

    set_param(mdlH,'ParameterArgumentNames',paramNames.strip('right',','));
end

function locCreateModelMask(mdlH,params)
    mdlMask=Simulink.Mask.create(mdlH);
    for i=1:numel(params)
        prm=params{i};
        if isempty(prm.MaskInfo)
            continue;
        end

        mskPrm=mdlMask.getParameter(prm.Name);
        mskPrm.Prompt=prm.MaskInfo.Prompt;
        mskPrm.Value=prm.MaskInfo.ValueExpr;
    end
end