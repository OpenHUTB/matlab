classdef DlgBkmrkRange<handle







    properties
sourceId
rangeId
rangeObj
firstLine
lastLine
    end

    methods

        function obj=DlgBkmrkRange(sourceId,rangeId)
            obj.sourceId=sourceId;
            obj.rangeId=rangeId;
            obj.rangeObj=slreq.getTextRange(sourceId,rangeId);
            lines=obj.rangeObj.getLineRange();
            obj.firstLine=lines(1);
            obj.lastLine=lines(2);
        end

        function dlgStruct=getDialogSchema(this)

            firstSpacer.Type='text';
            firstSpacer.Name=' ';
            firstSpacer.RowSpan=[1,1];
            firstSpacer.ColSpan=[1,1];

            secondSpacer.Type='text';
            secondSpacer.Name=' ';
            secondSpacer.RowSpan=[2,2];
            secondSpacer.ColSpan=[1,1];

            firstLabel.Type='text';
            firstLabel.Name='First line:';
            firstLabel.RowSpan=[1,1];
            firstLabel.ColSpan=[2,2];

            lastLabel.Type='text';
            lastLabel.Name='Last line:';
            lastLabel.RowSpan=[2,2];
            lastLabel.ColSpan=[2,2];

            firstEdit.Type='edit';
            firstEdit.Value=num2str(this.firstLine);
            firstEdit.Tag='BkmrkRange_firstEdit';
            firstEdit.RowSpan=[1,1];
            firstEdit.ColSpan=[3,3];
            firstEdit.MaximumSize=[75,25];
            firstEdit.ObjectMethod='BkmrkRange_firstEdit_callback';
            firstEdit.MethodArgs={'%dialog'};
            firstEdit.ArgDataTypes={'handle'};

            lastEdit.Type='edit';
            lastEdit.Value=num2str(this.lastLine);
            lastEdit.Tag='BkmrkRange_lastEdit';
            lastEdit.RowSpan=[2,2];
            lastEdit.ColSpan=[3,3];
            lastEdit.MaximumSize=[75,25];
            lastEdit.ObjectMethod='BkmrkRange_lastEdit_callback';
            lastEdit.MethodArgs={'%dialog'};
            lastEdit.ArgDataTypes={'handle'};

            decrementFirst.Type='pushbutton';
            decrementFirst.Tag='BkmrkRange_firstUp';
            decrementFirst.Name='-';
            decrementFirst.RowSpan=[1,1];
            decrementFirst.ColSpan=[4,4];
            decrementFirst.MaximumSize=[25,25];
            decrementFirst.ObjectMethod='BkmrkRange_firstUp_callback';
            decrementFirst.MethodArgs={'%dialog'};
            decrementFirst.ArgDataTypes={'handle'};
            decrementFirst.Enabled=this.firstLine>1;

            incrementFirst.Type='pushbutton';
            incrementFirst.Tag='BkmrkRange_firstDown';
            incrementFirst.Name='+';
            incrementFirst.RowSpan=[1,1];
            incrementFirst.ColSpan=[5,5];
            incrementFirst.MaximumSize=[25,25];
            incrementFirst.ObjectMethod='BkmrkRange_firstDown_callback';
            incrementFirst.MethodArgs={'%dialog'};
            incrementFirst.ArgDataTypes={'handle'};
            incrementFirst.Enabled=this.firstLine<this.lastLine;

            decrementLast.Type='pushbutton';
            decrementLast.Tag='BkmrkRange_lastUp';
            decrementLast.Name='-';
            decrementLast.RowSpan=[2,2];
            decrementLast.ColSpan=[4,4];
            decrementLast.MaximumSize=[25,25];
            decrementLast.ObjectMethod='BkmrkRange_lastUp_callback';
            decrementLast.MethodArgs={'%dialog'};
            decrementLast.ArgDataTypes={'handle'};
            decrementLast.Enabled=this.lastLine>this.firstLine;

            incrementLast.Type='pushbutton';
            incrementLast.Tag='BkmrkRange_lastDown';
            incrementLast.Name='+';
            incrementLast.RowSpan=[2,2];
            incrementLast.ColSpan=[5,5];
            incrementLast.MaximumSize=[25,25];
            incrementLast.ObjectMethod='BkmrkRange_lastDown_callback';
            incrementLast.MethodArgs={'%dialog'};
            incrementLast.ArgDataTypes={'handle'};
            incrementLast.Enabled=this.lastLine<this.getMaxLine();

            panel.Type='group';
            panel.Name=getString(message('Slvnv:slreq_objtypes:TextRangeDialogPanel',this.rangeId));
            panel.LayoutGrid=[2,5];
            panel.Items={...
            firstSpacer,firstLabel,firstEdit,decrementFirst,incrementFirst...
            ,secondSpacer,lastLabel,lastEdit,decrementLast,incrementLast};

            dlgStruct.DialogTitle=getString(message('Slvnv:slreq_objtypes:TextRangeDialogTitle'));
            dlgStruct.DialogTag='slreq_TextRangeDialog';
            dlgStruct.Items={panel};
            dlgStruct.StandaloneButtonSet={'OK'};

            dlgStruct.Sticky=true;

        end

    end




    methods(Access=public,Hidden=true)

        function BkmrkRange_firstEdit_callback(this,dlg)
            userInput=dlg.getWidgetValue('BkmrkRange_firstEdit');
            newFirstLine=str2num(userInput);%#ok<ST2NM>
            if~this.validate(newFirstLine)
                dlg.setWidgetValue('BkmrkRange_firstEdit',num2str(this.firstLine));
                error(message('Slvnv:rmipref:InvalidArgument',userInput));
            end
            if newFirstLine<=this.lastLine
                this.firstLine=newFirstLine;
                this.updateButtons(dlg);
                this.commit();
            else
                dlg.setWidgetValue('BkmrkRange_firstEdit',num2str(this.lastLine));
            end
        end

        function BkmrkRange_lastEdit_callback(this,dlg)
            userInput=dlg.getWidgetValue('BkmrkRange_lastEdit');
            newLastLine=str2num(userInput);%#ok<ST2NM> 
            if~this.validate(newLastLine)
                dlg.setWidgetValue('BkmrkRange_firstEdit',num2str(this.lastLine));
                error(message('Slvnv:rmipref:InvalidArgument',userInput));
            end
            if newLastLine>=this.firstLine
                this.lastLine=newLastLine;
                this.updateButtons(dlg);
                this.commit();
            else
                dlg.setWidgetValue('BkmrkRange_lastEdit',num2str(this.firstLine));
            end
        end

        function BkmrkRange_firstUp_callback(this,dlg)
            if this.firstLine>1
                origValue=this.firstLine;
                this.firstLine=this.firstLine-1;
                backendError=this.commit();
                if isempty(backendError)
                    dlg.setWidgetValue('BkmrkRange_firstEdit',num2str(this.firstLine));
                    this.updateButtons(dlg);
                else
                    this.firstLine=origValue;
                    rethrow(backendError);
                end
            end
        end

        function BkmrkRange_firstDown_callback(this,dlg)
            if this.firstLine<this.lastLine
                this.firstLine=this.firstLine+1;
                dlg.setWidgetValue('BkmrkRange_firstEdit',num2str(this.firstLine));
                this.updateButtons(dlg);
                this.commit();
            end
        end

        function BkmrkRange_lastUp_callback(this,dlg)
            if this.lastLine>this.firstLine
                this.lastLine=this.lastLine-1;
                dlg.setWidgetValue('BkmrkRange_lastEdit',num2str(this.lastLine));
                this.updateButtons(dlg);
                this.commit();
            end
        end

        function BkmrkRange_lastDown_callback(this,dlg)
            if this.lastLine<slreq.mleditor.ReqPluginHelper.getInstance.getMaxLineNumber(this.sourceId)
                origValue=this.lastLine;
                this.lastLine=this.lastLine+1;
                backendError=this.commit();
                if isempty(backendError)
                    dlg.setWidgetValue('BkmrkRange_lastEdit',num2str(this.lastLine));
                    this.updateButtons(dlg);
                else
                    this.lastLine=origValue;
                    rethrow(backendError);
                end
            end
        end

    end



    methods(Access=private)

        function maxLine=getMaxLine(this)
            maxLine=slreq.mleditor.ReqPluginHelper.getInstance.getMaxLineNumber(this.sourceId);
        end

        function tf=validate(this,lineNumber)
            if isempty(lineNumber)||~isnumeric(lineNumber)
                tf=false;
            elseif lineNumber<1||floor(lineNumber)<lineNumber
                tf=false;
            else
                tf=lineNumber<=this.getMaxLine();
            end
        end

        function updateButtons(this,dlg)
            dlg.setEnabled('BkmrkRange_firstDown',this.firstLine<this.lastLine);
            dlg.setEnabled('BkmrkRange_lastUp',this.lastLine>this.firstLine);
            canUP=this.firstLine>1&&isempty(slreq.getTextRange(this.sourceId,this.firstLine-1));
            dlg.setEnabled('BkmrkRange_firstUp',canUP);
            canDown=this.lastLine<this.getMaxLine()&&isempty(slreq.getTextRange(this.sourceId,this.lastLine+1));
            dlg.setEnabled('BkmrkRange_lastDown',canDown);
        end

        function ex=commit(this)
            ex=[];
            try
                this.rangeObj.setLineRange([this.firstLine,this.lastLine]);
            catch ex
            end
        end

        function notifyEditor(this)
            rmiml.notifyEditor(this.sourceId,this.rangeId,[this.firstLine,this.lastLine]);
        end

    end

end

