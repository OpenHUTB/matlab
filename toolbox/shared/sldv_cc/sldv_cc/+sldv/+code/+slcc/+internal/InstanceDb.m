



classdef InstanceDb<sldv.code.internal.InstanceDb
    methods



        function this=InstanceDb()
            this@sldv.code.internal.InstanceDb();
        end





        function changed=clearSameArchitecture(this,analyzer)
            changed=this.removeIf(@(current)strcmp(current.Architecture,analyzer.Architecture));
        end








        function[analysis,info]=getAnalysisInfo(this,~,searched,~)
            analysis=[];
            info=[];

            for ii=1:numel(this.Analyzers)
                currentAnalyzer=this.Analyzers{ii};

                if searched.isExistingInfo(currentAnalyzer,true,false)&&...
                    strcmp(searched.ModelName,currentAnalyzer.ModelName)
                    analysis=currentAnalyzer;
                    return
                end
            end
        end
    end
end
