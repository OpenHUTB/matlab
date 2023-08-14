classdef PatternAssistant<handle
















    properties

        mPttrnChoice;
        mSeed;
        mPattern;
        mPatternName;
        mPatternDistribution;
        mOutVar;
        mParentBlkDlg;
        mWidgetTag;
        mEditTimeAttribs;
        mCurrentEntry;
        mExistingVars;
        mReqStatTbs;
        evDDGDialog;
    end


    methods


        function this=PatternAssistant(parentBlkDlg,wdgtTag,evDDGDialog)

            this.mPttrnChoice=0;
            this.mSeed='12345';
            this.mPattern=[];
            this.mPatternDistribution=0;
            this.mOutVar='x';
            this.mParentBlkDlg=parentBlkDlg;
            this.mWidgetTag=wdgtTag;
            this.evDDGDialog=evDDGDialog;

        end


        function schema=getDialogSchema(this)


            this.mEditTimeAttribs=this.getEditTimeAttributes();


            this.mCurrentEntry=this.getCurrentContents();


            this.mExistingVars=this.getExistingVars();


            row=1;
            wPttrnPanel=this.getPatternPanelSchema();
            wPttrnPanel.RowSpan=[row,row];


            row=row+1;
            wPttrnProperties=this.getPatternPropertiesSchema();
            wPttrnProperties.RowSpan=[row,row];


            row=row+1;
            wPttrnAssignedToVar=this.getPatternAssignedToVarSchema();
            wPttrnAssignedToVar.RowSpan=[row,row];


            wPrimaryWdgts.Name='';
            wPrimaryWdgts.Type='group';
            wPrimaryWdgts.Items={...
            wPttrnPanel,...
            wPttrnProperties,...
            wPttrnAssignedToVar,...
            };


            row=row+1;
            wButtonSet=this.getButtonSetSchema();
            wButtonSet.RowSpan=[row,row];


            schema.DialogTitle='Event Actions Assistant';
            schema.Items={...
            wPrimaryWdgts,...
            wButtonSet,...
            };

            schema.Sticky=true;
            schema.StandaloneButtonSet={wButtonSet};
            schema.LayoutGrid=[numel(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,numel(schema.Items)),1];

        end



    end


    methods(Access=private)


        function wPatternPanel=getPatternPanelSchema(this)


            row=1;
            col=1;
            wPttrnChoice.Name='Pattern:';
            wPttrnChoice.Type='combobox';
            wPttrnChoice.Entries={...
            '< Select a pattern >',...
            'Repeating sequence',...
            'Random number',...
            };
            wPttrnChoice.Tag='PatternChoice';
            wPttrnChoice.ObjectProperty='mPttrnChoice';
            wPttrnChoice.Source=this;
            wPttrnChoice.RowSpan=[row,row];
            wPttrnChoice.ColSpan=[col,col];
            wPttrnChoice.Mode=true;
            wPttrnChoice.DialogRefresh=true;
            wPttrnChoice.ObjectMethod='handleComboSelectionAction';
            wPttrnChoice.MethodArgs={'%dialog','mPttrnChoice',...
            '%value'};
            wPttrnChoice.ArgDataTypes={'handle','string','mxArray'};

            isRNGPattern=isequal(this.mPttrnChoice,2);

            row=row+1;
            wSeed.Type='edit';
            wSeed.Name='Seed:';
            wSeed.Tag='Seed';
            wSeed.Source=this;
            wSeed.ObjectProperty='mSeed';
            wSeed.Mode=false;
            wSeed.Graphical=true;
            wSeed.DialogRefresh=false;
            wSeed.RowSpan=[row,row];
            wSeed.ColSpan=[col,col];
            wSeed.Visible=isRNGPattern;
            wSeed.ObjectMethod='handleEditActions';
            wSeed.MethodArgs={'%dialog','mSeed','%value'};
            wSeed.ArgDataTypes={'handle','string','string'};

            row=row+1;
            wDistribution.Name='Distribution:';
            wDistribution.Type='combobox';
            wDistribution.Entries={...
            'Exponential',...
            'Bernoulli',...
            'Uniform',...
            'Binomial',...
            'Gamma',...
            'Gaussian (normal)',...
            'Geometric',...
            'Poisson',...
            'Lognormal',...
            'Beta',...
            'Discrete uniform',...
            'Weibull',...
            'Arbitrary continuous',...
            'Arbitrary discrete',...
            };
            wDistribution.Tag='PatternDistribution';
            wDistribution.ObjectProperty='mPatternDistribution';
            wDistribution.Mode=true;
            wDistribution.Source=this;
            wDistribution.DialogRefresh=true;
            wDistribution.ObjectMethod='handleComboSelectionAction';
            wDistribution.MethodArgs={'%dialog',...
            'mPatternDistribution','%value'};
            wDistribution.ArgDataTypes={'handle','string','mxArray'};
            wDistribution.Visible=isRNGPattern;
            wDistribution.RowSpan=[row,row];
            wDistribution.ColSpan=[col,col];

            wPatternPanel.Name='Pattern';
            wPatternPanel.Type='panel';
            wPatternPanel.Items={...
            wPttrnChoice,...
            wSeed,...
            wDistribution,...
            };
            wPatternPanel.LayoutGrid=[numel(wPatternPanel.Items)+1,1];
            wPatternPanel.RowStretch=[zeros(1,numel(wPatternPanel.Items)),1];

        end


        function pttrnProperties=getPatternPropertiesSchema(this)



            this.mPattern=createPattern(this);
            this.mReqStatTbs=this.mPattern.mRequiresStatTbx;
            pttrnProperties=this.mPattern.getDialogSchema();
            pttrnProperties.Visible=~isequal(this.mPttrnChoice,0);

        end


        function wAssignOutTo=getPatternAssignedToVarSchema(this)


            nAttribs=numel(this.mEditTimeAttribs);
            nVars=numel(this.mExistingVars);
            entries=cell(1,nAttribs+nVars+2);




            entries{1}=this.updateVarName('x',this.mExistingVars);
            this.mOutVar=entries{1};

            for idx=1:nVars
                cVar=this.mExistingVars{idx};
                if strcmp(cVar,'entity')||strcmp(cVar,'entitySys')
                    continue;
                end
                entries{idx+1}=cVar;
            end

            idxVal=1+nVars;
            for idx=(idxVal+1):(idxVal+nAttribs)
                cAttrib=this.mEditTimeAttribs{idx-idxVal};
                if strcmp(cAttrib,'entity')
                    continue;
                end
                entries{idx}=strcat('entity.',cAttrib);
            end

            entries{end}='entitySys.priority';


            entries=entries(~cellfun(@isempty,entries));


            row=1;
            col=1;
            wAssignOutTo.Type='combobox';
            wAssignOutTo.Name='Assign output to:';
            wAssignOutTo.Tag='AssignOutputTo';
            wAssignOutTo.Entries=entries;
            wAssignOutTo.Source=this;
            wAssignOutTo.ObjectProperty='mOutVar';
            wAssignOutTo.RowSpan=[row,row];
            wAssignOutTo.ColSpan=[col,col];
            wAssignOutTo.Mode=false;
            wAssignOutTo.Graphical=true;
            wAssignOutTo.DialogRefresh=false;
            wAssignOutTo.Visible=~isequal(this.mPttrnChoice,0);
            wAssignOutTo.Editable=true;
            wAssignOutTo.ObjectMethod='handleEditActions';
            wAssignOutTo.MethodArgs={'%dialog','mOutVar',...
            '%value'};
            wAssignOutTo.ArgDataTypes={'handle','string','string'};

        end


        function buttonSetPanel=getButtonSetSchema(this)


            row=1;
            bttnGenerate.Type='pushbutton';
            bttnGenerate.Name='OK';
            bttnGenerate.Tag='GenerateCode';
            bttnGenerate.Source=this;
            bttnGenerate.ObjectMethod='generate';
            bttnGenerate.MethodArgs={'%dialog'};
            bttnGenerate.ArgDataTypes={'handle'};
            bttnGenerate.RowSpan=[row,row];
            bttnGenerate.ColSpan=[1,3];
            bttnGenerate.Enabled=~isequal(this.mPttrnChoice,0);
            bttnGenerate.DialogRefresh=false;
            bttnGenerate.Graphical=false;


            bttnCancel.Type='pushbutton';
            bttnCancel.Name='Cancel';
            bttnCancel.Tag='Cancel';
            bttnCancel.Source=this;
            bttnCancel.ObjectMethod='cancel';
            bttnCancel.MethodArgs={'%dialog'};
            bttnCancel.ArgDataTypes={'handle'};
            bttnCancel.RowSpan=[row,row];
            bttnCancel.ColSpan=[4,6];
            bttnCancel.Visible=true;
            bttnCancel.DialogRefresh=false;
            bttnCancel.Graphical=false;


            bttnHelp.Type='pushbutton';
            bttnHelp.Name='Help';
            bttnHelp.Tag='Help';
            bttnHelp.Source=this;
            bttnHelp.ObjectMethod='help';
            bttnHelp.MethodArgs={'%dialog'};
            bttnHelp.ArgDataTypes={'handle'};
            bttnHelp.RowSpan=[row,row];
            bttnHelp.ColSpan=[8,8];
            bttnHelp.Visible=true;
            bttnHelp.DialogRefresh=false;
            bttnHelp.Graphical=false;


            buttonSetPanel.Type='panel';
            buttonSetPanel.Tag='ActionButtons';
            buttonSetPanel.Items={...
            bttnHelp,...
            bttnGenerate,...
            bttnCancel,...
            };
            buttonSetPanel.LayoutGrid=[numel(buttonSetPanel.Items)+1,1];
            buttonSetPanel.RowStretch=[zeros(1,numel(buttonSetPanel.Items)),1];
            buttonSetPanel.RowSpan=[1,1];
            buttonSetPanel.ColSpan=[1,2];

        end


        function patternObj=createPattern(this)


            switch this.mPttrnChoice

            case 0
                this.mPatternName='Repeating Sequence';
                patternObj=slde.ddg.SequenceGenerator;

            case 1
                this.mPatternName='Repeating Sequence';
                patternObj=slde.ddg.SequenceGenerator;

            case 2

                switch this.mPatternDistribution

                case 0
                    this.mPatternName='Exponential distribution';
                    patternObj=slde.ddg.ExponentialNumber;

                case 1
                    this.mPatternName='Bernoulli distribution';
                    patternObj=slde.ddg.BernoulliNumber;

                case 2
                    this.mPatternName='Uniform distribution';
                    patternObj=slde.ddg.UniformNumber;

                case 3
                    this.mPatternName='Binomial distribution';
                    patternObj=slde.ddg.BinomialNumber;

                case 4
                    this.mPatternName='Gamma distribution';
                    patternObj=slde.ddg.GammaNumber;

                case 5
                    this.mPatternName='Gaussian (normal) distribution';
                    patternObj=slde.ddg.GaussianNormalNumber;

                case 6
                    this.mPatternName='Geometric distribution';
                    patternObj=slde.ddg.GeometricNumber;

                case 7
                    this.mPatternName='Poisson distribution';
                    patternObj=slde.ddg.PoissonNumber;

                case 8
                    this.mPatternName='Lognormal distribution';
                    patternObj=slde.ddg.LognormalNumber;

                case 9
                    this.mPatternName='Beta distribution';
                    patternObj=slde.ddg.BetaNumber;

                case 10
                    this.mPatternName='Discrete uniform distribution';
                    patternObj=slde.ddg.DiscreteUniformNumber;

                case 11
                    this.mPatternName='Weibull distribution';
                    patternObj=slde.ddg.WeibullNumber;

                case 12
                    this.mPatternName='Arbitrary continuous distribution';
                    patternObj=slde.ddg.ArbitraryContinuousNumber;

                case 13
                    this.mPatternName='Arbitrary discrete distribution';
                    patternObj=slde.ddg.ArbitraryDiscreteNumber;
                end

            otherwise
                patternObj=[];
            end
        end


        function editTimeAttribs=getEditTimeAttributes(this)





            if strcmp(get_param(this.mParentBlkDlg.getDialogSource,...
                'BlockType'),'EntityGenerator')
                editTimeAttribs=this.getGeneratorAttributes(...
                this.mParentBlkDlg.getDialogSource);
            else
                sigHier=this.getSigHierFromPort();
                editTimeAttribs=this.getEditTimeAttributesHelper(...
                sigHier,'');
            end

        end


        function attribs=getGeneratorAttributes(this,tbegSrc)







            unused_variable(this);
            tbegHndl=get_param(tbegSrc,'Handle');
            attribsInRawFormat=get_param(tbegHndl,'AttributeName');
            if isempty(attribsInRawFormat)
                attribs={};
            else




                tmpAttribsMarker=regexp(attribsInRawFormat,'\|');
                if isempty(tmpAttribsMarker)

                    attribs={attribsInRawFormat};
                else


                    attribs=cell(1,numel(tmpAttribsMarker)+1);
                    startIdx=1;
                    for idx=1:numel(tmpAttribsMarker)


                        endIdx=tmpAttribsMarker(idx);
                        attribs{idx}=attribsInRawFormat(...
                        startIdx:(endIdx-1));
                        startIdx=endIdx+1;
                    end


                    attribs{end}=attribsInRawFormat(startIdx:end);
                end
            end
        end


        function editTimeAttribs=getEditTimeAttributesHelper(this,...
            sigHier,sigName)



            editTimeAttribs={};
            if(~isempty(sigHier))
                for j=1:numel(sigHier)
                    attribs=sigHier(j);

                    if(~isempty(attribs))
                        for i=1:length(attribs)
                            if(isempty(sigName))
                                editTimeAttribs=...
                                [editTimeAttribs,...
                                this.getEditTimeAttributesHelper(...
                                attribs(i).Children,...
                                attribs(i).SignalName)];%#ok<AGROW>
                            else
                                editTimeAttribs=...
                                [editTimeAttribs,...
                                this.getEditTimeAttributesHelper(...
                                attribs(i).Children,...
                                strcat(sigName,'.',...
                                attribs(i).SignalName))];%#ok<AGROW>
                            end
                        end
                    else
                        if(isempty(sigName))



                            editTimeAttribs(end+1)={...
                            sigHier(j).SignalName};%#ok<AGROW>
                        else
                            editTimeAttribs(end+1)={strcat(sigName,...
                            '.',sigHier(j).SignalName)};%#ok<AGROW>
                        end
                    end
                end
            elseif(isempty(sigName))

                editTimeAttribs(end+1)={'entity'};
            else
                editTimeAttribs(end+1)={sigName};
            end

            editTimeAttribs=unique(editTimeAttribs);

        end


        function sigHier=getSigHierFromPort(this)

            sigHier=this.evDDGDialog.getSigHierFromPort();
        end



    end


    methods


        function generate(this,dialog)



            if this.mReqStatTbs&&~license('test','Statistics_Toolbox')
                statTbxFlag=sprintf('\n%% Requires Statistics Toolbox\n');
            else
                statTbxFlag=newline;
            end
            startFlag=sprintf('\n\n%% Pattern: %s\n',...
            this.mPatternName);
            seedEntry=getSeedEntry(this);
            rngEntry=this.mPattern.generate(dialog,...
            this.mExistingVars,this.mOutVar);


            if isequal(this.mPttrnChoice,2)
                updatedEntry=strcat(this.mCurrentEntry,seedEntry,...
                startFlag,statTbxFlag,rngEntry);
            else
                updatedEntry=strcat(this.mCurrentEntry,startFlag,...
                statTbxFlag,rngEntry);
            end


            this.mParentBlkDlg.setWidgetValue(this.mWidgetTag,...
            updatedEntry);


            dialog.delete;

        end


        function help(this,dialog)

            unused_variable(this);
            unused_variable(dialog);
            helpview(fullfile(docroot,'simevents','helptargets.map'),...
            'eventaction_help');

        end


        function seedEntry=getSeedEntry(this)

            seedEntry='';


            currentCode=mtree(this.mCurrentEntry);
            rngFunc=mtfind(currentCode,'Fun','rng');



            if isempty(rngFunc)
                tabSpc='    ';
                rngVar='rngInit';
                seedEntry=sprintf('\npersistent %s;\n',rngVar);
                seedEntry=strcat(seedEntry,...
                sprintf('\nif isempty(%s)\n',rngVar));
                seedEntry=strcat(seedEntry,...
                sprintf('\n%sseed = %s;\n',tabSpc,this.mSeed));
                seedEntry=strcat(seedEntry,...
                sprintf('\n%srng(seed);\n',tabSpc));
                seedEntry=strcat(seedEntry,...
                sprintf('\n%s%s = true;\n',tabSpc,rngVar));
                seedEntry=strcat(seedEntry,sprintf('\nend\n'));
            end

        end


        function cancel(this,dialog)

            unused_variable(this);
            dialog.delete;

        end


        function currentEntry=getCurrentContents(this)

            currentEntry=this.mParentBlkDlg.getWidgetValue(...
            this.mWidgetTag);

        end


        function vars=getExistingVars(this)

            vars={};


            currentCode=mtree(this.mCurrentEntry);
            varsAlreadyPresent=currentCode.asgvars;
            if~isempty(varsAlreadyPresent)
                vars=strings(varsAlreadyPresent);
            end

        end


        function handleEditActions(this,dialog,param,value)

            unused_variable(dialog);
            this.(param)=value;

        end


        function handleComboSelectionAction(this,dialog,param,value)

            unused_variable(dialog);
            this.(param)=value;

        end


        function varName=updateVarName(this,varName,existingVars)

            unused_variable(this);
            if~any(strcmp(varName,existingVars))
                return;
            end





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




function unused_variable(varargin)

end


