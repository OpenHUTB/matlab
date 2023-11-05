classdef FILCommInterface<eda.internal.boardmanager.PredefinedInterface

    properties(Abstract,Constant)
        Communication_Channel;
    end
    properties(Abstract)
        RTIOStreamLibName;
    end
    properties
        ProtocolParams='';
        GenerateOnlyChIf=false;
        PostCodeGenerationFcn='';
    end

end

