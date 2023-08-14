classdef BlockConditionalBreakpointDialogSource<handle
    properties
        mData;
        mSrc;
        mMdl;
        mComponentName;
    end
    methods(Static,Access=public)
        function r=handleSelectionChanged(ssTag,selections,obj)
            disp('done');
            r=true;
        end
    end
    methods

        function this=BlockConditionalBreakpointDialogSource(model,blockHandle)
            this.mData=[];
            this.mMdl=model;
            this.mSrc=blockHandle;
            name=[get_param(blockHandle,'Parent'),'/',get_param(blockHandle,'Name')];
            this.mComponentName=sprintf('GLUE2:SpreadSheet/%s',name);
        end
        function children=getChildren(this)
            children=[];
            if isempty(this.mData)
                for idx=1:SLStudio.StepperBlockDiagnostics.NumAllowedDiagnostics
                    childObj=SLStudio.StepperBreakpointSingle(idx,this.mSrc,...
                    {0,6,SLStudio.StepperBlockDiagnostics.AllowedSet(idx,1),0,0,0});
                    children=[children,childObj];
                end
                this.mData=children;
            end
            children=this.mData;
        end








    end
end