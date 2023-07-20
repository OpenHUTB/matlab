function hf=createHDLFilterObj(this,hC)







    bfp=hC.SimulinkHandle;

    cpdt=get_param(bfp,'CompiledPortDataTypes');
    in_sltype=char(cpdt.Inport(1));
    [inputWL,inputFL]=hdlgetsizesfromtype(in_sltype);

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

    bfp=hC.SimulinkHandle;
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

    hf.InputComplex=inComplex;


end


function hf=getHDLFiltObjFromBlockInfo(this,block,hC,options)




    bfp=hC.SimulinkHandle;
    inputformat=options.inputformat;





    switch block.ftype
    case 'Interpolator'
        hf=hdlfilter.cicinterp;
    otherwise
        error(message('hdlcoder:validate:UnsupportedFilterStructure',block.Name));
    end


    hf.FilterStructure=block.ftype;



    hf.RoundMode='floor';
    hf.OverflowMode=0;


    hf.InterpolationFactor=this.hdlslResolve('R',bfp);
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



    bfp=hC.SimulinkHandle;
    block=get_param(bfp,'Object');

    switch block.filterInternals
    case{'Full precision','Minimum section word lengths','Specify word lengths'}
        [ssizes,sbps]=getWLFL(this,hC,block.filterInternals,inputformat,hf);
    case{'Binary point scaling'}
        ssizes=this.hdlslResolve('BPS',bfp);
        if size(ssizes,2)==1

            ssizes=ssizes*ones(1,2*hf.NumberOfSections);
        end
        sbps=this.hdlslResolve('FLPS',bfp);
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
        sltypes=[sltypes,{nsltype}];%#ok
    end
    hf.SectionSLtypes=sltypes;

end



function[ssizes,sbps,outwl,outfl]=getWLFL(this,hC,filterinternals,inputformat,hf)

    bfp=hC.SimulinkHandle;
    switch filterinternals
    case 'Full precision'
        outwl=0;
        swl=0;
        modestr='fullprecision';
    case 'Minimum section word lengths'
        outwl=this.hdlslResolve('outputWordLength',bfp);
        swl=0;
        modestr='minwordlengths';
    case 'Specify word lengths'
        modestr='specifywordlengths';
        outwl=this.hdlslResolve('outputWordLength',bfp);
        swl=this.hdlslResolve('BPS',bfp);
        if length(swl)==1
            swl=swl*ones(1,2*hf.numberofsections);
        end
    end
    [ssizes,sbps,outwl,outfl]=filterdesign.internal.cicinterpwlnfl(inputformat(1),inputformat(2),...
    modestr,hf.NumberOfSections,hf.InterpolationFactor,...
    hf.DifferentialDelay,outwl,swl);

end



function hf=updateOutputInfo(this,hf,hC,inputformat)




    bfp=hC.SimulinkHandle;
    block=get_param(bfp,'Object');

    switch block.filterInternals
    case{'Full precision','Minimum section word lengths','Specify word lengths'}
        [~,~,outsize,outbp]=getWLFL(this,hC,block.filterInternals,inputformat,hf);
    case{'Binary point scaling'}
        outsize=this.hdlslResolve('outputWordLength',bfp);
        outbp=this.hdlslResolve('outputFracLength',bfp);
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

            if isa(ud.filter,'dsp.CICInterpolator')

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



    if~isa(ud.filter,'dsp.CICInterpolator')

        hf=createhdlfilter(hd);
    else
        options.SysObjImpl.InterpolationFactor=hd.InterpolationFactor;
        options.SysObjImpl.DifferentialDelay=hd.DifferentialDelay;
        options.SysObjImpl.NumSections=hd.NumSections;

        hf=getHDLFiltObjFromSysObj(this,hC,options);
    end

end


function hf=getHDLFiltObjFromSysObj(this,hC,options)



    sysObjHandle=options.SysObjImpl;


    inputformat=options.inputformat;


    hf=hdlfilter.cicinterp;


    hf.FilterStructure='Interpolator';





    hf.RoundMode='floor';
    hf.OverflowMode=0;


    hf.InterpolationFactor=sysObjHandle.InterpolationFactor;
    hf.DifferentialDelay=sysObjHandle.DifferentialDelay;
    hf.NumberOfSections=sysObjHandle.NumSections;


    hf=updateInputInfo(hf,inputformat);


    hf=updateSectionsInfo(this,hf,hC,inputformat);


    hf=updateOutputInfo(this,hf,hC,inputformat);

end

