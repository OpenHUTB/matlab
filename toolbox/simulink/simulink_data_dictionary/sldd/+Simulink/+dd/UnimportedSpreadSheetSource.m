classdef UnimportedSpreadSheetSource<handle





    properties
        mData;
        mComponentName;
        duplicateList;
        conflictList;
        unsupportedList;

    end
    methods
        function obj=UnimportedSpreadSheetSource(tag,dups,conflicts,unsupporteds)
            obj.mData=[];
            obj.mComponentName=sprintf('GLUE2:SpreadSheet/%s',tag);
            obj.duplicateList=dups;
            obj.conflictList=conflicts;
            obj.unsupportedList=unsupporteds;
        end

        function children=getChildren(obj)

            children=Simulink.dd.UnimportedSpreadSheetRow.empty(length([obj.duplicateList;obj.conflictList;obj.unsupportedList]),0);
            if isempty(obj.mData)

                if~isempty(obj.duplicateList)
                    for i=1:length(obj.duplicateList)
                        childObj=Simulink.dd.UnimportedSpreadSheetRow(obj.duplicateList{i},...
                        DAStudio.message('SLDD:sldd:Reason_Duplicate'),...
                        DAStudio.message('SLDD:sldd:Existing_Identical'));
                        children(i)=childObj;
                    end
                else
                    i=0;
                end

                if~isempty(obj.conflictList)
                    for j=1:length(obj.conflictList)
                        childObj=Simulink.dd.UnimportedSpreadSheetRow(obj.conflictList{j},...
                        DAStudio.message('SLDD:sldd:Reason_Conflict'),...
                        DAStudio.message('SLDD:sldd:Existing_Conflict'));
                        children(i+j)=childObj;
                    end
                else
                    j=0;
                end

                if~isempty(obj.unsupportedList)
                    for k=1:length(obj.unsupportedList)
                        childObj=Simulink.dd.UnimportedSpreadSheetRow(obj.unsupportedList{k},...
                        DAStudio.message('SLDD:sldd:Reason_UnsupportedVar'),...
                        DAStudio.message('SLDD:sldd:Unsupported_details'));
                        children(i+j+k)=childObj;
                    end
                end
                obj.mData=children;
            end
            children=obj.mData;
        end
    end
end


