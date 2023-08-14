classdef UniformNumber<slde.ddg.Pattern





    properties

        mMin;
        mMax;

    end


    methods


        function this=UniformNumber

            this@slde.ddg.Pattern;
            this.mMin='0';
            this.mMax='1';

        end


        function schema=getDialogSchema(this)


            row=1;
            col=1;
            wMin.Type='edit';
            wMin.Name='Minimum:';
            wMin.Tag='Min';
            wMin.Source=this;
            wMin.ObjectProperty='mMin';
            wMin.RowSpan=[row,row];
            wMin.ColSpan=[col,col];
            wMin.Mode=false;
            wMin.Graphical=true;
            wMin.DialogRefresh=false;
            wMin.ObjectMethod='handleEditActions';
            wMin.MethodArgs={'%dialog','mMin',...
            '%value'};
            wMin.ArgDataTypes={'handle','string','string'};


            row=row+1;
            wMax.Type='edit';
            wMax.Name='Maximum:';
            wMax.Tag='Max';
            wMax.Source=this;
            wMax.ObjectProperty='mMax';
            wMax.RowSpan=[row,row];
            wMax.ColSpan=[col,col];
            wMax.Mode=false;
            wMax.Graphical=true;
            wMax.DialogRefresh=false;
            wMax.ObjectMethod='handleEditActions';
            wMax.MethodArgs={'%dialog','mMax',...
            '%value'};
            wMax.ArgDataTypes={'handle','string','string'};

            schema.Type='group';
            schema.Items={...
            wMin,...
            wMax,...
            };
            schema.LayoutGrid=[numel(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,numel(schema.Items)),1];

        end


        function mlcode=generate(this,dialog,existingVars,outVar)

            minVar='m';
            maxVar='M';
            mlItem=sprintf('');
            mlItem=strcat(mlItem,sprintf('\n%% %s: Minimum, ',minVar));
            mlItem=strcat(mlItem,sprintf(' %s: Maximum\n',...
            maxVar));
            mlItem=strcat(mlItem,sprintf('\n%s = %s;\n',minVar,...
            this.mMin));
            mlItem=strcat(mlItem,sprintf(' %s = %s;\n',maxVar,...
            this.mMax));
            mlItem=strcat(mlItem,sprintf(...
            '\n%s = %s + (%s - %s) * rand;\n',outVar,minVar,...
            maxVar,minVar));
            mlcode=sprintf('%s\n',mlItem);

        end



    end



end


