classdef HTMLLinkManager<coder.report.HTMLLinkManagerBase





    properties(GetAccess=private,Constant)
        UseNewStyleLinks=false


        OLDDefaultHiliteCallbackFormat='matlab:coder.internal.code2model(''%s'')'


        NEWDefaultHiliteCallbackFormat='javascript:code2model(''%s'')'
    end

    properties(Transient,Hidden)
        SystemMap=[]
        IncludeHyperlinkInReport=false
        SourceSubsystem=''
        hasWebview=false
        ModelName=''
        HTMLEscape=true
DefaultHiliteCallbackFormat
    end

    methods
        function obj=HTMLLinkManager
            if obj.UseNewStyleLinks
                obj.DefaultHiliteCallbackFormat=obj.NEWDefaultHiliteCallbackFormat;
            else
                obj.DefaultHiliteCallbackFormat=obj.OLDDefaultHiliteCallbackFormat;
            end
        end
    end
end


