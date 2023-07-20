classdef ExponentialNumber<slde.ddg.Pattern






    properties

        mMean;

    end


    methods


        function this=ExponentialNumber

            this@slde.ddg.Pattern;
            this.mMean='1';

        end


        function schema=getDialogSchema(this)


            row=1;
            col=1;
            wMean.Type='edit';
            wMean.Name='Mean:';
            wMean.Tag='Mean';
            wMean.Source=this;
            wMean.ObjectProperty='mMean';
            wMean.RowSpan=[row,row];
            wMean.ColSpan=[col,col];
            wMean.Mode=false;
            wMean.Graphical=true;
            wMean.DialogRefresh=false;
            wMean.ObjectMethod='handleEditActions';
            wMean.MethodArgs={'%dialog','mMean',...
            '%value'};
            wMean.ArgDataTypes={'handle','string','string'};

            schema.Type='group';
            schema.Items={...
            wMean,...
            };
            schema.LayoutGrid=[numel(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,numel(schema.Items)),1];

        end


        function mlcode=generate(this,dialog,existingVars,outVar)

            meanVar='mu';
            mlItem='';
            mlItem=strcat(mlItem,sprintf('\n%s = %s;\n',meanVar,...
            this.mMean));
            mlItem=strcat(mlItem,sprintf(...
            '\n%s = -%s * log(1 - rand());\n',outVar,meanVar));
            mlcode=sprintf('%s\n',mlItem);

        end



    end



end

