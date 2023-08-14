classdef SequenceGenerator<slde.ddg.Pattern



    properties

        mSeqVal;
        mOutFormat;

    end


    methods


        function this=SequenceGenerator

            this.mSeqVal='[3 1 4 2 1 7 5 2]';
            this.mOutFormat=0;

        end


        function schema=getDialogSchema(this)


            row=1;
            wSequence.Type='edit';
            wSequence.Name='Sequence value:';
            wSequence.NameLocation=2;
            wSequence.Tag='SequenceValue';
            wSequence.Source=this;
            wSequence.ObjectProperty='mSeqVal';
            wSequence.RowSpan=[row,row];
            wSequence.ColSpan=[1,1];
            wSequence.Mode=false;
            wSequence.Graphical=true;
            wSequence.DialogRefresh=false;
            wSequence.ObjectMethod='handleEditActions';
            wSequence.MethodArgs={'%dialog','mSeqVal',...
            '%value'};
            wSequence.ArgDataTypes={'handle','string','string'};


            row=row+1;
            wOutOpt.Type='combobox';
            wOutOpt.Name='Output after final value:';
            wOutOpt.Entries={...
            'Repeat',...
            'Set to infinity',...
            'Set to zero',...
            };
            wOutOpt.Tag='OutOpt';
            wOutOpt.Source=this;
            wOutOpt.ObjectProperty='mOutFormat';
            wOutOpt.RowSpan=[row,row];
            wOutOpt.ColSpan=[1,1];
            wOutOpt.Mode=true;
            wOutOpt.DialogRefresh=false;
            wOutOpt.ObjectMethod='handleComboSelectionAction';
            wOutOpt.MethodArgs={'%dialog','mOutFormat',...
            '%value'};
            wOutOpt.ArgDataTypes={'handle','string','mxArray'};


            schema.Type='group';
            schema.Items={...
            wSequence,...
            wOutOpt,...
            };
            schema.LayoutGrid=[numel(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,numel(schema.Items)),1];

        end


        function mlcode=generate(this,dialog,existingVars,outVar)

            tabSpc='    ';
            seqName='SEQ';
            if any(strcmp(seqName,existingVars))
                seqName=this.updateVarName(seqName,existingVars);
            end

            idxVar='idx';
            if any(strcmp(idxVar,existingVars))
                idxVar=this.updateVarName(idxVar,existingVars);
            end

            mlItem=sprintf('');
            mlItem=strcat(mlItem,...
            sprintf('\npersistent %s;\n',seqName));
            mlItem=strcat(mlItem,...
            sprintf('\npersistent %s;\n',idxVar));
            mlItem=strcat(mlItem,sprintf('\nif isempty(%s)\n',seqName));
            mlItem=strcat(mlItem,sprintf('\n%s%s = %s;\n',tabSpc,...
            seqName,this.mSeqVal));
            mlItem=strcat(mlItem,sprintf('\n%s%s = 1;\n',tabSpc,idxVar));
            mlItem=strcat(mlItem,sprintf('\nend\n'));

            mlItem=strcat(mlItem,newline);
            mlItem=strcat(mlItem,sprintf('\nif %s > numel(%s)\n',...
            idxVar,seqName));
            if isequal(this.mOutFormat,0)
                mlItem=strcat(mlItem,sprintf('\n%s%s = 1;\n',...
                tabSpc,idxVar));
                mlItem=strcat(mlItem,sprintf('\nend\n'));
                mlItem=strcat(mlItem,sprintf('\n%s = %s(%s);\n',...
                outVar,seqName,idxVar));
            else
                if isequal(this.mOutFormat,1)
                    mlItem=strcat(mlItem,sprintf('\n%s%s = inf;\n',...
                    tabSpc,outVar));
                else
                    mlItem=strcat(mlItem,sprintf('\n%s%s = 0;\n',...
                    tabSpc,outVar));
                end
                mlItem=strcat(mlItem,sprintf('\nelse\n'));
                mlItem=strcat(mlItem,sprintf('\n%s%s = %s(%s);\n',...
                tabSpc,outVar,seqName,idxVar));
                mlItem=strcat(mlItem,sprintf('\nend\n'));
            end
            mlItem=strcat(mlItem,sprintf('\n%s = %s + 1;\n',...
            idxVar,idxVar));
            mlcode=sprintf('%s\n',mlItem);

        end


        function varName=updateVarName(this,varName,existingVars)

            tmpName='';
            for lID=1:10
                tmpName=sprintf('%s%d',varName,lID);
                if~any(strcmp(tmpName,existingVars))
                    break;
                end
            end

            varName=tmpName;

        end



    end


end

