



classdef CodeAnalyzer<sldv.code.CodeAnalyzer


    methods
        function this=CodeAnalyzer(irChecksum)
            this@sldv.code.CodeAnalyzer();
            this.ModelName=irChecksum;
        end

    end

    methods
        function containerName=getInstanceContainerName(~,~)
            containerName='';
        end

        function removed=removeUnsupported(~)
            removed={};
        end

        ok=runSldvAnalysis(this,options,...
        modelH,...
        modelInfo,...
        emitterDb,...
        wrapperInfo,...
        analyzedInfo);

    end
end


