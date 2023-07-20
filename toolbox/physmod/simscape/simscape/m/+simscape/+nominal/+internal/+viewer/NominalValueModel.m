





classdef NominalValueModel<handle

    properties(SetAccess=private)



Name
        Data=struct("Values",{},"Units",{});
    end

    methods

        function this=NominalValueModel(mdlname,values,units)
            this.Name=mdlname;
            this.Data=lEntry(values,units);
        end

        function addRow(this,~,~)
            val='--';
            unit='--';
            this.Data(end+1)=lEntry(val,unit);
        end

        function deleteRow(this,selectedCellIndices,~)
            this.Data(selectedCellIndices(1))=[];
        end

        function updateData(this,editedCellIndices,val,unit)
            this.Data(editedCellIndices(1))=lEntry(val,unit);
        end

        function updateMdlName(this,newMdlName)
            this.Name=newMdlName;
        end
    end
end

function s=lEntry(values,units)
    s=struct("Values",values,"Units",units);
end