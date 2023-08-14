


classdef(Hidden=true)FunctionWriter<handle
    properties
StorageClass
ReturnType
FunctionName
ArgumentList
FunctionBody
    end

    methods(Access=public)
        function this=FunctionWriter(storageClass,retType,fcnName,argList,fcnBody)
            this.StorageClass=storageClass;
            this.ReturnType=retType;
            this.FunctionName=fcnName;


            assert(isempty(argList)||iscellstr(argList));%#ok


            if isempty(argList)
                this.ArgumentList='void';
            else
                this.ArgumentList=strjoin(argList,', ');
            end



            assert(isempty(fcnBody)||iscellstr(fcnBody));%#ok

            this.FunctionBody=fcnBody;
        end




        function writeFunctionDeclaration(this,writer)
            writer.wLine('%s %s %s(%s);',this.StorageClass,this.ReturnType,this.FunctionName,this.ArgumentList);
        end







        function writeFunctionDefinition(this,writer)
            writer.wLine('%s %s(%s)',this.ReturnType,this.FunctionName,this.ArgumentList);
            writer.wBlockStart('');
            for lineIdx=1:length(this.FunctionBody)
                writer.wLine(this.FunctionBody{lineIdx});
            end
            writer.wBlockEnd('');
        end















        function writeAsMacro(this,writer)


            assert(~isempty(this.FunctionBody));

            assert(isempty(this.ArgumentList));

            writer.wLine(['#ifndef ',this.FunctionName]);

            if length(this.FunctionBody)==1
                writer.wLine(['#define ',this.FunctionName,'() (',this.FunctionBody{1},')']);
            else
                writer.wLine(['#define ',this.FunctionName,'() ({ \']);
                for lineIdx=1:length(this.FunctionBody)
                    writer.wLine([this.FunctionBody{lineIdx},' \']);
                end
                writer.wLine('})');
            end
            writer.wLine('#endif');

        end
    end
end

