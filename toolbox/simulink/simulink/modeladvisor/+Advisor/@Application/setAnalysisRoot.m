























function setAnalysisRoot(this,varargin)






















    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    p=inputParser();
    p.addParameter('root','',@ischar);
    p.addParameter('rootType',Advisor.component.Types.Model);
    p.addParameter('multiMode',true,@islogical);
    p.addParameter('discardResults',false,@islogical);

    p.addParameter('legacy',false,@islogical);
    p.addParameter('configFile',[],@ischar);

    p.parse(varargin{:});
    in=p.Results;


    if in.legacy
        in.multiMode=false;
        this.LegacyMode=true;
    end






    try
        [rootCompId,rootType,linked,file]=...
        Advisor.component.ComponentManager.parseAnalysisRoot(...
        in.root,in.rootType);
    catch E
        if this.LegacyMode&&...
            (strcmp(E.identifier,'Advisor:base:Components_UnsupportedComponentTypeError')||...
            strcmp(E.identifier,'Advisor:base:Components_IncorrectSubsystemPath'))





            rootCompId=Simulink.ID.getSID(in.root);
            rootType=Advisor.component.Types.SubSystem;
            linked=false;
            file='';
        else
            E.rethrow();
        end
    end


    if~this.LegacyMode&&linked
        DAStudio.error('Advisor:base:Components_LibraryRoot',in.root);
    end




    if in.multiMode&&isempty(file)
        system=bdroot(in.root);
        DAStudio.error('Advisor:base:Components_NewModelError',system);
    end


    this.AnalysisRoot=in.root;
    this.AnalysisRootComponentId=rootCompId;


    this.AnalysisRootType=rootType;


    this.RootModel=bdroot(this.AnalysisRoot);



    this.mdlListenerOperation('DetachListener');

    this.mdlListenerOperation('AttachListener');


    this.MultiMode=in.multiMode;






    this.ID=this.getID(this.AdvisorId,this.AnalysisRoot);

    this.initVariantManager(this.ID,in.root);



    if~isempty(this.ComponentManager)
        this.ComponentManager.delete();
        this.ComponentManager=[];
    end


    this.deleteMAObjs();

    if ischar(in.configFile)

        this.TaskManager.initialize(this.AnalysisRootComponentId,in.configFile);
    else
        this.TaskManager.initialize(this.AnalysisRootComponentId);
    end

    if this.LegacyMode

        this.updateModelAdvisorObj(this.AnalysisRootComponentId,true);
    end




end

