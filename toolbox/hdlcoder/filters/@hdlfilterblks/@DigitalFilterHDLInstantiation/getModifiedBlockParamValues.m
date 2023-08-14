function blockPVs=getModifiedBlockParamValues(this,hC)






    blockPVs={};

    isSysObj=isa(hC,'hdlcoder.sysobj_comp');

    hF=this.createHDLFilterObj(hC);

    if~strcmpi(hF.InputSLType,'double')&&isa(hF,'hdlfilter.abstractdffir')...
        &&hF.needModifyforFullPrecision
        [csize,cbp]=hdlgetsizesfromtype(hF.CoeffSLType);
        fpsets=getFullPrecisionSettings(hF);

        if~isSysObj
            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');
        end

        if isSysObj||~strcmpi(block.FilterSource,'dfilt object')

            blockPVs={...
            'firstCoeffMode','Binary point scaling',...
            'firstCoeffWordLength',num2str(csize),...
            'firstCoeffFracLength',num2str(cbp),...
            'prodOutputMode','Binary point scaling',...
            'prodOutputWordLength',num2str(fpsets.product(1)),...
            'prodOutputFracLength',num2str(fpsets.product(2)),...
            'accumMode','Binary point scaling',...
            'accumWordlength',num2str(fpsets.accumulator(1)),...
            'accumFraclength',num2str(fpsets.accumulator(2)),...
            'outputMode','Binary point scaling',...
            'outputWordLength',num2str(fpsets.output(1)),...
            'outputfraclength',num2str(fpsets.output(2))};
            if isfield(fpsets,'tapsum')
                blockPVs=[blockPVs,{'tapSumMode','Binary point scaling',...
                'tapSumWordLength',num2str(fpsets.tapsum(1)),...
                'tapSumfraclength',num2str(fpsets.tapsum(2))}];
            end
        else


            [inpsize,inpbp]=hdlgetsizesfromtype(hF.InputSLType);


            filter_class=class(hdlslResolve('dfiltObjectName',bfp));

            Hd=eval(filter_class);
            Hd.arithmetic='fixed';

            Hd.specifyall;
            Hd.Numerator=hF.Coefficients;
            Hd.InputWordLength=inpsize;
            Hd.InputFracLength=inpbp;

            Hd.specifyall;

            Hd.CoeffWordLength=csize;
            Hd.NumFracLength=cbp;



            Hd.ProductWordLength=fpsets.product(1);
            Hd.ProductFracLength=fpsets.product(2);

            Hd.AccumWordLength=fpsets.accumulator(1);
            Hd.AccumFracLength=fpsets.accumulator(2);

            Hd.OutputWordLength=fpsets.output(1);
            Hd.OutputFracLength=fpsets.output(2);

            hDriver=hdlcurrentdriver;
            hBE=hDriver.BackEnd;
            gen_modelName=hBE.OutModelFile;



            Hd.RoundMode=hF.RoundMode;

            if hF.overflowMode
                Hd.OverflowMode='saturate';
            else
                Hd.OverflowMode='wrap';
            end


            hws=get_param(gen_modelName,'modelworkspace');
            hws.DataSource='Model File';
            varname=uniquifyMWSVarName(this,hws,'Hfilter');
            hws.assignin(varname,Hd);

            blockPVs={...
            'FilterSource','dfilt object',...
            'dfiltObjectName',varname};

        end
    end

