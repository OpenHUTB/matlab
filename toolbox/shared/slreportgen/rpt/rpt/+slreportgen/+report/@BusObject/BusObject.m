classdef BusObject<slreportgen.report.Reporter&matlab.mixin.CustomDisplay

























































































    properties(SetAccess=protected)



        Name{mlreportgen.report.validators.mustBeString};
    end

    properties





        Object{mlreportgen.report.validators.mustBeInstanceOfMultiClass(...
        {'slreportgen.finder.ModelVariableResult','Simulink.VariableUsage'},Object)};










        ReportedBusProperties{mlreportgen.report.validators.mustBeVectorOf(["string","char"],ReportedBusProperties)};










        ReportedElementProperties{mlreportgen.report.validators.mustBeVectorOf(["string","char"],ReportedElementProperties)};







        ShowName{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=false;








        ShowHierarchy{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true;








        ShowProperties{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true;








        ShowElements{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true;








        ShowUsedBy{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true;











        ShowUsedBySnapshot{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true;














        CreateSections{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true;








        HierarchyListFormatter{mlreportgen.report.validators.mustBeInstanceOfMultiClass(...
        {'mlreportgen.dom.UnorderedList','mlreportgen.dom.OrderedList'},HierarchyListFormatter)};








        UsedByListFormatter{mlreportgen.report.validators.mustBeInstanceOfMultiClass(...
        {'mlreportgen.dom.UnorderedList','mlreportgen.dom.OrderedList'},UsedByListFormatter)};












        PropertiesTableReporter{mlreportgen.report.validators.mustBeInstanceOf('mlreportgen.report.BaseTable',PropertiesTableReporter)};












        ElementsTableReporter{mlreportgen.report.validators.mustBeInstanceOf('mlreportgen.report.BaseTable',ElementsTableReporter)}



























        HorizontalElementsTable{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=false;











        SectionReporter{mlreportgen.report.validators.mustBeInstanceOf('mlreportgen.report.Section',SectionReporter)};





























        PropertyFilterFcn{mlreportgen.report.validators.mustBeInstanceOfMultiClass({'function_handle','char','string'},PropertyFilterFcn)};
    end

    properties(Access=public,Hidden)

        HierarchyContent=[];
        PropertiesContent=[];
        ElementsContent=[];
        UsedByContent=[];



        Result=[];


        BusValue;



        HashLinkIDs=true;




        VariablesList=[];
    end

    properties(Constant,Access=public,Hidden)

        DefaultBusProperties=[...
"Elements"...
        ,"DataScope"...
        ,"HeaderFile"...
        ,"Alignment"...
        ,"Description"...
        ];


        DefaultBusElementProperties=[...
        "DataType",...
        "Complexity",...
"Dimensions"...
        ,"DimensionsMode",...
        "Min",...
        "Max",...
        "Unit",...
        "Description",...
        ];
    end

    methods
        function this=BusObject(varargin)
            if nargin==1
                varObj=varargin{1};
                varargin={"Object",varObj};
            end

            this=this@slreportgen.report.Reporter(varargin{:});


            if~isempty(this.Object)
                if isa(this.Object,"Simulink.VariableUsage")
                    this.Result=slreportgen.finder.ModelVariableResult(this.Object);
                elseif isa(this.Object,"slreportgen.finder.ModelVariableResult")
                    this.Result=this.Object;
                end

                this.Name=this.Object.Name;
            end


            p=inputParser;




            p.KeepUnmatched=true;




            addParameter(p,"TemplateName","BusObject");

            ul=mlreportgen.dom.UnorderedList();
            ul.StyleName="BusObjectHierarchyList";
            addParameter(p,"HierarchyListFormatter",ul);

            ul=mlreportgen.dom.UnorderedList();
            ul.StyleName="BusObjectUsedByList";
            addParameter(p,"UsedByListFormatter",ul);

            baseTable=mlreportgen.report.BaseTable();
            baseTable.TableStyleName="BusObjectPropertiesTable";
            addParameter(p,"PropertiesTableReporter",baseTable);

            baseTable=mlreportgen.report.BaseTable();
            baseTable.TableStyleName="BusObjectElementsTable";
            addParameter(p,"ElementsTableReporter",baseTable);

            section=mlreportgen.report.Section();
            addParameter(p,"SectionReporter",section);


            parse(p,varargin{:});


            results=p.Results;
            this.TemplateName=results.TemplateName;
            this.HierarchyListFormatter=results.HierarchyListFormatter;
            this.UsedByListFormatter=results.UsedByListFormatter;
            this.PropertiesTableReporter=results.PropertiesTableReporter;
            this.ElementsTableReporter=results.ElementsTableReporter;
            this.SectionReporter=results.SectionReporter;
        end

        function set.Object(this,value)

            mustBeNonempty(value);

            this.Object=value;
        end

        function set.HierarchyListFormatter(this,value)

            mustBeNonempty(value);


            if~isempty(value.Children)
                error(message("slreportgen:report:error:nonemptyListFormatter"));
            end

            this.HierarchyListFormatter=value;
        end

        function set.UsedByListFormatter(this,value)

            mustBeNonempty(value);


            if~isempty(value.Children)
                error(message("slreportgen:report:error:nonemptyListFormatter"));
            end

            this.UsedByListFormatter=value;
        end

        function set.PropertiesTableReporter(this,value)

            mustBeNonempty(value);

            this.PropertiesTableReporter=value;
        end

        function set.ElementsTableReporter(this,value)

            mustBeNonempty(value);

            this.ElementsTableReporter=value;
        end

        function set.SectionReporter(this,value)

            mustBeNonempty(value);

            this.SectionReporter=value;
        end

        function set.BusValue(this,value)

            if~isa(value,"Simulink.Bus")
                error(message("slreportgen:report:error:invalidBusObject"));
            end

            this.BusValue=value;
        end

        function value=get.Name(this)
            if~isempty(this.Object)
                value=string(this.Object.Name);
            else
                value=[];
            end
        end

        function impl=getImpl(this,rpt)
            if isempty(this.Object)

                error(message("slreportgen:report:error:noSourceObjectSpecified",class(this)));
            else

                if~isempty(this.UsedByListFormatter.Children)...
                    ||~isempty(this.HierarchyListFormatter.Children)
                    error(message("slreportgen:report:error:nonemptyListFormatter"));
                end


                if isa(this.Object,"Simulink.VariableUsage")
                    this.Result=slreportgen.finder.ModelVariableResult(this.Object);
                elseif isa(this.Object,"slreportgen.finder.ModelVariableResult")
                    this.Result=this.Object;
                end
                this.Name=string(this.Object.Name);


                this.BusValue=this.Result.getVariableValue();


                if isempty(this.LinkTarget)
                    this.LinkTarget=createBusLinkID(this,this.Name);
                end





                if strcmp(this.Result.SourceType,"base workspace")
                    this.VariablesList=evalin("base","who");
                else

                    sourceDD=Simulink.data.dictionary.open(this.Result.Source);
                    dataSect=getSection(sourceDD,"Design Data");
                    this.VariablesList=evalin(dataSect,"who");
                end



                impl=getImpl@slreportgen.report.Reporter(this,rpt);
            end

        end

    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=slreportgen.report.BusObject.getClassFolder();
            templatePath=...
            mlreportgen.report.ReportForm.getFormTemplatePath(...
            path,rpt.Type);
        end

    end

    methods(Access={?mlreportgen.report.ReportForm,?slreportgen.report.BusObject})

        function content=getNameContent(this,rpt)


            if this.ShowName
                content=mlreportgen.dom.Paragraph(this.Name);
                content.StyleName="BusObjectParagraph";
                content.Bold=true;
            else
                content=[];
            end
        end

        function content=getHierarchyContent(this,rpt)


            if this.ShowHierarchy
                busList=createBusHierarchyList(this,this.Name,this.BusValue,Inf);



                hierarchyStr=getString(message("slreportgen:report:BusObject:hierarchy"));
                content=addSectionOrLabel(this,rpt,hierarchyStr,busList);
            else
                content=[];
            end

            this.HierarchyContent=content;
        end

        function content=getUsedByContent(this,rpt)


            if this.ShowUsedBy
                content={};
                allUsers=this.Result.Users;
                nUsers=numel(allUsers);

                if this.ShowUsedBySnapshot&&nUsers>1
                    content=createUsedByListWithSnapshots(this,rpt,allUsers);
                elseif nUsers==1

                    if this.ShowUsedBySnapshot

                        modelH=slreportgen.utils.getModelHandle(bdroot(allUsers{1}));
                        compileModel(rpt,modelH);
                        content={getUsedBySnapshot(this,rpt,get_param(allUsers{1},"Parent"),allUsers{1})};
                    end

                    content{end+1}=mlreportgen.dom.Paragraph(allUsers{1},"BusObjectParagraph");
                else

                    ul=this.UsedByListFormatter.clone();
                    append(ul,allUsers);
                    content=ul;
                end



                usedByStr=getString(message("slreportgen:report:BusObject:usedBy"));
                content=addSectionOrLabel(this,rpt,usedByStr,content);
            else
                content=[];
            end

            this.UsedByContent=content;
        end

        function content=getPropertiesContent(this,rpt)


            if this.ShowProperties
                busObj=this.BusValue;


                if isempty(this.ReportedBusProperties)

                    allProperties=this.DefaultBusProperties;

                    allProperties=union(allProperties,fieldnames(busObj),"stable");
                else


                    allProperties=intersect(string(this.ReportedBusProperties),fieldnames(busObj),"stable");
                end


                [propVals,isFiltered]=getPropertyValues(this,this.Name,busObj,allProperties);
                propNames=allProperties(~isFiltered);
                propVals=propVals(~isFiltered)';


                t=copy(this.PropertiesTableReporter);
                propertyContent=[num2cell(propNames),propVals];
                if isempty(propertyContent)

                    propertyContent=["",""];
                end
                t.Content=mlreportgen.dom.FormalTable(...
                {getString(message("mlreportgen:report:VariableReporter:property")),...
                getString(message("mlreportgen:report:VariableReporter:value"))},...
                propertyContent);


                cols=mlreportgen.dom.TableColSpecGroup();
                cols.Span=2;
                col1=mlreportgen.dom.TableColSpec();
                col1.Style={mlreportgen.dom.Width("25%")};
                col2=mlreportgen.dom.TableColSpec();
                col2.Style={mlreportgen.dom.Width("75%")};
                cols.ColSpecs=[col1,col2];
                t.Content.ColSpecGroups=cols;
                t.Content.Width="100%";



                propertiesStr=getString(message("slreportgen:report:BusObject:properties"));
                content=addSectionOrLabel(this,rpt,propertiesStr,t);
            else
                content=[];
            end

            this.PropertiesContent=content;
        end

        function content=getElementsContent(this,rpt)


            if this.ShowElements
                busElements=this.BusValue.Elements;



                possibleProps=arrayfun(@(elem)fieldnames(elem)',busElements,"UniformOutput",false);
                possibleProps=unique([possibleProps{:}]);


                possibleProps(strcmp(possibleProps,"Name"))=[];

                if isempty(this.ReportedElementProperties)

                    defaultOrder=this.DefaultBusElementProperties;
                    allProperties=union(defaultOrder,possibleProps,"stable");
                else


                    allProperties=intersect(string(this.ReportedElementProperties),possibleProps,"stable");
                end



                if this.HorizontalElementsTable
                    elementTable=createHorizontalElementsTable(this,busElements,allProperties);
                else
                    elementTable=createVerticalElementsTable(this,busElements,allProperties);
                end

                t=copy(this.ElementsTableReporter);
                t.Content=elementTable;



                elementsStr=getString(message("slreportgen:report:BusObject:elements"));
                content=addSectionOrLabel(this,rpt,elementsStr,t);
            else
                content=[];
            end

            this.ElementsContent=content;
        end

    end

    methods(Access=protected,Hidden)

        result=openImpl(reporter,impl,varargin)
    end


    methods(Static)
        function path=getClassFolder()


            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)








            path=slreportgen.report.BusObject.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classFile=customizeReporter(toClasspath)









            classFile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"slreportgen.report.BusObject");
        end

    end

    methods(Access=private)

        function labeledContent=addSectionOrLabel(this,rpt,labelStr,content)






            if this.CreateSections

                labeledContent=copy(this.SectionReporter);
                switch class(labeledContent.Title)
                case "mlreportgen.report.SectionTitle"
                    sectionTitle=labeledContent.getTitleReporter;
                    sectionTitle.Content={sectionTitle.Content,labelStr};
                    labeledContent.Title=sectionTitle;
                case "mlreportgen.dom.Paragraph"
                    append(labeledContent.Title,labelStr);
                case "double"

                    labeledContent.Title=labelStr;
                otherwise
                    labeledContent.Title={labeledContent.Title,labelStr};
                end
                add(labeledContent,content);
            elseif isa(content,"mlreportgen.report.BaseTable")

                appendTitle(content,labelStr);
                if mlreportgen.report.Reporter.isInlineContent(content.Title)
                    titleReporter=getTitleReporter(content);
                    titleReporter.TemplateSrc=this;

                    if isChapterNumberHierarchical(this,rpt)
                        titleReporter.TemplateName="BusObjectHierNumberedTitle";
                    else
                        titleReporter.TemplateName="BusObjectNumberedTitle";
                    end
                    content.Title=titleReporter;
                end
                labeledContent=content;
            else

                heading=mlreportgen.dom.Paragraph(strcat(labelStr,":"));
                heading.Bold=true;
                heading.StyleName="BusObjectParagraph";
                labeledContent={heading,content};
            end
        end

        function content=createUsedByListWithSnapshots(this,rpt,allUsers)




            content={};


            modelH=slreportgen.utils.getModelHandle(bdroot(allUsers{1}));
            compileModel(rpt,modelH);




            sysUserMap=containers.Map();
            nUsers=numel(allUsers);
            for i=1:nUsers
                user=allUsers(i);


                sys=get_param(user,"Parent");
                if isKey(sysUserMap,sys)

                    sysUserMap(sys)=[sysUserMap(sys),user];
                else

                    sysUserMap(sys)=user;
                end
            end


            systems=keys(sysUserMap);
            nSys=sysUserMap.Count;
            for i=1:nSys
                sys=systems{i};


                sysUsers=sysUserMap(sys);



                content{end+1}=getUsedBySnapshot(this,rpt,sys,sysUsers);


                ul=this.UsedByListFormatter.clone();
                append(ul,sysUsers);
                content{end+1}=ul;
            end
        end

        function content=getUsedBySnapshot(~,rpt,usersParent,users)



            if(strcmp(get_param(usersParent,"Type"),"block")&&~strcmp(get_param(usersParent,"MaskHideContents"),"off"))



                hilite_system(usersParent);
                highlighted=usersParent;
                parent=get_param(highlighted,"Parent");
            else

                hilite_system(users);
                highlighted=users;
                parent=usersParent;
            end

            diag=slreportgen.report.Diagram(parent);
            content=getImpl(diag,rpt);%#ok<*AGROW>


            hilite_system(highlighted,"none");
        end

        function elemTable=createHorizontalElementsTable(this,busElements,allProperties)






            nElements=numel(busElements);
            nProps=numel(allProperties);






            propContainer=cell(nElements,nProps+1);
            filteredProps=false(nElements,nProps);

            for elemIdx=1:nElements

                busElement=busElements(elemIdx);
                busElementName=busElement.Name;


                busElementID=createBusElementLinkID(this,this.Name,busElementName);
                busElementLinkTarget=mlreportgen.dom.LinkTarget(busElementID);
                busElementPara=mlreportgen.dom.Paragraph(busElementName);
                append(busElementPara,busElementLinkTarget);



                [propVals,isFiltered]=getPropertyValues(this,busElementName,busElement,allProperties);


                propContainer(elemIdx,:)=[{busElementPara},propVals];
                filteredProps(elemIdx,:)=isFiltered;
            end



            keep=~all(filteredProps);
            propVals=["Name",allProperties(keep)];
            propContainer=propContainer(:,[true,keep]);
            elemTable=mlreportgen.dom.FormalTable(propVals,propContainer);
        end

        function elemTable=createVerticalElementsTable(this,busElements,allProperties)





            elemTable=mlreportgen.dom.FormalTable(3);

            title=mlreportgen.dom.TableRow;
            te=mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:BusObject:element")));
            append(title,te);
            te=mlreportgen.dom.TableHeaderEntry(getString(message("mlreportgen:report:VariableReporter:property")));
            append(title,te);
            te=mlreportgen.dom.TableHeaderEntry(getString(message("mlreportgen:report:VariableReporter:value")));
            append(title,te);
            append(elemTable.Header,title);



            grps=mlreportgen.dom.TableColSpecGroup();
            grps.Span=3;
            specs1=mlreportgen.dom.TableColSpec();
            specs1.Style={mlreportgen.dom.Width("25%")};
            specs2=mlreportgen.dom.TableColSpec();
            specs2.Style={mlreportgen.dom.Width("25%")};
            specs3=mlreportgen.dom.TableColSpec();
            specs3.Style={mlreportgen.dom.Width("50%")};
            grps.ColSpecs=[specs1,specs2,specs3];
            elemTable.ColSpecGroups=grps;

            elemTable.Width="100%";


            nElements=numel(busElements);
            for elemIdx=1:nElements

                busElement=busElements(elemIdx);
                busElementName=busElement.Name;


                busElementID=createBusElementLinkID(this,this.Name,busElementName);
                busElementLinkTarget=mlreportgen.dom.LinkTarget(busElementID);
                busElementPara=mlreportgen.dom.Paragraph(busElementName);
                append(busElementPara,busElementLinkTarget);



                [propVals,isFiltered]=getPropertyValues(this,busElementName,busElement,allProperties);

                propNames=allProperties(~isFiltered);
                propVals=propVals(~isFiltered);
                nProperties=numel(propVals);


                row=mlreportgen.dom.TableRow();


                busElementEntry=mlreportgen.dom.TableEntry();
                append(busElementEntry,busElementPara);
                busElementEntry.VAlign="middle";

                if nProperties>0


                    busElementEntry.RowSpan=nProperties;

                    append(row,busElementEntry);
                else


                    append(row,busElementEntry);
                    append(row,mlreportgen.dom.TableEntry(""));
                    append(row,mlreportgen.dom.TableEntry(""));
                    append(elemTable.Body,row);
                end


                for propIdx=1:nProperties



                    if isempty(row)
                        row=mlreportgen.dom.TableRow();
                    end


                    propNameEntry=mlreportgen.dom.TableEntry(propNames(propIdx));
                    propValueEntry=mlreportgen.dom.TableEntry();
                    append(propValueEntry,propVals{propIdx});


                    append(row,propNameEntry);
                    append(row,propValueEntry);


                    append(elemTable.Body,row);


                    row=[];
                end
            end
        end

        function[vals,isFiltered]=getPropertyValues(this,name,obj,allProperties)





            nProps=numel(allProperties);
            vals=cell(1,nProps);
            isFiltered=false(1,nProps);
            for propIdx=1:nProps
                propName=allProperties(propIdx);
                if~isFilteredProperty(this,name,obj,propName)
                    propVal=obj.(propName);
                    propStr=mlreportgen.utils.toString(propVal);
                    if strcmp(propName,"DataType")
                        dataType=strtrim(erase(propStr,"Bus:"));
                        [isBus,~,~]=extractDataTypeInfo(this,dataType);
                        if isBus


                            busID=createBusLinkID(this,dataType);
                            propStr=mlreportgen.dom.InternalLink(busID,propStr);
                        end
                    elseif isa(propVal,"Simulink.BusElement")


                        propStr=createBusHierarchyList(this,this.Name,this.BusValue,0);
                    end
                    vals{propIdx}=propStr;
                else
                    vals{propIdx}="";
                    isFiltered(propIdx)=true;
                end
            end
        end

        function isFiltered=isFilteredProperty(this,varName,variableObject,propName)




            isFiltered=false;
            filterFcn=this.PropertyFilterFcn;


            variableName=string(varName);
            propertyName=string(propName);


            if~isprop(variableObject,propertyName)
                isFiltered=true;
            elseif~isempty(filterFcn)

                try
                    if isa(filterFcn,"function_handle")
                        isFiltered=filterFcn(variableName,variableObject,propertyName);
                    else
                        eval(filterFcn);
                    end
                catch me
                    warning(message("mlreportgen:report:warning:filterFcnError","PropertyFilterFcn",me.message));
                end
            end
        end

        function id=createBusElementLinkID(this,busName,busElement)



            id=compose("bus-element-%s-%s",busName,busElement);
            if this.HashLinkIDs
                id=mlreportgen.utils.normalizeLinkID(id);
            end
        end

        function id=createBusLinkID(this,busName)



            id=compose("bus-%s",busName);
            if this.HashLinkIDs
                id=mlreportgen.utils.normalizeLinkID(id);
            end
        end

        function list=createBusHierarchyList(this,busName,busObj,depth)






            list=this.HierarchyListFormatter.clone();


            nBusElements=numel(busObj.Elements);
            for i=1:nBusElements
                busElement=busObj.Elements(i);
                busElementName=busElement.Name;


                listItem=mlreportgen.dom.ListItem();


                busElementID=createBusElementLinkID(this,busName,busElementName);




                busElementType=strtrim(erase(busElement.DataType,"Bus:"));
                [isBus,newBusResult,newBusResultValue]=extractDataTypeInfo(this,busElementType);



                if isBus
                    label=compose("%s (%s)",busElementName,busElementType);
                    if this.ShowElements

                        internalLink=mlreportgen.dom.InternalLink(busElementID,label);
                        append(listItem,internalLink);
                    else
                        append(listItem,label);
                    end
                    append(list,listItem);


                    if(depth>0)


                        sublist=createBusHierarchyList(this,newBusResult.Name,newBusResultValue,depth-1);
                        append(list,sublist);
                    end
                else

                    if this.ShowElements
                        internalLink=mlreportgen.dom.InternalLink(busElementID,busElementName);
                        append(listItem,internalLink);
                    else
                        append(listItem,busElementName);
                    end
                    append(list,listItem);
                end

            end
        end

        function[isBus,newResult,newVal]=extractDataTypeInfo(this,dataType)



            isBus=false;
            newResult=[];
            newVal=[];

            if ismember(dataType,this.VariablesList)


                newVarUsage=Simulink.VariableUsage(dataType,this.Result.Source);
                newResult=slreportgen.finder.ModelVariableResult(newVarUsage);
                newVal=getVariableValue(newResult);
                if isa(newVal,"Simulink.Bus")
                    isBus=true;
                end
            end

        end

    end

end