function dialog=getDialogSchema(self,~)




    dialog.DialogTitle=DAStudio.message('Simulink:dialog:autosaveDialogTitle');
    dialog.DialogTag='autosaveDialog';
    dialog.HelpMethod='helpview';
    dialog.HelpArgs={[docroot,'/toolbox/simulink/helptargets.map'],'autosave_dialog'};

    if self.numFiles()==1

        dialog.StandaloneButtonSet={''};

        explanation.Type='text';
        [folder,bdname]=fileparts(self.files{1});
        explanation.Name=DAStudio.message('Simulink:dialog:autosaveExplanationSingle',bdname,folder);
        explanation.ColSpan=[1,4];
        explanation.RowSpan=[1,1];

        ignore.Type='pushbutton';
        ignore.Name=DAStudio.message('Simulink:dialog:autosaveIgnore');
        ignore.Tag='ignore';
        ignore.ObjectMethod='buttonCallback';
        ignore.MethodArgs={'ignore'};
        ignore.ArgDataTypes={'string'};
        ignore.ColSpan=[2,2];
        ignore.RowSpan=[2,2];

        restore.Type='pushbutton';
        restore.Name=DAStudio.message('Simulink:dialog:autosaveRestore');
        restore.Tag='restore';
        restore.ObjectMethod='buttonCallback';
        restore.MethodArgs={'restore'};
        restore.ArgDataTypes={'string'};
        restore.ColSpan=[3,3];
        restore.RowSpan=[2,2];

        discard.Type='pushbutton';
        discard.Name=DAStudio.message('Simulink:dialog:autosaveDiscard');
        discard.Tag='discard';
        discard.ObjectMethod='buttonCallback';
        discard.MethodArgs={'discard'};
        discard.ArgDataTypes={'string'};
        discard.ColSpan=[4,4];
        discard.RowSpan=[2,2];

        dialog.Items={explanation,ignore,restore,discard};
        dialog.LayoutGrid=[2,4];

    else

        dialog.StandaloneButtonSet={'OK','Cancel','Help'};

        explanation.Type='text';
        explanation.Name=DAStudio.message('Simulink:dialog:autosaveExplanation');

        newtable.Type='group';
        newtable.Items={};
        newtable.Items=[newtable.Items,i_generateTitleLine(self),i_generateButtonLine(self)];
        newtable.LayoutGrid=[2+self.numFiles(),21];
        for i=1:self.numFiles()
            newtable.Items=[newtable.Items,i_generateFileLine(self,i)];
        end

        dialog.Items={explanation,newtable};
    end

    dialog.PostApplyMethod='apply';
    dialog.CloseMethod='close';
    dialog.MinimalApply=false;


    function line=i_generateTitleLine(~)
        titles={DAStudio.message('Simulink:dialog:autosaveRestore')...
        ,DAStudio.message('Simulink:dialog:autosaveTableTitle2')...
        ,DAStudio.message('Simulink:dialog:autosaveIgnore')...
        ,DAStudio.message('Simulink:dialog:autosaveTableTitle4')...
        ,DAStudio.message('Simulink:dialog:autosaveTableTitle5')...
        ,DAStudio.message('Simulink:dialog:autosaveTableTitle6')...
        ,DAStudio.message('Simulink:dialog:autosaveTableTitle7')
        };
        line=num2cell(arrayfun(...
        @(x)struct('Type','text','Name',x,'RowSpan',[1,1],'Alignment',6),...
        titles));
        for i=1:length(line)
            line{i}.ColSpan=[3*i-2,3*i];
        end


        function line=i_generateButtonLine(self)
            texts={DAStudio.message('Simulink:dialog:autosaveAllButton1')...
            ,DAStudio.message('Simulink:dialog:autosaveAllButton2')...
            ,DAStudio.message('Simulink:dialog:autosaveAllButton3')};
            proto.Type='pushbutton';
            proto.RowSpan=[2,2];
            proto.Alignment=6;
            proto.ObjectMethod='setButtonState';
            proto.ArgDataTypes={'mxArray','mxArray','bool'};
            line=cell(1,3);
            for i=1:3
                line{i}=proto;
                line{i}.Tag=['A_',int2str(i)];
                line{i}.Name=texts{i};
                line{i}.ColSpan=[3*i-2,3*i];
                line{i}.MethodArgs={1:self.numFiles(),i-1,true};
            end


            function line=i_generateFileLine(self,j)
                filename=self.files{j};
                filedate=self.filedates{j};
                autodate=self.autodates{j};
                [path,name]=fileparts(filename);
                buttons=i_checkBoxVersion(self,j);
                line=buttons;
                spacer=blanks(10);
                line=[line,num2cell(arrayfun(...
                @(x)struct('Type','text','Name',strcat(spacer,x,spacer),...
                'RowSpan',[j+2,j+2],'Alignment',6),...
                {name,path,filedate,autodate}))];
                for i=4:7
                    line{i}.ColSpan=[3*i-1,3*i-1];
                end


                function buttons=i_checkBoxVersion(self,j)
                    proto.Type='checkbox';
                    proto.Name='';
                    proto.RowSpan=[j+2,j+2];
                    proto.Alignment=6;
                    proto.ArgDataTypes={'mxArray','mxArray','bool'};
                    proto.ObjectMethod='setButtonState';
                    buttons=cell(1,3);
                    for i=1:3
                        buttons{i}=proto;
                        buttons{i}.Tag=['Check_',int2str(i),'_',int2str(j)];
                        buttons{i}.ColSpan=[3*i-2,3*i];
                        buttons{i}.Value=self.filestate(j)+1==i;
                        buttons{i}.MethodArgs={j,i-1,true};
                    end
