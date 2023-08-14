

classdef vendorToolPathDlg<handle



    properties
        sys='';
        vendorToolPath='';
    end

    properties(Access=private)
        hModelCloseListener;
    end


    methods(Access=private)
        function installModelCloseListener(obj)




            h=@(a,b,x)x.delete;
            blkDiagram=get_param(bdroot(obj.sys),'Object');
            obj.hModelCloseListener=Simulink.listener(blkDiagram,'CloseEvent',...
            @(src,evt)h(src,evt,obj));
        end
    end


    methods

        function dlg=vendorToolPathDlg(sys)

            dlg.sys=sys;

            dlg.vendorToolPath=pwd;

            dlg.installModelCloseListener();
        end

        function delete(obj)

            hdlverifier.internal.sltoolstrip.vendorToolPathDlg.dlgActionMap(obj.sys,'close');
        end

        function schema=getDialogSchema(obj)

            tag_prefix='vendorToolDlg_';


            descriptionText.Type='text';
            descriptionText.Name=DAStudio.message('EDALink:SLToolstrip:General:vendorToolPathDlgDescriptionText');
            descriptionText.RowSpan=[1,1];
            descriptionText.ColSpan=[1,1];
            descriptionText.Tag=[tag_prefix,'descriptionText'];
            descriptionText.WordWrap=true;

            descriptionGroup.Type='group';
            descriptionGroup.Name=DAStudio.message('EDALink:SLToolstrip:General:vendorToolPathDlgDescriptionGroupLabel');
            descriptionGroup.LayoutGrid=[1,1];
            descriptionGroup.Tag=[tag_prefix,'descriptionGroup'];
            items={descriptionText};

            descriptionGroup.Items=items;




            editTextField.Type='edit';
            editTextField.RowSpan=[1,1];
            editTextField.ColSpan=[2,2];


            editTextField.Source=obj;
            editTextField.ObjectProperty='vendorToolPath';
            editTextField.ListenToProperties={'vendorToolPath'};
            editTextField.Tag=[tag_prefix,'editTextField'];
            editTextField.ToolTip=DAStudio.message('EDALink:SLToolstrip:General:vendorToolPathDlgEditTextFieldTooltip');


            editTextFieldLabel.Type='text';
            editTextFieldLabel.Alignment=2;
            editTextFieldLabel.Name=DAStudio.message('EDALink:SLToolstrip:General:vendorToolPathDlgSpecifyPathTextLabel');
            editTextFieldLabel.RowSpan=[1,1];
            editTextFieldLabel.ColSpan=[1,1];
            editTextFieldLabel.Tag=[tag_prefix,'editTextFieldLabel'];
            editTextFieldLabel.Buddy=editTextField.Tag;


            browsePathButton.Type='pushbutton';
            browsePathButton.Name=DAStudio.message('EDALink:SLToolstrip:General:vendorToolPathDlgBrowseButtonLabel');
            browsePathButton.RowSpan=[1,1];
            browsePathButton.ColSpan=[3,3];
            browsePathButton.Mode=1;
            browsePathButton.DialogRefresh=1;
            browsePathButton.Source=obj;
            browsePathButton.ObjectMethod='browseToolLocation';
            browsePathButton.MethodArgs={'%dialog'};
            browsePathButton.ArgDataTypes={'handle'};
            browsePathButton.Tag=[tag_prefix,'browsePathButton'];
            browsePathButton.ToolTip=DAStudio.message('EDALink:SLToolstrip:General:vendorToolPathDlgBrowseButtonTooltip');

            specifyPathGroup.Type='group';
            specifyPathGroup.Name=DAStudio.message('EDALink:SLToolstrip:General:vendorToolPathDlgSpecifyPathGroupLabel');
            specifyPathGroup.LayoutGrid=[1,3];
            specifyPathGroup.Tag=[tag_prefix,'specifyPathGroup'];
            items={editTextFieldLabel,editTextField,browsePathButton};

            specifyPathGroup.Items=items;


            addPathButton.Type='pushbutton';
            addPathButton.RowSpan=[1,1];
            addPathButton.ColSpan=[4,4];
            addPathButton.Tag=[tag_prefix,'addPathButton'];
            addPathButton.Name=DAStudio.message('EDALink:SLToolstrip:General:vendorToolPathDlgAddPathButtonLabel');
            addPathButton.ObjectMethod='addToolToPath';
            addPathButton.Enabled=true;


            cancelButton.Type='pushbutton';
            cancelButton.Name=DAStudio.message('EDALink:SLToolstrip:General:vendorToolPathDlgCancelButtonLabel');
            cancelButton.RowSpan=[1,1];
            cancelButton.ColSpan=[5,5];
            cancelButton.ObjectMethod='cancelDlg';
            cancelButton.Tag=[tag_prefix,'cancelButton'];


            standaloneButtonPanel.Type='panel';
            standaloneButtonPanel.LayoutGrid=[1,5];
            standaloneButtonPanel.ColStretch=[0,0,0,0,0];
            standaloneButtonPanel.Items={addPathButton,cancelButton};


            schema.DialogTitle=DAStudio.message('EDALink:SLToolstrip:General:vendorToolPathDlgTitle');
            schema.DialogTag=[tag_prefix,'DialogTitle'];


            schema.CloseCallback='hdlverifier.internal.sltoolstrip.vendorToolPathDlg.CloseCallback';
            schema.CloseArgs={'%dialog'};



            schema.OpenCallback=@hdlverifier.internal.sltoolstrip.vendorToolPathDlg.OpenCallback;

            schema.StandaloneButtonSet=standaloneButtonPanel;
            schema.IsScrollable=false;
            schema.Items={descriptionGroup,specifyPathGroup};
        end



        function browseToolLocation(obj,h)
            currentPath=h.getWidgetValue('vendorToolDlg_editTextField');
            if isempty(currentPath)

                currentPath=pwd;
            end

            pathName=uigetdir(currentPath,'EDALink:SLToolstrip:General:vendorToolPathDlgBrowseDlgHeader');

            if pathName~=0
                obj.vendorToolPath=pathName;
                h.setWidgetValue('vendorToolDlg_editTextField',pathName);
            end
        end

        function addToolToPath(obj)


            origPATH=getenv('PATH');
            setenv('PATH',[obj.vendorToolPath,pathsep,origPATH]);

            delete(obj);
        end


        function cancelDlg(obj)
            delete(obj);
        end

    end


    methods(Static)

        function out=dlgActionMap(sys,action)


            persistent currentDlgMap;
            if isempty(currentDlgMap)
                currentDlgMap=containers.Map;
            end




            sysObj=get_param(sys,'Object');
            if strcmp(sysObj.Path,sysObj.Name)
                sys=sysObj.Name;
            else
                sys=[sysObj.Path,'/',sysObj.Name];
            end
            rootName=bdroot(sys);


            if strcmp(action,'open')



                if~currentDlgMap.isKey(rootName)
                    currentDlgMap(rootName)=hdlverifier.internal.sltoolstrip.vendorToolPathDlg(sys);
                    out=currentDlgMap(rootName);
                else
                    out=[];

                end

            elseif strcmp(action,'close')


                if currentDlgMap.isKey(rootName)
                    currentDlgMap.remove(rootName);
                    out=[];
                end

            else


                out=[];
            end
        end



        function CloseCallback(h)
            dlgSrc=h.getSource;
            hdlverifier.internal.sltoolstrip.vendorToolPathDlg.dlgActionMap(dlgSrc.sys,'close');
        end


        function OpenCallback(h)
            dlgSrc=h.getSource;
            h.setWidgetValue('vendorToolDlg__editTextField',dlgSrc.vendorToolPath);
        end

    end
end
