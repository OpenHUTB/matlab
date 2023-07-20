classdef(Sealed)Container<handle







































































    properties(SetAccess=private,Transient)





Name
    end

    properties(Access=private,Transient)
LastSetPosition
    end

    properties(Hidden,Transient)
Desktop
    end

    properties(Hidden,Transient,Constant)
        HiddenFigureTags={'figMenuHelp','figMenuWindow','figMenuDesktop',...
        'Standard.EditPlot','figMenuPropertyInspector',...
        'figMenuToolsPlotedit','figMenuPropertyEditor','figMenuFigurePalette',...
        'figMenuPlotBrowser','figMenuEditGCO','figMenuEditGCA','figMenuEditGCF',...
        'figMenuInsert','figMenuPloteditToolbar','figMenuCameraToolbar'}
    end

    properties(Dependent)






Position





Layout



ExpandToolstrip
    end

    methods(Access=private)
        function this=Container(containerName)
































































            narginchk(1,1);
            this.Desktop=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            this.Name=containerName;

            group=javaObjectEDT('com.mathworks.toolbox.shared.spcuilib.unifiedscopes.ScopesGroup',containerName,false);
            javaMethodEDT('addGroup',this.Desktop,group);

            contPos=getContainerPosition;
            this.LastSetPosition=contPos;
            this.Position=contPos;
            this.Layout=[1,1];

            internal.matlab.publish.PublishFigures.setgetContainerNames(containerName);
        end
    end

    methods(Static)
        function singleObj=getInstance(containerName)



            import matlab.internal.lang.capability.Capability;

            if isdeployed

                error(message('Spcuilib:container:ScopesContainerDeployed'));
            end
            if~Capability.isSupported(Capability.LocalClient)

                error(message('Spcuilib:container:ScopesContainerMATLABOnline'));
            end

            if isempty(containerName)||(~ischar(containerName)&&(~(isstring(containerName)&&isscalar(containerName))))
                error(message('Spcuilib:scopes:ErrorInputMustBeString'));
            end
            containerName=char(containerName);
            if isequal(containerName,'Scopes')||isequal(containerName,'Figures')


                error(message('Spcuilib:container:DisallowScopesContainer',containerName));
            end
            persistent localObjMap
            if isempty(localObjMap)||~isvalid(localObjMap)
                localObjMap=containers.Map('KeyType','char','ValueType','any');
            end
            if~localObjMap.isKey(containerName)||~isvalid(localObjMap(containerName))
                localObjMap(containerName)=matlabshared.scopes.Container(containerName);
            end
            singleObj=localObjMap(containerName);
        end
    end

    methods

        function show(this)


            javaMethodEDT('showGroup',this.Desktop,this.Name,false);

            bringToFront(this);
        end

        function hide(this)


            javaMethodEDT('closeGroup',this.Desktop,this.Name);
        end

        function dockContainer(this)


            javaMethodEDT('setGroupDocked',this.Desktop,this.Name,true);
        end

        function undockContainer(this)



            javaMethodEDT('setGroupDocked',this.Desktop,this.Name,false);
        end

        function dockScope(this,hScope)






            if~iscell(hScope)
                hScope={hScope};
            end
            for cIndx=1:numel(hScope)
                hFig=matlabshared.scopes.Container.getFigure(hScope{cIndx});
                if~isempty(hFig)
                    grpName=matlabshared.scopes.Container.getGroupName(hFig);

                    if strcmp(grpName,this.Name)
                        matlabshared.scopes.Container.dockFigure(hFig);
                    end
                end
            end
        end

        function undockScope(this,hScope)






            if~iscell(hScope)
                hScope={hScope};
            end
            for cIndx=1:numel(hScope)
                hFig=matlabshared.scopes.Container.getFigure(hScope{cIndx});
                if~isempty(hFig)
                    grpName=matlabshared.scopes.Container.getGroupName(hFig);

                    if strcmp(grpName,this.Name)
                        matlabshared.scopes.Container.undockFigure(hFig);
                    end
                end
            end
        end

        function pos=get.Position(this)

            loc=javaMethodEDT('getGroupLocation',this.Desktop,this.Name);
            if~isempty(loc)
                pos=[javaMethodEDT('getFrameX',loc),javaMethodEDT('getFrameY',loc)...
                ,javaMethodEDT('getFrameWidth',loc),javaMethodEDT('getFrameHeight',loc)];

                localFig=figure('Visible','off');
                pos=matlab.ui.internal.PositionUtils.getPlatformPixelRectangleInPixels(pos,localFig);
                localFig.delete;
            else
                pos=this.LastSetPosition;
            end
        end

        function set.Position(this,pos)

            if~matlabshared.scopes.Validator.Position(pos)
                error(message('Spcuilib:scopes:InvalidPosition'));
            end
            this.LastSetPosition=pos;
            matlabshared.scopes.Container.setGroupLocation(this.Desktop,this.Name,pos);
        end

        function set.Layout(this,layout)

            validateattributes(layout,{'double'},{'>=',1,'<=',4,'ncols',2,'nrows',1},'','Layout');
            javaMethodEDT('setDocumentArrangement',this.Desktop,this.Name,this.Desktop.TILED,...
            java.awt.Dimension(layout(2),layout(1)));
        end

        function layout=get.Layout(this)

            dims=javaMethodEDT('getDocumentTiledDimension',this.Desktop,this.Name);
            layout=zeros(1,2);
            layout(1)=javaMethodEDT('getHeight',dims);
            layout(2)=javaMethodEDT('getWidth',dims);
        end

        function set.ExpandToolstrip(this,value)

            validateattributes(value,{'logical'},{'scalar'},'','ExpandToolstrip');
            groupFrame=javaMethodEDT('getFrameContainingGroup',this.Desktop,this.Name);
            if~isempty(groupFrame)
                toolStrip=javaMethodEDT('getToolstrip',groupFrame);
                if~isempty(toolStrip)
                    if value
                        value=javaMethodEDT('valueOf','com.mathworks.toolstrip.Toolstrip$State','EXPANDED');
                    else
                        value=javaMethodEDT('valueOf','com.mathworks.toolstrip.Toolstrip$State','COLLAPSED');
                    end
                    javaMethodEDT('setAttribute',toolStrip,com.mathworks.toolstrip.Toolstrip.STATE,value);
                end
            end
        end

        function value=get.ExpandToolstrip(this)

            value=true;
            groupFrame=javaMethodEDT('getFrameContainingGroup',this.Desktop,this.Name);
            if~isempty(groupFrame)
                toolStrip=javaMethodEDT('getToolstrip',groupFrame);
                if~isempty(toolStrip)
                    value=javaMethodEDT('getAttribute',toolStrip,com.mathworks.toolstrip.Toolstrip.STATE);
                    value=javaMethodEDT('equals',value,value.EXPANDED);
                end
            end
        end

        function add(this,hScope,placement)





















            if nargin==1
                this.addAllScopes;
                return;
            end
            narginchk(2,3);
            if nargin<3
                placement=[];
            end
            if~iscell(hScope)
                hScope={hScope};
            end
            if nargin==3
                validateattributes(placement,{'double'},{'numel',numel(hScope)},'','Placement');

                gridLength=prod(this.Layout);
                for cIndx=1:numel(placement)
                    validateattributes(placement(cIndx),{'double'},{'positive','real','scalar','>=',1,'<=',gridLength},'','Placement');
                end
            end






            grpCont=javaMethodEDT('getGroupContainer',this.Desktop,this.Name);
            firstClient=javaMethodEDT('getFirstClientDockedInGroup',this.Desktop,this.Name);
            shouldSetLayoutAfterAdd=false;
            if(isempty(grpCont)||isempty(firstClient))
                shouldSetLayoutAfterAdd=true;
                cachedLayout=this.Layout;



                this.Layout=[1,1];
            end
            for cIndx=1:numel(hScope)
                hFig=matlabshared.scopes.Container.getFigure(hScope{cIndx});
                if~isempty(hFig)
                    [grpName,jf]=matlabshared.scopes.Container.getGroupName(hFig);


                    if isempty(jf)
                        continue;
                    end


                    if(isa(hScope{cIndx},'matlab.ui.Figure'))
                        setupFigure(this,hScope{cIndx});
                    end

                    if~strcmp(grpName,this.Name)
                        jf.setGroupName(this.Name);
                        matlabshared.scopes.Container.dockFigure(hFig);
                        if shouldSetLayoutAfterAdd
                            this.Layout=cachedLayout;
                            shouldSetLayoutAfterAdd=false;
                        end
                        if~isempty(placement)
                            place(this,hFig,placement(cIndx));
                        end
                    else


                        matlabshared.scopes.Container.dockFigure(hFig);
                    end
                end
            end


            bringToFront(this);
        end

        function remove(this,hScope)











            narginchk(2,2);
            if~iscell(hScope)
                hScope={hScope};
            end
            for cIndx=1:numel(hScope)
                hFig=matlabshared.scopes.Container.getFigure(hScope{cIndx});
                if~isempty(hFig)


                    isFigure=isa(hScope{cIndx},'matlab.ui.Figure');
                    if isFigure
                        teardownFigure(this,hScope{cIndx});
                    end


                    [grpName,jf]=matlabshared.scopes.Container.getGroupName(hFig);

                    if strcmp(grpName,this.Name)
                        matlabshared.scopes.Container.undockFigure(hFig);


                        defaultGroupName='Figures';
                        if~isFigure
                            defaultGroupName='Scopes';
                        end
                        jf.setGroupName(defaultGroupName);
                    end
                end
            end
        end

        function place(this,hScope,placement)













            narginchk(3,3);
            if~iscell(hScope)
                hScope={hScope};
            end
            validateattributes(placement,{'double'},{'numel',numel(hScope)},'','Placement');
            for cIndx=1:numel(hScope)
                if isa(hScope{cIndx},'matlab.ui.Figure')
                    hFig=hScope{cIndx};
                else
                    hFig=matlabshared.scopes.Container.getFigure(hScope{cIndx});
                end
                layout=this.Layout;
                gridLength=prod(this.Layout);
                validateattributes(placement(cIndx),{'double'},{'positive','real','scalar','>=',1,'<=',gridLength},'','Placement');
                if~isempty(hFig)

                    m=(reshape(1:gridLength,layout(2),layout(1)))';
                    placement(cIndx)=m(placement(cIndx));

                    placement(cIndx)=placement(cIndx)-1;
                    grpName=matlabshared.scopes.Container.getGroupName(hFig);
                    if strcmp(grpName,this.Name)
                        loc=com.mathworks.widgets.desk.DTLocation.create(placement(cIndx));
                        javaMethodEDT('setClientLocation',this.Desktop,hFig.Name,this.Name,loc);
                    end
                end
            end
        end

        function setColumnWidths(this,widths)





            layout=this.Layout;
            validateattributes(widths,{'double'},{'>=',0,'<=',1,'ncols',layout(2),'nrows',1},'','Widths');
            validateattributes(sum(widths),{'double'},{'scalar','<=',1},'','sum(Widths)');
            javaMethodEDT('setDocumentColumnWidths',this.Desktop,this.Name,widths);
        end

        function setRowHeights(this,heights)





            layout=this.Layout;
            validateattributes(heights,{'double'},{'>=',0,'<=',1,'ncols',layout(1),'nrows',1},'','Heights');
            validateattributes(sum(heights),{'double'},{'scalar','<=',1},'','sum(Heights)');
            javaMethodEDT('setDocumentRowHeights',this.Desktop,this.Name,heights);
        end

        function setColumnSpan(this,row,column,span)




            javaMethodEDT('setDocumentColumnSpan',this.Desktop,this.Name,row-1,column-1,span);
        end

        function setRowSpan(this,row,column,span)




            javaMethodEDT('setDocumentRowSpan',this.Desktop,this.Name,row-1,column-1,span);
        end

    end

    methods(Static,Hidden)
        function this=loadobj(s)

            this=matlabshared.scopes.Container.getInstance(s.Name);
            this.Position=s.Position;
            this.Layout=s.Layout;
            this.ExpandToolstrip=s.ExpandToolstrip;
        end
        function[groupName,jf]=getGroupName(hFig)

            narginchk(1,1);
            groupName='';
            jf=[];
            if isa(hFig,'matlab.ui.Figure')
                [lastWarnMsg,lastWarnId]=lastwarn;
                w=uiservices.WarningCleanup('MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');%#ok<NASGU>
                jf=matlab.ui.internal.JavaMigrationTools.suppressedJavaFrame(hFig);
                if~isempty(jf)
                    groupName=char(jf.getGroupName);
                end

                lastwarn(lastWarnMsg,lastWarnId);
            end
        end
        function setGroupName(jf,containerName)


            if~isempty(jf)


                desktop=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                groupExists=javaMethodEDT('hasGroup',desktop,containerName);
                if~groupExists
                    group=javaObjectEDT('com.mathworks.toolbox.shared.spcuilib.unifiedscopes.ScopesGroup',false);
                    javaMethodEDT('addGroup',desktop,group);
                end
                jf.setGroupName(containerName);
            end
        end
        function hFig=getFigure(hScope)

            narginchk(1,1);
            hFig=[];
            if isa(hScope,'matlabshared.scopes.SystemScope')


                hFig=hScope.getFramework.Parent;
            elseif isa(hScope,'matlabshared.scopes.UnifiedScope')
                hFig=hScope.Parent;
            elseif isa(hScope,'matlab.ui.Figure')&&ishandle(hScope)
                hFig=hScope;
            elseif matlabshared.scopes.Container.isScopeBlock(hScope)


                hScopeSpec=get_param(hScope,'ScopeSpecificationObject');
                hScope=getUnifiedScope(hScopeSpec);
                hFig=hScope.Parent;
            end
        end
        function b=isScopeBlock(hScope)


            b=false;
            try
                hScopeSpec=get_param(hScope,'ScopeSpecificationObject');
                if~isempty(hScopeSpec)&&isLaunched(hScopeSpec)
                    b=true;
                end
            catch E %#ok<NASGU>
            end
        end
        function dockFigure(hFig)

            narginchk(1,1);
            if isa(hFig,'matlab.ui.Figure')
                hFig.WindowStyle='docked';

                if strcmp(hFig.Visible,'on')
                    drawnow;pause(0.5);
                end
            end
        end
        function undockFigure(hFig)

            narginchk(1,1);
            if isa(hFig,'matlab.ui.Figure')
                hFig.WindowStyle='normal';

                if strcmp(hFig.Visible,'on')
                    drawnow;pause(0.5);
                end
            end
        end
        function setGroupLocation(desktop,containerName,pos)

            localFig=figure('Visible','off');
            pos=matlab.ui.internal.PositionUtils.getPixelRectangleInPlatformPixels(pos,localFig);
            localFig.delete;
            loc=com.mathworks.widgets.desk.DTLocation.createExternal(int16(pos(1)),...
            int16(pos(2)),int16(pos(3)),int16(pos(4)));
            javaMethodEDT('setGroupLocation',desktop,containerName,loc);
        end
    end

    methods(Hidden)
        function s=saveobj(this)

            s.Name=this.Name;
            s.Position=this.Position;
            s.Layout=this.Layout;
            s.ExpandToolstrip=this.ExpandToolstrip;
        end
    end

    methods(Access=private)
        function setupFigure(this,hFig)



            for kndx=1:length(this.HiddenFigureTags)
                set(findall(hFig,'Tag',this.HiddenFigureTags{kndx}),'Visible','off');
            end
            hFig.NumberTitle='off';
        end

        function teardownFigure(this,hFig)


            for kndx=1:length(this.HiddenFigureTags)
                set(findall(hFig,'Tag',this.HiddenFigureTags{kndx}),'Visible','on');
            end
            hFig.NumberTitle='on';
        end

        function addAllScopes(this)



            hFigures=findall(groot,'Type','figure');
            numFigures=length(hFigures);
            openFigures=cell(1,numFigures);
            mndx=1;
            for kndx=1:numFigures
                hFig=hFigures(kndx);
                isAllowedGroup=any(strcmp(hFig.Tag,{'spcui_scope_framework',...
                'SIMULINK_SIMSCOPE_FIGURE','scopes_container_figure'}));
                if ishandle(hFig)&&isAllowedGroup&&strcmpi(hFig.Visible,'on')&&...
                    strcmpi(hFig.WindowStyle,'normal')
                    openFigures{mndx}=hFig;
                    mndx=mndx+1;
                end
            end
            this.add(openFigures);
        end

        function bringToFront(this)


            grpCont=javaMethodEDT('getGroupContainer',this.Desktop,this.Name);
            if~isempty(grpCont)
                grpDocument=javaMethodEDT('getTopLevelAncestor',grpCont);
                javaMethodEDT('setSelected',grpDocument,true);
            end
        end
    end
end

function ret=getContainerPosition

    width=1200;
    height=800;

    r=groot;
    screenWidth=r.ScreenSize(3);
    screenHeight=r.ScreenSize(4);
    maxWidth=0.8*screenWidth;
    maxHeight=0.8*screenHeight;
    if maxWidth>0&&width>maxWidth
        width=maxWidth;
    end
    if maxHeight>0&&height>maxHeight
        height=maxHeight;
    end

    xOffset=(screenWidth-width)/2;
    yOffset=(screenHeight-height)/2;
    ret=[xOffset,yOffset,width,height];
end


