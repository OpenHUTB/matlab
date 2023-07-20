classdef ArbitraryContinuousNumber<slde.ddg.Pattern





    properties

        mValVector;
        mCPDF;

    end


    methods


        function this=ArbitraryContinuousNumber

            this@slde.ddg.Pattern;
            this.mValVector='[0 1]';
            this.mCPDF='[0 1]';

        end


        function schema=getDialogSchema(this)


            row=1;
            col=1;
            wValVector.Type='edit';
            wValVector.Name='Value vector:';
            wValVector.Tag='ValueVector';
            wValVector.Source=this;
            wValVector.ObjectProperty='mValVector';
            wValVector.RowSpan=[row,row];
            wValVector.ColSpan=[col,col];
            wValVector.Mode=false;
            wValVector.Graphical=true;
            wValVector.DialogRefresh=false;
            wValVector.ObjectMethod='handleEditActions';
            wValVector.MethodArgs={'%dialog','mValVector',...
            '%value'};
            wValVector.ArgDataTypes={'handle','string','string'};


            row=row+1;
            wCPDF.Type='edit';
            wCPDF.Name=...
            'Cumulative probability function vector:';
            wCPDF.Tag='CumulativePDF';
            wCPDF.Source=this;
            wCPDF.ObjectProperty='mCPDF';
            wCPDF.RowSpan=[row,row];
            wCPDF.ColSpan=[col,col];
            wCPDF.Mode=false;
            wCPDF.Graphical=true;
            wCPDF.DialogRefresh=false;
            wCPDF.ObjectMethod='handleEditActions';
            wCPDF.MethodArgs={'%dialog','mCPDF',...
            '%value'};
            wCPDF.ArgDataTypes={'handle','string','string'};

            schema.Type='group';
            schema.Items={...
            wValVector,...
            wCPDF,...
            };
            schema.LayoutGrid=[numel(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,numel(schema.Items)),1];

        end


        function mlcode=generate(this,dialog,existingVars,outVar)

            tabSpc='    ';
            valVectorVar='V';
            cpdfVar='P';
            mlItem=sprintf('\n%% Arbitrary continuous random number\n');
            mlItem=strcat(mlItem,...
            sprintf('\n%% Value vector = %s\n',this.mValVector));
            mlItem=strcat(mlItem,...
            sprintf(...
            '\n%% Cumulative probability function vector = %s\n',...
            this.mCPDF));
            mlItem=strcat(mlItem,sprintf('\n%s = %s;\n',...
            valVectorVar,this.mValVector));
            mlItem=strcat(mlItem,sprintf('\n%s = %s;\n',...
            cpdfVar,this.mCPDF));
            mlItem=strcat(mlItem,sprintf('\nr = rand;'));
            mlItem=strcat(mlItem,sprintf('\nif r == 0\n'));
            mlItem=strcat(mlItem,sprintf('\n%s%s = V(1);\n',...
            tabSpc,outVar));
            mlItem=strcat(mlItem,sprintf('\nelse\n'));
            mlItem=strcat(mlItem,...
            sprintf('\n%sidx = find(r < %s, 1);\n',tabSpc,cpdfVar));
            mlItem=strcat(mlItem,...
            sprintf(['\n%s%s = V(idx - 1) + ',...
            ' (V(idx) - V(idx - 1)) * ',...
            ' (r - %s(idx - 1));\n'],tabSpc,outVar,cpdfVar));
            mlItem=strcat(mlItem,sprintf('\nend\n'));
            mlcode=sprintf('%s\n',mlItem);

        end



    end



end

