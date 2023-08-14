function[typeconv_arch,cast_result]=emit_outputtypeconvert(this,last_sum)




    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    typeconv_arch.functions='';
    typeconv_arch.typedefs='';
    typeconv_arch.constants='';
    typeconv_arch.signals='';
    typeconv_arch.body_blocks='';
    typeconv_arch.body_output_assignments='';

    arch=this.implementation;

    complexity=isOutputPortComplex(this);

    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');
    outputsize=outputall.size;
    outputbp=outputall.bp;
    outputsigned=outputall.signed;
    outputvtype=outputall.portvtype;
    outputsltype=outputall.portsltype;
    castvtype=outputall.vtype;
    castsltype=outputall.sltype;

    sumall=hdlgetallfromsltype(this.AccumSLtype);
    sumsize=sumall.size;
    sumbp=sumall.bp;
    sumsigned=sumall.signed;
    sumvtype=sumall.vtype;
    sumsltype=sumall.sltype;

    rmode=this.Roundmode;
    [outputrounding,~,sumrounding]=deal(rmode);

    omode=this.Overflowmode;
    [outputsaturation,~,sumsaturation]=deal(omode);

    if emitMode
        if~strcmpi(outputvtype,sumvtype)||...
            ~strcmp(outputsltype,sumsltype)||...
            any([outputsize,outputbp,outputsigned]~=[sumsize,sumbp,sumsigned])||...
            ~strcmpi(outputrounding,sumrounding)||...
            outputsaturation~=sumsaturation||strcmpi(arch,'distributedarithmetic')

            [~,cast_result]=hdlnewsignal('output_typeconvert','filter',-1,...
            complexity,0,castvtype,castsltype);
            typeconv_arch.signals=[typeconv_arch.signals,makehdlsignaldecl(cast_result)];
            tempbody=hdldatatypeassignment(last_sum,cast_result,outputrounding,outputsaturation);
            typeconv_arch.body_blocks=[typeconv_arch.body_blocks,tempbody];

        else
            cast_result=last_sum;
        end
    else
        if~last_sum.Type.isEqual(hN.PirOutputSignals.Type)||...
            ~strcmpi(outputrounding,sumrounding)||...
            outputsaturation~=sumsaturation||strcmpi(arch,'distributedarithmetic')

            vectorSize=pirelab.getVectorTypeInfo(last_sum,1);
            [~,cast_result]=hdlnewsignal('output_typeconvert','filter',-1,...
            complexity,vectorSize,castvtype,castsltype,last_sum.SimulinkRate);
            hdldatatypeassignment(last_sum,cast_result,outputrounding,outputsaturation);
        else
            cast_result=last_sum;
        end
    end