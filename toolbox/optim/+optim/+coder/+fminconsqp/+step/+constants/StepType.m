function val=StepType(cname)














%#codegen

    coder.allowpcode('plain');

    switch cname
    case 'Normal'
        val=coder.internal.indexInt(1);
    case 'Relaxed'
        val=coder.internal.indexInt(2);
    case 'SOC'
        val=coder.internal.indexInt(3);
    otherwise
        assert(false,'fminconsqp.step.constants.StepType() unexpected input');
    end

end