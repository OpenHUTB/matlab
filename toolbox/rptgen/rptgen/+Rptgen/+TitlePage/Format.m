classdef Format<handle



    properties

Side
LayoutGrid
IncludeElements
ExcludeElements

    end

    methods

        function this=Format(side)
            this.Side=side;
            this.LayoutGrid=Rptgen.TitlePage.LayoutGrid;
        end

        function ce=getIncludeElement(this,name)
            ce=this.IncludeElements(cellfun(@(a)strcmp(a.Name,name),...
            this.IncludeElements));
            if~isempty(ce)
                ce=ce{1};
            end
        end

        function ce=getExcludeElement(this,name)
            ce=this.ExcludeElements(cellfun(@(a)strcmp(a.Name,name),...
            this.ExcludeElements));
            if~isempty(ce)
                ce=ce{1};
            end
        end

        function excludeElement(this,name)
            ce=getIncludeElement(this,name);
            if~isempty(ce)
                this.IncludeElements=...
                this.IncludeElements(cellfun(@(a)~strcmp(a.Name,name),...
                this.IncludeElements));
                this.ExcludeElements=[this.ExcludeElements,{ce}];
            end
        end

        function includeElement(this,name)
            ce=getExcludeElement(this,name);
            if~isempty(ce)
                this.ExcludeElements=...
                this.ExcludeElements(cellfun(@(a)~strcmp(a.Name,name),...
                this.ExcludeElements));
                this.IncludeElements=[this.IncludeElements,{ce}];
            end
        end


        function save(this,docFormat)
            elFormat=docFormat.createElement(Rptgen.TitlePage.Format.getTagName());
            elFormat.setAttribute('mcos-class',class(this));
            docFormat.appendChild(elFormat);


            this.LayoutGrid.save(docFormat,elFormat);


            elContentElements=docFormat.createElement('tp_include_elements');
            elFormat.appendChild(elContentElements);
            for i=1:length(this.IncludeElements)
                elCE=docFormat.createElement(Rptgen.TitlePage.Element.getTagName());
                this.IncludeElements{i}.save(elCE);
                elContentElements.appendChild(elCE);
            end


            elContentElements=docFormat.createElement('tp_exclude_elements');
            elFormat.appendChild(elContentElements);
            for i=1:length(this.ExcludeElements)
                elCE=docFormat.createElement(Rptgen.TitlePage.Element.getTagName());
                this.ExcludeElements{i}.save(elCE);
                elContentElements.appendChild(elCE);
            end

        end


    end

    methods(Abstract)

        generateTemplateContent(this,jTemplate)

    end

    methods(Static)

        function tagName=getTagName()
            tagName='tp_format';
        end

        function format=load(elFormat)


            ctr=str2func(char(elFormat.getAttribute('mcos-class')));
            format=ctr();



            format.LayoutGrid={};
            format.IncludeElements={};
            format.ExcludeElements={};


            nodes=elFormat.getElementsByTagName(Rptgen.TitlePage.LayoutGrid.getTagName());
            format.LayoutGrid=Rptgen.TitlePage.LayoutGrid.load(nodes.item(0));


            nodeList=elFormat.getElementsByTagName('tp_include_elements');
            elContentElements=nodeList.item(0);
            nodeList=elContentElements.getElementsByTagName(Rptgen.TitlePage.Element.getTagName());
            for i=0:nodeList.getLength()-1
                contentElement=Rptgen.TitlePage.Element.load(nodeList.item(i));
                format.IncludeElements=[format.IncludeElements,{contentElement}];
            end


            nodeList=elFormat.getElementsByTagName('tp_exclude_elements');
            elContentElements=nodeList.item(0);
            nodeList=elContentElements.getElementsByTagName(Rptgen.TitlePage.Element.getTagName());
            for i=0:nodeList.getLength()-1
                contentElement=Rptgen.TitlePage.Element.load(nodeList.item(i));
                format.ExcludeElements=[format.ExcludeElements,{contentElement}];
            end

        end

    end

end