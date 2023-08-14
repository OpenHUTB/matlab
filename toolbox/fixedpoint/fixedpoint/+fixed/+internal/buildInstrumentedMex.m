function varargout=buildInstrumentedMex(varargin)




    license_checkout_flag=builtin('license','checkout','Fixed_Point_Toolbox');
    if~license_checkout_flag
        error(message('fixed:fi:licenseCheckoutFailed'));
    end

    featurecnfg=coder.internal.FeatureControl;

    argin=varargin;

    for i=length(argin):-1:1
        help_found=false;
        if ischar(argin{i})&&isequal(argin{i},'-?')
            argin(i)=[];
            help_found=true;
        end
        if help_found
            help('buildInstrumentedMex');
            if isempty(argin)
                return
            end
        end
    end

    for i=length(argin):-1:1
        if ischar(argin{i})&&strcmpi(argin{i},'-feature')
            argin(i)=[];
        end
    end
    for i=length(argin):-1:1
        if isa(argin{i},'coder.internal.FeatureControl')
            featurecnfg=argin{i};
            argin(i)=[];
        end
    end
    featurecnfg.LocationLogging='Mex';



    for i=length(argin):-1:1
        if ischar(argin{i})&&strcmpi(argin{i},'-histogram')
            featurecnfg.HistogramLogging=true;
            argin(i)=[];
            break;
        end
    end


    coder_option=false;
    for i=length(argin):-1:1
        if ischar(argin{i})&&strcmpi(argin{i},'-coder')
            coder_option=true;
            argin(i)=[];
        end
    end


    unsupportedOptions={'-singleC','-config:lib','-config:hdl'};
    unsupportedClassOptions={
'coder.EmbeddedCodeConfig'
'coder.HdlConfig'
'coder.CodeConfig'
'coder.FixPtConfig'
'coder.SingleConfig'
    };
    for i=1:length(argin)
        for j=1:length(unsupportedOptions)
            if strcmpi(argin{i},unsupportedOptions{j})
                error(message('fixed:instrumentation:UnsupportedOption',argin{i}));
            end
        end
        for j=1:length(unsupportedClassOptions)
            if isa(argin{i},unsupportedClassOptions{j})
                error(message('fixed:instrumentation:UnsupportedClassOption',class(argin{i})));
            end
        end
    end

    if coder_option==true||featurecnfg.Developer==true
        coder_report=codegen('-feature',featurecnfg,argin{:});
    else
        coder_report=fiaccel('-feature',featurecnfg,argin{:});
    end

    if nargout==0
        coder.internal.emcError('buildInstrumentedMex',coder_report);
    end

    if~isempty(coder_report)&&...
        isstruct(coder_report)&&isfield(coder_report,'summary')&&...
        isstruct(coder_report.summary)&&isfield(coder_report.summary,'name')

        function_name=coder_report.summary.name;


        mex_file_name=[function_name,'_mex'];
        for i=1:length(argin)
            if ischar(argin{i})&&strcmp('-o',argin{i})&&(i+1)<=length(argin)
                mex_file_name=argin{i+1};
                break
            end
        end
        [~,mex_file_name,~]=fileparts(mex_file_name);
        fixed.internal.clearLog(mex_file_name);
        fixed.internal.InstrumentationManager.setCoderReport(mex_file_name,coder_report);
    end

    if nargout>0
        varargout{1}=coder_report;
    end

end
