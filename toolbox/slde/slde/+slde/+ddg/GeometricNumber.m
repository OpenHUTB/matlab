classdef GeometricNumber<slde.ddg.Pattern





    properties

        mProb;

    end


    methods


        function this=GeometricNumber

            this@slde.ddg.Pattern;
            this.mRequiresStatTbx=true;
            this.mProb='0.5';

        end


        function schema=getDialogSchema(this)


            row=1;
            col=1;
            wProb.Type='edit';
            wProb.Name=...
            'Probability of success in a single trial:';
            wProb.Tag='ProbabilityTrue';
            wProb.Source=this;
            wProb.ObjectProperty='mProb';
            wProb.RowSpan=[row,row];
            wProb.ColSpan=[col,col];
            wProb.Mode=false;
            wProb.Graphical=true;
            wProb.DialogRefresh=false;
            wProb.ObjectMethod='handleEditActions';
            wProb.MethodArgs={'%dialog','mProb',...
            '%value'};
            wProb.ArgDataTypes={'handle','string','string'};

            schema.Type='group';
            schema.Items={...
            wProb,...
            };
            schema.LayoutGrid=[numel(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,numel(schema.Items)),1];

        end


        function mlcode=generate(this,dialog,existingVars,outVar)

            probVar='P';
            mlItem=sprintf('');
            mlItem=strcat(mlItem,sprintf(...
            '\n%% %s: Probability of success in a single trial\n',...
            probVar));
            mlItem=strcat(mlItem,sprintf('\n%s = %s;\n',...
            probVar,this.mProb));
            mlItem=strcat(mlItem,sprintf(...
            '\n%s = geornd(%s);\n',outVar,probVar));
            mlcode=sprintf('%s\n',mlItem);

        end



    end



end

