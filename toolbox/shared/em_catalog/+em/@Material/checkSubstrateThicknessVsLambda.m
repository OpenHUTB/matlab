function numLayers=checkSubstrateThicknessVsLambda(obj,antobj)

    SubThickness=obj.Thickness;


    if strcmpi(getMeshMode(antobj),'auto')
        lambda_0=getMeshingLambda(antobj);
        if isempty(lambda_0)
            parentObj=getParent(antobj);
            if~isempty(parentObj)
                lambda_0=getMeshingLambda(parentObj);
            else
                return;
            end
        end




        NumMeshingElements=10;
        lambda_g=min(lambda_0)/sqrt(mean(obj.EpsilonR));
        thicknessLimit=lambda_g/NumMeshingElements;
        msgstr1='1/10th of the wavelength in dielectric;';
        msgstr2='Use the';
        helpstr=sprintf('<a href="matlab:help %s">%s</a>','+em/@MeshGeometry/mesh',...
        'mesh');
        msgstr3='function to mesh the structure manually or set antenna height/spacing to be less than';
        msgstr4=[num2str(thicknessLimit),'m'];
        msg={msgstr1,msgstr2,helpstr,msgstr3,msgstr4};
        msg=strjoin(msg);
        SubThickness=obj.Thickness;
        if~isempty(thicknessLimit)&&any(SubThickness>thicknessLimit)


            numLayers=ceil(SubThickness./thicknessLimit);
        else
            numLayers=ones(1,numel(SubThickness));
        end

    else
        numLayers=ones(1,numel(SubThickness));
    end