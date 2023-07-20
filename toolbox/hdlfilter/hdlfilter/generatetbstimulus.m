function inputdata=generatetbstimulus(filterobj,varargin)













































    for k=1:length(varargin)
        if iscell(varargin{k})
            [varargin{k}{:}]=convertStringsToChars(varargin{k}{:});
        else
            varargin{k}=convertStringsToChars(varargin{k});
        end
    end

    fdhdlcInstallCheck;



    if isa(filterobj,'dsp.internal.FilterAnalysis')||isa(filterobj,'dsp.VariableFractionalDelay')
        supportedSystemObjs=dsp.internal.gethdlSysObj;
        if any(strcmp(class(filterobj),supportedSystemObjs))
            filterobj=sysobjHdl(filterobj,varargin{:});
        end
    end

    [cando,~,errObj]=ishdlable(filterobj);
    if~cando
        error(errObj);
    end


    hprop=PersistentHDLPropSet;
    if isempty(hprop)
        hprop=hdlcoderprops.HDLProps;
        PersistentHDLPropSet(hprop);
        hdlsetparameter('tbrefsignals',false);
    end

    set(hprop.CLI,'TestbenchUserStimulus',[]);
    set(hprop.CLI,'TestbenchStimulus','');
    set(hprop.CLI,'TestbenchFracDelayStimulus','');
    set(hprop.CLI,'TestbenchCoeffStimulus',[]);
    set(hprop.CLI,'TestBenchName','filter_tb');

    set(hprop.CLI,varargin{:});
    updateINI(hprop);



    if isa(filterobj,'dfilt.farrowlinearfd')||isa(filterobj,'dfilt.farrowfd')...
        ||isa(filterobj,'dfilt.basefilter')||isa(filterobj,'filtergroup.usrp2')

        hF=createhdlfilter(filterobj);
    else
        indices=strcmpi(varargin,'inputdatatype');
        pos=1:length(indices);
        pos=pos(indices);
        if isempty(pos)
            error(message('hdlfilter:privgeneratehdl:inputdatatypenotspecified'));
        else

        end
        inputnumerictype=varargin{pos+1};
        if~strcmpi(class(inputnumerictype),'embedded.numerictype')
            error(message('hdlfilter:privgeneratehdl:incorrectinputdatatype'));
        end
        hF=createhdlfilter(filterobj,inputnumerictype);
    end
    inputdata=hF.maketbstimulus(filterobj,varargin{:});
