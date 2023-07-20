function impl=getFunctionImpl(this,hC)




    bfp=hC.SimulinkHandle;
    Fname=get_param(bfp,'Function');
    nfpFlag=0;
    switch Fname
    case 'sqrt'
        if targetmapping.hasFloatingPointPort(hC)
            if targetcodegen.targetCodeGenerationUtils.isFloatingPointMode()
                impl=hdldefaults.SqrtTargetLibrary();
                nfpFlag=1;
            else
                impl='';
            end
        else
            impl='';
        end

    case 'rSqrt'
        if(targetcodegen.targetCodeGenerationUtils.isAlteraMode()...
            ||targetcodegen.targetCodeGenerationUtils.isNFPMode())...
            &&targetmapping.hasFloatingPointPort(hC)
            impl=hdldefaults.SqrtTargetLibrary();

        else
            impl=hdldefaults.RecipSqrtNewton();
        end
        nfpFlag=1;
    case 'signedSqrt'
        if targetcodegen.targetCodeGenerationUtils.isNFPMode()...
            &&targetmapping.hasFloatingPointPort(hC)
            impl=hdldefaults.SqrtTargetLibrary();
            nfpFlag=1;
        else
            impl='';
        end
    otherwise
        impl='';
    end

    if(nfpFlag)

        latencyParam=this.getImplParams('LatencyStrategy');

        isCustomLatencyGenaralTabActive=~isempty(this.getImplParams('CustomLatency'));

        isCustomLatencyNFPTabActive=~isempty(this.getImplParams('NFPCustomLatency'));








        blockParamsNumber=length(this.implParams);


        paramsTemp=cell(1,blockParamsNumber);




        if strcmpi(latencyParam,'Custom')


            if isCustomLatencyNFPTabActive
                customLatencyTemp=int8(this.getImplParams('NFPCustomLatency'));
            else


                if(isCustomLatencyGenaralTabActive)
                    customLatencyTemp=int8(this.getImplParams('CustomLatency'));
                else
                    customLatencyTemp=int8(0);
                end
            end
        end

        index=1;




        for i=1:2:blockParamsNumber


            if(strcmpi(this.implParams{i},'CustomLatency'))
                if(strcmpi(latencyParam,'Custom'))
                    if(~isCustomLatencyNFPTabActive)
                        paramsTemp{index}='NFPCustomLatency';
                    end
                    paramsTemp{index+1}=customLatencyTemp;
                    index=index+2;
                end
            elseif(~strcmpi(this.implParams{i},'UseMultiplier')&&~strcmpi(this.implParams{i},'UsePipelines'))
                paramsTemp{index}=this.implParams{i};
                paramsTemp{index+1}=this.implParams{i+1};
                index=index+2;
            end
        end
        impl.implParams=paramsTemp(1:index-1);


    end
end



