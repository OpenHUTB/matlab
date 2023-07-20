classdef DiscreteUniformNumber<slde.ddg.Pattern






    properties

        mMin;
mMax
        mNumVals;

    end


    methods


        function this=DiscreteUniformNumber

            this@slde.ddg.Pattern;
            this.mMin='0';
            this.mMax='1';
            this.mNumVals='2';

        end


        function schema=getDialogSchema(this)


            row=1;
            col=1;
            wMin.Type='edit';
            wMin.Name='Minimum:';
            wMin.Tag='Minimum';
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
            wMax.Tag='Maximum';
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


            row=row+1;
            wNumVals.Type='edit';
            wNumVals.Name='Number of values:';
            wNumVals.Tag='NumVals';
            wNumVals.Source=this;
            wNumVals.ObjectProperty='mNumVals';
            wNumVals.RowSpan=[row,row];
            wNumVals.ColSpan=[col,col];
            wNumVals.Mode=false;
            wNumVals.Graphical=true;
            wNumVals.DialogRefresh=false;
            wNumVals.ObjectMethod='handleEditActions';
            wNumVals.MethodArgs={'%dialog','mNumVals',...
            '%value'};
            wNumVals.ArgDataTypes={'handle','string','string'};

            schema.Type='group';
            schema.Items={...
            wMin,...
            wMax,...
            wNumVals,...
            };
            schema.LayoutGrid=[numel(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,numel(schema.Items)),1];

        end


        function mlcode=generate(this,dialog,existingVars,outVar)

            minVar='m';
            maxVar='M';
            numValVar='N';
            mlItem=sprintf('');
            mlItem=strcat(mlItem,...
            sprintf('\n%% %s: Minimum, ',minVar));
            mlItem=strcat(mlItem,...
            sprintf(' %s: Maximum\n',maxVar));
            mlItem=strcat(mlItem,...
            sprintf('\n%% %s: Number of values\n',...
            numValVar));
            mlItem=strcat(mlItem,sprintf('\n%s = %s; ',...
            minVar,this.mMin));
            mlItem=strcat(mlItem,sprintf(' %s = %s; ',...
            maxVar,this.mMax));
            mlItem=strcat(mlItem,sprintf(' %s = %s;\n',...
            numValVar,this.mNumVals));
            mlItem=strcat(mlItem,sprintf(['\n%s = (randi(%s) - 1) ',...
            '* (%s - %s) / (%s - 1) + %s;'],...
            outVar,numValVar,maxVar,minVar,numValVar,minVar));
            mlcode=sprintf('%s\n',mlItem);

        end



    end



end


