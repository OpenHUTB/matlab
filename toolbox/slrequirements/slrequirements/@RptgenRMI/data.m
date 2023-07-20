function result=data(args)




    persistent data subviewers;
    if isempty(data)
        data={};
    end

    if nargin>0
        args=convertStringsToChars(args);
    end

    result=[];

    if iscell(args)
        data(end+1,:)=args;
    elseif ischar(args)
        switch args
        case 'reset'
            data={};
        case 'get'
            result=data;
        case 'system'

            slData=rptgen_sl.appdata_sl;
            data{end+1,1}=slData.CurrentSystem;
        case 'block'

            slData=rptgen_sl.appdata_sl;
            [data{end+1,:}]=deal(...
            strrep(get_param(slData.CurrentBlock,'Name'),char(10),' '),...
            get_param(slData.CurrentBlock,'BlockType'));
        case 'sf_no_reqs'

            sfData=rptgen_sf.appdata_sf;
            tableData=appendSfObjects(sfData.CurrentObject,false);
            if isempty(tableData)
                result=false;
            else
                data=[data;tableData];
                result=true;
            end
        case 'subviewers'
            result=subviewers;
        case 'exists'
            sfData=rptgen_sf.appdata_sf;
            sfCurrent=get(sfData.CurrentObject,'ID');
            result=any(subviewers==sfCurrent);
        otherwise
            data(end+1,:)={args};
        end
    else
        sfId=args;
        if args==0
            subviewers=[];
        elseif~any(subviewers==sfId)
            subviewers(end+1)=sfId;
        end
    end
end

function sfobjects=appendSfObjects(chartObj,should_have_reqs)


    sfFilter=rmisf.sfisa('isaFilter');
    allSfObjs=chartObj.find(sfFilter(3:end));
    sfobjects=cell(0,2);

    for obj=allSfObjs(:)'

        if isa(obj,'Stateflow.AtomicSubchart')
            sfobjects=[sfobjects;appendSfObjects(obj.Subchart,should_have_reqs)];%#ok<AGROW>
        elseif rmisf.has_req(obj,false)==should_have_reqs
            sfobjects=[sfobjects;appendOne(obj)];%#ok<AGROW>
        end
    end

    function oneObj=appendOne(obj)
        type=class(obj);
        type=strrep(type,'Stateflow.','');
        oneObj={rmi.objname(obj),type};
    end
end
