




classdef ProvideFunctionWriter<handle
    properties(Access=private)
CodeInfo
ModelInterface
Writer

BuildInfoSimulinkFunctions
SimulinkFunctionArgType
    end


    methods(Access=public)
        function this=ProvideFunctionWriter(modelInterface,codeInfo,writer)
            this.ModelInterface=modelInterface;
            this.CodeInfo=codeInfo;
            this.Writer=writer;
            this.BuildInfoSimulinkFunctions=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'SimulinkFunction');
            this.SimulinkFunctionArgType=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'SimulinkFunctionArgType');
        end


        function write(this)
            types=this.SimulinkFunctionArgType;
            numberOfFunctions=length(this.BuildInfoSimulinkFunctions);


            for i=1:numberOfFunctions
                fcn=this.BuildInfoSimulinkFunctions{i};
                nargin=length(fcn.ArginCGTypeIdxFlat);
                nargout=length(fcn.ArgoutCGTypeIdxFlat);

                if~strcmp(fcn.IsDefined,'no')&&~strcmp(fcn.IsScoped,'yes')&&~strcmp(fcn.IsConstUncalledFunction,'yes')

                    this.Writer.writeLine('static void ss%sProvideFunction(SimStruct *S, int_T tid,  _ssFcnCallExecArgs *args) {',fcn.CGFunctionName);


                    sep='';
                    fcnDclBegin=[fcn.CGFunctionName,'('];
                    fcnDclArgs='';
                    fcnDclEnd=');';

                    if strcmp(fcn.IsMultiInstance,'yes')&&isfield(this.ModelInterface,'DWorkType')
                        dworkType=this.ModelInterface.DWorkType;
                        this.Writer.writeLine('%s* dw = (%s*)ssGetDWork(S,0);',dworkType,dworkType);

                        fcnDclArgs='&(dw->rtm)';
                        sep=',';
                    end

                    for j=1:nargin
                        type=types{fcn.ArginCGTypeIdxFlat(j)+1}.CGTypeDetails;
                        ptr='*';
                        if type.IsImage||type.IsStruct||type.Width>1,ptr='';end
                        fcnDclArgs=[fcnDclArgs,sep,ptr,'(',type.FlatName,' *)(args->inArgs[',num2str(j-1),'].dataPtr)'];%#ok
                        sep=',';
                    end
                    for j=1:nargout
                        type=types{fcn.ArgoutCGTypeIdxFlat(j)+1}.CGTypeDetails;
                        fcnDclArgs=[fcnDclArgs,sep,'(',type.FlatName,' *)(args->outArgs[',num2str(j-1),'].dataPtr)'];%#ok
                        sep=',';
                    end

                    this.Writer.writeLine([fcnDclBegin,fcnDclArgs,fcnDclEnd]);

                    this.Writer.writeLine('}');
                end
            end
        end
    end
end
