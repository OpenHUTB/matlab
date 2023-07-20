
classdef AttributesItem<vision.internal.labeler.tool.ListItem

    properties(Constant)
        MinWidth=240;
        MinHeight=2;
        SelectedBGColor=[0.75,0.75,0.75];
        UnselectedBGColor=[0.94,0.94,0.94];
        TextStartX=10;

        MaxTextWidth=100;
        ControlStartX=120;
        MaxControlWidth=100;
        IconStartX=230;
        MaxIconWidth=15;
        MaxIconHeight=15;
        MaxDescriptionChar=60;
        DescriptionNewLineRange=15;
    end

    properties
Parent
Panel
Index
AttributesText
AttributesControl
AttributesIcon
        isFirstItem=false;
        AttributeName;
        AttributeType;
        Visible=true;
    end

    methods

        function this=AttributesItem(parent,idx,data)
            this.Parent=parent;
            this.Index=idx;

            if idx==1
                textStr=data;
                descriptionStr=data;
                this.isFirstItem=true;
                this.AttributeName='';
                this.AttributeType=attributeType.None;
            else
                textStr=data.Name;
                if data.Description
                    descriptionStr=['Description: ',data.Description];
                    descriptionStr=formatDescription(this,descriptionStr);
                else
                    descriptionStr=' Description: None';
                end
                this.AttributeName=textStr;
                this.AttributeType=data.Type;
            end
            itemH=50;
            dummyTextY=0;



            containerW=getContainerWidth(this,parent);
            panelW=max(this.MinWidth,containerW);
            this.Panel=uipanel('Parent',parent,...
            'Visible','on',...
            'Units','pixels',...
            'Position',[0,0,panelW,itemH],...
            'BackgroundColor',this.UnselectedBGColor,...
            'BorderType','none');

            if idx~=1

                textW=this.ControlStartX-this.TextStartX;
            else
                textW=panelW;
            end

            this.AttributesText=uicontrol('Style','text',...
            'Parent',this.Panel,...
            'String',textStr,...
            'Units','pixels',...
            'Position',[this.TextStartX,dummyTextY,textW,itemH],...
            'Visible','on',...
            'FontSize',10,...
            'HorizontalAlignment','left',...
            'Enable','off',...
            'BackgroundColor',this.UnselectedBGColor);

            if(idx>1)
                if(data.Type==attributeType.List)||...
                    (data.Type==attributeType.Logical)

                    popItemStr=getPopupItemString(this,data);

                    if vision.internal.labeler.tool.isWebFigure(this.Parent.Parent)
                        popItemPos=[this.ControlStartX,dummyTextY+30,this.MaxControlWidth,itemH-30];
                    else
                        popItemPos=[this.ControlStartX,dummyTextY,this.MaxControlWidth,itemH];
                    end

                    this.AttributesControl=uicontrol('Style','popup',...
                    'Parent',this.Panel,...
                    'String',popItemStr,...
                    'Units','pixels',...
                    'Position',popItemPos,...
                    'FontSize',10,...
                    'Visible','on',...
                    'Enable','off',...
                    'HorizontalAlignment','left',...
                    'BackgroundColor',this.UnselectedBGColor,...
                    'Tag',data.LabelName+"_"+data.SublabelName+"_"+data.Name+"_popup",...
                    'Callback',@this.AttributesPopupEditCallback);


                    if(data.Type==attributeType.Logical)
                        if islogical(data.Value)
                            val_popup=convertLogicalToPopupVal(data.Value);
                        else
                            val_popup=data.Value;
                        end
                        this.AttributesControl.Value=val_popup;
                    end


                else
                    ebH=20;
                    this.AttributesControl=uicontrol('Style','edit',...
                    'Parent',this.Panel,...
                    'String',data.Value,...
                    'Units','pixels',...
                    'Position',[this.ControlStartX,itemH-ebH,this.MaxControlWidth,ebH],...
                    'FontSize',10,...
                    'Visible','on',...
                    'Enable','off',...
                    'HorizontalAlignment','left',...
                    'BackgroundColor',this.UnselectedBGColor,...
                    'Tag',data.LabelName+"_"+data.SublabelName+"_"+data.Name+"_edit",...
                    'Callback',@this.AttributesPopupEditCallback);
                end

                iconLocation=fullfile(matlabroot,'toolbox','vision',...
                'vision','+vision','+internal','+videoLabeler','+tool');
                prevUnlabeledIcon=fullfile(iconLocation,'info.png');
                btnCData=imread(prevUnlabeledIcon);
                this.AttributesIcon=uicontrol('Style','pushbutton',...
                'Parent',this.Panel,...
                'String','',...
                'FontWeight','bold',...
                'CData',btnCData,...
                'Tooltip',descriptionStr,...
                'Units','pixels',...
                'Position',[this.IconStartX,dummyTextY+30,this.MaxIconWidth,this.MaxIconHeight],...
                'Visible','on',...
                'Enable','off',...
                'HorizontalAlignment','left');
            end
        end


        function str=getPopupItemString(~,data)
            if(data.Type==attributeType.Logical)
                str={'Empty','True','False'};
            elseif(data.Type==attributeType.List)
                str=data.Value;
            else
                str='';
            end
        end


        function setEnableStatus(this,s)
            this.AttributesText.Enable=s;
            if~this.isFirstItem
                this.AttributesControl.Enable=s;
                this.AttributesIcon.Enable=s;
            end
        end


        function enable(this)
            setEnableStatus(this,'on');
        end


        function disable(this)
            setEnableStatus(this,'off');
        end



        function select(~)

        end


        function unselect(~)

        end


        function data=createAttributeEventData(this,value)
            attribData=struct('AttributeName',this.AttributeName,...
            'AttributeType',this.AttributeType,...
            'AttributeValue',value);
            data=vision.internal.labeler.tool.ItemModifiedEvent(this.Index,attribData);
        end


        function[val,error]=getAttribValue(this,hControl)
            error=false;

            if(this.AttributeType==attributeType.String)
                val=hControl.String;
            elseif(this.AttributeType==attributeType.List)
                val=hControl.String{hControl.Value};
            elseif(this.AttributeType==attributeType.Logical)


                logicalVal={logical.empty,true,false};
                val=logicalVal{hControl.Value};
            elseif(this.AttributeType==attributeType.Numeric)
                val=str2double(hControl.String);
                if isnan(val)
                    hFig=this.Panel.Parent.Parent;
                    errMsg=vision.getMessage('vision:labeler:AttributeNumValueInvalidDlgMsg');
                    dlgName=vision.getMessage('vision:labeler:AttributeValueInvalidDlgName');
                    vision.internal.labeler.handleAlert(hFig,'errorWithModal',errMsg,dlgName);
                    error=true;
                end
            else
                val='';
            end
        end


        function AttributesPopupEditCallback(this,hControl,~)

            [val,error]=getAttribValue(this,hControl);
            if error
                return;
            end
            data=createAttributeEventData(this,val);
            notify(this,'ListItemModified',data);
        end


        function containerW=getContainerWidth(~,parent)
            fig=ancestor(parent,'Figure');
            containerW=fig.Position(3);
        end


        function adjustWidth(this,parentWidth)

            this.Panel.Units='pixels';
            this.AttributesText.Units='pixels';

            this.Panel.Position(3)=max(this.MinWidth,parentWidth);


            if this.Index==1
                this.AttributesText.Position(3)=this.Panel.Position(3)-4;
            else
                textW=this.ControlStartX-this.TextStartX;
                this.AttributesText.Position(3)=min(textW,this.Panel.Position(3)-4);
            end
        end


        function hasMatch=compareDataElement(this,varargin)

            attribName=varargin{1};
            hasMatch=strcmpi(this.AttributeName,attribName);
        end


        function str=getHeaderText(this)
            if this.isFirstItem
                str=this.AttributesText.String;
            else
                str='';
            end
        end


        function modifyListDataValue(this,val)
            this.AttributesControl.String=val;
        end


        function modifyData(this,newName)
            this.AttributesText.String=newName;
            this.AttributeName=newName;
        end


        function modifyDescription(this,newDescription)
            if newDescription
                newDescription=['Description: ',newDescription];
                newDescription=formatDescription(this,newDescription);
            else
                newDescription=' Description: None';
            end
            this.AttributesIcon.Tooltip=newDescription;
        end


        function updateItemDataValue(this,val)
            if~this.isFirstItem
                if(this.AttributeType==attributeType.List)

                    if isempty(val)
                        val_popup=1;
                    else
                        if isnumeric(val)
                            val_popup=val;
                        else
                            selected_string=val;
                            matchIdx=find(strcmp(this.AttributesControl.String,selected_string));
                            val_popup=matchIdx;
                        end
                    end
                    this.AttributesControl.Value=val_popup;
                elseif(this.AttributeType==attributeType.Logical)
                    if isempty(val)
                        val_popup=1;
                    else



                        if islogical(val)
                            val_popup=convertLogicalToPopupVal(val);
                        else
                            val_popup=val;
                        end
                    end
                    this.AttributesControl.Value=val_popup;
                else
                    this.AttributesControl.String=val;
                end
            end
        end


        function updateFirstItemData(this,str)
            this.AttributesText.String=str;
        end


        function adjustHeight(this,~)
            if this.isFirstItem
                this.AttributesText.Position(2)=-15;
            end
        end

        function description=formatDescription(this,string)
            lines=splitlines(string);
            description=[];
            for ind=1:length(lines)
                lines{ind}=formatDescriptionHelper(this,lines{ind});
                description=[description,lines{ind},newline];%#ok<AGROW> 
            end
        end


        function description=formatDescriptionHelper(this,string)
            dLen=length(string);
            description=string;
            maxL=this.MaxDescriptionChar;
            rangeL=this.DescriptionNewLineRange;
            if dLen>maxL
                nIter=floor(dLen/maxL);
                midI=0;
                for iIter=1:nIter
                    midI=midI+maxL;
                    indRange=midI-rangeL:midI;
                    indSpace=find(description(indRange)==' ',1);
                    if indSpace
                        replaceInd=midI-rangeL+1+indSpace;
                        description(replaceInd)=newline;
                    else
                        description=[description(1:midI),newline,description(midI+1:end)];
                    end
                end
            end
        end

        function delete(this)
            delete(this.Panel);
            delete(this.AttributesControl);
            delete(this.AttributesText);
            delete(this.AttributesIcon);
        end

    end
end


function val_popup=convertLogicalToPopupVal(val)
    if val==true
        val_popup=2;
    elseif val==false
        val_popup=3;
    else
        val_popup=1;
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end