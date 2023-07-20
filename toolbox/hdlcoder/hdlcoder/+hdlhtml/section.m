

classdef section<handle
    properties(SetAccess=private,GetAccess=private)
mSection
    end

    methods


        function this=section(content,tag)
            if nargin<2
                tag='';
            end
            if isnumeric(tag)
                tag=['h',num2str(tag)];
            end
            if nargin<1
                content='';
            end
            this.mSection=ModelAdvisor.Element;
            if~isempty(tag)
                this.mSection.setTag(tag);
            end
            if~isempty(content)
                this.mSection.setContent(content);
            end
        end


        function setAttribute(this,param,value)
            this.mSection.setAttribute(param,value);
        end


        function newsection=formatTitle(this,title)
            this.mSection.setTag('b');
            this.setAttribute('class','midprod');
            outersection1=hdlhtml.section(this.getHTML,'font');
            outersection1.setAttribute('size','+1');
            outersection1.setAttribute('color','#000066');
            newsection=hdlhtml.section(outersection1.getHTML,'a');
            newsection.setAttribute('name',title);
        end


        function createEntry(this,item)
            data=item.getData;
            this.mSection.setContent(data.emitHTML);
        end


        function html=getHTML(this)
            html=this.mSection.emitHTML;
        end


        function section=getData(this)
            section=this.mSection;
        end

    end
end