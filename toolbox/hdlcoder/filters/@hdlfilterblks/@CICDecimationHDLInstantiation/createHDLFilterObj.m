function hf=createHDLFilterObj(this,hC)







    if isa(hC,'hdlcoder.sysobj_comp')

        if hdlsignaliscomplex(hC.PirInputSignals(1))
            inputWL=hC.PirInputSignals(1).Type.BaseType.WordLength;
            inputFL=-1*hC.PirInputSignals(1).Type.BaseType.FractionLength;
        else
            inputWL=hC.PirInputSignals(1).Type.WordLength;
            inputFL=-1*hC.PirInputSignals(1).Type.FractionLength;
        end
    else
        bfp=hC.SimulinkHandle;

        cpdt=get_param(bfp,'CompiledPortDataTypes');
        in_sltype=char(cpdt.Inport(1));
        [inputWL,inputFL]=hdlgetsizesfromtype(in_sltype);
    end

    if inputWL==0
        arithmetic='double';
    else
        arithmetic='fixed';
    end


    options.mapstates=[];


    options.arithmetic=arithmetic;
    options.inputformat=[inputWL,inputFL];

    if strncmp(options.arithmetic,'double',6)||strncmp(options.arithmetic,'single',6)
        options.arithmetic='double';
        options.fixedMode=false;
    elseif strncmp(options.arithmetic,'fixed',5)
        options.fixedMode=true;
    else
        error(message('hdlcoder:validate:InvalidArithmetic'));
    end


    if~isnumeric(options.inputformat)||~isvector(options.inputformat)||...
        (length(options.inputformat)~=2)
        error(message('hdlcoder:validate:InvalidInputFormat'));
    end
    options.inputformat=double(options.inputformat);

    if isa(hC,'hdlcoder.sysobj_comp')
        hf=getHDLFiltObjFromSysObj(this,hC,options);
        inComplex=hdlsignaliscomplex(hC.PirInputSignals(1));
    else

        block=get_param(bfp,'Object');

        if~isa(block,'Simulink.SFunction')
            error(message('hdlcoder:validate:InvalidBlockInput'));
        end
        switch block.filtFrom
        case{'Dialog','Dialog parameters'}
            hf=getHDLFiltObjFromBlockInfo(this,block,hC,options);
        case{'Multirate object in workspace','Filter object'}
            hf=getHDLFiltObjFromFiltObj(this,hC,block,options);
        end

        inComplex=block.CompiledPortComplexSignals.Inport;
    end

    hf.InputComplex=inComplex;


end



function hf=getHDLFiltObjFromSysObj(this,hC,options)



    if isa(hC,'hdlcoder.sysobj_comp')

        sysObjHandle=hC.getSysObjImpl;
    else
        sysObjHandle=options.SysObjImpl;
    end


    inputformat=options.inputformat;


    hf=hdlfilter.cicdecim;


    hf.FilterStructure='Decimator';





    hf.RoundMode='floor';
    hf.OverflowMode=0;


    hf.DecimationFactor=sysObjHandle.DecimationFactor;
    hf.DifferentialDelay=sysObjHandle.DifferentialDelay;
    hf.NumberOfSections=sysObjHandle.NumSections;


    hf=updateInputInfo(hf,inputformat);


    hf=updateSectionsInfo(this,hf,hC,inputformat);


    hf=updateOutputInfo(this,hf,hC,inputformat);

end


function hf=getHDLFiltObjFromBlockInfo(this,block,hC,options)




    bfp=hC.SimulinkHandle;
    inputformat=options.inputformat;





    switch block.ftype
    case 'Decimator'
        hf=hdlfilter.cicdecim;
    case 'Zero-latency decimator'
        hf=hdlfilter.firtdecim;
    otherwise
        error(message('hdlcoder:validate:UnsupportedFilterStructure',block.Name));
    end


    hf.FilterStructure=block.ftype;



    hf.RoundMode='floor';
    hf.OverflowMode=0;


    hf.DecimationFactor=this.hdlslResolve('R',bfp);
    hf.DifferentialDelay=this.hdlslResolve('M',bfp);
    hf.NumberOfSections=this.hdlslResolve('N',bfp);


    hf=updateInputInfo(hf,inputformat);


    hf=updateSectionsInfo(this,hf,hC,inputformat);


    hf=updateOutputInfo(this,hf,hC,inputformat);

end


function hf=updateInputInfo(hf,inputformat)


    [~,hf.inputsltype]=hdlgettypesfromsizes(inputformat(1),inputformat(2),true);

end


function hf=updateSectionsInfo(this,hf,hC,inputformat)



    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        filterInternals=sysObjHandle.FixedPointDataType;
    else

        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        switch block.filtFrom
        case{'Dialog','Dialog parameters'}
            filterInternals=block.filterInternals;
        case{'Multirate object in workspace','Filter object'}
            filterInternals=block.UserData.filter.FixedPointDataType;
        end
    end

    switch filterInternals
    case{'Full precision','Minimum section word lengths','Specify word lengths'}
        [ssizes,sbps]=getWLFL(this,hC,filterInternals,inputformat,hf);
    case{'Binary point scaling','Specify word and fraction lengths'}
        if isa(hC,'hdlcoder.sysobj_comp')
            ssizes=sysObjHandle.SectionWordLengths;
            sbps=sysObjHandle.SectionFractionLengths;
        else
            block=get_param(bfp,'Object');

            if~isa(block,'Simulink.SFunction')
                error(message('hdlcoder:validate:InvalidBlockInput'));
            end
            switch block.filtFrom
            case{'Dialog','Dialog parameters'}
                ssizes=this.hdlslResolve('BPS',bfp);
                sbps=this.hdlslResolve('FLPS',bfp);
            case{'Multirate object in workspace','Filter object'}
                ssizes=block.UserData.filter.SectionWordLengths;
                sbps=block.UserData.filter.SectionFractionLengths;
            end
        end
        if size(ssizes,2)==1

            ssizes=ssizes*ones(1,2*hf.NumberOfSections);
        end
        numbp=size(sbps,2);
        reqdnumbp=2*hf.NumberOfSections;
        if numbp<reqdnumbp

            numzeros=reqdnumbp-numbp;
            sbps=[sbps,zeros(1,numzeros)];
        end
    otherwise
        error(message('hdlcoder:validate:unsupportedmode',block.filterInternals));
    end
    sltypes={};
    for n=1:length(ssizes)
        [~,nsltype]=hdlgettypesfromsizes(ssizes(n),sbps(n),true);
        sltypes={sltypes{:},nsltype};
    end

    hf.SectionSLtypes=sltypes;

end


function[ssizes,sbps,outwl,outfl]=getWLFL(this,hC,filterInternals,inputformat,hf)


    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
    else
        bfp=hC.SimulinkHandle;
    end
    switch filterInternals
    case 'Full precision'
        outwl=0;
        swl=0;
        modestr='fullprecision';
    case 'Minimum section word lengths'
        if isa(hC,'hdlcoder.sysobj_comp')
            outwl=sysObjHandle.OutputWordLength;
        else
            block=get_param(bfp,'Object');

            if~isa(block,'Simulink.SFunction')
                error(message('hdlcoder:validate:InvalidBlockInput'));
            end
            switch block.filtFrom
            case{'Dialog','Dialog parameters'}
                outwl=this.hdlslResolve('outputWordLength',bfp);
            case{'Multirate object in workspace','Filter object'}
                outwl=block.UserData.filter.OutputWordLength;
            end
        end
        swl=0;
        modestr='minwordlengths';
    case 'Specify word lengths'
        modestr='specifywordlengths';
        if isa(hC,'hdlcoder.sysobj_comp')
            outwl=sysObjHandle.OutputWordLength;
            swl=sysObjHandle.SectionWordLengths;
        else
            block=get_param(bfp,'Object');

            if~isa(block,'Simulink.SFunction')
                error(message('hdlcoder:validate:InvalidBlockInput'));
            end
            switch block.filtFrom
            case{'Dialog','Dialog parameters'}
                outwl=this.hdlslResolve('outputWordLength',bfp);
                swl=this.hdlslResolve('BPS',bfp);
            case{'Multirate object in workspace','Filter object'}
                outwl=block.UserData.filter.OutputWordLength;
                swl=block.UserData.filter.SectionWordLengths;
            end

        end
        if length(swl)==1
            swl=swl*ones(1,2*hf.numberofsections);
        end
    end
    [ssizes,sbps,outwl,outfl]=filterdesign.internal.cicdecimwlnfl(inputformat(1),inputformat(2),...
    modestr,hf.NumberOfSections,hf.DecimationFactor,...
    hf.DifferentialDelay,outwl,swl);

end


function hf=updateOutputInfo(this,hf,hC,inputformat)



    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        filterInternals=sysObjHandle.FixedPointDataType;
    else
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        switch block.filtFrom
        case{'Dialog','Dialog parameters'}
            filterInternals=block.filterInternals;
        case{'Multirate object in workspace','Filter object'}
            filterInternals=block.UserData.filter.FixedPointDataType;
        end
    end

    switch filterInternals
    case{'Full precision','Minimum section word lengths','Specify word lengths'}
        [~,~,outsize,outbp]=getWLFL(this,hC,filterInternals,inputformat,hf);
    case{'Binary point scaling','Specify word and fraction lengths'}
        if isa(hC,'hdlcoder.sysobj_comp')
            outsize=sysObjHandle.OutputWordLength;
            outbp=sysObjHandle.OutputFractionLength;
        else
            switch block.filtFrom
            case{'Dialog','Dialog parameters'}
                outsize=this.hdlslResolve('outputWordLength',bfp);
                outbp=this.hdlslResolve('outputFracLength',bfp);
            case{'Multirate object in workspace','Filter object'}
                outsize=block.UserData.filter.OutputWordLength;
                outbp=block.UserData.filter.OutputFractionLength;
            end
        end
    otherwise
        error(message('hdlcoder:validate:unsupportedmode',block.filterInternals));
    end

    [~,hf.outputsltype]=hdlgettypesfromsizes(outsize,outbp,true);

end











function hf=getHDLFiltObjFromFiltObj(this,hC,block,options)

    filtObjName=block.filtobj;
    if~isempty(filtObjName)
        ud=block.UserData;
        if isfield(ud,'filter');

            if isa(ud.filter,'dsp.CICDecimator')

                hd=clone(ud.filter);
            else
                hd=copy(ud.filter);
            end;
        else
            error(message('hdlcoder:validate:undefinedDFILT',filtObjName));
        end
    else
        error(message('hdlcoder:validate:emptyDFILT'));
    end

    if~isempty(options.mapstates)
        if options.mapstates
            hd.PersistentMemory=true;
        end
    end



    if~isa(ud.filter,'dsp.CICDecimator')

        hf=createhdlfilter(hd);
    else
        options.SysObjImpl.DecimationFactor=hd.DecimationFactor;
        options.SysObjImpl.DifferentialDelay=hd.DifferentialDelay;
        options.SysObjImpl.NumSections=hd.NumSections;

        hf=getHDLFiltObjFromSysObj(this,hC,options);
    end;

end
