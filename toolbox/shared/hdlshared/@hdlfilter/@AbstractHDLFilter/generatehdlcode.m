function generatehdlcode(this,filterobj,varargin)










    hdlcodegenmode('filtercoder');

    hprop=this.HDLParameters;
    PersistentHDLPropSet(hprop);

    updateHdlfilterINI(this);

    this.setimplementation;








    orig_coeffs=this.setProcIntCoeffs;
    v=this.checkhdl(varargin{:});
    if v.Status


        error(v.MessageID,v.Message);
    end

    this.makeComment(filterobj);


    this.resetINIOnlyProps();

    makehdl(this);


    this.setProcIntCoeffs(orig_coeffs);

    cosimModel=this.getHDLParameter('generatecosimmodel');
    switch lower(cosimModel)
    case 'none'

    case{'modelsim'}
        makemodel(this,filterobj,'modelsim',varargin{:});
    case{'incisive'}
        makemodel(this,filterobj,'incisive',varargin{:});
    otherwise
        error(message('HDLShared:hdlfilter:UnknownSimulator',upper(cosimModel)));
    end

    if this.getHDLParameter('generatecosimblock')
        hF=createhdlfilter(filterobj);
        makecosimblks(hF,filterobj);
    end








    tbprops={'TestbenchUserStimulus','TestbenchStimulus','TestbenchFracDelayStimulus',...
    'TestbenchCoeffStimulus','TestBenchName'};
    tbargs=varargin;
    for ii=1:numel(tbprops)




        tbprop=tbprops{ii};
        tbval=get(hprop.CLI,tbprop);


        if strcmpi(tbprop,'TestbenchFracDelayStimulus')&&isempty(tbval)
            tbval='';
        end
        tbargs=[{tbprop},{tbval},tbargs];
    end


    if this.getHDLParameter('generatehdltestbench')
        generatetbcode(this,filterobj,tbargs{:});
    end




