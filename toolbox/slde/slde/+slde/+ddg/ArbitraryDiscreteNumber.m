classdef ArbitraryDiscreteNumber<slde.ddg.Pattern





    properties

        mValVector;
        mProbVector;

    end


    methods


        function this=ArbitraryDiscreteNumber

            this@slde.ddg.Pattern;
            this.mValVector='[0 1]';
            this.mProbVector='[0.5 0.5]';

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
            wProbVector.Type='edit';
            wProbVector.Name='Probability vector:';
            wProbVector.Tag='ProbabilityVector';
            wProbVector.Source=this;
            wProbVector.ObjectProperty='mProbVector';
            wProbVector.RowSpan=[row,row];
            wProbVector.ColSpan=[col,col];
            wProbVector.Mode=false;
            wProbVector.Graphical=true;
            wProbVector.DialogRefresh=false;
            wProbVector.ObjectMethod='handleEditActions';
            wProbVector.MethodArgs={'%dialog','mProbVector',...
            '%value'};
            wProbVector.ArgDataTypes={'handle','string','string'};

            schema.Type='group';
            schema.Items={...
            wValVector,...
            wProbVector,...
            };
            schema.LayoutGrid=[numel(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,numel(schema.Items)),1];

        end


        function mlcode=generate(this,dialog,existingVars,outVar)

            valVectorVar='V';
            probVecVar='P';
            mlItem=sprintf('');
            mlItem=strcat(mlItem,...
            sprintf('\n%% %s: Value vector\n',valVectorVar));
            mlItem=strcat(mlItem,...
            sprintf('\n%% %s: Probability vector\n',...
            probVecVar));
            mlItem=strcat(mlItem,sprintf('\n%s = %s;\n',...
            valVectorVar,this.mValVector));
            mlItem=strcat(mlItem,sprintf('\n%s = %s;\n',...
            probVecVar,this.mProbVector));
            mlItem=strcat(mlItem,sprintf(['\n%s = randsample(',...
            '%s, 1, true, %s);\n'],outVar,valVectorVar,...
            probVecVar));
            mlcode=sprintf('%s\n',mlItem);

        end



    end



end

