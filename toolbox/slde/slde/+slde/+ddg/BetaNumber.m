classdef BetaNumber<slde.ddg.Pattern





    properties

        mShapeA;
        mShapeB;

    end


    methods


        function this=BetaNumber

            this@slde.ddg.Pattern;
            this.mRequiresStatTbx=true;
            this.mShapeA='1';
            this.mShapeB='1';

        end


        function schema=getDialogSchema(this)


            row=1;
            col=1;
            wShapeA.Type='edit';
            wShapeA.Name='Shape parameter a:';
            wShapeA.Tag='ShapeA';
            wShapeA.Source=this;
            wShapeA.ObjectProperty='mShapeA';
            wShapeA.RowSpan=[row,row];
            wShapeA.ColSpan=[col,col];
            wShapeA.Mode=false;
            wShapeA.Graphical=true;
            wShapeA.DialogRefresh=false;
            wShapeA.ObjectMethod='handleEditActions';
            wShapeA.MethodArgs={'%dialog','mShapeA',...
            '%value'};
            wShapeA.ArgDataTypes={'handle','string','string'};


            row=row+1;
            wShapeB.Type='edit';
            wShapeB.Name='Shape parameter b:';
            wShapeB.Tag='ShapeB';
            wShapeB.Source=this;
            wShapeB.ObjectProperty='mShapeB';
            wShapeB.RowSpan=[row,row];
            wShapeB.ColSpan=[col,col];
            wShapeB.Mode=false;
            wShapeB.Graphical=true;
            wShapeB.DialogRefresh=false;
            wShapeB.ObjectMethod='handleEditActions';
            wShapeB.MethodArgs={'%dialog','mShapeB',...
            '%value'};
            wShapeB.ArgDataTypes={'handle','string','string'};

            schema.Type='group';
            schema.Items={...
            wShapeA,...
            wShapeB,...
            };
            schema.LayoutGrid=[numel(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,numel(schema.Items)),1];

        end


        function mlcode=generate(this,dialog,existingVars,outVar)

            shapeAVar='a';
            shapeBVar='b';
            mlItem=sprintf('');
            mlItem=strcat(mlItem,...
            sprintf('\n%% %s: Shape parameter',shapeAVar));
            mlItem=strcat(mlItem,...
            sprintf('\n%% %s: Shape parameter',shapeBVar));
            mlItem=strcat(mlItem,sprintf('\n%s = %s; ',...
            shapeAVar,this.mShapeA));
            mlItem=strcat(mlItem,sprintf(' %s = %s;\n',...
            shapeBVar,this.mShapeB));
            mlItem=strcat(mlItem,...
            sprintf('\n%s = betarnd(%s, %s);',outVar,shapeAVar,...
            shapeBVar));
            mlcode=sprintf('%s\n',mlItem);

        end



    end



end


