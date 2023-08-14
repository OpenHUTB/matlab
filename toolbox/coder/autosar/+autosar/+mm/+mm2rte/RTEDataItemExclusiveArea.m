classdef RTEDataItemExclusiveArea<handle




    properties(Access='private')
        ShortName;
    end

    methods(Access='public')
        function this=RTEDataItemExclusiveArea(areaName)
            this.ShortName=areaName;
        end

        function writeForHeader(this,writerHFile)
            writerHFile.wLine('void Rte_Enter_%s(void);',this.ShortName);
            writerHFile.wLine('void Rte_Exit_%s(void);',this.ShortName);
        end

        function writeForSource(this,writerCFile)
            writerCFile.wBlockStart('void Rte_Enter_%s(void)',this.ShortName);
            writerCFile.wLine('return;');
            writerCFile.wBlockEnd;
            writerCFile.wBlockStart('void Rte_Exit_%s(void)',this.ShortName);
            writerCFile.wLine('return;');
            writerCFile.wBlockEnd;
        end
    end
end
