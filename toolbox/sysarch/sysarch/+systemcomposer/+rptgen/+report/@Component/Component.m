classdef Component<slreportgen.report.Reporter







































































    properties

Source








Snapshot









Properties










Stereotypes









Ports









Functions

Children









Description





        IncludeSnapshot{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true






        IncludeProperties{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true






        IncludeStereotypes{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true






        IncludeChildren{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true






        IncludeFunctions{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true






        IncludePorts{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true






        IncludeDescription{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true
    end

    methods(Static,Access=private)
        function componentInformationTable=createTableForComponentInformation()

            import mlreportgen.dom.*
            [componentInformationTable,rowForHeader]=systemcomposer.rptgen.report.Component.createTableWithProperties();
            Parent=TableEntry(message('SystemArchitecture:ReportGenerator:Parent').getString);
            ReferenceName=TableEntry(message('SystemArchitecture:ReportGenerator:ReferencedModel').getString);
            Type=TableEntry(message('SystemArchitecture:ReportGenerator:ChildComponents').getString);
            Kind=TableEntry(message('SystemArchitecture:ReportGenerator:Kind').getString);
            append(rowForHeader,Parent);
            append(rowForHeader,Kind);
            append(rowForHeader,ReferenceName);
            append(rowForHeader,Type);
        end

        function tempStereotypeTable=createTableForStereotypesInformation()
            import mlreportgen.dom.*
            [tempStereotypeTable,rowForHeader]=systemcomposer.rptgen.report.Component.createTableWithProperties();
            Stereotype=TableEntry(message('SystemArchitecture:ReportGenerator:Stereotype').getString);
            Properties=TableEntry(message('SystemArchitecture:ReportGenerator:Property').getString);
            Value=TableEntry(message('SystemArchitecture:ReportGenerator:Value').getString);
            append(rowForHeader,Stereotype);
            append(rowForHeader,Properties);
            append(rowForHeader,Value);
        end

        function portInformationTable=createTableForPortInformation()

            import mlreportgen.dom.*
            [portInformationTable,rowForHeader]=systemcomposer.rptgen.report.Component.createTableWithProperties();
            Name=TableEntry(message('SystemArchitecture:ReportGenerator:Name').getString);
            Direction=TableEntry(message('SystemArchitecture:ReportGenerator:Direction').getString);
            Interface=TableEntry(message('SystemArchitecture:ReportGenerator:Interface').getString);
            append(rowForHeader,Name);
            append(rowForHeader,Direction);
            append(rowForHeader,Interface);
        end

        function[table,rowForHeader]=createTableWithProperties()

            import mlreportgen.dom.*;
            table=FormalTable();
            table.Style=[table.Style,{Border('single'),Width('100%'),RowSep('single'),ColSep('single'),FontFamily('Calibri')}];
            table.TableEntriesStyle={HAlign('center')};
            rowForHeader=TableRow();
            tableHeader=append(table,rowForHeader);
            tableHeader.Style=[tableHeader.Style,{InnerMargin("2pt","2pt","2pt","2pt"),BackgroundColor("lightgray"),Bold(true)}];
        end

        function componentInformationTable=createLinkedTableForComponent(this,f,rpt)
            import mlreportgen.report.*
            import mlreportgen.dom.*
            import slreportgen.report.*;
            import mlreportgen.utils.*
            import systemcomposer.query.Property;
            componentInformationTable=systemcomposer.rptgen.report.Component.createTableForComponentInformation();
            row=TableRow();
            if strcmp(this.Parent,"-")
                Parent=TableEntry("-");
            else
                Parent=TableEntry(string(this.Parent));
            end


            append(row,Parent);
            if~isempty(f.Kind)
                Kind=TableEntry(string(f.Kind));
            else
                Kind=TableEntry("-");
            end
            append(row,Kind);
            ReferenceName=TableEntry();
            if this.ReferenceName==categorical(cellstr('none'))
                append(ReferenceName,"-");
            else
                append(ReferenceName,string(this.ReferenceName));
            end
            append(row,ReferenceName);
            Subcomponent=TableEntry();
            Subcomponent.Border='single';
            n=length(this.SubComponents);
            for i=1:n
                if(this.SubComponents(i)==categorical(cellstr('none')))
                    append(Subcomponent,"-");
                else
                    cf=systemcomposer.rptgen.finder.ComponentFinder(f.ModelName);
                    cf.Query=contains(systemcomposer.query.Property('Name'),this.SubComponents(i));
                    result=find(cf);
                    link=systemcomposer.rptgen.utils.getObjectID(result);
                    context=getContext(rpt,this.SubComponents(i));
                    if~isempty(context)
                        append(Subcomponent,InternalLink(link,string(this.SubComponents(i))));
                    else
                        append(Subcomponent,string(this.SubComponents(i)));
                    end


                end
            end
            append(row,Subcomponent);
            append(componentInformationTable,row);
        end

        function portStruct=createPortStruct(this)




            ports=this.Ports;
            portStruct=[];
            if~isempty(ports)
                for i=1:length(ports)
                    portStruct(i).obj=ports(i).UUID;
                    portStruct(i).Name=string(ports(i).Name);
                    portStruct(i).Direction=string(ports(i).Direction);
                    if isempty(ports(i).InterfaceName)
                        portStruct(i).Interface="none";
                    else
                        portStruct(i).Interface=string(ports(i).InterfaceName);
                    end
                    if isa(ports(i).Interface,"systemcomposer.ValueType")

                        if ports(i).Interface.getImpl.isAnonymous
                            anonymousInterfaceStruct=["Owned Interface";...
                            "Type - "+ports(i).Interface.DataType;
                            "Dimensions - "+ports(i).Interface.Dimensions;
                            "Description - "+ports(i).Interface.Description;
                            "Complexity - "+ports(i).Interface.Complexity];
                            portStruct(i).Interface=categorical(anonymousInterfaceStruct);
                        end
                    end
                end
            end
        end

        function portsTable=createPortsTable(this)
            import mlreportgen.dom.*
            import mlreportgen.utils.*
            import systemcomposer.rptgen.report.utils.*
            portsTable=[];
            portStruct=systemcomposer.rptgen.report.Component.createPortStruct(this);
            if~isempty(portStruct)
                portsTable=systemcomposer.rptgen.report.Component.createTableForPortInformation();
                for portEntry=portStruct
                    row=TableRow;
                    Name=TableEntry();
                    append(Name,string(portEntry.Name));
                    append(row,Name);
                    Direction=TableEntry();
                    append(Direction,string(portEntry.Direction));
                    append(row,Direction);
                    Interface=TableEntry();
                    if(string(portEntry.Interface)=="none")
                        append(Interface,"-");
                    else
                        if length(portEntry.Interface)==1
                            intf=systemcomposer.rptgen.finder.InterfaceFinder(this.ModelName);
                            intf.Filter=portEntry.Interface;
                            result=find(intf);
                            linkID=systemcomposer.rptgen.utils.getObjectID(result);
                            append(Interface,InternalLink(linkID,string(portEntry.Interface)));
                        else
                            interfacesList=[portEntry.Interface];
                            for i=1:length(interfacesList)
                                append(Interface,string(interfacesList(i)));
                            end
                        end
                    end
                    append(row,Interface);
                    append(portsTable,row);
                end
            end
        end

        function[componentInformationTable,childInformationTable]=createComponentInformationTableFromStruct(this,rpt)
            import systemcomposer.rptgen.finder.*
            component=this;
            componentInformationStruct.Parent=categorical(cellstr(component.Parent));
            ports=[];
            if isempty(component.Ports)
                ports=categorical(cellstr('none'));
            else
                for port=component.Ports
                    ports=[ports;string(port.Name)];%#ok<*AGROW>
                end
            end
            componentInformationStruct.Ports=ports;
            children=[];
            if isempty(component.Children)
                children=categorical(cellstr('none'));
            else
                for child=component.Children
                    children=[children;child.Name];
                end
            end
            componentInformationStruct.SubComponents=children;
            if~strcmp(component.ReferenceName,"")
                componentInformationStruct.ReferenceName=categorical(cellstr(component.ReferenceName));
            else
                componentInformationStruct.ReferenceName=categorical(cellstr('none'));
            end
            componentInformationTable=systemcomposer.rptgen.report.Component.createLinkedTableForComponent(componentInformationStruct,this,rpt);
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.report.Component})
        function table=getProperties(f,rpt)

            import mlreportgen.utils.*
            import mlreportgen.dom.*


            table=mlreportgen.report.BaseTable();
            if(f.IncludeProperties)
                table=copy(f.Properties);
                formalTable=systemcomposer.rptgen.report.Component.createComponentInformationTableFromStruct(f.Source,rpt);
                if~isempty(formalTable)
                    table.Content=formalTable;
                    table.Title="Properties";
                end

                table.LinkTarget=systemcomposer.rptgen.utils.getObjectID(f.Source);
                appendTitle(table,LinkTarget(table.LinkTarget));

                allocationLink=mlreportgen.utils.normalizeLinkID(f.Source.FullName);
                appendTitle(table,LinkTarget(allocationLink));
            end
        end

        function table=getPorts(f,~)

            import mlreportgen.utils.*
            import mlreportgen.dom.*


            table=mlreportgen.report.BaseTable();
            if(f.IncludePorts)
                table=copy(f.Ports);
                formalTable=systemcomposer.rptgen.report.Component.createPortsTable(f.Source);
                if~isempty(formalTable)
                    table.Content=formalTable;
                    table.Title="Ports";
                end
            end
        end

        function description=getDescription(f,~)

            import mlreportgen.utils.*
            import mlreportgen.dom.*


            desc=f.Description;
            title=mlreportgen.dom.Paragraph("Description");
            title.Bold=1;
            if(f.IncludeDescription)
                comp=f.Source;
                if~isempty(comp.Description)
                    desc=comp.Description;
                    description={mlreportgen.dom.Paragraph(" "),title,desc};
                else
                    description={};
                end
            end
        end

        function[heading,children]=getChildren(f,~)
            children=[];
            if(f.IncludeChildren)
                if~isempty(f.Source)s
                    if~isempty(f.Source.Children)
                        childrenInformation=[];
                        for child=f.Source.Children
                            heading=Paragraph(child.Name);
                            childrenInformation=[childrenInformation,systemcomposer.rptgen.report.Component("Source",child)];
                        end
                        children=childrenInformation;
                    end
                end
            end
        end

        function diagram=getSnapshot(f,~)



            import slreportgen.report.*;
            import mlreportgen.report.*
            import mlreportgen.dom.*
            import systemcomposer.rptgen.finder.*
            diagram=[];
            if f.IncludeSnapshot
                diagram=copy(f.Snapshot);
                component=f.Source;
                modelName=f.Source.ModelName;
                isAutosarModel=strcmpi(get_param(modelName,'SimulinkSubDomain'),'AUTOSARArchitecture');
                if(isAutosarModel)
                    arch=autosar.arch.loadModel(modelName);
                else
                    arch=systemcomposer.loadModel(modelName);
                end



                componentFullPath=string(find_system(modelName,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'Name',component.Name));
                componentFullPath=componentFullPath(componentFullPath==component.FullName);



                fOpts=Simulink.FindOptions('MatchFilter',@Sldv.utils.findBSWServiceComponentBlks,...
                'IncludeCommented',false,'FollowLinks',true);
                serviceComponentHandles=Simulink.findBlocksOfType(modelName,'SubSystem',fOpts);
                currentComponentHandles=get_param(componentFullPath,'handle');
                if iscell(currentComponentHandles)
                    currentComponentHandles=cell2mat(get_param(componentFullPath,'handle'));
                end

                if~isempty(componentFullPath)&&isempty(intersect(serviceComponentHandles,currentComponentHandles))
                    if(~isAutosarModel)
                        componentObj=lookup(arch,'Path',componentFullPath);
                        if isa(componentObj,'systemcomposer.arch.VariantComponent')
                            activeChoice=getActiveChoice(componentObj);
                            componentFullPath=string(getfullname(activeChoice.SimulinkHandle));
                        end
                    end
                    n=length(string(componentFullPath));
                    for j=1:n
                        if n>1

                            diagram.Source=string(componentFullPath(j));
                        else
                            diagram.Source=string(componentFullPath);
                        end
                        diagram.Snapshot.Caption=string(component.Name);
                    end
                else
                    diagram=[];
                end
            end
        end

        function functionsTable=getFunctions(f,~)
            import mlreportgen.report.*
            import slreportgen.report.*
            import slreportgen.finder.*
            import mlreportgen.dom.*
            import mlreportgen.utils.*
            import systemcomposer.query.Property;
            functionsTable=copy(f.Functions);
            modelName=f.Source.ModelName;
            modelHandle=load_system(modelName);
            isSWArch=Simulink.internal.isArchitectureModel(modelHandle,'SoftwareArchitecture');
            if isSWArch
                if f.IncludeFunctions
                    ff=systemcomposer.rptgen.finder.FunctionFinder(f.Source.ModelName);
                    ff.ComponentName=f.Source.Name;
                    result=find(ff);
                    functionsTable=systemcomposer.rptgen.report.Function("Source",result);
                end
            end
        end

        function stereotypesTable=getStereotypes(f,~)

            import mlreportgen.report.*
            import slreportgen.report.*
            import slreportgen.finder.*
            import mlreportgen.dom.*
            import mlreportgen.utils.*
            import systemcomposer.query.Property;
            stereotypesTable=[];


            modelHandle=load_system(f.Source.ModelName);
            isARM=Simulink.internal.isArchitectureModel(modelHandle,"AUTOSARArchitecture");
            if~isARM
                if(f.IncludeStereotypes)
                    comp=f.Source;

                    constraint=contains(systemcomposer.query.Property('Name'),comp.Name);
                    model=systemcomposer.loadModel(f.Source.ModelName);
                    [~,components]=find(model,constraint);
                    component="";
                    for c=components
                        if strcmp(comp.Parent,c.Parent.Name)
                            component=c;
                        end
                    end
                    stereotypes=component.getStereotypes;
                    stereotypesTable=copy(f.Stereotypes);
                    allStereotypes=[];
                    for x=stereotypes
                        allStereotypes=[allStereotypes,x];
                    end
                    uniqueStereotypes=unique(allStereotypes);
                    stereotypeProperties=[component.getStereotypeProperties];
                    PropertyValues=[];
                    for j=1:length(stereotypeProperties)
                        PropertyValues=[PropertyValues,string(component.getPropertyValue(stereotypeProperties(j)))];
                    end

                    tempStereotypeTable=systemcomposer.rptgen.report.Component.createTableForStereotypesInformation();

                    if~isempty(uniqueStereotypes)
                        for st=uniqueStereotypes
                            profilesInModel=systemcomposer.loadModel(f.Source.ModelName).Profiles;
                            profileNames=[];
                            for p=profilesInModel
                                profileNames=[profileNames,string(p.Name)];
                            end
                            for profile=profileNames
                                row=TableRow();
                                stereotypeEntry=TableEntry();
                                pf=systemcomposer.rptgen.finder.ProfileFinder(profile);
                                result=find(pf);
                                linkID=systemcomposer.rptgen.utils.getObjectID(result);
                                append(stereotypeEntry,InternalLink(linkID,string(st)));
                                append(row,stereotypeEntry);

                                propertyEntry=TableEntry();
                                for propNames=stereotypeProperties
                                    append(propertyEntry,propNames);
                                end
                                append(row,propertyEntry);

                                valueEntry=TableEntry();
                                for values=PropertyValues
                                    if(values=="")
                                        append(valueEntry,"-");
                                    else
                                        append(valueEntry,values);
                                    end
                                end
                                append(row,valueEntry);
                            end
                            append(tempStereotypeTable,row);
                        end
                        if~isempty(tempStereotypeTable)
                            stereotypesTable.Content=tempStereotypeTable;
                            stereotypesTable.Title="Stereotypes";
                        end
                    end
                end
            end
        end
    end

    methods
        function this=Component(varargin)
            if nargin==1

                varargin=["Source",varargin];
            end
            this=this@slreportgen.report.Reporter(varargin{:});
            this.Snapshot=slreportgen.report.Diagram();
            this.Description=mlreportgen.dom.Paragraph();
            this.Properties=mlreportgen.report.BaseTable;
            this.Properties.TableStyleName="AboutTable";
            this.Ports=mlreportgen.report.BaseTable;
            this.Ports.TableStyleName="Ports in Component";
            this.Stereotypes=mlreportgen.report.BaseTable;
            this.Stereotypes.TableStyleName="Stereotypes in Component";
            this.Functions=mlreportgen.report.BaseTable;
            this.Functions.TableStyleName="Functions on Component";
            this.Children=[];
            this.TemplateName="Component";
        end

        function impl=getImpl(this,rpt)
            for comp=this.Source
                setContext(rpt,comp.Name,this);
                children=comp.Children;
                for c=children
                    setContext(rpt,c.Name,this)
                end
            end
            impl=getImpl@slreportgen.report.Reporter(this,rpt);
        end
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=systemcomposer.rptgen.report.Component.getClassFolder();
            templatePath=...
            mlreportgen.report.ReportForm.getFormTemplatePath(...
            path,rpt.Type);
        end
    end

    methods(Access=protected,Hidden)
        result=openImpl(rpt,impl,varargin)
    end

    methods(Static)
        function path=getClassFolder()
            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)
            path=systemcomposer.rptgen.report.Component.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)
            classfile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"systemcomposer.rptgen.report.Component");
        end
    end
end