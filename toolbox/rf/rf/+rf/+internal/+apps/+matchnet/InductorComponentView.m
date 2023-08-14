
classdef InductorComponentView<rf.internal.apps.matchnet.ComponentView



    properties(Access=public)
        ComponentConnection(1,:)char
    end

    properties(Access=public,Constant)
        IMAGE_SERINDCT='series_inductor_60@2x.png'
        IMAGE_SHNTINDCT='shunt_inductor_60@2x.png'
    end

    methods(Access=public)
        function this=InductorComponentView(parent,component,connection)
            this@rf.internal.apps.matchnet.ComponentView(parent,component);
            this.ComponentConnection=connection;
        end


        function uiobjectOut=getEditableControls(this,parent)
            uiobjectOut=uipanel(parent,'Title',['Component ',strrep(this.Component.Name,'_','')]);

            datagrid=uigridlayout(uiobjectOut,...
            'RowHeight',{'fit','fit'},'ColumnWidth',{'fit','fit'});

            uilabel(datagrid,'Text','Inductance (nH)');
            scaledComponentValue=this.Component.Inductance*1e9;
            uilabel(datagrid,'Text',num2str(scaledComponentValue,4),'HorizontalAlignment','right');











        end
    end

    methods(Access=protected)
        function setImage(this)
            if(strcmp(this.ComponentConnection,'shunt'))
                filename=fullfile(this.IMAGE_PATH,this.IMAGE_SHNTINDCT);
                ComponentName=pad(regexprep(this.Component.Name,'[_]',...
                '','once'),24+numel(this.Component.Name),'left');
                HA='left';
                VA='center';
            else
                filename=fullfile(this.IMAGE_PATH,this.IMAGE_SERINDCT);
                ComponentName=regexprep(this.Component.Name,'[_]',' ',...
                'once');
                HA='center';
                VA='top';
            end
            this.ComponentImage=uiimage(this.OverallLayout,...
            'ImageSource',filename);
            this.ComponentText=uilabel(this.OverallLayout,'Text',...
            ComponentName,'HorizontalAlignment',HA,...
            'VerticalAlignment',VA);
            this.ComponentText.Layout.Column=this.ComponentImage.Layout.Column;
            this.ComponentText.Layout.Row=this.ComponentImage.Layout.Row;

            scaledComponentValue=this.Component.Inductance*1e9;
            this.ComponentText.Tooltip=[num2str(scaledComponentValue,4),' nH'];
        end
    end
end
