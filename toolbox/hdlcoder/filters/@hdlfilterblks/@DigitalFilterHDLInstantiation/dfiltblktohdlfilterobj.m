function hf=dfiltblktohdlfilterobj(this,hC,varargin)








































    props={'arithmetic','inputformat'};


    options.mapstates=[];
    options.arithmetic='double';
    options.inputformat=[16,15];


    for n=1:2:length(varargin)
        property=varargin{n};
        value=varargin{n+1};
        if~isempty(property)

            proppos=strncmpi(property,props,length(property));
            if~isempty(proppos)
                options.(props{proppos})=value;
            end
        end
    end


    options.arithmetic=lower(options.arithmetic);

    if strncmp(options.arithmetic,'double',6)||strncmp(options.arithmetic,'single',6)
        options.fixedMode=false;
    elseif strncmp(options.arithmetic,'fixed',5)
        options.fixedMode=true;
    else
        error(message('hdlcoder:validate:InvalidArithmetic'));
    end


    if~isnumeric(options.inputformat)||~isvector(options.inputformat)||...
        (length(options.inputformat)~=3)
        error(message('hdlcoder:validate:InvalidInputFormat'));
    end
    options.inputformat=double(options.inputformat);

    if isa(hC,'hdlcoder.sysobj_comp')
        block=hC.getSysObjImpl;
    else
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
    end


    hf=getHDLFiltObjFromBlockInfo(this,block,hC,options);

end


function hf=getHDLFiltObjFromBlockInfo(this,block,hC,options)





    isSysObj=isa(hC,'hdlcoder.sysobj_comp');

    fixedMode=options.fixedMode;
    inputformat=options.inputformat;


    if fixedMode
        if~isSysObj
            roundingMode=this.getblkparam(block,'roundingMode');
            overflowMode=this.getblkparam(block,'overflowMode');
        else
            roundingMode=block.RoundingMethod;
            overflowMode=block.OverflowAction;
        end
        if(strncmpi(roundingMode,'ceiling',7))
            roundMode='ceil';
        elseif(strncmpi(roundingMode,'convergent',10))
            roundMode='convergent';
        elseif(strncmpi(roundingMode,'floor',5))
            roundMode='floor';
        elseif(strncmpi(roundingMode,'nearest',7))
            roundMode='nearest';
        elseif(strncmpi(roundingMode,'round',5))
            roundMode='round';
        elseif(strncmpi(roundingMode,'simplest',8))
            roundMode='floor';
        else
            roundMode='fix';
        end
        if(strncmpi(overflowMode,'off',3)||strncmpi(overflowMode,'wrap',4))
            overflowMode=false;
        else
            overflowMode=true;
        end
    else
        roundMode='floor';
        overflowMode=false;
    end

    hf=whichhdlfilter(this,block);


    arith=options.arithmetic;


    hf.RoundMode=roundMode;
    hf.OverflowMode=overflowMode;


    hf=updateInputInfo(this,hf,inputformat,arith);


    hf=updateCoeffInfo(this,hf,hC,arith);


    hf=updateProdInfo(this,hf,hC,arith);


    hf=updateAccumInfo(this,hf,hC,arith);


    hf=updateTapSumInfo(this,hf,hC,arith);


    hf=updateStateInfo(this,hf,hC,arith);


    hf=updateOutputInfo(this,hf,hC,arith);


    hf=updateSectionInfo(this,hf,hC,arith);


    hf=updateMultiplicandInfo(this,hf,hC,arith);

end
