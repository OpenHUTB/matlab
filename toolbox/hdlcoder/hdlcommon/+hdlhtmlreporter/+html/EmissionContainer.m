


classdef EmissionContainer<handle
    properties
        groupCssStyleMap=containers.Map;
groupCssStyles

activeSection
sectionStack
    end

    methods
        function obj=EmissionContainer(activeSection)
            if nargin<1
                obj.activeSection='';
            else
                obj.activeSection=activeSection;
            end

            obj.sectionStack=hdlhtmlreporter.html.SectionStack;
            obj.sectionStack.push(obj.activeSection);
            obj.groupCssStyleMap=containers.Map;
            obj.groupCssStyles={};
        end

        function table=createTable(~,numRows,numCols,hasHeading,cssStyles,id)
            if nargin<6
                id='';
            end
            if nargin<5
                cssStyles={};
            end
            if nargin<4
                hasHeading=false;
            end

            table=hdlhtmlreporter.html.Table(numRows,numCols,hasHeading,id,cssStyles);
        end

        function commitTable(obj,tableEmissionContainer)
            tableEmissionContainer.commitTable;

            table=tableEmissionContainer.getTableElement;
            if~isempty(obj.activeSection)
                obj.activeSection.addElement(table);



                tableGroupCssStyle=tableEmissionContainer.groupCssStyles;
                obj.processGroupCssStyles(tableGroupCssStyle);
            end
        end

        function addSection(obj,title,cssStyles,id)
            if nargin<4
                id='';
            end
            if nargin<3
                cssStyles={};
            end

            if nargin<2
                title='';
            end

            section=hdlhtmlreporter.html.Section(title,id,cssStyles);
            obj.addSectionObject(section,cssStyles);
        end

        function addSectionObject(obj,section,cssStyles)
            if~isempty(obj.activeSection)
                obj.sectionStack.push(section);
                obj.activeSection=section;
                obj.processGroupCssStyles(cssStyles);
            end
        end

        function paragraph=addParagraph(obj,content,cssStyles,id)
            if nargin<4
                id='';
            end
            if nargin<3
                cssStyles={};
            end

            paragraph=hdlhtmlreporter.html.Paragraph(content,id,cssStyles);
            obj.addObject(paragraph,cssStyles);
        end

        function text=addText(obj,content)
            text=hdlhtmlreporter.html.Text(content);
            obj.addObject(text,{});
        end

        function heading=addHeading(obj,content,order,cssStyles,id)
            if nargin<5
                id='';
            end
            if nargin<4
                cssStyles={};
            end
            if nargin<3
                order=2;
            end
            if nargin<2
                content='';
            end
            heading=hdlhtmlreporter.html.Heading(content,order,id,cssStyles);
            obj.addObject(heading,cssStyles);
        end

        function boldtext=addBoldText(obj,content,cssStyles,id)
            if nargin<4
                id='';
            end
            if nargin<3
                cssStyles={};
            end

            boldtext=hdlhtmlreporter.html.BoldText(content,id,cssStyles);
            obj.addObject(boldtext,cssStyles);
        end

        function image=addImage(obj,imageFilePath,cssStyles,id)
            if nargin<4
                id='';
            end
            if nargin<3
                cssStyles={};
            end

            image=hdlhtmlreporter.html.Image(imageFilePath,id,cssStyles);
            obj.addObject(image,cssStyles);
        end

        function link=addLink(obj,href,content,cssStyles,id)
            if nargin<5
                id='';
            end
            if nargin<4
                cssStyles={};
            end

            link=hdlhtmlreporter.html.Link(href,content,id,cssStyles);
            obj.addObject(link,cssStyles);
        end


        function br=addBreak(obj,numBreaks)
            if nargin<2
                numBreaks=1;
            end

            br=hdlhtmlreporter.html.Break(numBreaks);
            obj.addBreakObject(br);
        end

        function addBreakObject(obj,br)
            if~isempty(obj.activeSection)
                obj.activeSection.addElement(br);
            end
        end

        function addObject(obj,object,cssStyles)
            if nargin<3
                cssStyles={};
            end

            if~isempty(obj.activeSection)
                obj.activeSection.addElement(object);
                obj.processGroupCssStyles(cssStyles);
            end
        end

        function commitSection(obj)

            sectionToBeCommitted=obj.sectionStack.pop;
            if~isempty(sectionToBeCommitted)
                obj.activeSection=obj.sectionStack.top;
                if~isempty(obj.activeSection)
                    obj.activeSection.addElement(sectionToBeCommitted);
                end
            end

        end

        function clearEmissionState(obj)
            obj.activeSection='';
            obj.sectionStack.clear;
        end

        function setupEmissionState(obj,section)
            obj.sectionStack.clear;
            obj.sectionStack.push(section);
            obj.activeSection=section;
        end

        function numSec=countPendingSection(obj)
            numSec=obj.sectionStack.Count;
        end

        function emitStr=emitHTML(obj)
            emitStr=obj.activeSection.emitHTML;
        end
    end

    methods(Access=protected)
        function processGroupCssStyles(obj,cssStyles)
            for ii=1:length(cssStyles)
                cssStyle=cssStyles{ii};
                if strcmpi(cssStyle.selector,'class')
                    className=cssStyle.className;
                    elementName=cssStyle.elementName;

                    groupCssStyleKey=obj.generateGlobalCssStyleKey(className,elementName);

                    if~obj.groupCssStyleMap.isKey(groupCssStyleKey)

                        obj.groupCssStyles{end+1}=cssStyle;

                        groupCssStylesLocation=length(obj.groupCssStyles);

                        obj.groupCssStyleMap(groupCssStyleKey)=groupCssStylesLocation;

                    else

                        groupCssStylesLocation=obj.groupCssStyleMap(groupCssStyleKey);

                        obj.groupCssStyles{groupCssStylesLocation}=cssStyle;
                    end
                end

            end
        end

        function key=generateGlobalCssStyleKey(~,className,elementName)
            key=[className,' ',elementName];
        end

    end



end