classdef SDPDataProvider<mdom.BaseDataProvider




    properties
dataModel
    end

    methods
        function obj=SDPDataProvider(model)
            obj.dataModel=simulinkcoder.internal.sdp.setup.SDPDataModel(model);
        end


        requestData(obj,ev)
        rangeData=getRangeData(obj,range)
        rowInfo=getRowInfo(obj,rowList)
        colInfo=getColumnInfo(obj,colList)


        [data,meta]=getNameData(obj,id,role)
        [data,meta]=getDeployableData(obj,id,role)
        [data,meta]=getCoderDictionaryData(obj,id,role)
        [data,meta]=getPlatformData(obj,id,role)
        [data,meta]=getDeploymentTypeData(obj,id,role)
        [data,meta]=getCodeInterfaceData(obj,id,role)


        onExpand(obj,id)
        onCollapse(obj,id)
        onEditComplete(obj,rowid,col,data)
    end
end

