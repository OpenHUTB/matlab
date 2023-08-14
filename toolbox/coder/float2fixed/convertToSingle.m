function convertToSingle(varargin)











































































    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    for i=coder.internal.evalinArgs(varargin)
        try
            varargin{i}=evalin('caller',varargin{i});
        catch
        end
    end



    try
        varargin=coder.internal.handleFloat2FixedConversion('convertToSingle',varargin);
    catch ex
        disp(ex.message);
        fprintf('%s\n',getHelpMessage('convertToSingle'));
        msgStruct=struct();
        error(msgStruct);
    end

    singleCfg=[];
    for ii=1:numel(varargin)
        arg=varargin{ii};
        if isa(arg,'coder.SingleConfig')
            singleCfg=arg;
            break;
        end
    end




    if dig.isProductInstalled('MATLAB Coder')

        clientType='codegen';
    else

        clientType='fiaccel';
    end


    singleCfg.DoNotRunConversionYet=true;



    coderReport=[];
    kernelLog=evalc('coderReport = emlcprivate(''emlckernel'', clientType, varargin{:});');

    singleCfg.DoNotRunConversionYet=false;
    if~isempty(coderReport)

        if isfield(coderReport,'summary')&&...
            isfield(coderReport.summary,'passed')&&coderReport.summary.passed
            converter=singleCfg.ConverterInstance;
            singleCfg.ConverterInstance=[];
            coderReport=convert(converter);
        else
        end

        displayLog(kernelLog,clientType);
        coder.internal.emcError(mfilename,coderReport);
    else

        displayLog(kernelLog,clientType);
    end
end


function txt=getHelpMessage(clientType)
    href=sprintf('matlab: help(''%s'')',clientType);
    msg=message('Coder:reportGen:UsageLinked',href,clientType);
    txt=msg.getString();
end

function displayLog(kernelLog,clientType)

    kernelLog=strrep(kernelLog,getHelpMessage(clientType),getHelpMessage('convertToSingle'));
    kernelLog=strrep(kernelLog,'help codegen','help convertToSingle');
    if~isempty(kernelLog)
        fprintf('%s',kernelLog);
    end
end

function coderReport=convert(converter)
    try
        coderReport=converter.doFixPtConversion();
    catch ex
        throwAsCaller(ex);
    end
end


