function[table,container]=uitable_deprecated(varargin)






    warn=warning('query','MATLAB:uitable:DeprecatedFunction');
    if isequal(warn.state,'on')
        warning(message('MATLAB:uitable:DeprecatedFunction'));
    end




    error(javachk('awt'));
    nargoutchk(0,2);

    parent=[];
    numargs=nargin;


    datastatus=false;columnstatus=false;
    rownum=1;colnum=1;
    position=[20,20,200,200];
    combo_box_found=false;
    check_box_found=false;

    if(numargs>0&&isscalar(varargin{1})&&...
        ishghandle(varargin{1},'figure'))
        parent=varargin{1};
        varargin=varargin(2:end);
        numargs=numargs-1;
    end

    if(numargs>0&&isscalar(varargin{1})&&ishandle(varargin{1}))
        if~isa(varargin{1},'javax.swing.table.DefaultTableModel')
            error('MATLAB:uitable:UnrecognizedParameter',['Unrecognized parameter: ',varargin{1}]);
        end
        data_model=varargin{1};
        varargin=varargin(2:end);
        numargs=numargs-1;

    elseif((numargs>1)&&isscalar(varargin{1})&&isscalar(varargin{2}))
        if(isnumeric(varargin{1})&&isnumeric(varargin{2}))
            rownum=varargin{1};
            colnum=varargin{2};

            varargin=varargin(3:end);
            numargs=numargs-2;
        else
            error(message('MATLAB:uitable:InputMustBeScalar'))
        end

    elseif((numargs>1)&&isequal(size(varargin{2},1),1)&&iscell(varargin{2}))
        if(size(varargin{1},2)==size(varargin{2},2))
            if(isnumeric(varargin{1}))
                varargin{1}=num2cell(varargin{1});
            end
        else
            error(message('MATLAB:uitable:MustMatchInfo'));
        end
        data=varargin{1};datastatus=true;
        coln=varargin{1+1};columnstatus=true;

        varargin=varargin(3:end);
        numargs=numargs-2;
    end

    for i=1:2:numargs-1
        if(~(ischar(varargin{i})||isstring(varargin{i})))
            error('MATLAB:uitable:UnrecognizedParameter',['Unrecognized parameter: ',varargin{i}]);
        end
        switch lower(varargin{i})
        case 'data'
            if(isnumeric(varargin{i+1}))
                varargin{i+1}=num2cell(varargin{i+1});
            end
            data=varargin{i+1};
            datastatus=true;

        case 'columnnames'
            if(iscell(varargin{i+1}))
                coln=varargin{i+1};
                columnstatus=true;
            else
                error(message('MATLAB:uitable:InvalidCellArray'))
            end

        case 'numrows'
            if(isnumeric(varargin{i+1}))
                rownum=varargin{i+1};
            else
                error(message('MATLAB:uitable:NumrowsMustBeScalar'))
            end

        case 'numcolumns'
            if(isnumeric(varargin{i+1}))
                colnum=varargin{i+1};
            else
                error(message('MATLAB:uitable:NumcolumnsMustBeScalar'))
            end

        case 'gridcolor'
            if(ischar(varargin{i+1}))
                gridcolor=varargin{i+1};
            elseif(isnumeric(varargin{i+1})&&(numel(varargin{i+1})==3))
                gridcolor=varargin{i+1};
            else
                error(message('MATLAB:uitable:InvalidString'))
            end

        case 'rowheight'
            if(isnumeric(varargin{i+1}))
                rowheight=varargin{i+1};
            else
                error(message('MATLAB:uitable:RowheightMustBeScalar'))
            end

        case 'parent'
            if ishandle(varargin{i+1})
                parent=varargin{i+1};
            else
                error(message('MATLAB:uitable:InvalidParent'))
            end

        case 'position'
            if(isnumeric(varargin{i+1}))
                position=varargin{i+1};
            else
                error(message('MATLAB:uitable:InvalidPosition'))
            end

        case 'columnwidth'
            if(isnumeric(varargin{i+1}))
                columnwidth=varargin{i+1};
            else
                error(message('MATLAB:uitable:ColumnwidthMustBeScalar'))
            end
        otherwise
            error('MATLAB:uitable:UnrecognizedParameter',['Unrecognized parameter: ',varargin{i}]);
        end
    end


    if(datastatus)
        if(iscell(data))
            rownum=size(data,1);
            colnum=size(data,2);
            combo_count=0;
            check_count=0;
            combo_box_data=num2cell(zeros(1,colnum));
            combo_box_column=zeros(1,colnum);
            check_box_column=zeros(1,colnum);
            for j=1:rownum
                for k=1:colnum
                    if(iscell(data{j,k}))
                        combo_box_found=true;
                        combo_count=combo_count+1;
                        combo_box_data{combo_count}=data{j,k};
                        combo_box_column(combo_count)=k;
                        dc=data{j,k};
                        data{j,k}=dc{1};
                    else
                        if(islogical(data{j,k}))
                            check_box_found=true;
                            check_count=check_count+1;
                            check_box_column(check_count)=k;
                        end
                    end
                end
            end
        end
    end



    if isempty(parent)
        parent=gcf;
    end

    if(columnstatus&&datastatus)
        if(size(data,2)~=size(coln,2))
            error(message('MATLAB:uitable:NeedSameNumberColumns'));
        end
    elseif(~columnstatus&&datastatus)
        for i=1:size(data,2)
            coln{i}=num2str(i);
        end
        columnstatus=true;
    elseif(columnstatus&&~datastatus)
        error(message('MATLAB:uitable:NoDataProvided'));
    end

    if(~exist('data_model','var'))
        data_model=javax.swing.table.DefaultTableModel;
    end
    if exist('rownum','var')
        data_model.setRowCount(rownum);
    end
    if exist('colnum','var')
        data_model.setColumnCount(colnum);
    end

    table_h=com.mathworks.hg.peer.UitablePeer(data_model);


    if(datastatus),table_h.setData(data);end
    if(columnstatus),table_h.setColumnNames(coln);end

    if(combo_box_found)
        for i=1:combo_count
            table_h.setComboBoxEditor(combo_box_data(i),combo_box_column(i));
        end
    end
    if(check_box_found)
        for i=1:check_count
            table_h.setCheckBoxEditor(check_box_column(i));
        end
    end

    [table,container]=javacomponentfigurechild_helper(table_h,position,parent);



    flushed=false;
    if exist('gridcolor','var')
        pause(.1);drawnow;
        flushed=true;
        table_h.setGridColor(gridcolor);
    end
    if exist('rowheight','var')
        if(~flushed)
            drawnow;
        end
        table_h.setRowHeight(rowheight);
    end
    if exist('columnwidth','var')
        table_h.setColumnWidth(columnwidth);
    end


    temp=handle.listener(table,'ObjectBeingDestroyed',@componentDelete);
    save__listener__(table,temp);

    function componentDelete(src,evd)%#ok

        src.cleanup;


        delete(handle(src.getFigureComponent()));
