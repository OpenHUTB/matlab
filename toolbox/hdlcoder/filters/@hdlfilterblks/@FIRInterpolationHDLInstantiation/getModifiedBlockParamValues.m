function blockPVs=getModifiedBlockParamValues(this,hC)






    blockPVs={};

    hF=this.createHDLFilterObj(hC);

    [csize,cbp]=hdlgetsizesfromtype(hF.CoeffSLType);
    fpsets=getFullPrecisionSettings(hF);

    bfp=hC.SimulinkHandle;
    block=get_param(bfp,'Object');

    if~strcmpi(hF.InputSLType,'double')&&hF.needModifyforFullPrecision
        if~strcmpi(block.FilterSource,'Filter object')
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
        else


            [inpsize,inpbp]=hdlgetsizesfromtype(hF.InputSLType);
            w=warning('off','dsp:mfilt:mfilt:Obsolete');
            Hd=dsp.internal.mfilt.firinterp;
            warning(w);
            Hd.InterpolationFactor=hF.InterpolationFactor;
            Hd.arithmetic='fixed';

            Hd.specifyall;
            polycoeffs=hF.PolyphaseCoefficients;
            Hd.Numerator=polycoeffs(:)';
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

            Hd.RoundMode=block.roundingMode;

            switch block.overflowMode
            case 'off'
                Hd.OverflowMode='wrap';
            case 'on'
                Hd.OverflowMode='saturate';
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
            'FilterObject',varname};
        end
    end


