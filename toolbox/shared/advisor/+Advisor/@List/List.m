classdef(CaseInsensitiveProperties=true)List<Advisor.Element

    properties(Access='public')
        Type='Bulleted';
        Items={};
    end


    methods
        function set.Type(this,value)
            this.Type=Advisor.str2enum(value,'Advisor.AdvisorListTypeEnum');
        end
    end


    methods(Access='public')




        function addItem(this,newItem)
            if~iscell(newItem)
                newItem={newItem};
            end

            for i=1:length(newItem)
                if ischar(newItem{i})
                    temp=Advisor.Text(newItem{i});
                    newItem{i}=temp;
                elseif~isa(newItem{i},'Advisor.Element')
                    DAStudio.error('Advisor:engine:MAUnsupportedItem');
                end
            end
            this.Items={this.Items{:},newItem{:}};%#ok<CCAT> necessary here because elements could be of any row/column layout
        end

        function outputString=emitHTML(this)








            outputString='';
            for i=1:length(this.Items)
                temp=Advisor.Element;
                tempContent='';
                for j=1:length(this.Items{i})
                    tempContent=[tempContent,this.Items{i}(j).emitHTML];%#ok<AGROW>
                end
                temp.setContent(tempContent);
                temp.setTag('li');
                outputString=[outputString,temp.emitHTML];%#ok<AGROW>
            end


            temp=Advisor.Element;
            temp.TagAttributes=this.TagAttributes;
            temp.setContent(outputString);
            if strcmp(this.Type,'Bulleted')
                temp.setTag('ul');
            else
                temp.setTag('ol');
            end


            if strcmp(this.CollapsibleMode,'none')||Advisor.Options.getOption('PrettyPrint')||...
                (strcmp(this.CollapsibleMode,'systemdefined')&&length(this.Items)<=10)
                outputString=temp.emitHTML;
            else
                outputString=emitCollapsibleHTML(this,temp);
            end
        end


        function setType(this,type)
            if ischar(type)
                this.Type=Advisor.str2enum(type,'Advisor.AdvisorListTypeEnum');
            else
                this.Type=type;
            end
        end

    end
end



function outputString=emitCollapsibleHTML(this,Element)
    if strcmp(this.CollapsibleMode,'systemdefined')
        ID1=char(matlab.lang.internal.uuid);



        Element.setAttribute('class','SystemdefinedCollapse','append');
        Element.setAttribute('id',ID1);
        Element.setAttribute('dataCollapse','off');
        outputString=Element.emitHTML;


        Element=Advisor.Element;
        Element.setTag('span')
        Element.setAttribute('class','SDCollapseControl');
        Element.setAttribute('onclick',['collapseSD(this, ''',ID1,''')']);
        Element.setAttribute('onmouseover','this.style.cursor = ''pointer''');
        Element.setContent(['&#8743; ',DAStudio.message('Advisor:engine:CollapseLess')]);

        outputString=[outputString,Element.emitHTML,'<br />'];

    elseif strcmp(this.CollapsibleMode,'all')
        outputString=Element.emitHTML;

        ID1=char(matlab.lang.internal.uuid);
        ID2=char(matlab.lang.internal.uuid);


        Element=Advisor.Element;
        Element.setTag('span')
        Element.setAttribute('onclick',['collapseAll(this, ''',ID1,''',''',ID2,''')']);
        Element.setAttribute('onmouseover','this.style.cursor = ''pointer''');
        if strcmp(this.DefaultCollapsibleState,'expanded')
            ImgSrc=['data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8',...
            '/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAABGdBTUEAALGOfPtRkwAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAAAhklEQVR42mL8/',...
            '/8/AyUAIICYGCgEAAFEsQEAAUSxAQABxIIu0NTURDBQ6urqGGFsgABiwaagpqYOp+aWliYUPkAAUewFgACi2ACAAGLBKcGCafafP/8wxAACCKcB2BRjAwABRLEXAAKIY',...
            'gMAAoiFmKjCBwACiJHSzAQQQBR7ASCAKDYAIMAAUtQUow+YsTsAAAAASUVORK5CYII='];
        else
            ImgSrc=['data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/',...
            '9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAABGdBTUEAALGOfPtRkwAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAAAkUlEQVR42mL8/',...
            '/8/AyUAIICYGCgEAAFEsQEAAUSxAQABxIIu0NTURDBQ6urqGGFsgABiwaagpqYOp+aWliYUPkAAEfQCCwt+JQABRHEYAAQQCzE2w9h//vzDUAcQQDgNgCkGacamEQYAA',...
            'ohiLwAEEEED8NkOAgABxEJMVOEDAAHESGlmAgggisMAIIAoNgAgwAC+/BqtC+40NQAAAABJRU5ErkJggg=='];
        end
        Element.setContent(['<img class="CollapseAllControlImage" src="',ImgSrc,'"/>']);

        CollIMG=Element.emitHTML;

        Element=Advisor.Element;
        Element.setTag('div')
        Element.setAttribute('id',ID1);
        Element.setAttribute('class','AllCollapse');


        if strcmp(this.DefaultCollapsibleState,'collapsed')
            Element.setAttribute('style','display:none;');
        end
        Element.setContent(outputString);
        outputString=Element.emitHTML;


        if~isempty(this.HiddenContent)
            Element=Advisor.Element;
            Element.setTag('div')
            Element.setAttribute('id',ID2);


            if strcmp(this.DefaultCollapsibleState,'expanded')
                DispStyle='display:none;';
            else
                DispStyle='display:'''';';
            end
            Element.setAttribute('style',DispStyle);

            tempContent='';
            for n=1:length(this.HiddenContent)
                tempContent=[tempContent,this.HiddenContent(n).emitHTML];%#ok<AGROW>
            end
            Element.setContent(tempContent)

            HTMLCollState=Element.emitHTML;
        else
            HTMLCollState='';
        end
        outputString=['<div>',CollIMG,outputString,HTMLCollState,'</div>'];
    else
        outputString=Element.emitHTML;
    end
end
