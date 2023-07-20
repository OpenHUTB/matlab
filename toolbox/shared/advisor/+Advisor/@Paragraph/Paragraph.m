classdef Paragraph<Advisor.Element

    properties(Access='public')
        Align='left';
        Items=[];
    end


    methods
        function set.Align(this,value)
            this.Align=Advisor.str2enum(value,'Advisor.AdvisorAlignTypeEnum');
        end
    end


    methods(Access='public')


        function this=Paragraph(varargin)
            if nargin==0
            elseif nargin==1
                this.addItem(convertStringsToChars(varargin{1}));
            end
        end


        function setAlign(this,align)
            this.Align=align;
        end


        function addItem(this,newItem)
            if iscell(newItem)
                newItem=[newItem{:}];
            end

            if isa(newItem,'Advisor.Element')
                this.Items=[this.Items,newItem];
            elseif ischar(newItem)
                newItem=Advisor.Text(newItem);
                this.Items=[this.Items,newItem];
            else
                DAStudio.error('Advisor:engine:MAUnsupportedItem');
            end
        end



        function outputString=emitHTML(this)


            outputString='';
            for i=1:length(this.Items)
                outputString=[outputString,this.Items(i).emitHTML];%#ok<AGROW>
            end


            temp=Advisor.Element;
            temp.TagAttributes=this.TagAttributes;
            temp.setContent(outputString);
            temp.setTag('p');



            if~strcmp(this.Align,'left')
                temp.setAttribute('style',['text-align:',char(this.Align),';'],'append');
            end


            if strcmp(this.CollapsibleMode,'none')||Advisor.Options.getOption('PrettyPrint')
                outputString=temp.emitHTML;
            else
                outputString=emitCollapsibleHTML(this,temp);
            end


            function outputString=emitCollapsibleHTML(this,Element)



                if strcmp(this.CollapsibleMode,'all')
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

        end
    end
end