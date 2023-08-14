function cfgObj=config(cfgType,varargin)































    try
        if nargin<1
            cfgType='mex';
        end

        cfgTypes={'mex','dll','lib','exe','fixpt','dvora','single'};
        if(strcmpi(cfgType,'hdl')&&coderprivate.hasHDLCoderLicense(false,true))
            cfgTypes=[cfgTypes,{'hdl'}];
        end
        if(strcmpi(cfgType,'plc')&&coderprivate.hasPLCCoderLicense())
            cfgTypes=[cfgTypes,{'plc'}];
        end
        cfgType=validatestring(cfgType,cfgTypes,'coder.config','OPTION');

        p=inputParser();
        p.FunctionName='coder.config';
        p.addParameter('Code',true);
        p.addParameter('Ecoder',coderprivate.hasEmbeddedCoder());
        p.parse(varargin{:});
        r=p.Results;
        code=r.Code;
        ecoder=r.Ecoder;

        validateattributes(code,{'double','logical'},{'scalar','binary'},'coder.config','CODE');
        validateattributes(ecoder,{'double','logical'},{'scalar','binary'},'coder.config','ECODER');
        if~(ischar(cfgType)&&isvector(cfgType))&&~(isstring(cfgType)&&isscalar(cfgType))
            error(message('Coder:common:ConfigTypeNotString'));
        end

        switch lower(cfgType)
        case 'mex'
            cfgObj=newMexConfig(code);
        case{'dll','lib','exe'}
            cfgObj=newCodeConfig(cfgType,ecoder);
        case 'hdl'
            if nargin>1
                error(message('Coder:common:TooManyInputs'));
            end
            cfgObj=coder.HdlConfig;
            cfgObj.HDLTBMexConfig=coder.MexCodeConfig;
            cfgObj.HDLTBMexConfig.EnableJIT=true;
            cfgObj.HDLTBMexConfig.ResponsivenessChecks=false;
            cfgObj.HDLTBMexConfig.GenerateComments=false;
        case 'plc'
            if nargin>1
                error(message('Coder:common:TooManyInputs'));
            end
            cfgObj=coder.PLCConfig;
        case 'fixpt'
            if nargin>1
                error(message('Coder:common:TooManyInputs'));
            end
            cfgObj=coder.FixPtConfig;
        case 'single'
            if nargin>1
                error(message('Coder:common:TooManyInputs'));
            end
            cfgObj=coder.SingleConfig;
        case 'dvora'
            if nargin>1
                error(message('Coder:common:TooManyInputs'));
            end
            cfgObj=coder.DvoRangeAnalysisConfig;
        otherwise
            error(message('Coder:common:UnrecognizedConfigType',cfgType));
        end
    catch me
        me.throwAsCaller();
    end
end

function cfgObj=newMexConfig(code)

    if code
        cfgObj=coder.MexCodeConfig.internalConstructor;
    else
        cfgObj=coder.MexConfig.internalConstructor;
    end

end


function cfgObj=newCodeConfig(cfgType,ecoder)

    if ecoder
        cfgObj=coder.EmbeddedCodeConfig.internalConstructor;
    else
        cfgObj=coder.CodeConfig.internalConstructor;
    end

    cfgObj.OutputType=upper(char(cfgType));
end
