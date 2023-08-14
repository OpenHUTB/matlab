classdef LognormalNumber<slde.ddg.Pattern





    properties

        mThreshold;
        mMu;
        mSigma;

    end


    methods


        function this=LognormalNumber

            this@slde.ddg.Pattern;
            this.mRequiresStatTbx=true;
            this.mThreshold='0';
            this.mMu='1';
            this.mSigma='1';

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
            wMu.Type='edit';
            wMu.Name='Mu:';
            wMu.Tag='Mu';
            wMu.Source=this;
            wMu.ObjectProperty='mMu';
            wMu.RowSpan=[row,row];
            wMu.ColSpan=[col,col];
            wMu.Mode=false;
            wMu.Graphical=true;
            wMu.DialogRefresh=false;
            wMu.ObjectMethod='handleEditActions';
            wMu.MethodArgs={'%dialog','mMu',...
            '%value'};
            wMu.ArgDataTypes={'handle','string','string'};


            row=row+1;
            wSigma.Type='edit';
            wSigma.Name='Sigma:';
            wSigma.Tag='Sigma';
            wSigma.Source=this;
            wSigma.ObjectProperty='mSigma';
            wSigma.RowSpan=[row,row];
            wSigma.ColSpan=[col,col];
            wSigma.Mode=false;
            wSigma.Graphical=true;
            wSigma.DialogRefresh=false;
            wSigma.ObjectMethod='handleEditActions';
            wSigma.MethodArgs={'%dialog','mSigma',...
            '%value'};
            wSigma.ArgDataTypes={'handle','string','string'};

            schema.Type='group';
            schema.Items={...
            wThreshold,...
            wMu,...
            wSigma,...
            };
            schema.LayoutGrid=[numel(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,numel(schema.Items)),1];

        end


        function mlcode=generate(this,dialog,existingVars,outVar)

            thresholdVar='T';
            muVar='mu';
            sigmaVar='S';
            mlItem=sprintf('');
            mlItem=strcat(mlItem,sprintf('\n%s = %s; ',muVar,...
            this.mMu));
            mlItem=strcat(mlItem,sprintf(' %s = %s; ',sigmaVar,...
            this.mSigma));
            mlItem=strcat(mlItem,sprintf(' %s = %s;\n',...
            thresholdVar,this.mThreshold));
            mlItem=strcat(mlItem,...
            sprintf('\n%s = %s + lognrnd(%s, %s);',...
            outVar,thresholdVar,muVar,sigmaVar));
            mlcode=sprintf('%s\n',mlItem);

        end



    end



end


