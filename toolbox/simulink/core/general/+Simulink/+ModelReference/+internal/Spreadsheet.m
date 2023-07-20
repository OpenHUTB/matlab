


classdef Spreadsheet<handle
    properties(SetAccess=private,GetAccess=public)
        m_DlgSource;
        m_SlimDialog;
    end

    methods
        function obj=Spreadsheet(aDlgSource,...
            isSlimDialog)
            obj.m_DlgSource=aDlgSource;
            obj.m_SlimDialog=isSlimDialog;
            obj.m_DlgSource.UserData.m_Children=[];
        end

        function aChildren=getChildren(this)
            if isfield(this.m_DlgSource.UserData,'m_Children')&&~isempty(this.m_DlgSource.UserData.m_Children)
                aChildren=this.m_DlgSource.UserData.m_Children;
                return;
            end


            this.m_DlgSource.UserData.m_Children=[];
            aBlkHdl=this.m_DlgSource.getBlock().Handle;

            try
                aModelArgsInfo=get_param(aBlkHdl,'ParameterArgumentInfo');
            catch
                aChildren=[];
                return;
            end

            aModelArgValuesArr=slInternal('getParsedParameterArgumentValues',aBlkHdl);
            aModelArgNamesArr=strsplit(get_param(aBlkHdl,'ParameterArgumentNames'),',');
            if~isempty(aModelArgValuesArr)
                name2value=containers.Map(aModelArgNamesArr,aModelArgValuesArr);
            end
            aUsingDefault=get_param(aBlkHdl,'UsingDefaultArgumentValue');

            if isempty(aUsingDefault)
                aUsingDefaultArr=[];
            else
                aUsingDefaultArr=strsplit(aUsingDefault,',');
                aUsingDefaultArr=cellfun(@str2num,aUsingDefaultArr);
            end




            if length(aModelArgValuesArr)~=length(aModelArgsInfo)
                aUsingDefaultArr=zeros(length(aModelArgsInfo),1);
                set_param(aBlkHdl,'ParameterArgumentValues','');
            end

            aChildren=Simulink.ModelReference.internal.SpreadsheetRow.empty(length(aModelArgsInfo),0);
            for i=1:length(aModelArgsInfo)
                if~isempty(aUsingDefaultArr)&&aUsingDefaultArr(i)
                    aValue='';
                else
                    if isfield(aModelArgsInfo(i),'SIDPath')&&~isempty(aModelArgsInfo(i).SIDPath)
                        aValue=name2value(aModelArgsInfo(i).SIDPath);
                    else
                        aValue=name2value(aModelArgsInfo(i).ArgName);
                    end
                end

                path=aModelArgsInfo(i).FullPath;
                if strcmp(aModelArgsInfo(i).FullPath,'<Model Workspace>')
                    refModel=get_param(aBlkHdl,'ModelNameDialog');
                    isProtected=slInternal('getReferencedModelFileInformation',refModel);

                    if isProtected
                        path=Simulink.ModelReference.internal.SpreadsheetRow.protectedLabel;
                    end
                end

                refModel=get_param(aBlkHdl,'ModelNameDialog');
                isProtected=slInternal('getReferencedModelFileInformation',refModel);
                if(isProtected)
                    modelName='';
                else
                    modelName=get_param(aBlkHdl,'ModelName');
                end

                isFromProtectedModel=aModelArgsInfo(i).IsFromProtectedModel;

                aChildren(i)=...
                Simulink.ModelReference.internal.SpreadsheetRow(this.m_DlgSource,...
                aModelArgsInfo(i).DisplayName,...
                aModelArgsInfo(i).DefaultValue,...
                modelName,...
                aValue,...
                path,...
                isFromProtectedModel,...
                this.m_SlimDialog);
            end
            this.m_DlgSource.UserData.m_Children=aChildren;
        end

        function aResolved=resolveSourceSelection(~,aSelections,~,~)
            aResolved=aSelections;
        end

    end
end


