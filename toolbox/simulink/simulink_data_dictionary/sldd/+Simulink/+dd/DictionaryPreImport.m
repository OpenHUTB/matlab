

classdef DictionaryPreImport<handle
    properties
        mDDConn='';
        mExistingList='';
        mSource='';
        mSourceIsDict=false;
        mCallbackF='';
        mCallbackArgs='';
        mOverwrite=false;
        mAlreadyClosed=false;
        mAllowOverwrite='on';
        mUseHTML=false;
    end

    methods

        function obj=DictionaryPreImport(ddConn,existingList,source,bAllowOverwrite,callbackFunc,varargin)
            obj.mDDConn=ddConn;
            obj.mExistingList=existingList;
            obj.mSource=source;
            obj.mCallbackF=callbackFunc;
            obj.mCallbackArgs=varargin;
            obj.mAllowOverwrite=bAllowOverwrite;
            if~isempty(obj.mSource)
                [~,~,fileExt]=fileparts(obj.mSource);
                if isequal(fileExt,'.sldd')
                    obj.mSourceIsDict=true;
                    obj.mUseHTML=false;
                else
                    obj.mUseHTML=false;
                end
            else
                obj.mUseHTML=false;
            end
        end

        function schema=getDialogSchema(obj)
            image.Type='image';
            image.Tag='image';
            image.RowSpan=[1,1];
            image.ColSpan=[1,1];
            image.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','warningicon.gif');

            if isempty(obj.mExistingList)
                description.Name='All items already exist in this dictionary';
            elseif isequal(obj.mAllowOverwrite,'on')||isequal(obj.mAllowOverwrite,'always')
                description.Name=DAStudio.message('SLDD:sldd:ImportConflicts',length(obj.mExistingList(:,1)));
            elseif obj.mSourceIsDict
                description.Name=DAStudio.message('SLDD:sldd:ImportConflictsDD',length(obj.mExistingList(:,1)));
            else
                description.Name=DAStudio.message('SLDD:sldd:ImportConflicts2',length(obj.mExistingList(:,1)));
            end

            description.Type='text';
            description.WordWrap=true;
            description.Tag='DictPreImportDlg_GeneralMsg';
            description.RowSpan=[1,1];
            description.ColSpan=[2,5];
            description.Alignment=9;

            details.Type='textbrowser';
            details.Editable=false;
            details.Tag='DictPreImportDlg_SpecificMsg';
            details.RowSpan=[2,2];
            details.ColSpan=[2,5];
            if isempty(obj.mExistingList)
                details.Visible=false;
            else
                if obj.mUseHTML
                    newline='<br/>';
                    dictPath=obj.mDDConn.filespec;
                    dictPath2='';
                    if obj.mSourceIsDict
                        other_dd=Simulink.dd.open(obj.mSource);
                        dictPath2=other_dd.filespec;
                    end
                else
                    newline=sprintf('\n');
                end
                displayList=sort(obj.mExistingList(:,1));
                duplicateStr='';
                len=length(displayList);
                for i=1:len
                    if i>1
                        duplicateStr=[duplicateStr,newline];
                    end

                    if obj.mUseHTML
                        secondVar=obj.mExistingList{i};
                        if obj.mSourceIsDict
                            secondVar=[obj.mExistingList{i,2},'.',secondVar];
                        end
                        entryStr=['<a href="matlab: Simulink.dd.DictionaryPreImport.diff(''',dictPath,''',''',[obj.mExistingList{i,2},'.',obj.mExistingList{i,1}],''',''',dictPath2,''',''',secondVar,''')">','',obj.mExistingList{i},'','</a>'];
                    else
                        entryStr=displayList{i};
                    end

                    duplicateStr=[duplicateStr,'''',entryStr,''''];
                end
                details.Text=duplicateStr;
            end

            spacer.Name='';
            spacer.Type='text';
            spacer.Tag='spacer';
            spacer.RowSpan=[5,5];
            spacer.ColSpan=[1,5];

            btnImport.Type='pushbutton';
            btnImport.Tag='Simulink:editor:DialogContinue';
            if isequal(obj.mAllowOverwrite,'always')
                btnImport.Name=DAStudio.message('Simulink:editor:DialogOverwrite');
            else
                btnImport.Name=DAStudio.message(btnImport.Tag);
            end
            btnImport.MatlabMethod='Simulink.dd.DictionaryPreImport.buttonCB';
            btnImport.MatlabArgs={'%dialog',btnImport.Tag};
            btnImport.RowSpan=[6,6];
            btnImport.ColSpan=[4,4];
            if isempty(obj.mExistingList)
                btnImport.Enabled=false;
            end

            btnDuplicates.Type='checkbox';
            btnDuplicates.Tag='SLDD:sldd:OverwriteExisting';
            btnDuplicates.Name=DAStudio.message(btnDuplicates.Tag);
            btnDuplicates.RowSpan=[4,4];
            btnDuplicates.ColSpan=[2,4];
            btnDuplicates.MatlabMethod='Simulink.dd.DictionaryPreImport.buttonCB';
            btnDuplicates.MatlabArgs={'%dialog',btnDuplicates.Tag};

            btnCancel.Type='pushbutton';
            btnCancel.Tag='Simulink:editor:DialogCancel';
            btnCancel.Name=DAStudio.message(btnCancel.Tag);
            btnCancel.MatlabMethod='Simulink.dd.DictionaryPreImport.buttonCB';
            btnCancel.MatlabArgs={'%dialog',btnCancel.Tag};
            btnCancel.RowSpan=[6,6];
            btnCancel.ColSpan=[5,5];

            if isempty(obj.mSource)
                schema.DialogTitle=DAStudio.message('SLDD:sldd:ImportFromBaseWorkspace');
            elseif obj.mSourceIsDict
                schema.DialogTitle=DAStudio.message('SLDD:sldd:ImportFromDictionary');
            else
                [~,~,fileExt]=fileparts(obj.mSource);
                if isequal(fileExt,'.xml')
                    schema.DialogTitle=DAStudio.message('dds:ui:ImportDlgTitle');
                else
                    schema.DialogTitle=DAStudio.message('SLDD:sldd:ImportFromFile');
                end
            end
            schema.DialogTag='DictPreImportDlg';
            schema.StandaloneButtonSet={''};
            schema.Sticky=true;
            schema.LayoutGrid=[6,5];
            if isequal(obj.mAllowOverwrite,'on')
                schema.Items={image,description,details,btnDuplicates,spacer,btnImport,btnCancel};
            else
                schema.Items={image,description,details,spacer,btnImport,btnCancel};
            end
            schema.DisplayIcon=fullfile('toolbox','shared','dastudio','resources','DictionaryIcon.png');

            schema.CloseCallback='Simulink.dd.DictionaryPreImport.closeCB';
            schema.CloseArgs={'%dialog','%closeaction'};
        end

        function continueProcess(obj)
            obj.mAlreadyClosed=true;
            obj.mCallbackF(obj.mDDConn,obj.mSource,true,obj.mOverwrite,obj.mCallbackArgs{:});
        end

        function cancelProcess(obj)
            obj.mAlreadyClosed=true;
            obj.mCallbackF(obj.mDDConn,obj.mSource,false,false,obj.mCallbackArgs{:});
        end

        function clickCheckbox(obj,bChecked)
            obj.mOverwrite=bChecked;
        end

    end

    methods(Static)
        function buttonCB(dialogH,clickedTag)
            dlgsrc=dialogH.getDialogSource;
            if isequal(clickedTag,'SLDD:sldd:OverwriteExisting')
                dlgsrc.clickCheckbox(dialogH.getWidgetValue(clickedTag));
            elseif isequal(clickedTag,'Simulink:editor:DialogContinue')
                dlgsrc.continueProcess();
                delete(dialogH);
            else
                dlgsrc.cancelProcess();
                delete(dialogH);
            end
        end

        function closeCB(dialogH,action)
            dlgsrc=dialogH.getDialogSource;
            if~dlgsrc.mAlreadyClosed
                dlgsrc.cancelProcess();
            end
        end

        function diff(dictPath,existingVar,dictPath2,newVar)
            ddConn=Simulink.dd.open(dictPath);
            dictVarID=ddConn.getEntryID(existingVar);
            ddConn.close();
            entryIDStr=num2str(dictVarID);
            vs1Str=['slddEvaluate(''',dictPath,''', ',entryIDStr,', true)'];
            if isempty(dictPath2)
                vs2Str=['evalin(''base'',','''',newVar,''')'];
            else
                ddConn=Simulink.dd.open(dictPath2);
                dictVarID=ddConn.getEntryID(newVar);
                ddConn.close();
                entryIDStr=num2str(dictVarID);
                vs2Str=['slddEvaluate(''',dictPath2,''', ',entryIDStr,', true)'];
            end

            vs1=comparisons.internal.var.makeVariableSource(existingVar,vs1Str);
            vs2=comparisons.internal.var.makeVariableSource(newVar,vs2Str);

            comparisons.internal.var.startComparison(vs1,vs2)
        end

    end

end
