classdef CheckSelector<Advisor.WindowBase

    properties(Access=public)
        ID='';
        App='CheckSelector';

        propValues=[];
    end

    properties(Access=private)
        Parent;
        TreeData=[];

        width=450;
        height=625;
        minWidth=450;
        minHeight=625;
    end

    properties(Hidden)
        REL_URL='toolbox/simulink/slcheck_exclusioneditor/ma_check_selector/index.html';
        DEBUG_URL='toolbox/simulink/slcheck_exclusioneditor/ma_check_selector/index-debug.html';
    end

    methods(Access=public)

        result=getTreeData(this);
        result=openHelp(this);
        result=saveData(this,nodeIDs);
    end

    methods(Access=public,Hidden)

        function setParent(this,ParentWindow)
            this.Parent=ParentWindow;
        end


        function parentWindow=getParent(this)
            parentWindow=this.Parent;
        end

        function setInitPropValues(this,pv)
            this.propValues=pv;
        end
    end


    methods(Access=public)
        function this=CheckSelector(varargin)
            this=this@Advisor.WindowBase(varargin);
            this.setWindowTitle(DAStudio.message('ModelAdvisor:engine:CheckSelectorHeading'));
        end

        function delete(this)
            delete@Advisor.WindowBase(this);
        end
    end

    methods(Access=public)

        function createSession(this,varargin)
            Advisor.UIService.getInstance().register(this);
        end

        function destroySession(this,varargin)
            Advisor.UIService.getInstance().unregister(this.App,this.ID);
        end

        function retStruct=defineURLQueryStruct(this)
            retStruct=struct();
        end

        function sizeData=defineWindowSize(this)
            sizeData=struct();
            w=this.width;
            h=this.height;
            r=groot;
            screenWidth=r.ScreenSize(3);
            screenHeight=r.ScreenSize(4);
            maxWidth=0.8*screenWidth;
            maxHeight=0.8*screenHeight;
            if maxWidth>0&&this.width>maxWidth
                w=maxWidth;
            end
            if maxHeight>0&&this.height>maxHeight
                h=maxHeight;
            end

            xOffset=(screenWidth-this.width)/2;
            yOffset=(screenHeight-this.height)/2;

            sizeData.size=[xOffset,yOffset,w,h];
            sizeData.minSize=[450,625];
        end
    end


end