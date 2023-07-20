function fpset=getFullPrecisionSettings(this)





    mults=this.getHDLParameter('filter_nummultipliers');
    uff=this.getHDLParameter('userspecified_foldingfactor');

    if(mults==-1)
        [mults,~]=this.getSerialPartForFoldingFactor('foldingfactor',uff);
    end

    [inpsize,~]=hdlgetsizesfromtype(this.InputSltype);
    if inpsize>0
        if(mults==1)

            densumall=hdlgetallfromsltype(this.denAccumSLtype);
            densumsltype=densumall.sltype;

            numsumall=hdlgetallfromsltype(this.numAccumSLtype);
            numsumsltype=numsumall.sltype;
            [densumsize,densumbp]=hdlgetsizesfromtype(densumsltype);
            [numsumsize,numsumbp]=hdlgetsizesfromtype(numsumsltype);
            fpsumbp=max([densumbp,numsumbp]);
            fpsumsize=max([densumsize-densumbp,numsumsize-numsumbp])+fpsumbp;
        else

            denprodall=hdlgetallfromsltype(this.denprodSLtype);
            denproductsltype=denprodall.sltype;

            numprodall=hdlgetallfromsltype(this.numprodSLtype);
            numproductsltype=numprodall.sltype;

            [denprodsize,denprodbp]=hdlgetsizesfromtype(denproductsltype);
            [numprodsize,numprodbp]=hdlgetsizesfromtype(numproductsltype);
            fpsumbp=max([denprodbp,numprodbp]);
            fpsumsize=max([denprodsize-denprodbp,numprodsize-numprodbp])+fpsumbp+4;
        end
        fpset.accumulator=[fpsumsize,fpsumbp];


        [opsize,opbp]=hdlgetsizesfromtype(this.OutputSltype);
        fpset.output=[opsize,opbp];


        if isa(this,'hdlfilter.df2sos')
            [statesize,statebp]=hdlgetsizesfromtype(this.StateSltype);
            fpset.state=[statesize,statebp];
        end
    else
        fpset.accumulator=[0,0];
        fpset.output=[0,0];
        if isa(this,'hdlfilter.df2sos')
            fpset.state=[0,0];
        end
    end

