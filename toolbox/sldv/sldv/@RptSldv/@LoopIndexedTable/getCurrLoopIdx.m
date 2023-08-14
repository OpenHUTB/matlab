function[idx,descr]=getCurrLoopIdx(h)



    [idx,descr]=getIdx(h);

    function[idx,descr]=getIdx(h)
        idx=[];
        descr=[];
        while(~isempty(h.up)&&isempty(idx))
            h=h.up;
            if~isempty(find(get(classhandle(h),'properties'),'Name','RuntimeLoopObjects'))
                co=h.RuntimeCurrentObject;
                if~isempty(co)&&~ishandle(co)&&isstruct(co)&&isfield(co,'idx')
                    idx=h.RuntimeCurrentObject.idx;
                    if ischar(idx)
                        descr=['.',idx];
                    else
                        descr=['(',num2str(idx),')'];
                    end
                else
                    objs=h.RuntimeLoopObjects;
                    subsrefType='';
                    if ischar(objs)
                        h={h};%#ok-mlint
                        subsrefType='{}';
                    elseif iscell(objs)
                        subsrefType='{}';
                    else
                        subsrefType='()';
                    end

                    for i=1:size(objs,1)
                        to=subsref(objs,substruct(subsrefType,{i,':'}));
                        if isequal(to,co)
                            idx=i;
                            break;
                        end
                    end
                end
            end
        end


