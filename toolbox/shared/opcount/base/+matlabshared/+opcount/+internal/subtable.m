classdef subtable
    methods(Static)
        function htable=create_htable(entrytable,hierarchy)
            htable=table;
            for i=1:size(entrytable,1)
                [htable,~]=matlabshared.opcount.internal.subtable.sort_selector(htable,entrytable(i,:),[hierarchy,{''}],1);
            end
        end

        function fstruct=flatten_htable(htable)
            [fstruct,~]=matlabshared.opcount.internal.subtable.extract_hierarchy(htable,[],0,nan);
        end
    end

    methods(Static,Hidden)
        function[fstruct,id]=extract_hierarchy(htable,fstruct,id,pid)
            for i=1:size(htable,1)
                tmpstr=table2struct(htable(i,:));
                subtable=tmpstr.SubTable;
                tmpstr=rmfield(tmpstr,'SubTable');
                if(isnan(pid))
                    tmpstr.parentID=pid;
                else
                    tmpstr.parentID=num2str(pid);
                end
                tmpstr.id=num2str(id);
                fstruct=[fstruct,tmpstr];
                previd=id;
                id=id+1;
                if(~isempty(subtable))
                    [fstruct,id]=matlabshared.opcount.internal.subtable.extract_hierarchy(subtable,fstruct,id,previd);
                end
            end
        end

        function line=new_line(entry,hierarchy,hidx)

            line=[{''},{''},{0},{''},{''},{''},{table}];
            for i=1:hidx
                line(i)=entry.(hierarchy{i});
            end
            line{3}=0;
        end

        function[htable,cnt]=sort_selector(htable,entry,hierarchy,hidx)

            switch hierarchy{hidx}
            case 'FileName'
                [htable,cnt]=matlabshared.opcount.internal.subtable.insert_fname(htable,entry,hierarchy,hidx);
            case 'Path'
                [htable,cnt]=matlabshared.opcount.internal.subtable.insert_path(htable,entry,hierarchy,hidx);
            case 'Count'
                [htable,cnt]=matlabshared.opcount.internal.subtable.sort_selector(htable,entry,hierarchy,hidx+1);
            case 'Operator'
                [htable,cnt]=matlabshared.opcount.internal.subtable.insert_op(htable,entry,hierarchy,hidx);
            case 'DataType'
                [htable,cnt]=matlabshared.opcount.internal.subtable.sort_selector(htable,entry,hierarchy,hidx+1);
            otherwise
                [htable,cnt]=matlabshared.opcount.internal.subtable.insert_detail(htable,entry,hierarchy,hidx);
            end
        end

        function[htable,cnt]=insert_fname(htable,entry,hierarchy,hidx)

            idx=0;
            if~isempty(htable)
                idxs=strcmp(entry.FileName,htable.FileName);
                if any(idxs)
                    idxs=find(idxs);
                    idx=idxs(1);
                end
            else
                htable=cell2table(matlabshared.opcount.internal.subtable.new_line(entry,hierarchy,hidx),...
                'VariableNames',[entry.Properties.VariableNames,{'SubTable'}]);
                idx=1;
            end

            if~idx
                htable=[htable;matlabshared.opcount.internal.subtable.new_line(entry,hierarchy,hidx)];
                idx=size(htable,1);
            end
            [htable.SubTable{idx},cnt]=matlabshared.opcount.internal.subtable.sort_selector(htable.SubTable{idx},entry,hierarchy,hidx+1);
            htable.Count(idx)=htable.Count(idx)+cnt;
        end

        function[htable,cnt]=insert_path(htable,entry,hierarchy,hidx)

            idx=0;
            if~isempty(htable)
                idxs=strcmp(entry.Path,htable.Path);
                if any(idxs)
                    idxs=find(idxs);
                    idx=idxs(1);
                end
            else
                htable=cell2table(matlabshared.opcount.internal.subtable.new_line(entry,hierarchy,hidx),...
                'VariableNames',[entry.Properties.VariableNames,{'SubTable'}]);
                idx=1;
            end

            if~idx
                htable=[htable;matlabshared.opcount.internal.subtable.new_line(entry,hierarchy,hidx)];
                idx=size(htable,1);
            end
            [htable.SubTable{idx},cnt]=matlabshared.opcount.internal.subtable.sort_selector(htable.SubTable{idx},entry,hierarchy,hidx+1);
            htable.Count(idx)=htable.Count(idx)+cnt;
        end

        function[htable,cnt]=insert_op(htable,entry,hierarchy,hidx)

            idx=0;
            if~isempty(htable)
                idxs=strcmp(entry.Operator,htable.Operator);
                if any(idxs)
                    idxs=find(idxs);
                    for j=1:numel(idxs)
                        if strcmp(entry.DataType,htable.DataType(idxs(j)))
                            idx=idxs(j);
                            break;
                        end
                    end
                end
            else
                htable=cell2table(matlabshared.opcount.internal.subtable.new_line(entry,hierarchy,hidx+1),...
                'VariableNames',[entry.Properties.VariableNames,{'SubTable'}]);
                idx=1;
            end

            if~idx
                htable=[htable;matlabshared.opcount.internal.subtable.new_line(entry,hierarchy,hidx+1)];
                idx=size(htable,1);
            end
            [htable.SubTable{idx},cnt]=matlabshared.opcount.internal.subtable.sort_selector(htable.SubTable{idx},entry,hierarchy,hidx+2);
            htable.Count(idx)=htable.Count(idx)+cnt;
        end

        function[htable,cnt]=insert_detail(htable,entry,hierarchy,hidx)
            idx=0;
            if~isempty(htable)

            else
                htable=cell2table([entry{1,:},{table}],...
                'VariableNames',[entry.Properties.VariableNames,{'SubTable'}]);
                idx=1;
            end
            if~idx

                htable=[htable;entry{1,:},{table}];
                idx=size(htable,1);
            end
            cnt=htable.Count(idx);
        end
    end
end