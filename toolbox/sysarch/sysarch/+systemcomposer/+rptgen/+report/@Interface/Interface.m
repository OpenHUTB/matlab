classdef Interface<slreportgen.report.Reporter





























































    properties

Source









Elements










PortsUsage





        IncludeElements{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true;






        IncludePortsUsage{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true;
    end

    methods(Static,Access=private)
        function interfaceElementsTable=createTableForInterfaceElements()

            import mlreportgen.dom.*
            [interfaceElementsTable,rowForHeader]=systemcomposer.rptgen.report.Interface.createTableWithProperties();
            Name=TableEntry(message('SystemArchitecture:ReportGenerator:Name').getString);
            Type=TableEntry(message('SystemArchitecture:ReportGenerator:Type').getString);
            Description=TableEntry(message('SystemArchitecture:ReportGenerator:Description').getString);
            Complexity=TableEntry(message('SystemArchitecture:ReportGenerator:Complexity').getString);
            Dimensions=TableEntry(message('SystemArchitecture:ReportGenerator:Dimensions').getString);
            Maximum=TableEntry(message('SystemArchitecture:ReportGenerator:Maximum').getString);
            Minimum=TableEntry(message('SystemArchitecture:ReportGenerator:Minimum').getString);
            append(rowForHeader,Name);
            append(rowForHeader,Type);
            append(rowForHeader,Description);
            append(rowForHeader,Complexity);
            append(rowForHeader,Dimensions);
            append(rowForHeader,Maximum);
            append(rowForHeader,Minimum);
        end

        function physicalInterfaceElementsTable=createTableForPhysicalInterfaceElements()
            import mlreportgen.dom.*
            [physicalInterfaceElementsTable,rowForHeader]=systemcomposer.rptgen.report.Interface.createTableWithProperties();
            Name=TableEntry(message('SystemArchitecture:ReportGenerator:Name').getString);
            Domain=TableEntry(message('SystemArchitecture:ReportGenerator:Domain').getString);
            append(rowForHeader,Name);
            append(rowForHeader,Domain);
        end

        function serviceInterfaceElementsTable=createTableForServiceInterfaceElements()
            import mlreportgen.dom.*
            [serviceInterfaceElementsTable,rowForHeader]=systemcomposer.rptgen.report.Interface.createTableWithProperties();
            Name=TableEntry(message('SystemArchitecture:ReportGenerator:Name').getString);
            FunctionPrototype=TableEntry(message('SystemArchitecture:ReportGenerator:FunctionPrototype').getString);
            append(rowForHeader,Name);
            append(rowForHeader,FunctionPrototype);
        end

        function interfaceArgumentsTable=createTableForInterfaceArguments()
            import mlreportgen.dom.*
            [interfaceArgumentsTable,rowForHeader]=systemcomposer.rptgen.report.Interface.createTableWithProperties();
            Name=TableEntry(message('SystemArchitecture:ReportGenerator:Name').getString);
            Type=TableEntry(message('SystemArchitecture:ReportGenerator:Type').getString);
            Description=TableEntry(message('SystemArchitecture:ReportGenerator:Description').getString);
            Dimensions=TableEntry(message('SystemArchitecture:ReportGenerator:Dimensions').getString);
            append(rowForHeader,Name);
            append(rowForHeader,Type);
            append(rowForHeader,Description);
            append(rowForHeader,Dimensions);
        end

        function portsUsageTable=createTableForPortsUsage()

            import mlreportgen.dom.*
            [portsUsageTable,rowForHeader]=systemcomposer.rptgen.report.Interface.createTableWithProperties();
            Interface=TableEntry(message('SystemArchitecture:ReportGenerator:Interface').getString);
            PortName=TableEntry(message('SystemArchitecture:ReportGenerator:PortName').getString);
            Direction=TableEntry(message('SystemArchitecture:ReportGenerator:Direction').getString);
            append(rowForHeader,Interface);
            append(rowForHeader,PortName);
            append(rowForHeader,Direction);
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

        function assignedPortsTable=createAssignedPortsTable(this)
            import mlreportgen.dom.*
            import mlreportgen.utils.*
            assignedPortsTable=[];
            ports=this.Source.Ports;
            if~isempty(fieldnames(ports))
                assignedPortsTable=systemcomposer.rptgen.report.Interface.createTableForPortsUsage();
                for port=ports
                    row=TableRow();
                    Name=TableEntry(string(port.InterfaceName));
                    append(row,Name);
                    fullNamesForPort=[];
                    for i=1:length(port.PortName)
                        fullNamesForPort=[fullNamesForPort;port.FullPortName(i)];%#ok<*AGROW>
                    end
                    Type=TableEntry();
                    for i=1:length(fullNamesForPort)


                        append(Type,string(fullNamesForPort(i)));
                    end
                    append(row,Type);
                    Description=TableEntry(string(port.Direction));
                    append(row,Description);
                    append(assignedPortsTable,row);
                end
            end
        end

        function interfaceElementsTable=createInterfaceElementsTable(this)
            import mlreportgen.dom.*
            import mlreportgen.utils.*
            interfaceElementsTable=[];
            interface=this.Source;
            if~isempty(fieldnames(interface.Elements))
                if length(fieldnames(interface.Elements))==7
                    interfaceElementsTable=systemcomposer.rptgen.report.Interface.createTableForInterfaceElements();
                    for element=interface.Elements
                        row=TableRow();
                        Name=TableEntry(string(element.Name));
                        append(row,Name);
                        if isfield(element,'Type')
                            Type=TableEntry();
                            typeOfElement=split(string(element.Type),":");
                            if length(typeOfElement)>1
                                append(Type,typeOfElement(2));
                                append(row,Type);
                            else
                                Type=TableEntry(string(element.Type));
                                append(row,Type);
                            end
                        elseif isfield(element,'DataType')
                            DataType=TableEntry(string(element.DataType));
                            append(row,DataType);
                        end
                        emptyEntry=TableEntry("-");
                        if isempty(element.Description)
                            Description=clone(emptyEntry);
                        else
                            Description=TableEntry(string(element.Description));
                        end
                        append(row,Description);
                        if~isempty(element.Complexity)
                            Complexity=TableEntry(string(element.Complexity));
                        else
                            Complexity=clone(emptyEntry);
                        end
                        append(row,Complexity);
                        if~isempty(element.Dimensions)
                            Dimensions=TableEntry(string(element.Dimensions));
                        else
                            Dimensions=clone(emptyEntry);
                        end
                        append(row,Dimensions);
                        if~isempty(element.Maximum)
                            Maximum=TableEntry(string(element.Maximum));
                        else
                            Maximum=clone(emptyEntry);
                        end
                        append(row,Maximum);
                        if~isempty(element.Minimum)
                            Minimum=TableEntry(string(element.Minimum));
                        else
                            Minimum=clone(emptyEntry);
                        end
                        append(row,Minimum);
                        append(interfaceElementsTable,row);
                    end
                elseif length(fieldnames(interface.Elements))==3
                    interfaceElementsTable=systemcomposer.rptgen.report.Interface.createTableForInterfaceElements();
                    ElementsTable=systemcomposer.rptgen.report.Interface.createTableForServiceInterfaceElements();
                    ArgumentsTable=systemcomposer.rptgen.report.Interface.createTableForInterfaceArguments();
                    for element=interface.Elements
                        row=TableRow();
                        Name=TableEntry(string(element.Name));
                        append(row,Name);
                        FunctionPrototype=TableEntry(string(element.FunctionPrototype));
                        append(row,FunctionPrototype);
                        append(ElementsTable,row);

                        arguments=element.FunctionArguments;
                        for arg=arguments
                            argRow=TableRow();
                            Name=TableEntry(string(arg.Name));
                            append(argRow,Name);
                            Type=TableEntry(string(arg.Type));
                            append(argRow,Type);
                            Dimensions=TableEntry(string(arg.Dimensions));
                            append(argRow,Dimensions);
                            Description=TableEntry(string(arg.Description));
                            append(argRow,Description);
                            append(ArgumentsTable,argRow);
                        end
                    end

                    ArgumentsTable=mlreportgen.report.BaseTable(ArgumentsTable);
                    ArgumentsTable.Title="Function Arguments";
                    interfaceElementsTable={ElementsTable;mlreportgen.dom.Paragraph("");ArgumentsTable.Title;ArgumentsTable.Content};
                elseif length(fieldnames(interface.Elements))==2
                    interfaceElementsTable=systemcomposer.rptgen.report.Interface.createTableForPhysicalInterfaceElements();
                    for element=interface.Elements
                        row=TableRow();
                        Name=TableEntry(string(element.Name));
                        append(row,Name);
                        Domain=TableEntry(string(element.Domain));
                        append(row,Domain);
                        append(interfaceElementsTable,row);
                    end
                end
            end
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.report.Interface})
        function t=getElements(f,~)

            import mlreportgen.dom.*
            import mlreportgen.utils.*


            t=mlreportgen.report.BaseTable();
            if(f.IncludeElements)
                t=copy(f.Elements);
                table=systemcomposer.rptgen.report.Interface.createInterfaceElementsTable(f);
                if~isempty(table)
                    t.Title="Elements";
                    t.Content=table;
                end
                t.LinkTarget=systemcomposer.rptgen.utils.getObjectID(f.Source);
                appendTitle(t,LinkTarget(t.LinkTarget));
            end
        end

        function t=getPortsUsage(f,~)



            t=mlreportgen.report.BaseTable();
            if(f.IncludePortsUsage)
                t=copy(f.PortsUsage);
                table=systemcomposer.rptgen.report.Interface.createAssignedPortsTable(f);
                if~isempty(table)
                    t.Title="Assigned Ports";
                    t.Content=table;
                end
            end
        end
    end

    methods
        function this=Interface(varargin)
            if nargin==1

                varargin=["Source",varargin];
            end
            this=this@slreportgen.report.Reporter(varargin{:});
            this.Elements=mlreportgen.report.BaseTable;
            this.Elements.TableStyleName="ElementsTable";
            this.PortsUsage=mlreportgen.report.BaseTable;
            this.PortsUsage.TableStyleName="PortsUsageTable";
            this.TemplateName="Interface";
        end
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=systemcomposer.rptgen.report.Interface.getClassFolder();
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
            path=systemcomposer.rptgen.report.Interface.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end
        function classfile=customizeReporter(toClasspath)
            classfile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"systemcomposer.rptgen.report.Interface");
        end
    end
end