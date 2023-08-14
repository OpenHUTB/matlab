function inputParamList=setDefaultInputParams(this,bAddFLLUM)
    if nargin==1
        bAddFLLUM=true;
    end

    if~isstruct(this.SubChecksCfg)
        error('Subcheck configuration given to the check is not a struct');
    end

    numlevels=numel(this.SubChecksCfg);
    inputParamList={};
    rowcount=1;
    ipForCallBack=[];
    for i=1:numlevels
        if~isfield(this.SubChecksCfg,'Type')
            error('Subcheck configuration does not specify a field named "Type"');
        end

        if strcmp(this.SubChecksCfg(i).Type,'Normal')
            if numlevels==1
                continue;
            end

            SO=slcheck.getSubCheckObject(this.SubChecksCfg(i).subcheck);
            SO.MessageCatalogPrefix=this.CheckCatalogPrefix;

            inputParamList{end+1}=getNormalSubCheckSelector(getIPNameFromSubcheck(SO),rowcount);%#ok<AGROW>
            rowcount=rowcount+1;
            ipForCallBack(end+1)=numel(inputParamList);%#ok<AGROW>      
        elseif strcmp(this.SubChecksCfg(i).Type,'Group')
            groupName=this.SubChecksCfg(i).GroupName;
            groupEntries={};
            for j=1:numel(this.SubChecksCfg(i).subcheck)
                SO=slcheck.getSubCheckObject(this.SubChecksCfg(i).subcheck(j));
                SO.MessageCatalogPrefix=this.CheckCatalogPrefix;

                groupEntries{end+1}=getIPNameFromSubcheck(SO);%#ok<AGROW>
            end

            inputParamList{end+1}=getGroupSubCheckSelector(groupName,groupEntries,rowcount,numel(this.SubChecksCfg)>1);%#ok<AGROW>
            rowcount=rowcount+numel(groupEntries)+1;
            ipForCallBack(end+1)=numel(inputParamList);%#ok<AGROW>
        else
            error('Invalid Type setting on Subcheck Config');
        end
    end

    if bAddFLLUM
        inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
        inputParamList{end}.RowSpan=[rowcount,rowcount];
        inputParamList{end}.ColSpan=[1,2];
        inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
        inputParamList{end}.RowSpan=[rowcount,rowcount];
        inputParamList{end}.ColSpan=[3,4];
        inputParamList{end}.Value='graphical';
    end
    this.setInputParametersLayoutGrid([rowcount,4]);
    this.setInputParameters(inputParamList);
    this.setInputParametersCallbackFcn(@(taskobj,tag,handle)slcheck.Check.defaultInputParamCallback(taskobj,tag,ipForCallBack));

end

function name=getIPNameFromSubcheck(Subcheck)
    name='';
    if~isempty(Subcheck.ID)
        name=[name,Subcheck.ID,': '];
    end
    name=[name,Subcheck.getDescription()];
end

function ip=getNormalSubCheckSelector(Name,row)
    ip=ModelAdvisor.InputParameter;
    ip.ColSpan=[1,4];
    ip.RowSpan=[row,row];
    ip.Name=Name;
    ip.Type='Bool';
    ip.Value=true;
    ip.Visible=false;
    ip.Enable=true;
end

function ip=getGroupSubCheckSelector(groupname,fieldsArray,row,disableButtonNeeded)

    ip=ModelAdvisor.InputParameter;
    ip.ColSpan=[1,4];
    ip.RowSpan=[row,row+length(fieldsArray)];
    ip.Name=groupname;
    if disableButtonNeeded
        ip.Entries=[{'Disable'},fieldsArray];
        ip.Value=1;
    else
        ip.Entries=fieldsArray;
        ip.Value=0;
    end
    ip.Type='RadioButton';
    ip.Visible=false;
    ip.Enable=true;
end

