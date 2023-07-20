




classdef RequestFunctionCallWriter<handle
    properties(Access=private)
CodeInfo
ModelInterface
Writer
BuildInfoSimulinkFunctions
    end


    methods(Access=public)
        function this=RequestFunctionCallWriter(modelInterface,codeInfo,writer)
            this.ModelInterface=modelInterface;
            this.CodeInfo=codeInfo;
            this.Writer=writer;
            this.BuildInfoSimulinkFunctions=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'SimulinkFunction');
        end


        function write(this)
            types=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'SimulinkFunctionArgType');


            numberOfFunctions=length(this.BuildInfoSimulinkFunctions);
            for i=1:numberOfFunctions
                fcn=this.BuildInfoSimulinkFunctions{i};
                nargin=length(fcn.ArginCGTypeIdxFlat);
                nargout=length(fcn.ArgoutCGTypeIdxFlat);

                if strcmp(fcn.IsDefined,'yes'),continue;end



                sep='';
                fcnDclArgs='';

                for j=1:nargin
                    type=types{fcn.ArginCGTypeIdxFlat(j)+1}.CGTypeDetails;
                    arg=['ain',num2str(j-1)];
                    if type.Width>1
                        arg=['const ',type.FlatName,' ',arg,'[',num2str(type.Width),']'];%#ok
                    elseif type.IsStruct||type.IsImage
                        arg=['const ',type.FlatName,' *',arg];%#ok
                    else
                        arg=[type.FlatName,' ',arg];%#ok
                    end
                    fcnDclArgs=[fcnDclArgs,sep,arg];%#ok
                    sep=',';
                end

                for j=1:nargout
                    type=types{fcn.ArgoutCGTypeIdxFlat(j)+1}.CGTypeDetails;
                    arg=['aout',num2str(j-1)];
                    if type.Width>1
                        arg=[type.FlatName,' ',arg,'[',num2str(type.Width),']'];%#ok
                    else
                        arg=[type.FlatName,' *',arg];%#ok
                    end
                    fcnDclArgs=[fcnDclArgs,sep,arg];%#ok
                    sep=',';
                end

                this.Writer.writeLine(['void ',fcn.CGFunctionName,'(',fcnDclArgs,') {}']);
            end
        end
    end


    methods(Access=private)
        function writeVariableDeclaration(this,typeName,name,size)
            if size>0
                this.Writer.writeLine('%s %s[%d];',typeName,name,size);
            else
                this.Writer.writeLine('%s *%s = NULL;',typeName,name);
            end
        end
    end
end
