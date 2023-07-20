function func=createCustomStringStrategy()







    func=@nCustomUpdateString;



    strCache=struct('Valid',false,...
    'Target',matlab.graphics.internal.WeakReference(),...
    'String','',...
    'CursorUpdated',event.listener.empty);

    function nCustomUpdateString(hObj,hCursor,hTipHandle)








        hEventObj=matlab.graphics.internal.DataTipEvent;
        hEventObj.Target=hCursor.DataSource.getAnnotationTarget();



        pos=hCursor.getReportedPosition();




        if isa(hTipHandle,'matlab.graphics.shape.internal.PanelTip')
            hEventObj.Interpreter='none';
        else
            hEventObj.Interpreter=hObj.Interpreter;
        end

        hEventObj.Position=pos.getLocation(hEventObj.Target);
        hEventObj.DataIndex=hCursor.DataIndex;
        hEventObj.InterpolationFactor=hCursor.InterpolationFactor;


        DelayedUpdateListener=addlistener(hObj,'MarkedClean',@(s,e)nDelayedUpdateCustomString(s,hEventObj));

        function nDelayedUpdateCustomString(hObj,hEventObj)

            delete(DelayedUpdateListener);

            if isvalid(hObj)



                hCursor=hObj.Cursor;
                if~isCacheValid(strCache,hEventObj)

                    try
                        str=localGetCustomString(hObj,hEventObj);
                    catch E
                        str=getString(message('MATLAB:graphics:datatip:ErrorInCustomFunction'));
                    end
                    strCache.Interpreter=hEventObj.Interpreter;
                    strCache.Value=strtrim(str);
                    strCache.Target.reset(hEventObj.Target);
                    strCache.Valid=true;
                    strCache.CursorUpdated=event.listener(hCursor,'CursorUpdated',@(s,e)makeCacheInvalid());
                end




                if isvalid(hTipHandle)
                    hTipHandle.String=strCache.Value;
                end
            end
        end
    end



    function makeCacheInvalid()
        strCache.Valid=false;
    end
end

function ret=isCacheValid(strCache,hEventObj)

    cacheTarget=strCache.Target.get();
    ret=strCache.Valid&&...
    ~isempty(cacheTarget)&&...
    hEventObj.Target==cacheTarget&&...
    isequal(strCache.Interpreter,hEventObj.Interpreter);
end


function str=localGetCustomString(hTip,hEventObj)


    str=hgfeval(hTip.UpdateFcn,hTip,hEventObj);


    if~(isstring(str)||ischar(str)||iscellstr(str))


        if isnumeric(str)
            str={str};
        end

        if iscell(str)
            for i=1:numel(str)
                if isnumeric(str{i})
                    str{i}=num2str(str{i});
                end
            end
        end

        if~(iscell(str)&&all(cellfun(@(s)ischar(s)||isstring(s),str)))
            str=getString(message('MATLAB:graphics:datatip:ErrorInCustomFunction'));
        end
    end
end