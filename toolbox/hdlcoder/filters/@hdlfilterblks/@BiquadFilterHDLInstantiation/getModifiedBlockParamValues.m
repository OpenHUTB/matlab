function blockPVs=getModifiedBlockParamValues(this,hC)





    blockPVs={};

    isSysObj=isa(hC,'hdlcoder.sysobj_comp');

    hF=this.createHDLFilterObj(hC);

    this.applySerialPartition(hF);


    if~strcmpi(hF.InputSLType,'double')&&hF.needModifyforFullPrecision
        fpsets=hF.getFullPrecisionSettings;
        if~isSysObj
            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');
        end
        if isSysObj||~strcmpi(block.FilterSource,'Filter object')
            blockPVs={...
            'accumMode','Binary point scaling',...
            'accumWordLength',num2str(fpsets.accumulator(1)),...
            'accumFracLength',num2str(fpsets.accumulator(2)),...
            'denaccumFracLength',num2str(fpsets.accumulator(2)),...
            'outputMode','Binary point scaling',...
            'outputWordLength',num2str(fpsets.output(1)),...
            'outputfraclength',num2str(fpsets.output(2))
            };
            if isa(hF,'hdlfilter.df2sos')
                blockPVs=[blockPVs,{'memoryMode','Binary point scaling',...
                'memoryWordLength',num2str(fpsets.state(1)),...
                'memoryFracLength',num2str(fpsets.state(2))}];
            end
        else

            filter_class=class(hdlslResolve('dfiltObjectName',bfp));

            Hd=eval(filter_class);
            Hd.arithmetic='fixed';
            Hd.specifyall;


            Hd.RoundMode=hF.RoundMode;
            if hF.overflowMode
                Hd.OverflowMode='saturate';
            else
                Hd.OverflowMode='wrap';
            end


            [inpsize,inpbp]=hdlgetsizesfromtype(hF.InputSLType);
            Hd.InputWordLength=inpsize;
            Hd.InputFracLength=inpbp;


            Hd.sosMatrix=hF.Coefficients;
            Hd.ScaleValues=hF.ScaleValues;
            [csize,scalebp]=hdlgetsizesfromtype(hF.ScaleSLtype);
            [~,numbp]=hdlgetsizesfromtype(hF.NumCoeffSLtype);
            [~,denbp]=hdlgetsizesfromtype(hF.DenCoeffSLtype);
            Hd.CoeffWordLength=csize;
            Hd.ScaleValueFracLength=scalebp;
            Hd.NumFracLength=numbp;
            Hd.DenFracLength=denbp;


            [psize,denbp]=hdlgetsizesfromtype(hF.DenProdSLtype);
            [~,numbp]=hdlgetsizesfromtype(hF.NumProdSLtype);
            Hd.ProductWordLength=psize;
            Hd.NumProdFracLength=numbp;
            Hd.DenProdFracLength=denbp;


            Hd.AccumWordLength=fpsets.accumulator(1);
            Hd.NumAccumFracLength=fpsets.accumulator(2);
            Hd.DenAccumFracLength=fpsets.accumulator(2);


            Hd.OutputWordLength=fpsets.output(1);
            Hd.OutputFracLength=fpsets.output(2);

            if isa(hF,'hdlfilter.df1sos')

                [numstatesize,numstatebp]=hdlgetsizesfromtype(hF.NumStateSLtype);
                [denstatesize,denstatebp]=hdlgetsizesfromtype(hF.DenStateSLtype);
                Hd.NumStateWordLength=numstatesize;
                Hd.NumStateFracLength=numstatebp;
                Hd.DenStateWordLength=denstatesize;
                Hd.DenStateFracLength=denstatebp;
            elseif isa(hF,'hdlfilter.df2sos')

                [secipsize,secipbp]=hdlgetsizesfromtype(hF.SectionInputSLtype);
                [secopsize,secopbp]=hdlgetsizesfromtype(hF.SectionOutputSLtype);
                Hd.SectionInputWordLength=secipsize;
                Hd.SectionInputFracLength=secipbp;
                Hd.SectionOutputWordLength=secopsize;
                Hd.SectionOutputFracLength=secopbp;
                Hd.StateWordLength=fpsets.state(1);
                Hd.StateFracLength=fpsets.state(2);
            end

            hDriver=hdlcurrentdriver;
            hBE=hDriver.BackEnd;
            gen_modelName=hBE.OutModelFile;


            hws=get_param(gen_modelName,'modelworkspace');
            hws.DataSource='Model File';
            varname=uniquifyMWSVarName(this,hws,'Hfilter');
            hws.assignin(varname,Hd);

            blockPVs={...
            'FilterSource','Filter object',...
            'dfiltObjectName',varname};
        end
    end
