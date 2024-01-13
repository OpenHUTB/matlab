classdef PslinkContext<dig.CustomContext

    properties(SetAccess=immutable)
        ModelHandle(1,1)double;
    end

    properties(SetAccess=private,SetObservable=true)
        VerificationMode;
        CodeAs;
        CodeAsTopModel(1,1)logical;
        CodeAsRefModel(1,1)logical;
        CodeAsCustomCode(1,1)logical;
        IsTargetLink(1,1)logical;
        RefreshAnnotations(1,1)logical;
    end


    methods
        function obj=PslinkContext(modelHandle)
            app=struct;
            app.name='polyspaceApp';
            app.defaultContextType='polyspaceAppContext';
            app.defaultTabName='polyspaceAppTab';
            app.priority=31;

            obj@dig.CustomContext(app);
            obj.ModelHandle=modelHandle;
            obj.setCodeAsMode('TopModel');

            if pssharedprivate('isTlInstalled')
                obj.TypeChain={'polyspaceAppContext','polyspaceTargetLinkContext'};
            else
                obj.TypeChain={'polyspaceAppContext','polyspaceEcoderContext'};
            end
        end


        function toggleTargetLink(obj)
            obj.IsTargetLink=~obj.IsTargetLink;
        end


        function setVerificationMode(obj,verificationMode)
            obj.VerificationMode=verificationMode;
        end


        function setCodeAsMode(obj,codeAsMode)
            obj.CodeAs=codeAsMode;
            if strcmpi(codeAsMode,'TopModel')
                obj.CodeAsTopModel=true;
                obj.CodeAsRefModel=false;
                obj.CodeAsCustomCode=false;
            elseif strcmpi(codeAsMode,'RefModel')
                obj.CodeAsTopModel=false;
                obj.CodeAsRefModel=true;
                obj.CodeAsCustomCode=false;
            else
                obj.CodeAsTopModel=false;
                obj.CodeAsRefModel=false;
                obj.CodeAsCustomCode=true;
            end
        end


        function toggleRefreshAnnotations(obj)
            obj.RefreshAnnotations=~obj.RefreshAnnotations;
        end
    end
end


