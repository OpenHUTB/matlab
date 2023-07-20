classdef ClassDiagramExpandCommand<diagram.editor.Command&...
    classdiagram.app.core.commands.ClassDiagramUndoRedo














































    properties(Access={
        ?diagram.editor.Command,...
        ?classdiagram.app.core.commands.ClassDiagramUndoRedo
        })
        App;
        RootDiagram;
    end

    properties(Access=private)
        AdjustLayout=true;
    end

    properties(Access=private,Hidden)
        forceRedrawCounter=0;
    end

    methods
        function cmd=ClassDiagramExpandCommand(data,syntax,app)
            cmd@diagram.editor.Command(data,syntax);
            cmd.App=app;
            cmd.RootDiagram=syntax.root;
        end
    end

    methods(Access=protected)
        function execute(self)
            data=self.data;

            if isfield(data,'all')
                classNames=string({self.App.syntax.root.entities.title});
                self.App.expandClass(classNames,data.all);
            elseif isfield(data,'sections')
                if isfield(data,'expanded')
                    self.App.syntax.modify(@(ops)self.handleExpandState(ops,data));
                else
                    self.expandSections(data.entity,data.sections);
                end
            elseif isfield(data,'entity')
                self.expandClass(data.entity,data.expanded);
            else

            end
        end
    end

    methods(Access=private)

        function[linesBySectionName,sectionsByName]=getLinesBySection(~,entity)
            linesBySectionName=struct;
            sectionsByName=struct;
            lines=entity.subdiagram.entities';
            activeSection=string.empty;
            for iline=1:numel(lines)
                line=lines(iline);
                if string(line.type)=="subtitle"
                    activeSection=string(line.title);
                    sectionsByName.(activeSection)=line;
                elseif~isempty(activeSection)
                    if~isfield(linesBySectionName,activeSection)
                        linesBySectionName.(activeSection)=[];
                    end
                    linesBySectionName.(activeSection)=[linesBySectionName.(activeSection),line];
                end
            end
        end


        function handleExpandState(self,operations,expandStates)

            self.AdjustLayout=false;
            for i=1:numel(expandStates)
                expandState=expandStates(i);
                className=expandState.entity;
                entity=self.App.findEntity(className);
                if isempty(entity)
                    return;
                end
                expandClass=isfield(expandState,'expanded')&&expandState.expanded;

                if isfield(expandState,'expanded')
                    operations.setAttributeValue(entity,"collapsed",~expandState.expanded);
                end
                if isfield(expandState,'sections')
                    sectionExpandState=expandState.sections;
                    collapseStruct=struct;
                    sections=string(fields(sectionExpandState));
                    for n=1:numel(sections)
                        section=sections(n);
                        collapseStruct.(section)=~sectionExpandState.(section);
                    end
                    self.handleCollapseMultiSection(operations,entity,collapseStruct,~expandClass);
                end
            end
        end

        function children=getChildren(~,entity)
            children=[];
            for p=entity.ports'
                for c=p.connections'
                    if c.destination.parent==entity
                        if isempty(children)
                            children=c.source.parent;
                        else
                            children(end+1)=c.source.parent;%#ok<AGROW>
                        end
                    end
                end
            end
        end

        function recursivePushPull(self,operations,parent,entity,delta)
            minGap=60;
            children=self.getChildren(entity);

            parentBottom=parent.getPosition.y+parent.getSize.height;
            pos=entity.getPosition;
            if delta<0||entity.getPosition.y<(parentBottom+minGap)
                operations.setPosition(entity,pos.x,pos.y+delta);
                for child=children
                    self.recursivePushPull(operations,entity,child,delta);
                end
            end
        end

        function adjustLayout(self,operations,entities,oldSizes)
            for i=1:numel(entities)
                entity=entities(i);
                oldSize=oldSizes(i);
                delta=entity.getSize.height-oldSize.height;
                children=self.getChildren(entity);
                for child=children
                    self.recursivePushPull(operations,entity,child,delta)
                end
            end
        end

        function handleCollapseClass(self,operations,entities,toCollapse)
            creator=classdiagram.app.core.ElementCreator(self.App,self.UuidToObjectMap);
            oldSizes(1,numel(entities))=diagram.interface.Rect;
            for i=1:numel(entities)
                entity=entities(i);
                oldSizes(i)=entity.getSize();
                self.forceRedrawCounter=self.forceRedrawCounter+1;
                operations.setAttributeValue(entity,"collapsed",toCollapse);
                if isempty(entity.subdiagram.entities)

                    if toCollapse
                        continue;
                    end

                    creator.createClassMembers(operations,Entity=entity);
                end

                lines=entity.subdiagram.entities';
                for iline=1:numel(lines)
                    line=lines(iline);
                    operations.setAttributeValue(line,"collapsed",toCollapse);
                    if(string(line.type)=="subtitle")
                        operations.setAttributeValue(line,"redraw",self.forceRedrawCounter);
                    end
                end
                self.App.reconcileEntityHeight(entity,operations);
            end
            if self.AdjustLayout
                self.adjustLayout(operations,entities,oldSizes);
            end
        end

        function handleCollapseMultiSection(self,operations,entity,collapseStruct,collapseClass)
            if isempty(entity.subdiagram.entities)...
                &&~isempty(collapseClass)&&~collapseClass

                creator=classdiagram.app.core.ElementCreator(self.App,self.UuidToObjectMap);


                [~,linesBySectionName,sectionsByName]=creator.createClassMembers(...
                operations,Entity=entity,toCollapse=~collapseClass);
            else
                [linesBySectionName,sectionsByName]=self.getLinesBySection(entity);
            end
            oldSize=entity.getSize;
            sections=string(fieldnames(collapseStruct));
            expandHeaders=false;
            for n=1:numel(sections)
                section=sections(n);
                if isfield(sectionsByName,section)
                    sectionLine=sectionsByName.(section);
                    lines=linesBySectionName.(section);
                    if~isempty(collapseClass)&&~collapseClass
                        operations.setAttributeValue(entity,"collapsed",false);
                        expandHeaders=true;
                    end
                    self.handleCollapseSection(operations,lines,sectionLine,collapseStruct.(section));
                end
            end
            if expandHeaders
                sections=string(fieldnames(sectionsByName));
                for n=1:numel(sections)
                    section=sections(n);
                    header=sectionsByName.(section);
                    operations.setAttributeValue(header,"collapsed",false);
                end
            end
            self.App.reconcileEntityHeight(entity,operations);
            if self.AdjustLayout
                self.adjustLayout(operations,entity,oldSize);
            end
        end

        function handleCollapseSection(self,operations,lines,header,toCollapse)


            self.forceRedrawCounter=self.forceRedrawCounter+1;
            for iline=1:numel(lines)
                line=lines(iline);
                operations.setAttributeValue(line,"collapsed",toCollapse);
            end
            if~isempty(header)
                if~toCollapse
                    operations.setAttributeValue(header,"collapsed",toCollapse);
                end
                operations.setAttributeValue(header,"redraw",self.forceRedrawCounter);
            end
        end

        function expandClass(self,classNames,toExpand)
            classNames=string(classNames);
            entities=diagram.interface.Entity.empty;
            for i=1:numel(classNames)
                className=classNames(i);
                entity=self.App.findEntity(className);
                if~isempty(entity)
                    entities(end+1)=entity;%#ok<AGROW>
                end
            end
            if isempty(entities)
                return;
            end
            self.App.syntax.modify(@(ops)self.handleCollapseClass(ops,entities,~toExpand));
        end

        function expandSections(self,className,expandStruct)
            expandStruct=self.convertSectionsStruct(expandStruct);
            sections=string(fieldnames(expandStruct));
            entity=self.App.findEntity(className);
            if isempty(entity)||isempty(sections)
                return;
            end
            collapseStruct=struct;
            expandClass=false;
            for n=1:numel(sections)
                section=sections(n);
                collapseStruct.(section)=~expandStruct.(section);
                if expandStruct.(section)
                    expandClass=true;
                end
            end
            self.App.syntax.modify(@(ops)self.handleCollapseMultiSection(ops,entity,collapseStruct,~expandClass));
        end

        function capStruct=convertSectionsStruct(~,sections)


            capStruct=struct;
            fields=string(fieldnames(sections));
            capFields=regexprep(lower(fields),'(\<[a-z])','${upper($1)}');
            for ii=1:numel(fields)
                capStruct.(capFields(ii))=sections.(fields(ii));
            end
        end
    end
end

