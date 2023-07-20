
classdef SublabelsItem<vision.internal.labeler.tool.ListItem

    properties(Constant)
        MinWidth=240;
        MinHeight=2;
        SelectedBGColor=[0.75,0.75,0.75];
        UnselectedBGColor=[0.94,0.94,0.94];
    end

    properties
Panel
Index
SublabelsText
        ItemHeight=2;
SublabelName
RootLabelName
        Visible=true;
    end

    methods

        function this=SublabelsItem(parent,idx,data)

            this.Index=idx;
            if isstruct(data)
                this.RootLabelName=data.LabelName;
                this.SublabelName=data.SublabelName;
                thisText=createText(this,data);
            else
                thisText=data;


                this.ItemHeight=3;
            end

            textWidth=getContainerWidth(this,parent)-5;
            if useAppContainer()&&textWidth<0

                textWidth=240;
            end
            if~useAppContainer
                panelPos=[0,0,textWidth,this.ItemHeight];
                this.Panel=uipanel('Parent',parent,...
                'Units','characters',...
                'Position',panelPos,...
                'BackgroundColor',this.UnselectedBGColor,...
                'BorderType','none');
            else
                panelPos=[1,1,textWidth*6,this.ItemHeight*12];
                this.Panel=uipanel('Parent',parent,...
                'Units','pixels',...
                'Position',panelPos,...
                'BackgroundColor',this.UnselectedBGColor,...
                'BorderType','none');
            end

            textPos=[1,0,textWidth,this.ItemHeight-1];
            this.SublabelsText=uicontrol('Style','text',...
            'Parent',this.Panel,...
            'String',thisText,...
            'Units','characters',...
            'Position',textPos,...
            'BackgroundColor',this.UnselectedBGColor,...
            'HorizontalAlignment','left');
            if~isEnglishMachine()
                this.SublabelsText.FontSize=8;
            end

            this.Panel.Units='pixels';
            this.SublabelsText.Units='pixels';





        end


        function updateItemDataValue(this,data)
            thisText=createText(this,data);
            this.SublabelsText.String=thisText;
        end


        function str=getRootName(this)
            str=this.RootLabelName;
        end


        function str=getDataNames(this)
            str=this.SublabelName;
        end


        function containerW=getContainerWidth(~,parent)
            fig=ancestor(parent,'Figure');
            containerW=fig.Position(3);
        end


        function setEnableStatus(this,s)
            this.SublabelsText.Enable=s;
            this.AttributesControl.Enable=s;
        end



        function select(~)

        end


        function unselect(~)

        end


        function str=createText(~,data)
            if ischar(data)
                str=data;
            elseif data.ForROIInstance
                str=[data.SublabelName,' : ',num2str(data.NumSublabelInstances)];
            else
                str=data.SublabelName;
            end
        end


        function adjustWidth(this,parentWidth)

            this.Panel.Units='pixels';
            this.SublabelsText.Units='pixels';

            this.Panel.Position(3)=max(this.MinWidth,parentWidth);

            textOffset=10;
            this.SublabelsText.Position(3)=this.Panel.Position(3)-textOffset;
        end

        function adjustHeight(this,~)
            if this.SublabelsText.Extent(3)>this.SublabelsText.Position(3)



                oldUnitsText=this.SublabelsText.Units;
                oldUnitsPanel=this.Panel.Units;
                if~useAppContainer
                    this.SublabelsText.Units='char';
                    this.Panel.Units='char';


                    this.Panel.Position(4)=4;



                    this.SublabelsText.Position(4)=this.Panel.Position(4)-1;
                else
                    this.SublabelsText.Units='pixels';
                    this.Panel.Units='pixels';


                    this.Panel.Position(4)=48;



                    this.SublabelsText.Position(4)=this.Panel.Position(4)-12;
                end

                this.SublabelsText.Units=oldUnitsText;
                this.Panel.Units=oldUnitsPanel;
            end
        end


        function delete(this)
            delete(this.Panel);
            delete(this.SublabelsText);
        end

    end
end

function isEng=isEnglishMachine()
    isEng=false;
    try
        loc=feature('locale');
        if isfield(loc,'ctype')
            ctype=loc.ctype;
            isEng=(length(ctype)>3)&&strcmpi(ctype(1:3),'en_');
        end
    catch ME %#ok<NASGU>
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end