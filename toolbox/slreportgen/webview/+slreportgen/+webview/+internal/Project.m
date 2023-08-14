classdef Project<handle

































    properties(SetAccess=private)

        Models(1,:)slreportgen.webview.internal.Model
    end

    properties(Dependent)

Parts


Diagrams
    end

    properties

ExportData
    end

    methods
        function this=Project()
        end

        function out=get.Diagrams(this)
            out=[this.Models.Diagrams];
        end

        function out=get.Parts(this)
            out=[this.Models.Parts];
        end

        function out=resolveDiagram(this,name)










            out=slreportgen.webview.internal.Diagram.empty();
            if(ischar(name)||isstring(name))
                if slreportgen.utils.isSID(name)
                    out=this.queryDiagrams(SID=name,Count=1);
                else

                    out=this.queryDiagrams(FullName=name,Count=1);


                    if isempty(out)
                        out=this.queryDiagrams(path=name,Count=1);
                    end
                end
            else
                try
                    sysH=slreportgen.utils.getSlSfHandle(name);
                    out=this.queryDiagrams(handle=sysH,Count=1);
                catch
                end
            end
        end

        function out=queryDiagrams(this,varargin)












            out=slreportgen.webview.internal.query(this.Diagrams,varargin{:});
        end

        function addModel(this,model)


            assert(all(this.Models~=model));
            this.Models(end+1)=model;
        end

        function out=paths(this)


            n=numel(this.Diagrams);
            out=string.empty(0,n);
            for i=1:n
                out(i)=this.Diagrams(i).path();
            end
        end
    end
end
