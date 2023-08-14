classdef GaussianNormalNumber<slde.ddg.Pattern






    properties

        mMean;
        mStdDev;

    end


    methods


        function this=GaussianNormalNumber

            this@slde.ddg.Pattern;
            this.mMean='0';
            this.mStdDev='1';

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


            row=row+1;
            wStdDev.Type='edit';
            wStdDev.Name='Standard deviation:';
            wStdDev.Tag='StandardDeviation';
            wStdDev.Source=this;
            wStdDev.ObjectProperty='mStdDev';
            wStdDev.RowSpan=[row,row];
            wStdDev.ColSpan=[col,col];
            wStdDev.Mode=false;
            wStdDev.Graphical=true;
            wStdDev.DialogRefresh=false;
            wStdDev.ObjectMethod='handleEditActions';
            wStdDev.MethodArgs={'%dialog','mStdDev',...
            '%value'};
            wStdDev.ArgDataTypes={'handle','string','string'};

            schema.Type='group';
            schema.Items={...
            wMean,...
            wStdDev,...
            };
            schema.LayoutGrid=[numel(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,numel(schema.Items)),1];

        end


        function mlcode=generate(this,dialog,existingVars,outVar)

            meanVar='m';
            stdDevVar='d';
            mlItem=sprintf('');
            mlItem=strcat(mlItem,sprintf('\n%% %s: Mean, ',...
            meanVar));
            mlItem=strcat(mlItem,sprintf(...
            ' %s: Standard deviation\n',stdDevVar));
            mlItem=strcat(mlItem,sprintf('\n%s = %s; ',meanVar,...
            this.mMean));
            mlItem=strcat(mlItem,sprintf(' %s = %s;\n',stdDevVar,...
            this.mStdDev));
            mlItem=strcat(mlItem,sprintf(...
            '\n%s = %s + %s * randn;\n',outVar,meanVar,stdDevVar));
            mlcode=sprintf('%s\n',mlItem);

        end



    end



end

