function crtool(varargin)





    unused=RTW.Argument;%#ok<NASGU> 


    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    daRoot=DAStudio.Root;
    me=daRoot.find('-isa','TflDesigner.explorer');

    for i=1:length(me)
        if~me(i).isVisible
            delete(me(i));
            me(i)=[];
        end
    end

    mlock;
    try
        if isempty(me)
            if~isempty(varargin)
                td=TflDesigner.explorer(varargin{1});
            else
                td=TflDesigner.explorer;
            end
        else
            td=TflDesigner.getexplorer;
            if~isempty(varargin)
                me.setStatusMessage(...
                DAStudio.message('RTW:tfldesigner:ImportInProgressStatusMsg'));
                rt=me.getRoot;
                if~ischar(varargin{1})
                    rt.populate(varargin{1});
                else
                    name=varargin{1};
                    TflDesigner.cba_import(name);
                end
                me.setStatusMessage(...
                DAStudio.message('RTW:tfldesigner:ReadyStatus'));
            end
        end
        td.show;
    catch ME
        throwAsCaller(ME);
    end
