function outputControlNet=elabOutputController(this,topNet,blockInfo,dataRate)
    downlinkMode=blockInfo.downlinkMode;
    boolType=pir_boolean_t();
    KType=blockInfo.KType;
    if blockInfo.outputCRCBits
        if downlinkMode
            CRClen=0;
        else
            CRClen=zeros(2,1);
        end
    else
        if downlinkMode
            CRClen=blockInfo.CRClen;
        else
            CRClen=[blockInfo.CRClen,blockInfo.ParityCRClen];
        end
    end

    inportNames={'startOutput','K','crcDone'};
    inTypes=[boolType,KType,boolType];

    if downlinkMode
        EType=blockInfo.EType;

        inportNames(end+1)={'E'};
        inTypes=[inTypes,EType];
    else
        inportNames(end+1)={'parityEn'};
        inTypes=[inTypes,boolType];
    end

    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'pathRdAddr','rdPath','startInt','endInt','validInt','validCrc'};
    outTypes=[KType,boolType,boolType,boolType,boolType,boolType];

    if downlinkMode
        outportNames(end+1)={'prepad'};
        outTypes=[outTypes,boolType];

        filename='outputControllerDL';
    else
        filename='outputControllerUL';
    end

    outputControlNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','outputController',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    desc='outputController - reconstructs output paths, runs CRC and outputs best path';

    fid=fopen(fullfile(blockInfo.emlPath,[filename,'.m']),'r');
    fcnBody=fread(fid,Inf,'char=>char');
    fclose(fid);

    inports=outputControlNet.PirInputSignals;
    outports=outputControlNet.PirOutputSignals;

    outputCtrl=outputControlNet.addComponent2(...
    'kind','cgireml',...
    'Name','outputController',...
    'InputSignals',inports,...
    'OutputSignals',outports,...
    'EMLFileName',filename,...
    'EMLFileBody',fcnBody,...
    'EMLParams',{CRClen},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc...
    );
    outputCtrl.runConcurrencyMaximizer(0);
end