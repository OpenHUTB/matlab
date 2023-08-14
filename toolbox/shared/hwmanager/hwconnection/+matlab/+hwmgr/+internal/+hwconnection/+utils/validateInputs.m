function supportedParams=validateInputs(varargin)





    if~isempty(varargin)
        numInputs=length(varargin);

        if(rem(numInputs,2)>0)
            error(message('hwconnection:setup:NonPairedArgs'));
        else
            validationFcn=@(x)(ischar(x)||isStringScalar(x));
            p=inputParser;
            p.addParameter('productname','',validationFcn);
            p.addParameter('productid','',validationFcn);
            p.addParameter('vendorid','',validationFcn);
            try
                p.parse(varargin{:});
            catch ME
                if(strcmp(ME.identifier,'MATLAB:InputParser:UnmatchedParameter'))
                    tmp_msg=strsplit(ME.message,'. ');
                    msg=[tmp_msg{1},message('hwconnection:setup:ParamNotSupported_MSG').getString];
                    causeException=MException('hwconnection:setup:ParamNotSupported',msg);
                    ME=addCause(ME,causeException);
                elseif(strcmp(ME.identifier,'MATLAB:InputParser:ArgumentFailedValidation'))
                    tmp_msg=strsplit(ME.message,'. ');
                    msg=[tmp_msg{1},message('hwconnection:setup:ArgTypeNotSupported_MSG').getString];
                    causeException=MException('hwconnection:setup:ArgTypeNotSupported',msg);
                    ME=addCause(ME,causeException);
                end
                rethrow(ME)
            end
            supportedParams=p.Results;
            supportedParams.productid=char(regexprep(supportedParams.productid,'0x',''));
            supportedParams.vendorid=char(regexprep(supportedParams.vendorid,'0x',''));
            supportedParams.productname=char(supportedParams.productname);
        end
    end

end


