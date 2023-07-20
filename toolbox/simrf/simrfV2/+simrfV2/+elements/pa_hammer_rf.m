function elementSchema=pa_hammer_rf(~)





    elementSchema=ne_lookupschema(@schema);

end

function schema=schema

    schema=NetworkEngine.ElementSchemaBuilder('pa_hammer_rf');
    schema.descriptor='PA_HAMMER_RF';


    pin=schema.terminal('pin');
    pin.description='Positive input terminal';
    pin.domain=foundation.rf.circuitenvelope;
    pin.label='Iin';
    pin.location={'left'};

    nin=schema.terminal('nin');
    nin.description='Negative input terminal';
    nin.domain=foundation.rf.circuitenvelope;
    nin.label='-';
    nin.location={'left'};

    pout=schema.terminal('pout');
    pout.description='Positive output terminal';
    pout.domain=foundation.rf.circuitenvelope;
    pout.label='Out';
    pout.location={'right'};

    nout=schema.terminal('nout');
    nout.description='Negative output terminal';
    nout.domain=foundation.rf.circuitenvelope;
    nout.label='-';
    nout.location={'right'};


    unitDelay=schema.parameter('unitDelay');
    unitDelay.description='PA unit coefficient delay, unitDelay';
    unitDelay.type=ne_type('real',[1,1],'s');
    unitDelay.default={1e-6,'s'};

    coeff=schema.parameter('coeff');
    coeff.description='Real coefficient matrix, coeff';
    coeff.type=ne_type('real','variable','1');
    coeff.default={1,'1'};



    modelType=schema.parameter('modelType');
    modelType.description='Model type: int representation, modelType';
    modelType.type=ne_type('real',[1,1],'1');
    modelType.default={1,'1'};

    schema.setup(@setup);
    schema=schema.finish();
end

function setup(src)
    coeffSize=size(src.coeff);
    memSize_str=num2str(coeffSize(1));
    degSize_str=num2str(coeffSize(2));
    switch value(src.modelType,'1')
    case 1
        pacore=src.element('pacore',...
        simrfV2.elements.powamp_parts.(...
        ['pa_gh_',memSize_str,'x',degSize_str,'_rf']));
    case 2
        powTerms=(coeffSize(2)+coeffSize(1)-1)/coeffSize(1);
        powTerms_str=num2str(round(powTerms));
        pacore=src.element('pacore',...
        simrfV2.elements.powamp_parts.(...
        ['pa_ggh_',memSize_str,'x',powTerms_str,'_rf']));
    end

    src.connect(pacore.pin,src.pin);
    src.connect(pacore.nin,src.nin);

    src.connect(pacore.pout,src.pout);
    src.connect(pacore.nout,src.nout);

    pacore.unitDelay=src.unitDelay;
    pacore.coeff=src.coeff(:);
end

