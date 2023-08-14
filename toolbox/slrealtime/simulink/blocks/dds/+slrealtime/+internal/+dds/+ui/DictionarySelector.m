classdef DictionarySelector<handle







    properties(Constant)

        SELECT_EXISTING_DICT=0
        SELECT_XML_IMPORT=1
        SELECT_DEFAULT=2
    end

    properties(SetAccess=protected)
        SelectedSLDD=''
        CloseFcnHandle=function_handle.empty
        SelectedOption=slrealtime.internal.dds.ui.DictionarySelector.SELECT_EXISTING_DICT;
        SelectedFileName='';
        ModelName='';
    end

    methods(Access=protected)

    end

    methods
        function obj=DictionarySelector(mdlName)
            obj.SelectedSLDD='';
            obj.SelectedFileName='';
            obj.ModelName=mdlName;
        end
        function dlg=openDialog(obj,closeFcnHandle)
            validateattributes(closeFcnHandle,{'function_handle'},{'scalar'});
            obj.SelectedSLDD='';
            obj.SelectedFileName='';
            obj.CloseFcnHandle=closeFcnHandle;
            dlg=DAStudio.Dialog(obj);
        end
    end



    methods(Hidden)

        function browseDictionaryCallback(obj,dlg)

            obj.SelectedSLDD='';
            obj.SelectedFileName='';
            if dlg.getWidgetValue('optionSelection')==slrealtime.internal.dds.ui.DictionarySelector.SELECT_EXISTING_DICT
                [fileName,pathName,~]=uigetfile('*.sldd',getString(message('slrealtime:dds:selectDD')));
                if~isequal(fileName,0)

                    try
                        Simulink.data.dictionary.open(fullfile(pathName,fileName));
                    catch ex

                        errordlg(ex.message,...
                        'Error','modal');
                        obj.SelectedSLDD='';
                        obj.SelectedFileName='';
                        dlg.refresh;
                        return
                    end

                    obj.SelectedSLDD=fileName;
                    obj.SelectedFileName=fileName;
                    dlg.refresh;
                end
            elseif dlg.getWidgetValue('optionSelection')==slrealtime.internal.dds.ui.DictionarySelector.SELECT_XML_IMPORT
                [fileName,pathName,~]=uigetfile('*.xml',getString(message('slrealtime:dds:fileSelectImport')),'MultiSelect','on');
                if~isequal(fileName,0)

                    [~,name,~]=fileparts(fileName);
                    try
                        dds.internal.simulink.Util.importDDSXml(fullfile(pathName,fileName),[name,'.sldd']);
                    catch ex

                        errordlg(ex.message,...
                        'Error','modal');
                        obj.SelectedSLDD='';
                        obj.SelectedFileName='';
                        dlg.refresh;
                        return
                    end

                    obj.SelectedSLDD=[name,'.sldd'];
                    obj.SelectedFileName=fileName;
                    dlg.refresh;
                end
            end
        end

        function dlgClose(obj,closeaction)



            if strcmpi(closeaction,'ok')&&obj.SelectedOption==slrealtime.internal.dds.ui.DictionarySelector.SELECT_DEFAULT
                defaultdds='defaultdds.xml';
                xmlFileList={fullfile(matlabroot,'toolbox','dds','src',defaultdds)};
                defaultSldd=[obj.ModelName,'.sldd'];
                try
                    dds.internal.simulink.Util.importDDSXml(xmlFileList,defaultSldd);
                    obj.SelectedSLDD=defaultSldd;
                catch ex

                    errordlg(ex.message,...
                    'Error','modal');
                    obj.SelectedSLDD='';
                    dlg.refresh;
                    return
                end
            end

            if~isempty(obj.CloseFcnHandle)
                isAcceptedSelection=strcmpi(closeaction,'ok');
                try
                    feval(obj.CloseFcnHandle,isAcceptedSelection,obj.SelectedSLDD);
                catch



                end
            end
        end


        function optionChangedCallback(obj,dlg)

            if dlg.getWidgetValue('optionSelection')==slrealtime.internal.dds.ui.DictionarySelector.SELECT_EXISTING_DICT
                obj.SelectedOption=slrealtime.internal.dds.ui.DictionarySelector.SELECT_EXISTING_DICT;
                dlg.setVisible('DictionaryEditText',true);
                dlg.setVisible('browseDictionary',true);
                dlg.setWidgetPrompt('DictionaryEditText','Simulink Dictionary:');
            elseif dlg.getWidgetValue('optionSelection')==slrealtime.internal.dds.ui.DictionarySelector.SELECT_XML_IMPORT
                obj.SelectedOption=slrealtime.internal.dds.ui.DictionarySelector.SELECT_XML_IMPORT;
                dlg.setVisible('DictionaryEditText',true);
                dlg.setVisible('browseDictionary',true);
                dlg.setWidgetPrompt('DictionaryEditText','Select XML:');
            else
                obj.SelectedOption=slrealtime.internal.dds.ui.DictionarySelector.SELECT_DEFAULT;
                dlg.setVisible('DictionaryEditText',false);
                dlg.setVisible('browseDictionary',false);
            end
            dlg.refresh;
        end

        function dlgstruct=getDialogSchema(obj)


            dlgstruct.DialogTitle=getString(message('slrealtime:dds:dictSelDialogTitle'));
            dlgstruct.CloseMethod='dlgClose';
            dlgstruct.CloseMethodArgs={'%closeaction'};
            dlgstruct.CloseMethodArgsDT={'string'};



            dlgstruct.Sticky=true;




            dlgstruct.StandaloneButtonSet=...
            {'Ok','Cancel'};

            if obj.SelectedOption==slrealtime.internal.dds.ui.DictionarySelector.SELECT_EXISTING_DICT
                dictFile.Name=getString(message('slrealtime:dds:editSelectDD'));
            elseif obj.SelectedOption==slrealtime.internal.dds.ui.DictionarySelector.SELECT_XML_IMPORT
                dictFile.Name=getString(message('slrealtime:dds:editImportXML'));
            else
                dictFile.Name='';
            end
            dictFile.Type='edit';
            dictFile.RowSpan=[2,2];
            dictFile.ColSpan=[1,1];
            dictFile.Tag='DictionaryEditText';
            dictFile.Value=obj.SelectedFileName;

            browseDict.Name=getString(message('slrealtime:dds:browseBtnName'));
            browseDict.Type='pushbutton';
            browseDict.RowSpan=[2,2];
            browseDict.ColSpan=[2,2];
            browseDict.ObjectMethod='browseDictionaryCallback';
            browseDict.Tag='browseDictionary';
            browseDict.WidgetId='browseDictionaryWidgetId';
            browseDict.MethodArgs={'%dialog'};
            browseDict.ArgDataTypes={'handle'};

            entryselect.Name='';
            entryselect.Type='radiobutton';
            entryselect.OrientHorizontal=false;
            entryselect.RowSpan=[1,1];
            entryselect.ColSpan=[1,2];
            selectableEntries={getString(message('slrealtime:dds:useExistingDict')),...
            getString(message('slrealtime:dds:importXML')),...
            getString(message('slrealtime:dds:createDefaultDict'))};

            entryselect.Entries=selectableEntries;
            entryselect.Tag='optionSelection';
            entryselect.Value=slrealtime.internal.dds.ui.DictionarySelector.SELECT_EXISTING_DICT;
            entryselect.ObjectMethod='optionChangedCallback';
            entryselect.MethodArgs={'%dialog'};
            entryselect.ArgDataTypes={'handle'};

            groupFolderSelector.Type='group';
            groupFolderSelector.Name=getString(message('slrealtime:dds:selectDD'));
            groupFolderSelector.LayoutGrid=[1,1];
            groupFolderSelector.Flat=true;
            groupFolderSelector.Items={entryselect,dictFile,browseDict};

            dlgstruct.Items={groupFolderSelector};
        end
    end
end
