function dlgstruct=getDialogSchema(this,name)%#ok<INUSD>





    tag='Tag_TflViewer_';

    switch this.Type
    case 'TflCustomization'

        lineN=1;
        DscLbl.Name=DAStudio.message('RTW:tfl:DescriptionText');
        DscLbl.Type='text';
        DscLbl.RowSpan=[lineN,lineN];
        DscLbl.ColSpan=[1,2];
        Dsc.Name=this.Content.Description;
        Dsc.Type='text';
        Dsc.RowSpan=[lineN,lineN];
        Dsc.ColSpan=[4,5];


        lineN=lineN+1;
        KeyLbl.Name=DAStudio.message('RTW:tfl:Key');
        KeyLbl.Type='text';
        KeyLbl.RowSpan=[lineN,lineN];
        KeyLbl.ColSpan=[1,2];
        Key.Name=[this.Content.Key,' with ',num2str(max(0,length(this.Content.ConceptualArgs)-1)),' input(s)'];
        Key.Type='text';
        Key.RowSpan=[lineN,lineN];
        Key.ColSpan=[4,5];


        lineN=lineN+1;
        ArrayLayoutLbl.Name=DAStudio.message('RTW:tfl:ArrayLayout');
        ArrayLayoutLbl.Type='text';
        ArrayLayoutLbl.RowSpan=[lineN,lineN];
        ArrayLayoutLbl.ColSpan=[1,2];
        ArrayLayout.Name='';
        if this.Content.containMatrix
            ArrayLayout.Name=this.Content.ArrayLayout;
        end
        ArrayLayout.Type='text';
        ArrayLayout.RowSpan=[lineN,lineN];
        ArrayLayout.ColSpan=[4,5];


        lineN=lineN+1;
        SatModeLbl.Name=DAStudio.message('RTW:tfl:SaturationMode');
        SatModeLbl.Type='text';
        SatModeLbl.RowSpan=[lineN,lineN];
        SatModeLbl.ColSpan=[1,2];
        SatMode.Name=this.Content.SaturationMode;
        SatMode.Type='text';
        SatMode.RowSpan=[lineN,lineN];
        SatMode.ColSpan=[4,5];

        lineN=lineN+1;
        RndModeLbl.Name=DAStudio.message('RTW:tfl:RoundingModes');
        RndModeLbl.Type='text';
        RndModeLbl.RowSpan=[lineN,lineN];
        RndModeLbl.ColSpan=[1,2];
        RndMode.Name=this.Content.RoundingMode;
        RndMode.Type='text';
        RndMode.RowSpan=[lineN,lineN];
        RndMode.ColSpan=[4,5];

        lineN=lineN+1;
        InlineLbl.Name=DAStudio.message('RTW:tfl:InlineFunction');
        InlineLbl.Type='text';
        InlineLbl.RowSpan=[lineN,lineN];
        InlineLbl.ColSpan=[1,2];
        if this.Content.InlineFcn
            InlineFcnName=DAStudio.message('RTW:tfl:yes');
        else
            InlineFcnName=DAStudio.message('RTW:tfl:no');
        end
        InlineMode.Name=InlineFcnName;
        InlineMode.Type='text';
        InlineMode.RowSpan=[lineN,lineN];
        InlineMode.ColSpan=[4,5];

        lineN=lineN+1;
        NonFiniteLbl.Name=DAStudio.message('RTW:tfl:SupportNonFinite');
        NonFiniteLbl.Type='text';
        NonFiniteLbl.RowSpan=[lineN,lineN];
        NonFiniteLbl.ColSpan=[1,2];
        NonFiniteMode.Name=this.Content.SupportNonFinite;
        NonFiniteMode.Type='text';
        NonFiniteMode.RowSpan=[lineN,lineN];
        NonFiniteMode.ColSpan=[4,5];


        lineN=lineN+1;
        AllowShapeAgnosticMatchLbl.Name=DAStudio.message('RTW:tfl:AllowShapeAgnosticMatch');
        AllowShapeAgnosticMatchLbl.Type='text';
        AllowShapeAgnosticMatchLbl.RowSpan=[lineN,lineN];
        AllowShapeAgnosticMatchLbl.ColSpan=[1,2];
        AllowShapeAgnosticMatch.Name='';
        if this.Content.containMatrix
            if this.Content.AllowShapeAgnosticMatch
                AllowShapeAgnosticMatch.Name=DAStudio.message('RTW:tfl:yes');
            else
                AllowShapeAgnosticMatch.Name=DAStudio.message('RTW:tfl:no');
            end
        else
            AllowShapeAgnosticMatch.Name=DAStudio.message('RTW:tfl:notApplicable');
        end
        AllowShapeAgnosticMatch.Type='text';
        AllowShapeAgnosticMatch.RowSpan=[lineN,lineN];
        AllowShapeAgnosticMatch.ColSpan=[4,5];


        generalSpcCol.Name='     ';
        generalSpcCol.Type='text';
        generalSpcCol.RowSpan=[lineN,lineN];
        generalSpcCol.ColSpan=[3,3];



        grpGeneral.Name=DAStudio.message('RTW:tfl:SummaryText');
        grpGeneral.Type='group';
        grpGeneral.LayoutGrid=[lineN,5];
        grpGeneral.ColStretch=[0,0,0,1,1];
        grpGeneral.Items={...
        DscLbl,Dsc,...
        KeyLbl,Key,...
        ArrayLayoutLbl,ArrayLayout,...
        SatModeLbl,SatMode,...
        RndModeLbl,RndMode,...
        InlineLbl,InlineMode,...
        NonFiniteLbl,NonFiniteMode,...
        AllowShapeAgnosticMatchLbl,AllowShapeAgnosticMatch,...
        generalSpcCol};

        tabGeneral.Name=DAStudio.message('RTW:tfl:GeneralInformation');
        tabGeneral.Items={grpGeneral};

        entryTab.Tabs={tabGeneral};

        entryTab.Name='TABS';
        entryTab.Type='tab';
        entryTab.LayoutGrid=[1,1];
        entryTab.RowSpan=[1,2];
        entryTab.ColSpan=[1,5];





        numConceptualArgs=length(this.Content.ConceptualArgs);

        ArgsTbl=[];
        ArgsTbl.Name='';
        ArgsTbl.Type='textbrowser';
        ArgsTbl.Enabled=true;
        ArgsTbl.Editable=false;



        CncptlArgNames={this.Content.ConceptualArgs.Name};
        if~iscell(CncptlArgNames)
            ConceptualData(1:numConceptualArgs,1)={CncptlArgNames};
        else
            ConceptualData(1:numConceptualArgs,1)=CncptlArgNames;
        end

        CncptlArgIOTypes={this.Content.ConceptualArgs.IOType};
        if~iscell(CncptlArgIOTypes)
            ConceptualData(1:numConceptualArgs,2)={CncptlArgIOTypes};
        else
            ConceptualData(1:numConceptualArgs,2)=CncptlArgIOTypes;
        end

        for idx=1:numConceptualArgs
            tmpType=this.Content.ConceptualArgs(idx).toString;
            if~isempty(tmpType)
                ConceptualData(idx,3)={tmpType};
            else
                ConceptualData(idx,3)={this.Content.ConceptualArgs(idx).Type.tostring};
            end
        end

        ConceptualTable=Advisor.Table(numConceptualArgs,3);
        ConceptualTable.setColHeading(1,'Name');
        ConceptualTable.setColHeading(2,'I/O type');
        ConceptualTable.setColHeading(3,'Data type');
        ConceptualTable.setBorder(1);
        for i=1:numConceptualArgs
            col1=ConceptualData(i,1);
            col2=ConceptualData(i,2);
            col3=ConceptualData(i,3);
            ConceptualTable.setEntry(i,1,(col1{1}));
            ConceptualTable.setEntry(i,2,(col2{1}));
            ConceptualTable.setEntry(i,3,(col3{1}));
        end
        CncptHTML=ConceptualTable.emitHTML;
        CncptHTML=['<b>Conceptual argument(s):</b><br>',CncptHTML];

        ArgsTbl.Text=['<br>',CncptHTML];
        ArgsTbl.RowSpan=[1,1];
        ArgsTbl.ColSpan=[1,1];

        grpArg.Type='group';
        grpArg.Name=DAStudio.message('RTW:tfl:EntryArguments');
        grpArg.RowSpan=[3,5];
        grpArg.ColSpan=[1,5];
        grpArg.LayoutGrid=[1,1];
        grpArg.RowStretch=0;
        grpArg.Items={ArgsTbl};

        HelpButton.Name=DAStudio.message('RTW:tfl:HelpText');
        HelpButton.Type='pushbutton';
        HelpButton.ObjectMethod='dialogCallback';
        HelpButton.MethodArgs={'Help'};
        HelpButton.ArgDataTypes={'string'};
        HelpButton.RowSpan=[6,6];
        HelpButton.ColSpan=[4,4];
        HelpButton.Enabled=true;
        HelpButton.Visible=true;

        CloseButton.Name=DAStudio.message('RTW:tfl:CloseText');
        CloseButton.Type='pushbutton';
        CloseButton.ObjectMethod='dialogCallback';
        CloseButton.MethodArgs={'Close'};
        CloseButton.ArgDataTypes={'string'};
        CloseButton.RowSpan=[6,6];
        CloseButton.ColSpan=[5,5];





        dlgstruct.DialogTitle=this.Content.Key;
        dlgstruct.Items={grpArg,entryTab,HelpButton,CloseButton};
        dlgstruct.LayoutGrid=[6,1];
        dlgstruct.RowStretch=[0,0,1,1,1,0];
        dlgstruct.EmbeddedButtonSet={''};
    case 'TflEntry'
        thisImpl={};
        isaBlockEntry=true;
        if~isa(this.Content,'RTW.TflBlockEntry')
            thisImpl=this.Content.Implementation;
            isaBlockEntry=false;
        end




        lineN=1;
        DscLbl.Name=DAStudio.message('RTW:tfl:DescriptionText');
        DscLbl.Type='text';
        DscLbl.RowSpan=[lineN,lineN];
        DscLbl.ColSpan=[1,2];
        Dsc.Name=this.Content.Description;
        Dsc.Type='text';
        Dsc.RowSpan=[lineN,lineN];
        Dsc.ColSpan=[4,5];


        lineN=lineN+1;
        KeyLbl.Name=DAStudio.message('RTW:tfl:Key');
        KeyLbl.Type='text';
        KeyLbl.RowSpan=[lineN,lineN];
        KeyLbl.ColSpan=[1,2];
        Key.Name=[this.Content.Key,' with ',num2str(max(0,length(this.Content.ConceptualArgs)-1)),' input(s)'];
        Key.Type='text';
        Key.RowSpan=[lineN,lineN];
        Key.ColSpan=[4,5];


        lineN=lineN+1;
        ArrayLayoutLbl.Name=DAStudio.message('RTW:tfl:ArrayLayout');
        ArrayLayoutLbl.Type='text';
        ArrayLayoutLbl.RowSpan=[lineN,lineN];
        ArrayLayoutLbl.ColSpan=[1,2];
        ArrayLayout.Name='';
        if this.Content.containMatrix
            ArrayLayout.Name=this.Content.ArrayLayout;
        end
        ArrayLayout.Type='text';
        ArrayLayout.RowSpan=[lineN,lineN];
        ArrayLayout.ColSpan=[4,5];


        lineN=lineN+1;
        ImplLbl.Name=DAStudio.message('RTW:tfl:Implementation');
        ImplLbl.Type='text';
        ImplLbl.RowSpan=[lineN,lineN];
        ImplLbl.ColSpan=[1,2];
        Impl.Name='';
        if~isaBlockEntry
            Impl.Name=[thisImpl.Name,' () with ',num2str(thisImpl.NumInputs),' input(s)'];
        end
        Impl.Type='text';
        Impl.RowSpan=[lineN,lineN];
        Impl.ColSpan=[4,5];

        NSLbl=[];
        NS=[];
        if~isaBlockEntry&&isa(thisImpl,'RTW.CPPImplementation')
            lineN=lineN+1;
            NSLbl.Name='Namespace:';
            NSLbl.Type='text';
            NSLbl.RowSpan=[lineN,lineN];
            NSLbl.ColSpan=[1,2];
            NS.Name=thisImpl.NameSpace;
            NS.Type='text';
            NS.RowSpan=[lineN,lineN];
            NS.ColSpan=[4,5];
        end


        lineN=lineN+1;
        ImpTypeLbl.Name=DAStudio.message('RTW:tfl:ImplementationType');
        ImpTypeLbl.Type='text';
        ImpTypeLbl.RowSpan=[lineN,lineN];
        ImpTypeLbl.ColSpan=[1,2];
        ImpType.Name=this.Content.ImplType;
        ImpType.Type='text';
        ImpType.RowSpan=[lineN,lineN];
        ImpType.ColSpan=[4,5];


        lineN=lineN+1;
        SatModeLbl.Name=DAStudio.message('RTW:tfl:SaturationMode');
        SatModeLbl.Type='text';
        SatModeLbl.RowSpan=[lineN,lineN];
        SatModeLbl.ColSpan=[1,2];
        SatMode.Name=this.Content.SaturationMode;
        SatMode.Type='text';
        SatMode.RowSpan=[lineN,lineN];
        SatMode.ColSpan=[4,5];

        lineN=lineN+1;
        RndModeLbl.Name=DAStudio.message('RTW:tfl:RoundingModes');
        RndModeLbl.Type='text';
        RndModeLbl.RowSpan=[lineN,lineN];
        RndModeLbl.ColSpan=[1,2];
        RndMode.Name=getFormattedRoundingModes(this.Content);
        RndMode.Type='text';
        RndMode.RowSpan=[lineN,lineN];
        RndMode.ColSpan=[4,5];

        EntryInfoLbl=[];
        EntryInfo=[];
        if~isempty(this.Content.EntryInfo)&&...
            ~isempty(getFormattedEntryInfo(this.Content))
            lineN=lineN+1;
            EntryInfoLbl.Name='EntryInfo:';
            EntryInfoLbl.Type='text';
            EntryInfoLbl.RowSpan=[lineN,lineN];
            EntryInfoLbl.ColSpan=[1,2];
            EntryInfo.Name=getFormattedEntryInfo(this.Content);
            EntryInfo.Type='text';
            EntryInfo.RowSpan=[lineN,lineN];
            EntryInfo.ColSpan=[4,5];
        end

        lineN=lineN+1;
        GcbLbl.Name='GenCallback file:';
        GcbLbl.Type='text';
        GcbLbl.RowSpan=[lineN,lineN];
        GcbLbl.ColSpan=[1,2];
        Gcb.Name=this.Content.GenCallback;
        Gcb.Type='text';
        Gcb.RowSpan=[lineN,lineN];
        Gcb.ColSpan=[4,5];

        lineN=lineN+1;
        HdrLbl.Name=DAStudio.message('RTW:tfl:ImplementationHeader');
        HdrLbl.Type='text';
        HdrLbl.RowSpan=[lineN,lineN];
        HdrLbl.ColSpan=[1,2];
        Hdr.Name='';
        if~isaBlockEntry
            Hdr.Name=thisImpl.HeaderFile;
        end
        Hdr.Type='text';
        Hdr.RowSpan=[lineN,lineN];
        Hdr.ColSpan=[4,5];

        lineN=lineN+1;
        SrcLbl.Name=DAStudio.message('RTW:tfl:ImplementationSource');
        SrcLbl.Type='text';
        SrcLbl.RowSpan=[lineN,lineN];
        SrcLbl.ColSpan=[1,2];
        Src.Name='';
        if~isaBlockEntry
            Src.Name=thisImpl.SourceFile;
        end
        Src.Type='text';
        Src.RowSpan=[lineN,lineN];
        Src.ColSpan=[4,5];

        lineN=lineN+1;
        PrtLbl.Name=DAStudio.message('RTW:tfl:PriorityText');
        PrtLbl.Type='text';
        PrtLbl.RowSpan=[lineN,lineN];
        PrtLbl.ColSpan=[1,2];
        Prt.Name=num2str(this.Content.Priority);
        Prt.Type='text';
        Prt.RowSpan=[lineN,lineN];
        Prt.ColSpan=[4,5];

        lineN=lineN+1;
        UscLbl.Name=DAStudio.message('RTW:tfl:TotalUsageCount');
        UscLbl.Type='text';
        UscLbl.RowSpan=[lineN,lineN];
        UscLbl.ColSpan=[1,2];
        Usc.Name=num2str(this.UsageCount);
        Usc.Type='text';
        Usc.RowSpan=[lineN,lineN];
        Usc.ColSpan=[4,5];


        lineN=lineN+1;
        ClsLbl.Name=DAStudio.message('RTW:tfl:EntryClass');
        ClsLbl.Type='text';
        ClsLbl.RowSpan=[lineN,lineN];
        ClsLbl.ColSpan=[1,2];
        Cls.Name=class(this.Content);
        Cls.Type='text';
        Cls.RowSpan=[lineN,lineN];
        Cls.ColSpan=[4,5];


        lineN=lineN+1;
        AllowShapeAgnosticMatchLbl.Name=DAStudio.message('RTW:tfl:AllowShapeAgnosticMatch');
        AllowShapeAgnosticMatchLbl.Type='text';
        AllowShapeAgnosticMatchLbl.RowSpan=[lineN,lineN];
        AllowShapeAgnosticMatchLbl.ColSpan=[1,2];
        AllowShapeAgnosticMatch.Name='';
        if this.Content.containMatrix
            if this.Content.AllowShapeAgnosticMatch
                AllowShapeAgnosticMatch.Name=DAStudio.message('RTW:tfl:yes');
            else
                AllowShapeAgnosticMatch.Name=DAStudio.message('RTW:tfl:no');
            end
        else
            AllowShapeAgnosticMatch.Name=DAStudio.message('RTW:tfl:notApplicable');
        end
        AllowShapeAgnosticMatch.Type='text';
        AllowShapeAgnosticMatch.RowSpan=[lineN,lineN];
        AllowShapeAgnosticMatch.ColSpan=[4,5];


        generalSpcCol.Name='     ';
        generalSpcCol.Type='text';
        generalSpcCol.RowSpan=[lineN,lineN];
        generalSpcCol.ColSpan=[3,3];



        grpGeneral.Name=DAStudio.message('RTW:tfl:SummaryText');
        grpGeneral.Type='group';
        grpGeneral.LayoutGrid=[lineN,5];
        grpGeneral.ColStretch=[0,0,0,1,1];
        if~isempty(NSLbl)&&~isempty(NS)
            if~isempty(EntryInfoLbl)&&~isempty(EntryInfo)
                grpGeneral.Items={...
                DscLbl,Dsc,...
                KeyLbl,Key,...
                ArrayLayoutLbl,ArrayLayout,...
                ImplLbl,Impl,...
                NSLbl,NS,...
                ImpTypeLbl,ImpType,...
                SatModeLbl,SatMode,...
                RndModeLbl,RndMode,...
                EntryInfoLbl,EntryInfo,...
                GcbLbl,Gcb,...
                HdrLbl,Hdr,...
                SrcLbl,Src,...
                PrtLbl,Prt,...
                UscLbl,Usc,...
                ClsLbl,Cls,...
                AllowShapeAgnosticMatchLbl,AllowShapeAgnosticMatch,...
                generalSpcCol};
            else
                grpGeneral.Items={...
                DscLbl,Dsc,...
                KeyLbl,Key,...
                ArrayLayoutLbl,ArrayLayout,...
                ImplLbl,Impl,...
                NSLbl,NS,...
                ImpTypeLbl,ImpType,...
                SatModeLbl,SatMode,...
                RndModeLbl,RndMode,...
                GcbLbl,Gcb,...
                HdrLbl,Hdr,...
                SrcLbl,Src,...
                PrtLbl,Prt,...
                UscLbl,Usc,...
                ClsLbl,Cls,...
                AllowShapeAgnosticMatchLbl,AllowShapeAgnosticMatch,...
                generalSpcCol};
            end
        else
            if~isempty(EntryInfoLbl)&&~isempty(EntryInfo)
                grpGeneral.Items={...
                DscLbl,Dsc,...
                KeyLbl,Key,...
                ArrayLayoutLbl,ArrayLayout,...
                ImplLbl,Impl,...
                ImpTypeLbl,ImpType,...
                SatModeLbl,SatMode,...
                RndModeLbl,RndMode,...
                EntryInfoLbl,EntryInfo,...
                GcbLbl,Gcb,...
                HdrLbl,Hdr,...
                SrcLbl,Src,...
                PrtLbl,Prt,...
                UscLbl,Usc,...
                ClsLbl,Cls,...
                AllowShapeAgnosticMatchLbl,AllowShapeAgnosticMatch,...
                generalSpcCol};
            else
                grpGeneral.Items={...
                DscLbl,Dsc,...
                KeyLbl,Key,...
                ArrayLayoutLbl,ArrayLayout,...
                ImplLbl,Impl,...
                ImpTypeLbl,ImpType,...
                SatModeLbl,SatMode,...
                RndModeLbl,RndMode,...
                GcbLbl,Gcb,...
                HdrLbl,Hdr,...
                SrcLbl,Src,...
                PrtLbl,Prt,...
                UscLbl,Usc,...
                ClsLbl,Cls,...
                AllowShapeAgnosticMatchLbl,AllowShapeAgnosticMatch,...
                generalSpcCol};
            end
        end





        numConceptualArgs=length(this.Content.ConceptualArgs);
        numImplementationArgs=0;
        if~isaBlockEntry
            numImplementationArgs=length(thisImpl.Arguments)+1;
        end

        ArgsTbl=[];
        ArgsTbl.Name='';
        ArgsTbl.Type='textbrowser';
        ArgsTbl.Enabled=true;
        ArgsTbl.Editable=false;



        CncptlArgNames={this.Content.ConceptualArgs.Name};

        if~iscell(CncptlArgNames)
            ConceptualData(1:numConceptualArgs,1)={CncptlArgNames};
        else
            ConceptualData(1:numConceptualArgs,1)=CncptlArgNames;
        end

        CncptlArgIOTypes={this.Content.ConceptualArgs.IOType};
        if~iscell(CncptlArgIOTypes)
            ConceptualData(1:numConceptualArgs,2)={CncptlArgIOTypes};
        else
            ConceptualData(1:numConceptualArgs,2)=CncptlArgIOTypes;
        end

        for idx=1:numConceptualArgs
            tmpType=this.Content.ConceptualArgs(idx).toString;
            if~isempty(tmpType)
                ConceptualData(idx,3)={tmpType};
            else
                ConceptualData(idx,3)={this.Content.ConceptualArgs(idx).Type.tostring};
            end
        end

        ConceptualTable=Advisor.Table(numConceptualArgs,3);
        ConceptualTable.setColHeading(1,'Name');
        ConceptualTable.setColHeading(2,'I/O type');
        ConceptualTable.setColHeading(3,'Data type');
        ConceptualTable.setBorder(1);
        for i=1:numConceptualArgs
            col1=ConceptualData(i,1);
            col2=ConceptualData(i,2);
            col3=ConceptualData(i,3);
            ConceptualTable.setEntry(i,1,(col1{1}));
            ConceptualTable.setEntry(i,2,(col2{1}));
            ConceptualTable.setEntry(i,3,(col3{1}));
        end
        CncptHTML=ConceptualTable.emitHTML;
        CncptHTML=['<b>Conceptual argument(s):</b><br>',CncptHTML];


        if numImplementationArgs>0

            ImpRetName=[];
            if~isempty(thisImpl.Return)
                ImpRetName=thisImpl.Return.Name;
            end
            if isempty(ImpRetName)
                ImpRetName='<I>Return undefined<I>';
            end
            ImplementationData(1,1)={ImpRetName};
            ImplArgNames=[];
            if(~isempty(thisImpl.Arguments))
                ImplArgNames={thisImpl.Arguments.Name};
            end
            if~iscell(ImplArgNames)
                ImplementationData(2:numImplementationArgs,1)={ImplArgNames};
            else
                ImplementationData(2:numImplementationArgs,1)=ImplArgNames;
            end

            ImpRetIOType=[];
            if(~isempty(thisImpl.Return))
                ImpRetIOType=thisImpl.Return.IOType;
            end
            if isempty(ImpRetIOType)
                ImpRetIOType='<I>Return undefined</I>';
            end
            ImplementationData(1,2)={ImpRetIOType};
            ImplArgIOTypes=[];
            if(~isempty(thisImpl.Arguments))
                ImplArgIOTypes={thisImpl.Arguments.IOType};
            end
            if~iscell(ImplArgIOTypes)
                ImplementationData(2:numImplementationArgs,2)={ImplArgIOTypes};
            else
                ImplementationData(2:numImplementationArgs,2)=ImplArgIOTypes;
            end

            try
                tmpType=thisImpl.Return.toString;
                if~isempty(tmpType)
                    ImplementationData(1,3)={tmpType};
                else
                    ImplementationData(1,3)={thisImpl.Return.Type.tostring};
                end
            catch %#ok<CTCH>
                ImplementationData(1,3)={'<I>Return undefined</I>'};
            end

            for idx=2:numImplementationArgs
                try
                    tmpType=thisImpl.Arguments(idx-1).toString;
                    if~isempty(tmpType)
                        ImplementationData(idx,3)={tmpType};
                    else
                        ImplementationData(idx,3)={thisImpl.Arguments(idx-1).Type.tostring};
                    end
                catch %#ok<CTCH>
                    ImplementationData(idx,3)={'<I>undefined</I>'};
                end
            end

            ImpAlignment=[];
            globalAlignment=[];
            if~isempty(thisImpl.ArgumentDescriptor)
                globalAlignment=num2str(thisImpl.ArgumentDescriptor.AlignmentBoundary);
            end
            if(~isempty(thisImpl.Return)&&...
                ~isempty(thisImpl.Return.Descriptor))
                ImpAlignment=num2str(thisImpl.Return.Descriptor.AlignmentBoundary);
            elseif~isempty(globalAlignment)
                ImpAlignment=globalAlignment;
            end
            if isempty(ImpAlignment)
                ImpAlignment='<I>none</I>';
            end
            ImplementationData(1,4)={ImpAlignment};
            for idx=2:numImplementationArgs
                thisArg=thisImpl.Arguments(idx-1);
                if~isempty(thisArg.Descriptor)
                    ImplementationData(idx,4)={num2str(thisArg.Descriptor.AlignmentBoundary)};
                elseif~isempty(globalAlignment)
                    ImplementationData(idx,4)={globalAlignment};
                else
                    ImplementationData(idx,4)={'<I>none</I>'};
                end
            end

            ImplementationTable=Advisor.Table(numImplementationArgs,4);
            ImplementationTable.setColHeading(1,'Name');
            ImplementationTable.setColHeading(2,'I/O type');
            ImplementationTable.setColHeading(3,'Data type');
            ImplementationTable.setColHeading(4,'Alignment');
            ImplementationTable.setBorder(1);

            for i=1:numImplementationArgs
                col1=ImplementationData(i,1);
                col2=ImplementationData(i,2);
                col3=ImplementationData(i,3);
                col4=ImplementationData(i,4);
                ImplementationTable.setEntry(i,1,(col1{1}));
                ImplementationTable.setEntry(i,2,(col2{1}));
                ImplementationTable.setEntry(i,3,(col3{1}));
                ImplementationTable.setEntry(i,4,(col4{1}));
            end
            ImplHTML=ImplementationTable.emitHTML;
            ImplHTML=['<br><b>Implementation:</b><br>',ImplHTML];
        else
            ImplHTML='';
        end

        ArgsTbl.Text=['<br>',CncptHTML,'<br>',ImplHTML];
        ArgsTbl.RowSpan=[1,1];
        ArgsTbl.ColSpan=[1,1];

        lineN=lineN+1;
        grpArg.Type='group';
        grpArg.Name=DAStudio.message('RTW:tfl:EntryArguments');
        grpArg.RowSpan=[lineN,lineN+5];
        grpArg.ColSpan=[1,5];
        grpArg.LayoutGrid=[1,1];
        grpArg.RowStretch=0;
        grpArg.Items={ArgsTbl};

        tabGeneral.Name='General Information';
        tabGeneral.Items={grpGeneral,grpArg};

        TraceTbl=[];
        TraceTbl.Name='';
        TraceTbl.Type='textbrowser';
        TraceTbl.Enabled=true;
        TraceTbl.Editable=false;
        TraceTbl.Tag=[tag,'TraceTable'];



        HitSources=this.Content.TraceManager.HitSourceLocations;
        numHitSources=length(HitSources);

        HitSrcHTML=[];
        if numHitSources>0
            HitSrcTable=Advisor.Table(numHitSources,1);
            HitSrcTable.setColHeading(1,'Source Location');
            HitSrcTable.setBorder(1);
            HitSrcTable.Tag=[tag,'HitSrcTable'];
            for i=1:numHitSources
                loc=locGetSourceLocationFromSID(HitSources{i},this.MeObj.UserData.IsMatlabCoder);
                HitSrcTable.setEntry(i,1,loc);
            end
            HitSrcHTML=HitSrcTable.emitHTML;
            HitSrcHTML=['<b>Hit Source Locations:</b><br>',HitSrcHTML];
        end


        MissSources=this.Content.TraceManager.MissSourceLocations;
        MissSrcHTML=[];

        [MissSrcTable,legend]=locGetMissTableLegendNoHeadings(MissSources,this.MeObj.UserData.IsMatlabCoder);

        if~isempty(MissSrcTable)
            MissSrcTable.Tag=[tag,'MissSrcTable'];
            MissSrcHTML=MissSrcTable.emitHTML;
            MissSrcHTML=['<h3>Miss Source Locations:</h3>',MissSrcHTML];
        end
        legendHTML=[];
        if~isempty(legend)
            legendKeys=keys(legend);
            legendVals=values(legend);
            [~,sortedIdxs]=sort(str2double(legendVals));
            for idx=1:length(legend)
                thisKey=legendKeys{sortedIdxs(idx)};
                thisMsg=DAStudio.message(['CoderFoundation:tflTrace:',thisKey]);
                thisVal=legendVals{sortedIdxs(idx)};
                legendHTML=[legendHTML,'<dt>',num2str(thisVal),'. ',thisMsg,'</dt>'];
            end
            legendHTML=['<dl>',legendHTML,'</dl>'];
        end
        TraceTbl.Text=['<br>',HitSrcHTML,'<ul>',legendHTML,'</ul><br>',MissSrcHTML];
        TraceTbl.RowSpan=[1,1];
        TraceTbl.ColSpan=[1,1];

        addTraceTab=false;
        if~isempty(HitSrcHTML)||...
            ~isempty(MissSrcHTML)
            addTraceTab=true;
        end
        tabTrace.Name='Trace Information';
        tabTrace.Items={TraceTbl};

        if isa(this.Content,'RTW.TflCOperationEntryGenerator')||isa(this.Content,'RTW.TflCOperationEntryGenerator_NetSlope')
            if isa(this.Content,'RTW.TflCOperationEntryGenerator_NetSlope')
                RSFFLabelName='Net Slope Adjustment Factor:';
                RSFELabelName='Net Fixed Exponent:';
                RSFFValue=num2str(this.Content.NetSlopeAdjustmentFactor);
                RSFEValue=num2str(this.Content.NetFixedExponent);
                SMBTSLblName=' ';
                SMBTSName=' ';
                MHZNBLblName=' ';
                MHZNBName=' ';
            else
                RSFFLabelName='Relative scaling factor F:';
                RSFELabelName='Relative scaling factor E:';
                RSFEValue=num2str(this.Content.RelativeScalingFactorE);
                RSFFValue=num2str(this.Content.RelativeScalingFactorF);

                SMBTSLblName='Slopes must be the same:';
                if this.Content.SlopesMustBeTheSame
                    SMBTSName='yes';
                else
                    SMBTSName='no';
                end
                MHZNBLblName='Must have zero net bias:';
                if this.Content.MustHaveZeroNetBias
                    MHZNBName='yes';
                else
                    MHZNBName='no';
                end
            end


            lineN=1;
            RSFFLbl.Name=RSFFLabelName;
            RSFFLbl.Type='text';
            RSFFLbl.RowSpan=[lineN,lineN];
            RSFFLbl.ColSpan=[1,2];
            RSFF.Name=RSFFValue;
            RSFF.Type='text';
            RSFF.RowSpan=[lineN,lineN];
            RSFF.ColSpan=[4,5];


            lineN=lineN+1;
            RSFELbl.Name=RSFELabelName;
            RSFELbl.Type='text';
            RSFELbl.RowSpan=[lineN,lineN];
            RSFELbl.ColSpan=[1,2];
            RSFE.Name=RSFEValue;
            RSFE.Type='text';
            RSFE.RowSpan=[lineN,lineN];
            RSFE.ColSpan=[4,5];


            lineN=lineN+1;
            SMBTSLbl.Name=SMBTSLblName;
            SMBTSLbl.Type='text';
            SMBTSLbl.RowSpan=[lineN,lineN];
            SMBTSLbl.ColSpan=[1,2];
            SMBTS.Name=SMBTSName;
            SMBTS.Type='text';
            SMBTS.RowSpan=[lineN,lineN];
            SMBTS.ColSpan=[4,5];


            lineN=lineN+1;
            MHZNBLbl.Name=MHZNBLblName;
            MHZNBLbl.Type='text';
            MHZNBLbl.RowSpan=[lineN,lineN];
            MHZNBLbl.ColSpan=[1,2];
            MHZNB.Name=MHZNBName;
            MHZNB.Type='text';
            MHZNB.RowSpan=[lineN,lineN];
            MHZNB.ColSpan=[4,5];


            lineN=lineN+1;
            fixptSpcRow.Name='';
            fixptSpcRow.Type='text';
            fixptSpcRow.RowSpan=[lineN,lineN];
            fixptSpcRow.ColSpan=[1,2];


            fixptSpcCol.Name='     ';
            fixptSpcCol.Type='text';
            fixptSpcCol.RowSpan=[lineN,lineN];
            fixptSpcCol.ColSpan=[3,3];

            grpFixPt.Name='Summary';
            grpFixPt.Type='group';
            grpFixPt.LayoutGrid=[lineN,5];
            grpFixPt.ColStretch=[0,0,0,1,1];
            grpFixPt.RowStretch=zeros(1,lineN);
            grpFixPt.RowStretch(lineN)=1;
            grpFixPt.Items={...
            RSFFLbl,RSFF,...
            RSFELbl,RSFE,...
            SMBTSLbl,SMBTS,...
            MHZNBLbl,MHZNB,...
            fixptSpcRow,fixptSpcCol};

            tabFixPt.Name='Fixed-point Settings';
            tabFixPt.Items={grpFixPt};
            if addTraceTab
                entryTab.Tabs={tabGeneral,tabFixPt,tabTrace};
            else
                entryTab.Tabs={tabGeneral,tabFixPt};
            end
        else
            if addTraceTab
                entryTab.Tabs={tabGeneral,tabTrace};
            else
                entryTab.Tabs={tabGeneral};
            end
        end

        entryTab.Name='TABS';
        entryTab.Type='tab';
        entryTab.LayoutGrid=[1,1];
        entryTab.RowSpan=[1,5];
        entryTab.ColSpan=[1,5];

        HelpButton.Name=DAStudio.message('RTW:tfl:HelpText');
        HelpButton.Type='pushbutton';
        HelpButton.ObjectMethod='dialogCallback';
        HelpButton.MethodArgs={'Help'};
        HelpButton.ArgDataTypes={'string'};
        HelpButton.RowSpan=[6,6];
        HelpButton.ColSpan=[4,4];
        HelpButton.Enabled=true;
        HelpButton.Visible=true;

        CloseButton.Name=DAStudio.message('RTW:tfl:CloseText');
        CloseButton.Type='pushbutton';
        CloseButton.ObjectMethod='dialogCallback';
        CloseButton.MethodArgs={'Close'};
        CloseButton.ArgDataTypes={'string'};
        CloseButton.RowSpan=[6,6];
        CloseButton.ColSpan=[5,5];





        dlgstruct.DialogTitle=this.Content.Key;
        dlgstruct.Items={entryTab,HelpButton,CloseButton};
        dlgstruct.LayoutGrid=[6,1];
        dlgstruct.RowStretch=[0,0,1,1,1,0];
        dlgstruct.EmbeddedButtonSet={''};

    case 'TflTable'


        lineN=1;
        DscLbl.Name=DAStudio.message('RTW:tfl:DescriptionText');
        DscLbl.Type='text';
        DscLbl.RowSpan=[lineN,lineN];
        DscLbl.ColSpan=[1,2];
        Dsc.Name='';
        Dsc.Type='text';
        Dsc.RowSpan=[lineN,lineN];
        Dsc.ColSpan=[4,5];

        lineN=lineN+1;
        NameLbl.Name=DAStudio.message('RTW:tfl:Name');
        NameLbl.Type='text';
        NameLbl.RowSpan=[lineN,lineN];
        NameLbl.ColSpan=[1,2];
        Name.Name=this.Content.Name;
        Name.Type='text';
        Name.RowSpan=[lineN,lineN];
        Name.ColSpan=[4,5];

        lineN=lineN+1;
        VerLbl.Name=DAStudio.message('RTW:tfl:Version');
        VerLbl.Type='text';
        VerLbl.RowSpan=[lineN,lineN];
        VerLbl.ColSpan=[1,2];
        Ver.Name=this.Content.Version;
        Ver.Type='text';
        Ver.RowSpan=[lineN,lineN];
        Ver.ColSpan=[4,5];

        lineN=lineN+1;
        NumEnLbl.Name=DAStudio.message('RTW:tfl:NumberOfEntries');
        NumEnLbl.Type='text';
        NumEnLbl.RowSpan=[lineN,lineN];
        NumEnLbl.ColSpan=[1,2];
        NumEn.Name=num2str(length(this.Content.AllEntries));
        NumEn.Type='text';
        NumEn.RowSpan=[lineN,lineN];
        NumEn.ColSpan=[4,5];

        SpcLbl.Name='     ';
        SpcLbl.Type='text';
        SpcLbl.RowSpan=[lineN,lineN];
        SpcLbl.ColSpan=[3,3];


        grpSummary.Type='group';
        grpSummary.Name=DAStudio.message('RTW:tfl:SummaryText');
        grpSummary.LayoutGrid=[lineN,5];
        grpSummary.ColStretch=[0,0,0,1,1];
        grpSummary.RowSpan=[1,2];
        grpSummary.ColSpan=[1,5];
        grpSummary.Items={...
        DscLbl,Dsc,...
        NameLbl,Name,...
        VerLbl,Ver,...
        NumEnLbl,NumEn,...
        SpcLbl};

        Inst.Text=DAStudio.message('RTW:tfl:TableInstructText');
        Inst.Type='textbrowser';
        Inst.RowSpan=[3,5];
        Inst.ColSpan=[1,5];

        SaveAsButton.Name=DAStudio.message('RTW:tfl:SaveAs');
        SaveAsButton.Type='pushbutton';
        SaveAsButton.ObjectMethod='dialogCallback';
        SaveAsButton.MethodArgs={'SaveAs'};
        SaveAsButton.ArgDataTypes={'string'};
        SaveAsButton.RowSpan=[6,6];
        SaveAsButton.ColSpan=[3,3];

        HelpButton.Name=DAStudio.message('RTW:tfl:HelpText');
        HelpButton.Type='pushbutton';
        HelpButton.ObjectMethod='dialogCallback';
        HelpButton.MethodArgs={'Help'};
        HelpButton.ArgDataTypes={'string'};
        HelpButton.RowSpan=[6,6];
        HelpButton.ColSpan=[4,4];
        HelpButton.Enabled=true;
        HelpButton.Visible=true;

        CloseButton.Name=DAStudio.message('RTW:tfl:CloseText');
        CloseButton.Type='pushbutton';
        CloseButton.ObjectMethod='dialogCallback';
        CloseButton.MethodArgs={'Close'};
        CloseButton.ArgDataTypes={'string'};
        CloseButton.RowSpan=[6,6];
        CloseButton.ColSpan=[5,5];




        dlgstruct.DialogTitle=this.Content.Name;
        dlgstruct.LayoutGrid=[6,1];
        dlgstruct.RowStretch=[0,0,1,1,1,0];
        dlgstruct.EmbeddedButtonSet={''};
        dlgstruct.Items={grpSummary,Inst,SaveAsButton,HelpButton,CloseButton};


    case 'TflRegistry'
        tr=RTW.TargetRegistry.get;

        lineN=1;
        NameLbl.Name=DAStudio.message('RTW:tfl:Name');
        NameLbl.Type='text';
        NameLbl.RowSpan=[lineN,lineN];
        NameLbl.ColSpan=[1,2];
        Name.Name=this.Content.Name;
        Name.Type='text';
        Name.RowSpan=[lineN,lineN];
        Name.ColSpan=[4,5];

        lineN=lineN+1;
        DscLbl.Name=DAStudio.message('RTW:tfl:DescriptionText');
        DscLbl.Type='text';
        DscLbl.RowSpan=[lineN,lineN];
        DscLbl.ColSpan=[1,2];
        Dsc.Name=this.Content.Description;
        Dsc.Type='text';
        Dsc.RowSpan=[lineN,lineN];
        Dsc.ColSpan=[4,5];

        lineN=lineN+1;
        BaseTflLbl.Name=DAStudio.message('RTW:tfl:BaseLibrary');
        BaseTflLbl.Type='text';
        BaseTflLbl.RowSpan=[lineN,lineN];
        BaseTflLbl.ColSpan=[1,2];
        try
            BaseTfl.Name=coder.internal.getTfl(tr,this.Content.BaseTfl).Name;
        catch %#ok<CTCH>
            BaseTfl.Name='';
        end
        BaseTfl.Type='text';
        BaseTfl.RowSpan=[lineN,lineN];
        BaseTfl.ColSpan=[4,5];

        lineN=lineN+1;
        NumEnLbl.Name=DAStudio.message('RTW:tfl:TotalNumberOfTables');
        NumEnLbl.Type='text';
        NumEnLbl.RowSpan=[lineN,lineN];
        NumEnLbl.ColSpan=[1,2];
        NumEn.Name=num2str(length(this.Children));
        NumEn.Type='text';
        NumEn.RowSpan=[lineN,lineN];
        NumEn.ColSpan=[4,5];

        SpcLbl.Name='     ';
        SpcLbl.Type='text';
        SpcLbl.RowSpan=[lineN,lineN];
        SpcLbl.ColSpan=[3,3];

        grpSummary.Type='group';
        grpSummary.Name=DAStudio.message('RTW:tfl:SummaryText');
        grpSummary.LayoutGrid=[lineN,5];
        grpSummary.ColStretch=[0,0,0,1,1];
        grpSummary.RowSpan=[1,2];
        grpSummary.ColSpan=[1,5];
        grpSummary.Items={...
        DscLbl,Dsc,...
        NameLbl,Name,...
        BaseTflLbl,BaseTfl,...
        NumEnLbl,NumEn,...
        SpcLbl};


        txt1=[DAStudio.message('RTW:tfl:RegistryTableInstructText'),'<br>'];
        tableList=coder.internal.getTflTableList(tr,this.Content.Name);
        [dummyList,Ia]=setdiff(tableList,{'private_ansi_tfl_table_tmw.mat','private_iso_tfl_table_tmw.mat'});
        if~isempty(dummyList)
            tableList=tableList(sort(Ia));
        end
        if~isempty(tableList)
            txt2=[DAStudio.message('RTW:tfl:RegistryTableListOrderText'),'<br>'...
            ,sprintf(' %s <br>',tableList{:})];
        else
            txt2=DAStudio.message('RTW:tfl:RegistryEmptyLibraryText');
        end
        Inst.Text=[txt1,txt2];
        Inst.Type='textbrowser';
        Inst.RowSpan=[3,5];
        Inst.ColSpan=[1,5];

        SaveAsButton.Name=DAStudio.message('RTW:tfl:SaveAs');
        SaveAsButton.Type='pushbutton';
        SaveAsButton.ObjectMethod='dialogCallback';
        SaveAsButton.MethodArgs={'SaveAs'};
        SaveAsButton.ArgDataTypes={'string'};
        SaveAsButton.RowSpan=[6,6];
        SaveAsButton.ColSpan=[3,3];
        SaveAsButton.Enabled=false;
        SaveAsButton.Visible=false;

        HelpButton.Name=DAStudio.message('RTW:tfl:HelpText');
        HelpButton.Type='pushbutton';
        HelpButton.ObjectMethod='dialogCallback';
        HelpButton.MethodArgs={'Help'};
        HelpButton.ArgDataTypes={'string'};
        HelpButton.RowSpan=[6,6];
        HelpButton.ColSpan=[4,4];
        HelpButton.Enabled=true;
        HelpButton.Visible=true;

        CloseButton.Name=DAStudio.message('RTW:tfl:CloseText');
        CloseButton.Type='pushbutton';
        CloseButton.ObjectMethod='dialogCallback';
        CloseButton.MethodArgs={'Close'};
        CloseButton.ArgDataTypes={'string'};
        CloseButton.RowSpan=[6,6];
        CloseButton.ColSpan=[5,5];




        dlgstruct.DialogTitle=this.Content.Name;
        dlgstruct.LayoutGrid=[6,1];
        dlgstruct.RowStretch=[0,0,1,1,1,0];
        dlgstruct.EmbeddedButtonSet={''};
        dlgstruct.Items={grpSummary,Inst,SaveAsButton,HelpButton,CloseButton};


    case 'TflControl'

        inst.Text=DAStudio.message('RTW:tfl:ViewerInstructText');
        inst.Type='textbrowser';
        inst.RowSpan=[1,5];
        inst.ColSpan=[1,5];

        SaveAsButton.Name=DAStudio.message('RTW:tfl:SaveAs');
        SaveAsButton.Type='pushbutton';
        SaveAsButton.ObjectMethod='dialogCallback';
        SaveAsButton.MethodArgs={'SaveAs'};
        SaveAsButton.ArgDataTypes={'string'};
        SaveAsButton.RowSpan=[6,6];
        SaveAsButton.ColSpan=[3,3];
        SaveAsButton.Enabled=false;
        SaveAsButton.Visible=false;

        HelpButton.Name=DAStudio.message('RTW:tfl:HelpText');
        HelpButton.Type='pushbutton';
        HelpButton.ObjectMethod='dialogCallback';
        HelpButton.MethodArgs={'Help'};
        HelpButton.ArgDataTypes={'string'};
        HelpButton.RowSpan=[6,6];
        HelpButton.ColSpan=[4,4];
        HelpButton.Enabled=true;
        HelpButton.Visible=true;

        CloseButton.Name=DAStudio.message('RTW:tfl:CloseText');
        CloseButton.Type='pushbutton';
        CloseButton.ObjectMethod='dialogCallback';
        CloseButton.MethodArgs={'Close'};
        CloseButton.ArgDataTypes={'string'};
        CloseButton.RowSpan=[6,6];
        CloseButton.ColSpan=[5,5];




        dlgstruct.DialogTitle='Controller';
        dlgstruct.LayoutGrid=[5,1];
        dlgstruct.Items={inst,SaveAsButton,HelpButton,CloseButton};
        dlgstruct.EmbeddedButtonSet={''};

    case 'TargetRegistry'
        inst.Text=DAStudio.message('RTW:tfl:RegistryInstructText');
        inst.Type='textbrowser';
        inst.RowSpan=[1,5];
        inst.ColSpan=[1,5];

        SaveAsButton.Name=DAStudio.message('RTW:tfl:SaveAs');
        SaveAsButton.Type='pushbutton';
        SaveAsButton.ObjectMethod='dialogCallback';
        SaveAsButton.MethodArgs={'SaveAs'};
        SaveAsButton.ArgDataTypes={'string'};
        SaveAsButton.RowSpan=[6,6];
        SaveAsButton.ColSpan=[3,3];
        SaveAsButton.Enabled=false;
        SaveAsButton.Visible=false;

        HelpButton.Name=DAStudio.message('RTW:tfl:HelpText');
        HelpButton.Type='pushbutton';
        HelpButton.ObjectMethod='dialogCallback';
        HelpButton.MethodArgs={'Help'};
        HelpButton.ArgDataTypes={'string'};
        HelpButton.RowSpan=[6,6];
        HelpButton.ColSpan=[4,4];
        HelpButton.Enabled=true;
        HelpButton.Visible=true;

        CloseButton.Name=DAStudio.message('RTW:tfl:CloseText');
        CloseButton.Type='pushbutton';
        CloseButton.ObjectMethod='dialogCallback';
        CloseButton.MethodArgs={'Close'};
        CloseButton.ArgDataTypes={'string'};
        CloseButton.RowSpan=[6,6];
        CloseButton.ColSpan=[5,5];




        dlgstruct.DialogTitle=DAStudio.message('RTW:tfl:CodeReplacementViewer');
        dlgstruct.LayoutGrid=[6,1];
        dlgstruct.Items={inst,SaveAsButton,HelpButton,CloseButton};
        dlgstruct.EmbeddedButtonSet={''};

    otherwise
        DAStudio.error('RTW:tfl:invalidObjError');
    end



    function fmtStr=getFormattedRoundingModes(hEnt)
        numMds=length(hEnt.RoundingModes);
        assert(numMds>=1);
        fmtStr=hEnt.RoundingModes{1};

        for idx=2:numMds
            fmtStr=sprintf('%s\n%s',fmtStr,hEnt.RoundingModes{idx});
        end



        function fmtStr=getFormattedEntryInfo(hEnt)
            fmtStr='';
            if~isempty(hEnt.EntryInfo)
                switch class(hEnt.EntryInfo)
                case{'RTW.TflEntrySineInfo','RTW.TflEntryRsqrtInfo','RTW.TflEntryRecipInfo'}
                    fmtStr=hEnt.EntryInfo.Algorithm;
                case 'RTW.TflEntryAddMinusInfo'
                    fmtStr=hEnt.EntryInfo.Algorithm;
                end
            end


            function loc=locGetSourceLocationFromSID(sid,isMatlabCoder)

                loc=sid;
                try %#ok
                    if isMatlabCoder
                        lm=coder.report.HTMLLinkManager;
                    else
                        lm=Simulink.report.HTMLLinkManager;
                        lm.IncludeHyperlinkInReport=true;
                    end

                    tmp=lm.getLinkToFrontEnd(sid);
                    if(~isempty(tmp))


                        tmp=regexprep(tmp,'name="[^"]*" \s*(class="[^"]*")','$1');


                        loc=tmp;
                    end
                end



                function[MissSrcTable,legend]=locGetMissTableLegendNoHeadings(MissSources,isMatlabCoder)
                    MissSrcTable=[];
                    legend=containers.Map;
                    numMissSources=length(MissSources);
                    if numMissSources>0
                        MissSrcTable=Advisor.Table(numMissSources,3);
                        MissSrcTable.setColHeading(1,'Call Site Object Preview');
                        MissSrcTable.setColHeading(2,'Source Location');
                        MissSrcTable.setColHeading(3,'Reason');
                        MissSrcTable.setBorder(1);
                        for idx=1:numMissSources

                            thisMiss=MissSources{idx};
                            csoidText=Advisor.Text(thisMiss.CSOID,'-html',false);
                            csoidText.RetainReturn=true;
                            MissSrcTable.setEntry(idx,1,csoidText.emitHTML);

                            locStr=['<dt>',locGetSourceLocationFromSID(thisMiss.SIDs{1},isMatlabCoder),'</dt>'];
                            for jdx=2:length(thisMiss.SIDs)
                                aLoc=locGetSourceLocationFromSID(thisMiss.SIDs{jdx},isMatlabCoder);
                                locStr=[locStr,'<dt>',aLoc,'</dt>'];%#ok<AGROW>
                            end


                            locText=Advisor.Text(['<dl>',locStr,'</dl>'],'-html',true);
                            MissSrcTable.setEntry(idx,2,locText);


                            reasons=thisMiss.MissInfos;
                            if~isempty(reasons)
                                uniqIdxs=[];
                                numReasons=length(reasons);

                                uniqIdxs(1)=1;
                                if numReasons>1
                                    currentID=reasons{1}.ID;
                                    for jdx=2:numReasons
                                        if~strcmp(currentID,reasons{jdx}.ID)
                                            currentID=reasons{jdx}.ID;
                                            uniqIdxs(end+1)=jdx;
                                        end
                                    end
                                end

                                numUniqIDs=length(uniqIdxs);
                                MissReasonTable=Advisor.Table(numUniqIDs,2);
                                MissReasonTable.setBorder(0);
                                for jdx=1:numUniqIDs
                                    startIdx=uniqIdxs(jdx);
                                    if jdx~=numUniqIDs
                                        endIdx=uniqIdxs(jdx+1)-1;
                                    else
                                        endIdx=numReasons;
                                    end
                                    if~isKey(legend,reasons{startIdx}.ID)
                                        reasonIdx=reasons{startIdx}.idIndex;
                                        legend(reasons{startIdx}.ID)=reasonIdx;
                                    else
                                        reasonIdx=legend(reasons{startIdx}.ID);
                                    end
                                    MissReasonTable.setEntry(jdx,1,Advisor.Text([num2str(reasonIdx),'.']));
                                    reasonsHtml=[];
                                    for kdx=startIdx:endIdx
                                        thisReason=reasons{kdx};

                                        reasonTable=Advisor.Text(thisReason.toString);
                                        if~isempty(reasonTable)
                                            reasonTblHTML=reasonTable.emitHTML;
                                            if~isempty(reasonsHtml)
                                                reasonsHtml=[reasonsHtml,'<dt>',reasonTblHTML,'</dt>'];
                                            else
                                                reasonsHtml=['<dt>',reasonTblHTML,'</dt>'];
                                            end
                                        end
                                    end
                                    MissReasonTable.setEntry(jdx,2,['<dl>',reasonsHtml,'</dl>']);
                                end
                                MissSrcTable.setEntry(idx,3,MissReasonTable);
                            end
                        end
                    end





