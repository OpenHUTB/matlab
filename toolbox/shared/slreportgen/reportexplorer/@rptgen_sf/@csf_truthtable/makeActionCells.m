function out=makeActionCells(c,d)







    aTable=c.RuntimeTruthTable.ActionTable;

    if c.ShowActionCode

        if nargin<2

            for i=1:size(aTable,1)
                aTable{i,2}=set(sgmltag,...
                'tag','ProgramListing',...
                'data',aTable{i,2},...
                'indent',logical(0));
            end
        else
            for i=1:size(aTable,1)
                if isempty(findstr(aTable{i,2},char(10)))



                    aTable{i,2}=d.createElement('computeroutput',aTable{i,2});
                else
                    aTable{i,2}=d.createElement('programlisting',aTable{i,2});
                    setAttribute(aTable{i,2},'xml:space','preserve');
                end
            end
        end

        aHeader={getString(message('RptgenSL:rsf_csf_truthtable:actionLabel'))};
        aWid=9;
    else

        aTable=aTable(:,1);
        aHeader={};
        aWid=[];
    end

    if c.ShowActionDescription
        aHeader=[{getString(message('RptgenSL:rsf_csf_truthtable:descriptionLabel'))},aHeader];
        aWid=[6,aWid];
    else

        aTable=aTable(:,2:end);
    end

    if c.ShowActionNumber&&~isempty(aTable)
        aTable=[num2cell(1:size(aTable,1))',aTable];
        aHeader=[{'#'},aHeader];
        aWid=[1,aWid];
    else

    end

    if c.ShowActionHeader
        aTable=[
aHeader
aTable
        ];
    end

    out={aTable,aWid};