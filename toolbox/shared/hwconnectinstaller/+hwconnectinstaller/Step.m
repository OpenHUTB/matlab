classdef Step<handle




    properties(SetObservable=true)
Label
Description
Children
Buttons
Complete
ID
Parent
Proxy
Selectable
CustomDlgSchemaFcnH
ExecuteFcnH
VisibleFcnH
StepData
AutoNext
EnableNextButton
    end

    properties(Access=private)
CachedDlgStruct
        Setup=[]
    end

    methods
        function h=Step(varargin)
            if(nargin>0)
                h.ID=varargin{1};
                if(nargin>4)
                    group=varargin{5};
                else
                    group='setup';
                end
                if(nargin>5)
                    messageCatalog=varargin{6};
                else
                    messageCatalog='hwconnectinstaller';
                end
                h.getLabelAndDescription(varargin{1},messageCatalog,group);
            end
            h.Complete=false;
            h.Selectable=false;
            h.AutoNext=false;
            h.CachedDlgStruct=[];
            if(nargin>1)
                h.CustomDlgSchemaFcnH=varargin{2};
            end
            if(nargin>2)
                h.ExecuteFcnH=varargin{3};
            end
            if(nargin>3)
                h.VisibleFcnH=varargin{4};
            else
                h.VisibleFcnH='';
            end
            if(nargin>6)
                h.Setup=varargin{7};
            end

            h.EnableNextButton=0;

        end

        function hSetup=getSetup(h)

            if isempty(h.Setup)
                h.Setup=hwconnectinstaller.Setup.get();
            end
            hSetup=h.Setup;
        end


        function valid=isValidAsNextStep(h)%#ok
            valid=true;
        end



        function markComplete(h)
            h.Complete=true;
        end



        function comp=isComplete(h)
            comp=h.Complete;
        end

        function child=getChildByID(h,id)
            childIDS={h.Children(:).ID};
            idx=find(strcmpi(id,childIDS),1);
            assert(~isempty(idx));
            child=h.Children(idx);
        end




        function haschld=hasChildren(h)%#ok
            haschld=false;
        end



        function y=getChildren(h)%#ok
            y=[];
        end




        function y=isHierarchical(h)%#ok<MANU>
            y=true;
        end



        function y=getHierarchicalChildren(h)
            y=h.Children;
        end


        function val=getDisplayIcon(h)%#ok
            val='toolbox/simulink/simulink/modeladvisor/private/icon_task.png';
        end



        function displayLabel=getDisplayLabel(h)
            displayLabel=h.Label;
        end





        function back(h,arg)
            completeOverride=false;
            if(~isempty(h.ExecuteFcnH))
                try
                    h.getSetup().freezeExplorer();
                    completeOverride=h.ExecuteFcnH(h,'back',arg);
                    h.getSetup().unfreezeExplorer();
                catch ex
                    h.getSetup().unfreezeExplorer();
                    h.showError(ex);
                end
            end
            if(~completeOverride)


                h.getSetup().back(h,h.getPrevSibling());
            end
        end





        function next(h,arg)
            completeOverride=false;
            if(~isempty(h.ExecuteFcnH))
                try
                    h.getSetup().freezeExplorer();
                    completeOverride=h.ExecuteFcnH(h,'next',arg);
                    h.getSetup().unfreezeExplorer();
                catch ex
                    h.getSetup().unfreezeExplorer();
                    h.showError(ex);
                end
            end

            if(~completeOverride&&(exist('ex','var')==0))
                if(~isempty(h.Children))
                    h.getSetup().next(h,h.Children(1));
                else
                    h.getSetup().next(h,[]);
                end
            end
        end


        function idx=findobj(h,siblings)
            idx=[];
            for i=1:length(siblings)
                if(isequal(siblings(i),h))
                    idx=i;
                    break;
                end
            end
        end


        function sib=getNextSibling(h)
            sib=[];
            if isa(h.Parent,'hwconnectinstaller.Step')
                siblings=h.Parent.Children;
                if(~isempty(siblings))
                    index=h.findobj(siblings);
                    assert(~isempty(index));
                    while(index~=length(siblings))
                        sib=siblings(index+1);

                        if isempty(sib.VisibleFcnH)
                            break;
                        else
                            if sib.VisibleFcnH(sib)
                                break;
                            else
                                index=index+1;
                                sib=[];
                            end
                        end

                    end
                end
                if(isempty(sib))
                    sib=h.Parent.getNextSibling();
                end
            end
        end


        function sib=getPrevSibling(h)
            sib=[];
            if isa(h.Parent,'hwconnectinstaller.Step')
                siblings=h.Parent.Children;
                if(~isempty(siblings))
                    index=h.findobj(siblings);
                    assert(~isempty(index));
                    while(index~=1)
                        sib=siblings(index-1);
                        if isempty(sib.VisibleFcnH)
                            break;
                        else
                            if sib.VisibleFcnH(sib)
                                break;
                            else
                                index=index-1;
                                sib=[];
                            end
                        end
                    end
                    if(index==1)
                        sib=h.Parent;
                    end
                end
                if(isempty(sib))
                    sib=h.Parent.getPrevSibling();
                end
            end
        end


        function cancel(h,arg)
            completeOverride=false;
            if(~isempty(h.ExecuteFcnH))
                try
                    h.getSetup().freezeExplorer();
                    completeOverride=h.ExecuteFcnH(h,'cancel',arg);
                    h.getSetup().unfreezeExplorer();
                catch ex
                    h.getSetup().unfreezeExplorer();
                    h.showError(ex);
                end
            end
            if(~completeOverride)
                h.Parent.cancel(arg);
            end
        end


        function finish(h,arg)
            completeOverride=false;
            if(~isempty(h.ExecuteFcnH))
                try
                    h.getSetup().freezeExplorer();
                    completeOverride=h.ExecuteFcnH(h,'finish',arg);
                    h.getSetup().unfreezeExplorer();
                catch ex
                    h.getSetup().unfreezeExplorer();
                    h.showError(ex);
                end
            end
            if(~completeOverride)
                h.Parent.finish(arg);
            end
        end




        function refreshParentAndProxy(h,Parent,Proxy)
            h.Parent=Parent;
            h.Proxy=Proxy;
            if(~isempty(h.Children))
                ProxyChildren=h.Proxy.getHierarchicalChildren();
                for i=1:length(h.Children)
                    h.Children(i).refreshParentAndProxy(h,ProxyChildren(i));
                end
            end
        end



        function initializeCustomData(h)

            if(~isempty(h.ExecuteFcnH))
                try
                    completeOverride=h.ExecuteFcnH(h,'initialize');%#ok
                catch ex
                    h.showError(ex);
                end
            end
            if(~isempty(h.Children))
                for i=1:length(h.Children)
                    h.Children(i).initializeCustomData();
                end
            end
        end




        function setEnableWidgets(h,hDlg,enable)
            if(~isempty(h.CachedDlgStruct)&&isfield(h.CachedDlgStruct,'Items')&&~isempty(hDlg))
                for i=1:length(h.CachedDlgStruct.Items)
                    curItem=h.CachedDlgStruct.Items{i};
                    tag='';
                    if(isfield(curItem,'Tag'))
                        tag=curItem.Tag;
                    end
                    if(~isempty(tag))
                        if isfield(curItem,'Enabled')
                            hDlg.setEnabled(tag,curItem.Enabled);
                        else
                            hDlg.setEnabled(tag,enable);
                        end
                    end
                end
            end
        end




        function dialogCallback(h,varargin)
            completeOverride=false;
            if(~isempty(h.ExecuteFcnH))
                try
                    h.getSetup().freezeExplorer();
                    completeOverride=h.ExecuteFcnH(h,'callback',varargin{:});
                    h.getSetup().unfreezeExplorer();
                catch ex
                    completeOverride=true;
                    h.getSetup().unfreezeExplorer();
                    h.showError(ex);
                end
            end
            if(~completeOverride)
                switch(varargin{1})
                case 'Help',
                    hwconnectinstaller.helpView();
                otherwise,
                    assert(false);
                end
            end
        end




        function dlgstruct=getDialogSchema(h,varargin)

            if(~h.Selectable)
                hSetup=h.getSetup();
                if~isequal(hSetup.CurrentStep,h)

                    dlgstruct.DialogTitle='';
                    dlgstruct.Items={};
                    dlgstruct.LayoutGrid=[8,6];
                    dlgstruct.RowStretch=[0,0,0,0,0,0,1,0];
                    dlgstruct.ColStretch=[0,1,0,0,0,0];
                    dlgstruct.EmbeddedButtonSet={''};
                    return;
                end
            end

            Desc.Name=h.Description;
            Desc.Tag=[h.ID,'_Step_Description'];
            Desc.Type='text';
            Desc.RowSpan=[1,1];
            Desc.ColSpan=[1,4];

            HelpButton.Name=h.Buttons.Help;
            HelpButton.Type='pushbutton';
            HelpButton.Tag=[h.ID,'_Step_Help'];
            HelpButton.MatlabMethod='dialogCallback';
            HelpButton.MatlabArgs={h,'Help',HelpButton.Tag};

            HelpButton.RowSpan=[8,8];
            HelpButton.ColSpan=[6,6];
            HelpButton.Enabled=true;



            if hwconnectinstaller.SupportTypeQualifierEnum.isTechPreview
                HelpButton.Visible=false;
            else
                HelpButton.Visible=true;
            end

            BackButton.Name=h.Buttons.Back;
            BackButton.Tag=[h.ID,'_Step_Back'];
            BackButton.Type='pushbutton';
            BackButton.MatlabMethod='back';
            BackButton.MatlabArgs={h,BackButton.Tag};
            BackButton.RowSpan=[8,8];
            BackButton.ColSpan=[3,3];
            BackButton.Visible=h.getSetup().canMoveBack(h);

            NextButton.Name=h.Buttons.Next;
            NextButton.Tag=[h.ID,'_Step_Next'];
            NextButton.Type='pushbutton';
            NextButton.MatlabMethod='next';
            NextButton.MatlabArgs={h,NextButton.Tag};
            NextButton.RowSpan=[8,8];
            NextButton.ColSpan=[4,4];
            NextButton.Visible=~isempty(h.Children)||~isempty(h.getNextSibling());

            FinishButton.Name=h.Buttons.Finish;
            FinishButton.Tag=[h.ID,'_Step_Finish'];
            FinishButton.Type='pushbutton';
            FinishButton.MatlabMethod='finish';
            FinishButton.MatlabArgs={h,FinishButton.Tag};
            FinishButton.RowSpan=[8,8];
            FinishButton.ColSpan=[4,4];
            FinishButton.Visible=~NextButton.Visible;

            CancelButton.Name=h.Buttons.Cancel;
            CancelButton.Tag=[h.ID,'_Step_Cancel'];
            CancelButton.Type='pushbutton';
            CancelButton.MatlabMethod='cancel';
            CancelButton.MatlabArgs={h,CancelButton.Tag};
            CancelButton.RowSpan=[8,8];
            CancelButton.ColSpan=[5,5];




            dlgstruct.DialogTitle=h.Label;
            dlgstruct.Items={Desc,HelpButton,BackButton,NextButton,FinishButton,CancelButton};
            dlgstruct.LayoutGrid=[8,6];
            dlgstruct.RowStretch=[0,0,0,0,0,0,1,0];
            dlgstruct.ColStretch=[0,1,0,0,0,0];
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.DialogTag='support_package_installer';




            if(~isempty(h.CustomDlgSchemaFcnH))
                safedlgstruct=dlgstruct;
                try
                    dlgstruct=h.CustomDlgSchemaFcnH(h,dlgstruct);
                catch ex
                    dlgstruct=safedlgstruct;
                    h.showError(ex);
                end
            end
            h.CachedDlgStruct=dlgstruct;
        end

        function index=findDialogWidget(h,dlgstruct,suffix)
            tag=[h.ID,'_Step_',suffix];
            index=[];
            for i=1:numel(dlgstruct.Items)
                item=dlgstruct.Items{i};
                if isfield(item,'Tag')&&strcmpi(item.Tag,tag)
                    index=i;
                    break;
                end
            end
        end


        function showError(h,ex)
            hwconnectinstaller.internal.inform(ex.getReport());
            dp=DAStudio.DialogProvider;
            dp.DisplayIcon='toolbox/shared/hwconnectinstaller/resources/MatlabIcon.png';
            errorMessage=hwconnectinstaller.Step.getErrorMessageWithHyperLinks(ex);
            dp.errordlg(errorMessage,['Error: ',h.Label],true);
        end


        function getLabelAndDescription(h,prefix,messageCatalog,group)
            xlateEnt=struct(...
            'Label','',...
            'Description','');
            xlateEnt=hwconnectinstaller.internal.getXlateEntries(messageCatalog,group,prefix,xlateEnt);
            xlateCommon=struct(...
            'Help','',...
            'Back','',...
            'Next','',...
            'Finish','',...
            'Cancel','');
            h.Buttons=hwconnectinstaller.internal.getXlateEntries('hwconnectinstaller','setup','Common',xlateCommon);
            h.Label=xlateEnt.Label;
            h.Description=xlateEnt.Description;
        end


    end

    methods(Static)
        function errorMessage=getErrorMessageWithHyperLinks(ex)



            validateattributes(ex,{'MException'},{'nonempty'},'getErrorMessageWithHyperLinks','ex');






            if strcmpi(ex.identifier,'MATLAB:Java:GenericException')&&...
                isprop(ex,'ExceptionObject')

                errorMessage=char(ex.ExceptionObject.getLocalizedMessage);
            else

                errorMessage=ex.message;
            end











            result=regexpi(errorMessage,'(<|&lt;)\s*a\s*href\s*=("|&quot;)(?<url>.*)("|&quot;)\s*(>|&gt;)','names');
            if~isempty(result)
                errorMessage=sprintf('%s:\n%s',errorMessage,urldecode(result.url));
            end
        end
    end

end




