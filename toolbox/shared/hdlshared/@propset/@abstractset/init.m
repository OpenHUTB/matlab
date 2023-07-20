function h=init(h,names,props)











    if~iscell(names)||isempty(names)||~isvector(names)

        error(message('HDLShared:propset:notCellarray'));
    end
    N=numel(names);
    if numel(unique(names))~=N
        error(message('HDLShared:propset:notUnique'));
    end



    if nargin<3
        props=repmat({handle([])},1,N);

    else
        if~iscell(props)

            error(message('HDLShared:propset:notCellarrayHandle'));
        end
        if numel(props)~=N

            error(message('HDLShared:propset:numberNotMatch',numel(props),N));
        end
    end




    ena=true(1,N);




    h.prop_set_names=names;
    h.prop_sets=props;
    h.prop_set_enables=ena;


