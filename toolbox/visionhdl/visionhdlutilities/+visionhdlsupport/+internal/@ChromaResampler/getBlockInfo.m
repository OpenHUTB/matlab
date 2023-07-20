function blockInfo=getBlockInfo(this,hC)




    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;





        InArg1=sysObjHandle.Resampling;
        InArg2=sysObjHandle.AntialiasingFilterSource;
        InArg3=sysObjHandle.InterpolationFilter;
        blockInfo.OperationMode=visionhdl.ChromaResampler.EnumOperationMode(InArg1,InArg2,InArg3);

        if blockInfo.OperationMode==1
            if strcmp(sysObjHandle.AntialiasingFilterSource,'Auto')
                blockInfo.Coefficients=[0.00251767046967...
                ,0.00490688948250...
                ,-0.00285843115822...
                ,-0.00890518732801...
                ,0.00395561699943...
                ,0.01685803908729...
                ,-0.00534284868508...
                ,-0.02947105950561...
                ,0.00652585779416...
                ,0.05132323586029...
                ,-0.00752159904442...
                ,-0.09829944333989...
                ,0.00816272666677...
                ,0.31564088548256...
                ,0.49161039145657];
                blockInfo.Coefficients(16:29)=fliplr(blockInfo.Coefficients(1:14));
            else
                blockInfo.Coefficients=sysObjHandle.HorizontalFilterCoefficients;
            end






            blockInfo.CustomCoefficientsDataType=sysObjHandle.CustomCoefficientsDataType;

        end
        blockInfo.RoundingMethod=sysObjHandle.RoundingMethod;
        blockInfo.OverflowAction=sysObjHandle.OverflowAction;
    else
        bfp=hC.Simulinkhandle;
        InArg1=get_param(bfp,'Resampling');
        InArg2=get_param(bfp,'AntialiasingFilterSource');
        InArg3=get_param(bfp,'InterpolationFilter');
        blockInfo.OperationMode=visionhdl.ChromaResampler.EnumOperationMode(InArg1,InArg2,InArg3);





        if blockInfo.OperationMode==1
            if strcmp(get_param(bfp,'AntialiasingFilterSource'),'Auto')
                blockInfo.Coefficients=[0.00251767046967...
                ,0.00490688948250...
                ,-0.00285843115822...
                ,-0.00890518732801...
                ,0.00395561699943...
                ,0.01685803908729...
                ,-0.00534284868508...
                ,-0.02947105950561...
                ,0.00652585779416...
                ,0.05132323586029...
                ,-0.00752159904442...
                ,-0.09829944333989...
                ,0.00816272666677...
                ,0.31564088548256...
                ,0.49161039145657];
                blockInfo.Coefficients(16:29)=fliplr(blockInfo.Coefficients(1:14));
            else
                blockInfo.Coefficients=this.hdlslResolve('HorizontalFilterCoefficients',bfp);
            end






            blockInfo.CustomCoefficientsDataType=this.hdlslResolve('CoeffDataTypeStr',bfp);

        end
        blockInfo.RoundingMethod=get_param(bfp,'roundingMode');
        if strcmp(get_param(bfp,'overflowMode'),'off')
            blockInfo.OverflowAction='Wrap';
        else
            blockInfo.OverflowAction='Saturate';
        end
    end









    gainParam=this.getImplParams('ConstMultiplierOptimization');
    OptimMode=0;
    if~isempty(gainParam)
        if strcmpi(gainParam,'none')
            OptimMode=0;
        elseif strcmpi(gainParam,'csd')
            OptimMode=1;
        elseif strcmpi(gainParam,'fcsd')
            OptimMode=2;
        elseif strcmpi(gainParam,'auto')
            OptimMode=3;
        end
    end
    blockInfo.gainOptimMode=OptimMode;
    blockInfo.gainMode=3;
