










classdef UIStatistic<SimBiology.simviewer.UIPanel

    properties(Access=public)
        Expression='';
        ExpressionField=-1;
        ExpressionTokens={};
        MoreButton=-1;
        Name='';
        NameLabel=-1;
        OriginalExpression='';
        Value=1.0;
        ValueField=-1;

        ShowExpression=false;
    end

    methods
        function obj=UIStatistic(model)
            obj.Expression=model.Expression;
            obj.OriginalExpression=model.Expression;
            obj.Name=model.Name;
            obj.Value=model.Value;
        end

        function compileExpression(obj)
            tokens=SimBiology.internal.parseExpression(obj.Expression);

            replacement=cell(1,length(tokens));
            for j=1:length(tokens)
                nextToken=tokens{j};
                if strcmp(nextToken,'time')
                    next='time';
                    replacement{j}=next;
                else
                    next=['x',num2str(j)];
                    replacement{j}=next;
                end
            end

            obj.Expression=SimBiology.internal.Utils.Parser.traverseSubstitute(obj.Expression,tokens,replacement);
            obj.ExpressionTokens=tokens;
        end

        function initComponents(obj,hFigure,index)
            obj.NameLabel=uicontrol(hFigure,'Style','text',...
            'String',[obj.Name,':'],...
            'HorizontalAlignment','left',...
            'Handlevisibility','off',...
            'Tag',['ExploreModelTab_Statistic_NameLabel_',num2str(index)]);

            obj.ValueField=uicontrol(hFigure,'Style','text',...
            'String','Not calculated',...
            'Enable','on',...
            'HorizontalAlignment','left',...
            'Handlevisibility','off',...
            'Tag',['ExploreModelTab_Statistic_ValueField_',num2str(index)]);

            obj.ExpressionField=uicontrol(hFigure,'Style','edit',...
            'String',obj.OriginalExpression,...
            'HorizontalAlignment','left',...
            'Enable','off',...
            'Handlevisibility','off',...
            'Tag',['ExploreModelTab_Statistic_ExpressionField_',num2str(index)]);

            obj.MoreButton=uicontrol(hFigure,'Style','pushbutton',...
            'String','...',...
            'Handlevisibility','off',...
            'Tag',['ExploreModelTab_Statistic_MoreButton_',num2str(index)]);

        end

        function y=positionComponents(obj,handles,x,y,okToPad)
            figPosition=handles.Figure.Position;
            tabPosition=handles.TabPanelGroup.Position;
            width=max(40,figPosition(3)*tabPosition(3)-SimBiology.simviewer.UIPanel.getXPosPadding());

            pad=0;
            if okToPad
                pad=6;
            end

            y=SimBiology.simviewer.UIPanel.moveComponent(obj.NameLabel,x,y,pad);
            SimBiology.simviewer.UIPanel.shiftComponentDown(obj.NameLabel,4);
            y=y-4;


            SimBiology.simviewer.internal.layouthandler('sizeTextLabel',obj.ValueField);
            labelWidth=obj.NameLabel.Position(3);
            fieldWidth=max(80,obj.ValueField.Position(3));
            buttonWidth=obj.MoreButton.Position(3);
            expressionWidth=max(20,width-labelWidth-fieldWidth-buttonWidth-19);


            x=x+obj.NameLabel.Position(3)+4;

            set(obj.ValueField,'Position',[x,y,fieldWidth,obj.ValueField.Position(4)]);
            x=x+fieldWidth+4;

            if obj.ShowExpression
                obj.ExpressionField.Visible='on';
                pos=obj.ExpressionField.Position;
                set(obj.ExpressionField,'Position',[x,y+4,expressionWidth,pos(4)]);
            else
                obj.ExpressionField.Visible='off';
            end


            x=width-buttonWidth;
            obj.MoreButton.Position=[x,y+4,buttonWidth,obj.MoreButton.Position(4)];

            y=y+5;
        end
    end
end