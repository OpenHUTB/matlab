function addImplParamInfo(this,implParamName,implParamType,implParamDefValue,implParamAllValues,panelLayout)











    if nargin<5
        implParamAllValues=[];
    end

    if nargin<6
        tabName=message('hdlcoder:hdlblockdialog:GeneralTab').getString;
        tabPosition=1;
        groupName=message('hdlcoder:hdlblockdialog:ImplementationParameters').getString;
        groupPosition=2;
        panelLayout=struct;
        panelLayout.tabName=tabName;
        panelLayout.tabPosition=tabPosition;
        panelLayout.groupName=groupName;
        panelLayout.groupPosition=groupPosition;
    end


    if isempty(this.implParamInfo)
        this.implParamInfo=containers.Map;
    end

    this.implParamInfo(lower(implParamName))=hdlimplparamstruct(implParamName,...
    implParamType,...
    implParamDefValue,...
    implParamAllValues,...
    panelLayout.tabName,...
    panelLayout.tabPosition,...
    panelLayout.groupName,...
    panelLayout.groupPosition);

