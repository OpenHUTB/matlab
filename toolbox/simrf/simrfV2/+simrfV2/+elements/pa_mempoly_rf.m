function elementSchema=pa_mempoly_rf(~)





    elementSchema=ne_lookupschema(@schema);

end

function schema=schema

    schema=NetworkEngine.ElementSchemaBuilder('pa_mempoly_rf');
    schema.descriptor='PA_MEMPOLY_RF';


    pI=schema.terminal('pI');
    pI.description='In-phase positive input terminal';
    pI.domain=foundation.rf.circuitenvelope;
    pI.label='Iin';
    pI.location={'left'};

    nI=schema.terminal('nI');
    nI.description='In-phase negative input terminal';
    nI.domain=foundation.rf.circuitenvelope;
    nI.label='-';
    nI.location={'left'};

    pQ=schema.terminal('pQ');
    pQ.description='Quadrature-phase positive input terminal';
    pQ.domain=foundation.rf.circuitenvelope;
    pQ.label='Qin';
    pQ.location={'left'};

    nQ=schema.terminal('nQ');
    nQ.description='Quadrature-phase negative input terminal';
    nQ.domain=foundation.rf.circuitenvelope;
    nQ.label='-';
    nQ.location={'left'};

    poI=schema.terminal('poI');
    poI.description='In-phase positive output terminal';
    poI.domain=foundation.rf.circuitenvelope;
    poI.label='Out_I';
    poI.location={'right'};

    noI=schema.terminal('noI');
    noI.description='Quadrature-phase negative output terminal';
    noI.domain=foundation.rf.circuitenvelope;
    noI.label='-';
    noI.location={'right'};

    poQ=schema.terminal('poQ');
    poQ.description='Quadrature-phase positive output terminal';
    poQ.domain=foundation.rf.circuitenvelope;
    poQ.label='Out_Q';
    poQ.location={'right'};

    noQ=schema.terminal('noQ');
    noQ.description='Quadrature-phase negative output terminal';
    noQ.domain=foundation.rf.circuitenvelope;
    noQ.label='-';
    noQ.location={'right'};


    unitDelay=schema.parameter('unitDelay');
    unitDelay.description='PA unit coefficient delay, unitDelay';
    unitDelay.type=ne_type('real',[1,1],'s');
    unitDelay.default={1e-6,'s'};

    coeffReal=schema.parameter('coeffReal');
    coeffReal.description='real(Coefficient matrix), coeffReal';
    coeffReal.type=ne_type('real','variable','1');
    coeffReal.default={1,'1'};

    coeffImag=schema.parameter('coeffImag');
    coeffImag.description='imag(Coefficient matrix), coeffImag';
    coeffImag.type=ne_type('real','variable','1');
    coeffImag.default={1,'1'};



    modType=schema.parameter('modType');
    modType.description='Model type - integer representation, modType';
    modType.type=ne_type('real',[1,1],'1');
    modType.default={1,'1'};

    schema.setup(@setup);
    schema=schema.finish();
end

function setup(src)
    coeffSize=size(src.coeffReal);
    memSize_str=num2str(coeffSize(1));
    degSize_str=num2str(coeffSize(2));
    switch value(src.modType,'1')
    case 1
        pacore=src.element('pacore',...
        simrfV2.elements.powamp_parts.(...
        ['pa_mp_',memSize_str,'x',degSize_str,'_rf']));
    case 2
        powTerms=(coeffSize(2)+coeffSize(1)-1)/coeffSize(1);
        powTerms_str=num2str(round(powTerms));
        pacore=src.element('pacore',...
        simrfV2.elements.powamp_parts.(...
        ['pa_gmp_',memSize_str,'x',powTerms_str,'_rf']));
    end

    src.connect(pacore.pI,src.pI);
    src.connect(pacore.nI,src.nI);
    src.connect(pacore.pQ,src.pQ);
    src.connect(pacore.nQ,src.nQ);

    src.connect(pacore.poI,src.poI);
    src.connect(pacore.noI,src.noI);
    src.connect(pacore.poQ,src.poQ);
    src.connect(pacore.noQ,src.noQ);

    pacore.unitDelay=src.unitDelay;
    pacore.coeffReal=src.coeffReal(:);
    pacore.coeffImag=src.coeffImag(:);
end

