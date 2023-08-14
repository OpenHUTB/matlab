function librarybrowser





    persistent me;
    persistent melistener3;%#ok<PUSE>

    persistent speedupReference;

    this=Simulink.ModelAdvisor.getActiveModelAdvisorObj;


    if this.NOBROWSER
        return
    end

    iconpath=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources');


    MAExplorecreated=false;
    if~isa(me,'DAStudio.Explorer')
        MAExplorecreated=true;
        me=DAStudio.Explorer(this.TaskAdvisorRoot,'Model Advisor',false);

        screenSize=get(0,'ScreenSize');
        height=screenSize(4);
        width=screenSize(3);
        x=floor(width/4);
        y=floor(height/6);
        if width>1280
            height=floor(height/2);
            width=floor(width/2);
        else
            height=floor(height*0.8);
            width=floor(width*0.8);
        end
        me.position=[x,y,width,height];


        me.icon=fullfile(iconpath,'check_browser.png');

        melistener3=handle.listener(me,'METreeSelectionChanged',{@MECallback});

    end

    if isempty(this.CheckLibraryRoot)

        dirtyflag=this.ConfigUIDirty;

        this.CheckLibraryRoot=ModelAdvisor.ConfigUI;
        this.CheckLibraryRoot.DisplayName=DAStudio.message('Simulink:tools:MACBTitle');
        this.CheckLibraryRoot.ID='LibRoot';
        this.CheckLibraryRoot.InLibrary=true;
        this.CheckLibraryRoot.Type='Group';
        this.CheckLibraryRoot.MAObj=this;
        CheckLibrary=this.CheckLibrary;

        for i=1:length(CheckLibrary)



            if isnumeric(CheckLibrary{i}.ParentObj)
                if CheckLibrary{i}.ParentObj==0
                    CheckLibrary{i}.ParentObj=this.CheckLibraryRoot;
                    this.CheckLibraryRoot.ChildrenObj{end+1}=CheckLibrary{i};
                else
                    CheckLibrary{i}.ParentObj=CheckLibrary{CheckLibrary{i}.ParentObj};
                end
                if isa(CheckLibrary{i}.ParentObj,'ModelAdvisor.ConfigUI')

                    CheckLibrary{i}.ParentObj.addChildren(CheckLibrary{i});
                end
            end

            if~isempty(CheckLibrary{i}.ChildrenObj)
                for j=1:length(CheckLibrary{i}.ChildrenObj)
                    CheckLibrary{i}.ChildrenObj{j}=CheckLibrary{CheckLibrary{i}.ChildrenObj{j}};
                end
            end
        end
        this.CheckLibrary=CheckLibrary;
        this.ConfigUIDirty=dirtyflag;
    end

    me.setRoot(this.CheckLibraryRoot);






    if isempty(me.UserData)
        am=DAStudio.ActionManager;
        am.initializeClient(me);

        tb=am.createToolBar(me);
        modeladvisorprivate('modeladvisorutil2','createToolbar',me,am,tb,'MACB');
    end


    if MAExplorecreated








        me.Title=DAStudio.message('Simulink:tools:MACBTitle')'';
        me.setTreeTitle(' ');
        this.CheckLibraryBrowser=me;
    end

    loc_updateMenu(me);

    me.showListView(false);
    me.show;


    function MECallback(this,event)
        switch(event.type)
        case 'METreeSelectionChanged'
            loc_updateMenu(this);
        otherwise
            DAStudio.error('Simulink:tools:MAUnknownEventReceived');
        end

        function loc_updateMenu(me)
            imme=DAStudio.imExplorer(me);
            selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
            mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
            if isempty(selectedNode.ParentObj)
                loc_enableAction(mdladvObj,'ConfigF_copyLib',0);
            else
                loc_enableAction(mdladvObj,'ConfigF_copyLib',1);
            end


            function loc_enableAction(mdladvObj,actionName,action)
                if isfield(mdladvObj.MEMenus,actionName)
                    dasActionObj=mdladvObj.MEMenus.(actionName);
                    if isa(dasActionObj,'DAStudio.Action')
                        if action
                            dasActionObj.enabled='on';
                        else
                            dasActionObj.enabled='off';
                        end
                    end
                end
