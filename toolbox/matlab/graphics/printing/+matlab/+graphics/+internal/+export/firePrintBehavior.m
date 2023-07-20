function firePrintBehavior(pj,callbackName)



    if isstruct(pj)
        h=pj.Handles{1};
    else
        h=pj.ParentFig;
    end
    allobj=findall(h,'Type','figure',...
    '-or','Type','axes',...
    '-or','Type','polaraxes',...
    '-or','Type','geoaxes',...
    '-or','Type','mapaxes',...
    '-or','Type','bigimageshow',...
    '-or','Type','legend',...
    '-or','-isa','matlab.graphics.shape.internal.ScribeGrid',...
    '-or','-isa','matlab.graphics.chart.Chart',...
    '-or','-isa','matlab.graphics.shape.internal.PointDataTip');
    axesToolbars=findobjinternal(h,'-isa','matlab.graphics.controls.AxesToolbar');
    dataTipHoverMarker=findobjinternal(h,'-isa','matlab.graphics.primitive.world.CompositeMarker',...
    '-and','Description','DataTipHoverMarker');
    allobj=[allobj(:);axesToolbars(:);dataTipHoverMarker(:)];
    for k=1:length(allobj)
        currObj=allobj(k);
        if ishandle(currObj)
            behavior=hggetbehavior(currObj,'Print','-peek');
            if~isempty(behavior)&&isprop(behavior,callbackName)&&...
                ~isempty(get(behavior,callbackName))


                pci.DriverClass=pj.DriverClass;
                setappdata(currObj,'PrintCallbackInfo',pci);
                c=onCleanup(@()rmappdata(currObj,'PrintCallbackInfo'));

                cb=get(behavior,callbackName);
                if isa(cb,'function_handle')
                    cb(handle(currObj),callbackName);
                elseif iscell(cb)
                    if length(cb)>1
                        feval(cb{1},handle(currObj),callbackName,cb{2:end});
                    else
                        feval(cb{1},handle(currObj),callbackName);
                    end
                else
                    feval(cb,handle(currObj),callbackName);
                end
            end
        end
    end

end
