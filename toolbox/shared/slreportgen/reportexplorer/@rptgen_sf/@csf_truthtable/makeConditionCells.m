function out=makeConditionCells(c,varargin)






    cTable=c.RuntimeTruthTable.ConditionTable;
    nDeterminants=size(cTable,2)-2;

    nTables=ceil(nDeterminants/c.ConditionWrapLimit);
    nDetPerTable=ceil(nDeterminants/nTables);
    out={};
    for i=1:nTables
        firstIdx=(i-1)*nDetPerTable+1;
        out=[out,locMakeConditionTableFragment(c,...
        cTable(:,[1,2,2+firstIdx:2+min(i*nDetPerTable,nDeterminants)]),...
        firstIdx,...
        varargin{:})];
    end


    function out=locMakeConditionTableFragment(c,cTable,conditionIdx,d)

        nDeterminants=size(cTable,2)-2;

        if c.ShowConditionCode

            if nargin<4

                for i=1:size(cTable,1)-1
                    cTable{i,2}=set(sgmltag,...
                    'tag','ProgramListing',...
                    'data',cTable{i,2},...
                    'indent',logical(0));
                end
            else
                for i=1:size(cTable,1)-1
                    if isempty(findstr(cTable{i,2},char(10)))



                        cTable{i,2}=d.createElement('computeroutput',cTable{i,2});
                    else
                        cTable{i,2}=d.createElement('programlisting',cTable{i,2});
                        setAttribute(cTable{i,2},'xml:space','preserve');
                    end
                end
            end


            cTable{end,2}=getString(message('RptgenSL:rsf_csf_truthtable:actionsLabel'));
            cHeader={getString(message('RptgenSL:rsf_csf_truthtable:conditionLabel'))};
            cWid=900;
        else

            cTable=[cTable(:,1),cTable(:,3:end)];
            cHeader={};
            cWid=[];
        end

        if c.ShowConditionDescription
            cHeader=[{getString(message('RptgenSL:rsf_csf_truthtable:descriptionLabel'))},cHeader];
            cWid=[600,cWid];
            if~c.ShowConditionCode
                cTable{end,1}=getString(message('RptgenSL:rsf_csf_truthtable:actionsLabel'));
            else
                cTable{end,1}='';
            end
        else

            cTable=cTable(:,2:end);
        end

        if c.ShowConditionNumber
            cTable=[[num2cell(1:size(cTable,1)-1)';{''}],cTable];
            cHeader=[{'#'},cHeader];
            cWid=[100,cWid];
            if~c.ShowConditionCode&~c.ShowConditionDescription
                cTable{end,1}='A:';
            end
        else

        end

        cWid=[cWid,100*ones(1,nDeterminants)];

        if c.ShowConditionHeader


            cTable=[
            [cHeader,num2cell([conditionIdx:conditionIdx+nDeterminants-1])]
cTable
            ];
        end

        out={cTable,cWid};