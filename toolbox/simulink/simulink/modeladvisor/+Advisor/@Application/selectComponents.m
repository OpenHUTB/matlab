


























function selectComponents(this,varargin)



























    if strcmp(this.AnalysisRoot,'empty')
        DAStudio.error('Advisor:base:App_NotInitialized');
    end



    if this.MultiMode
        p=inputParser();
        p.addParameter('ids',{});
        p.addParameter('hierarchicalSelection',false,@islogical);
        p.addParameter('type',[],@(x)isa(x,'Advisor.component.Types'));
        p.parse(varargin{:});
        in=p.Results;
        in.status=true;



        if isempty(this.ComponentManager)



            this.AsynchronousComponentSelectionCache{end+1}=in;
        else

            this.applyComponentSelection(in);
        end
    else
        DAStudio.error('Advisor:base:App_NoCompSelectionInSingleMode');
    end
end
