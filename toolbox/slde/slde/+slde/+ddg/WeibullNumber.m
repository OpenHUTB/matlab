classdef WeibullNumber<slde.ddg.Pattern





    properties

        mThreshold;
        mScale;
        mShape;

    end


    methods


        function this=WeibullNumber

            this@slde.ddg.Pattern;
            this.mRequiresStatTbx=true;
            this.mThreshold='0';
            this.mScale='1';
            this.mShape='1';

        end


        function schema=getDialogSchema(this)


            row=1;
            col=1;
            wThreshold.Type='edit';
            wThreshold.Name='Threshold:';
            wThreshold.Tag='Threshold';
            wThreshold.Source=this;
            wThreshold.ObjectProperty='mThreshold';
            wThreshold.RowSpan=[row,row];
            wThreshold.ColSpan=[col,col];
            wThreshold.Mode=false;
            wThreshold.Graphical=true;
            wThreshold.DialogRefresh=false;
            wThreshold.ObjectMethod='handleEditActions';
            wThreshold.MethodArgs={'%dialog','mThreshold',...
            '%value'};
            wThreshold.ArgDataTypes={'handle','string','string'};


            row=row+1;
            wScale.Type='edit';
            wScale.Name='Scale:';
            wScale.Tag='Scale';
            wScale.Source=this;
            wScale.ObjectProperty='mScale';
            wScale.RowSpan=[row,row];
            wScale.ColSpan=[col,col];
            wScale.Mode=false;
            wScale.Graphical=true;
            wScale.DialogRefresh=false;
            wScale.ObjectMethod='handleEditActions';
            wScale.MethodArgs={'%dialog','mScale',...
            '%value'};
            wScale.ArgDataTypes={'handle','string','string'};


            row=row+1;
            wShape.Type='edit';
            wShape.Name='Shape:';
            wShape.Tag='Shape';
            wShape.Source=this;
            wShape.ObjectProperty='mShape';
            wShape.RowSpan=[row,row];
            wShape.ColSpan=[col,col];
            wShape.Mode=false;
            wShape.Graphical=true;
            wShape.DialogRefresh=false;
            wShape.ObjectMethod='handleEditActions';
            wShape.MethodArgs={'%dialog','mShape',...
            '%value'};
            wShape.ArgDataTypes={'handle','string','string'};

            schema.Type='group';
            schema.Items={...
            wThreshold,...
            wScale,...
            wShape,...
            };
            schema.LayoutGrid=[numel(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,numel(schema.Items)),1];

        end


        function mlcode=generate(this,dialog,existingVars,outVar)

            thresholdVar='T';
            scaleVar='a';
            shapeVar='b';
            mlItem=sprintf('');
            mlItem=strcat(mlItem,...
            sprintf('\n%% %s: Threshold\n',thresholdVar));
            mlItem=strcat(mlItem,sprintf('\n%% %s: Scale, ',...
            scaleVar));
            mlItem=strcat(mlItem,sprintf(' %s: Shape\n',...
            shapeVar));
            mlItem=strcat(mlItem,sprintf('\n%s = %s; ',...
            thresholdVar,this.mThreshold));
            mlItem=strcat(mlItem,sprintf(' %s = %s; ',...
            scaleVar,this.mScale));
            mlItem=strcat(mlItem,sprintf(' %s = %s;\n',...
            shapeVar,this.mShape));
            mlItem=strcat(mlItem,...
            sprintf('\n%s = %s + wblrnd(%s, %s);',...
            outVar,thresholdVar,scaleVar,shapeVar));
            mlcode=sprintf('%s\n',mlItem);

        end



    end



end


