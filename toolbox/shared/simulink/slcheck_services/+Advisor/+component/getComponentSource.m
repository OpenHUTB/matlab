function[obj,context]=getComponentSource(component)
















    context=[];
    src_internal=Advisor.component.internal.getComponentSource(component);

    if isnumeric(src_internal)
        if isa(src_internal,'int32')
            obj=find(sfroot,'Id',src_internal);
        else

            obj=get_param(src_internal,'Object');
        end
    elseif iscell(src_internal)

        context=find(sfroot,'-isa','Stateflow.LinkChart',...
        '-and','Path',getfullname(src_internal{1}));%#ok<GTARG>
        obj=find(sfroot,'Id',src_internal{2});
    else

        obj=[];
    end
end

