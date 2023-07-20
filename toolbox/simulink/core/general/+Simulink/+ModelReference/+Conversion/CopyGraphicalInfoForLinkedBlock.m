classdef CopyGraphicalInfoForLinkedBlock<Simulink.ModelReference.Conversion.CopyGraphicalInfo
    properties(Constant)
        SpecialPrms={'InstantiateOnLoad','CopyFcn','DeleteFcn','UndoDeleteFcn','LoadFcn','ModelCloseFcn',...
        'PreSaveFcn','PostSaveFcn','InitFcn','StartFcn','PauseFcn','ContinueFcn','StopFcn',...
        'NameChangeFcn','ClipboardFcn','DestroyFcn','PreCopyFcn','OpenFcn','CloseFcn','PreDeleteFcn',...
        'ParentCloseFcn','MoveFcn','GeneratePreprocessorConditionals'};
    end

    methods(Access=public)
        function this=CopyGraphicalInfoForLinkedBlock(srcBlk)
            this@Simulink.ModelReference.Conversion.CopyGraphicalInfo(srcBlk);
        end
    end

    methods(Access=protected)
        function results=isFiltered(this,prmName)
            results=any(strcmp(prmName,this.FilterPrms))||...
            any(strcmp(prmName,this.SpecialPrms))||...
            strncmp(prmName,'Mask',4)||strncmp(prmName,'Ext',3);
        end
    end
end
