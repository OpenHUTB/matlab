classdef PIDialogContext<dig.ContextProvider
    properties(SetAccess=public)
        Name='Property Inspector Dialog Context';
        BlockHandle=[];
        ShowFrames=false;
        HasEvalErrors=false;
        DerivedDataType='Inertia';
        ShowDerivedData=false;
    end
    methods
        function obj=PIDialogContext()
            obj.Name='PIDialogContext';
            obj.TypeChain={'BlockProperties'};
            obj.BlockHandle=[];
            obj.ShowFrames=false;
            obj.HasEvalErrors=false;
            obj.DerivedDataType='Inertia';
            obj.ShowDerivedData=false;
        end
    end
end
