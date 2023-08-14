function varargout=setparam(this,blockPath,paramName,val,varargin)
































    p=inputParser;
    isScalarLogical=@(x)islogical(x)&&isscalar(x);
    addParameter(p,'Force',false,isScalarLogical);
    addParameter(p,'CodeDescriptor',[],@(x)isa(x,'coder.codedescriptor.CodeDescriptor'))
    parse(p,varargin{:});
    force=p.Results.Force;
    codeDescriptor=p.Results.CodeDescriptor;

    [blockPath,paramName]=slrealtime.internal.ParameterTuning.checkAndFormatArgs(blockPath,paramName);

    if~this.isConnected()
        this.connect();
    end

    try


        if isempty(this.xcp)
            this.throwError('slrealtime:target:noAppLoaded');
        end

        if nargout>0

            old_val=this.getparam(blockPath,paramName);
        end

        try
            paramtune=slrealtime.internal.ParameterTuning(this.xcp,this.mldatxCodeDescFolder);
            paramtune.Force=force;
            paramtune.CodeDescriptor=codeDescriptor;
            paramtune.setParam(blockPath,paramName,val);
            paramtune.tuneParams();
        catch ME
            if strcmp(ME.identifier,'slrealtime:connectivity:xcpMasterError')




                appName=this.tc.ModelProperties.Application;
                this.throwError('slrealtime:target:appNotResponding',...
                appName,this.TargetSettings.name);
            else
                rethrow(ME);
            end
        end

        if nargout>0

            ret_hist=struct(...
            'Source',[],...
            'OldValues',old_val,...
            'NewValues',val);
            ret_hist.Source={blockPath,paramName};
            varargout{1}=ret_hist;
        end

        notify(this,'ParamChanged',...
        slrealtime.events.TargetParamData(blockPath,paramName,val));

    catch ME
        this.throwErrorWithCause('slrealtime:target:setparamError',...
        ME,paramName,this.TargetSettings.name,ME.message);
    end
end
