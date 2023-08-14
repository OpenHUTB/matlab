classdef BinomialNumber<slde.ddg.Pattern





    properties

        mProb;
        mNumTrials;

    end


    methods


        function this=BinomialNumber


            this@slde.ddg.Pattern;
            this.mProb='0.25';
            this.mNumTrials='1';
            this.mRequiresStatTbx=true;

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


            row=row+1;
            wNumTrials.Type='edit';
            wNumTrials.Name='Number of trials:';
            wNumTrials.Tag='NumTrials';
            wNumTrials.Source=this;
            wNumTrials.ObjectProperty='mNumTrials';
            wNumTrials.RowSpan=[row,row];
            wNumTrials.ColSpan=[col,col];
            wNumTrials.Mode=false;
            wNumTrials.Graphical=true;
            wNumTrials.DialogRefresh=false;
            wNumTrials.ObjectMethod='handleEditActions';
            wNumTrials.MethodArgs={'%dialog','mNumTrials',...
            '%value'};
            wNumTrials.ArgDataTypes={'handle','string','string'};

            schema.Type='group';
            schema.Items={...
            wProb,...
            wNumTrials,...
            };
            schema.LayoutGrid=[numel(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,numel(schema.Items)),1];

        end


        function mlcode=generate(this,dialog,existingVars,outVar)

            probVar='P';
            numTrialVar='N';
            mlItem=sprintf('');
            mlItem=strcat(mlItem,sprintf(['\n%% %s: ',...
            'Probability of success in a single trial\n'],probVar));
            mlItem=strcat(mlItem,sprintf(['\n%% %s: Number ',...
            'of trials\n'],numTrialVar));
            mlItem=strcat(mlItem,sprintf('\n%s = %s;\n',...
            probVar,this.mProb));
            mlItem=strcat(mlItem,sprintf(' %s = %s;\n',...
            numTrialVar,this.mNumTrials));
            mlItem=strcat(mlItem,sprintf(...
            '\n%s = binornd(%s, %s);\n',outVar,numTrialVar,...
            probVar));
            mlcode=sprintf('%s\n',mlItem);

        end



    end



end


