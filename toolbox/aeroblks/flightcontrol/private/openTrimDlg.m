function openTrimDlg(mdl)








    tool=slctrlguis.lintool.LinearAnalysisToolManager.getLinTool(mdl);
    show(tool);

    exactLinName=slctrlguis.lintool.TabEnum.ExactLin.Name;
    setSelectedTab(tool,exactLinName);

    exactLinTesters=getExactLinTabTesters(tool);
    popUp=localClickDropDown(exactLinTesters.Widgets.OPPicker.getDropDown);
    index=localGetDropDownIndex(popUp,ctrlMsgUtils.message('Slcontrol:lintool:OPMenuNewTrim'));
    localClickDropDown(exactLinTesters.Widgets.OPPicker.getDropDown,index);
end

function index=localGetDropDownIndex(popup,title)
    for iter=numel(popup):-1:1

        ItemClassType=class(popup(iter));
        if isequaln(ItemClassType,'matlab.ui.internal.toolstrip.ListItem')
            TitleList(iter).Text=popup(iter).Text;
        else
            TitleList(iter).Text=popup(iter).Title;
        end
    end

    ListIndex=arrayfun(@(x)isequaln(x.Text,title),TitleList);
    index=find(ListIndex,1);
end

function[varargout]=localClickDropDown(varargin)


    obj=varargin{1};


    obj.qeDropDownPushed;
drawnow
    if isequal(numel(varargin),2)
        index=varargin{2};
        listItem=obj.Popup.Children(index);
        listItem.qePushed;
    end
    varargout{1}=obj.Popup.Children;

end
