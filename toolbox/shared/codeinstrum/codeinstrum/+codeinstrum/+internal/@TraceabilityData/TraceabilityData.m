classdef(Hidden=true)TraceabilityData<internal.cxxfe.instrum.TraceabilityData










    methods(Access=public)



        function this=TraceabilityData(varargin)
            this@internal.cxxfe.instrum.TraceabilityData(varargin{:});
        end





        function buf=saveobj(this)
            buf=this.serializeToJSON();
        end
    end

    methods(Static=true)



        function obj=loadobj(buf)
            obj=codeinstrum.internal.TraceabilityData('');
            obj.parseJSONString(buf);
        end
    end
    methods(Access=public,Hidden)



        function funSigs=extractReachableFunSignatures(this,entryPoints)

            this.computeShortestUniquePaths();


            funSigs=[];

            try

                entryPoints=[entryPoints{:}];
                funKeys=entryPoints(1:2:end);
                fileNames=entryPoints(2:2:end);


                callerFunSigs=[];
                for ii=1:numel(funKeys)

                    funs=this.getFunctionByKey(funKeys{ii});
                    if isempty(funs)

                        funName=regexprep(funKeys{ii},'\|.*','');
                        funs=this.getFunctionByName(funName);
                    end
                    for jj=1:numel(funs)
                        fun=funs(jj);
                        file=fun.location.file;




                        if~isempty(file)&&...
                            (strcmp(file.path,fileNames{ii})||...
                            endsWith(fileNames{ii},[filesep,file.shortPath]))

                            callerFunSigs=[callerFunSigs;{fun.signature}];%#ok<AGROW>
                            break
                        end
                    end
                end


                if isempty(callerFunSigs)
                    return
                end


                callGraph=codeinstrum.internal.CallGraph(this);
                funSigs=unique([callerFunSigs;callGraph.getCallees(callerFunSigs)]);

            catch MEx
                if codeinstrumprivate('feature','disableErrorRecovery')
                    rethrow(MEx);
                end
            end
        end
    end

end


