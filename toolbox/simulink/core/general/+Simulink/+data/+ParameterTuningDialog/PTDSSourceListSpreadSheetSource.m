classdef PTDSSourceListSpreadSheetSource<handle
    properties
        mData=[];
        mSourceData={};
        hmodel;
        tunableParametersSource;
    end
    methods
        function this=PTDSSourceListSpreadSheetSource(sourceListType,hModel,tunableParametersSource)
            this.hmodel=hModel;
            this.tunableParametersSource=tunableParametersSource;
            if isequal(sourceListType,'MatlabWorkspace')
                this.mSourceData=slGetSpecifiedWSData('',1,0,0);
            else
                referencedVars=get_param(hModel,'ReferencedWSVars');
                if~isempty(referencedVars)
                    varsList={referencedVars.Name}';
                    validNames=slGetSpecifiedWSData('',1,0,0);
                    this.mSourceData=intersect(varsList,validNames);
                end
            end
        end

        function children=getChildren(obj,component)
            children=obj.mData;
            if isempty(obj.mData)
                for i=1:numel(obj.mSourceData)
                    childObj=Simulink.data.ParameterTuningDialog.PTDSSourceListSpreadSheetSourceRow(obj.mSourceData{i},obj.hmodel,obj.tunableParametersSource);
                    children=[children,childObj];
                end
                obj.mData=children;
            end
        end
    end
end

