function this=MappingViewManager(h)





    this=DeploymentDiagram.MappingViewManager;
    this.Explorer=h;
    this.Explorer.GroupingEnabled=true;


    TaskManagerDomain=DAStudio.MEViewDomain(this,'TaskManagerDomain');
    this.ActiveDomainName='TaskManagerDomain';


    TaskManagerView=DAStudio.MEView('TaskManagerView','Desc');
    TaskManagerView.GroupName='Period';
    TaskManagerDomain.setActiveView(TaskManagerView);
    this.Domains=TaskManagerDomain;
    this.addView(TaskManagerView);
    this.ActiveView=TaskManagerView;
    this.SuggestionMode='auto';
    this.Serialize=false;


