classdef(Sealed)ReposDlg<handle

    properties
        Dialog=[];
        HasChoice(1,1)logical=false;
        Choice(1,1)int8{mustBeReal}=0;
        tempDir char='';
    end

    properties(Constant)
        SAVE=0;
        GENERATE=1;
        SKIP=2;
    end

    properties(Access='private')
        MissingList={};
    end

    methods(Access='private')
        function obj=ReposDlg()
        end

        function show(obj)
            obj.Dialog=DAStudio.Dialog(obj);
            obj.Dialog.show();
        end

        function obj=createTempDir(obj)
            dirName=tempname;
            mkdir(dirName);
            obj.tempDir=dirName;
        end

        function clearTempDir(obj)
            dir=obj.tempDir;
            if exist(dir,'dir')
                rmdir(dir,'s');
            end
        end
    end

    methods(Static=true)
        function obj=getInstance()

            mlock;
            persistent localObj;
            if isempty(localObj)||~isvalid(localObj)
                localObj=LibraryBrowser.ReposDlg();
                localObj.createTempDir();
            end
            obj=localObj;
        end

        function reset()
            obj=LibraryBrowser.ReposDlg.getInstance();
            obj.Choice=0;
            obj.HasChoice=false;
            obj.clearMissingList();
        end

        function result=shouldShowNotification()
            obj=LibraryBrowser.ReposDlg.getInstance();
            result=~isempty(obj.MissingList)&&~obj.HasChoice;
        end

        function execute(choice)
            obj=LibraryBrowser.ReposDlg.getInstance();
            if nargin==1
                obj.Choice=choice;
                obj.HasChoice=true;
            end

            if~isempty(obj.Dialog)||obj.HasChoice==true
                return;
            end

            obj.show();
        end

        function addLibToMissingList(aLibName)
            slBlocksFile=LibraryBrowser.internal.getSLBlocksFile(aLibName);
            if~isempty(slBlocksFile)
                [~,mdls,~,~,type,~,~,~,~]=LibraryBrowser.internal.getLibInfo(slBlocksFile);
                assert((size(mdls,1)==size(type,1))&&(size(mdls,2)==size(type,2)));

                obj=LibraryBrowser.ReposDlg.getInstance();



                for libIdx=1:numel(mdls)
                    if~isempty(type{libIdx})&&strcmpi(type{libIdx},'Palette')




                        continue;
                    end
                    obj.addToMissingList(mdls{libIdx});
                end
            end
        end

        function retChoice=getDialogChoice()
            obj=LibraryBrowser.ReposDlg.getInstance();
            retChoice=obj.Choice;
        end

        function retHasChoice=dialogHasChoice()
            obj=LibraryBrowser.ReposDlg.getInstance();
            retHasChoice=obj.HasChoice;
        end
    end

    methods
        function dlgstruct=getDialogSchema(obj)



            info_text.Type='text';
            info_text.Name=DAStudio.message('sl_lib_browse2:sl_lib_browse2:SLLB_ReposDlgInfo');
            info_text.WordWrap=true;
            info_text.RowSpan=[1,1];
            info_text.ColSpan=[1,2];





            choice_group.Type='radiobutton';
            choice_group.Tag='LBReposDlg_Choice';
            choice_group.Name='Action';
            choice_group.Entries={DAStudio.message('sl_lib_browse2:sl_lib_browse2:SLLB_ReposDlgSave'),...
            DAStudio.message('sl_lib_browse2:sl_lib_browse2:SLLB_ReposDlgGenerate'),...
            DAStudio.message('sl_lib_browse2:sl_lib_browse2:SLLB_ReposDlgSkip')
            };
            choice_group.Value=obj.Choice;
            choice_group.RowSpan=[2,2];
            choice_group.ColSpan=[1,2];




            dlgstruct.DialogTitle=DAStudio.message('sl_lib_browse2:sl_lib_browse2:SLLB_ReposDlgTitle');
            dlgstruct.DialogTag='LBReposDlg';
            dlgstruct.Items={info_text,choice_group};
            dlgstruct.StandaloneButtonSet={'OK','Cancel'};
            dlgstruct.DefaultOk=true;
            dlgstruct.ExplicitShow=true;
            dlgstruct.Sticky=true;
            dlgstruct.IsScrollable=false;
            dlgstruct.PreApplyMethod='onPreApply';
            dlgstruct.CloseMethod='onClose';
            dlgstruct.CloseMethodArgs={'%closeaction'};
            dlgstruct.CloseMethodArgsDT={'string'};
            dlgstruct.LayoutGrid=[2,2];
        end

        function onClose(obj,arg)
            if strcmpi(arg,'ok')
                if~isempty(obj.Dialog)
                    obj.Dialog.hide();
                    obj.Dialog.apply();
                    obj.Dialog.delete();

                    if obj.Choice~=LibraryBrowser.ReposDlg.SKIP



                        if LibraryBrowser.hasInstance
                            lb=LibraryBrowser.LibraryBrowser2;
                            lb.refresh();
                        else



                            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;

                            if~isempty(studios)
                                studio=studios(1);
                                bd_name=get_param(studio.App.blockDiagramHandle,'name');
                                lbcomp=studio.getComponent('LibraryBrowserComponent',bd_name);

                                if~isempty(lbcomp)
                                    lbcomp.refresh();
                                end
                            end
                        end

                    end
                end
            end
            obj.Dialog=[];
        end

        function onPreApply(obj)
            choice=obj.Dialog.getWidgetValue('LBReposDlg_Choice');
            obj.Choice=choice;
            obj.HasChoice=true;
        end

        function delete(obj)
            obj.clearTempDir();
        end
    end

    methods(Hidden)
        function addToMissingList(obj,libname)
            if~(ischar(libname)||(isstring(libname)&&isscalar(libname)))
                return;
            end
            if~obj.isInMissingList(libname)
                obj.MissingList=[obj.MissingList,libname];
            end
        end

        function removeFromMissingList(obj,libname)
            index=1;
            for entry=obj.MissingList
                if strcmpi(entry,libname)
                    break;
                end
                index=index+1;
            end


            if index<=length(obj.MissingList)
                obj.MissingList=[obj.MissingList(1:index-1),obj.MissingList(index+1:end)];
            end
        end

        function result=isInMissingList(obj,libname)
            result=false;
            for entry=obj.MissingList
                if strcmpi(entry,libname)
                    result=true;
                    break;
                end
            end
        end

        function clearMissingList(obj)
            obj.MissingList={};
        end

        function list=getMissingList(obj)
            list=obj.MissingList;
        end
    end
end


