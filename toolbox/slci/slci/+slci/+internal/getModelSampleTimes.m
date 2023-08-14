


function s=getModelSampleTimes(mdlH)

    s={};
    times=Simulink.BlockDiagram.getSampleTimes(mdlH);
    for i=1:numel(times)
        if strcmpi(times(i).Annotation(1),'M')

        elseif strcmpi(times(i).Annotation(1),'T')||...
            ~isempty(strfind(times(i).Annotation(1),'A'))

        elseif strcmpi(times(i).Annotation,'DD')

        elseif(~isempty(strfind(times(i).Annotation(1),'D'))&&...
            isfinite(times(i).Value(1)))
            s{end+1}=times(i).Value;%#ok
        elseif~isempty(strfind(times(i).Annotation(1),'V'))

        elseif~isempty(strfind(times(i).Annotation,'Cont'))
            s{end+1}=times(i).Value;%#ok
        elseif~isempty(strfind(times(i).Annotation(1),'F'))

        elseif strcmpi(times(i).Annotation(1),'P')

        elseif~isempty(strfind(times(i).Annotation(1),'U'))

        elseif~isempty(strfind(times(i).Annotation,'Prm'))||...
            strcmpi(times(i).Annotation,'Inf')
            s{end+1}=times(i).Value;%#ok
        else

        end
    end
end
