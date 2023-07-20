function h=explorer(varargin)





    crtoolName=DAStudio.message('RTW:tfldesigner:CRToolText');
    tflMessage=DAStudio.message('RTW:tfldesigner:ProgressBarText');
    hWaitBar=DAStudio.WaitBar;
    hWaitBar.setWindowTitle(crtoolName);
    hWaitBar.setLabelText(tflMessage);
    if nargin==0
        hWaitBar.setValue(40);
    elseif nargin==1
        hWaitBar.setValue(20);
    else
        DAStudio.error('RTW:tfl:invalidNumOfInput');
    end


    if~isempty(varargin)
        rt=TflDesigner.root(varargin{1});
        hWaitBar.setValue(40);
    else
        rt=TflDesigner.root;
    end






    h=TflDesigner.explorer(rt,'TFLDesigner',0);


    createui(h);

    createtoolbar(h);

    hWaitBar.setValue(60);

    h.listeners=handle.listener(h,'ObjectBeingDestroyed',{@cleanup});

    h.listeners(end+1)=handle.listener(h,'METreeSelectionChanged',{@TflDesigner.cbe_refreshactions});
    h.listeners(end+1)=handle.listener(h,'MEListSelectionChanged',{@TflDesigner.cbe_listchangedactions});
    h.listeners(end+1)=handle.listener(h,'MEPostClosed',{@TflDesigner.cbe_postclose});
    h.listeners(end+1)=handle.listener(h,'MEPostShow',{@TflDesigner.cbe_postshow});

    hWaitBar.setValue(80);

    h.getRoot.currenttreenode=rt;
    h.setListMultiSelect(1);
    h.customactions=struct;

    hWaitBar.setValue(90);
    if~isempty(varargin)&&ischar(varargin{1})
        TflDesigner.cba_import(varargin{1});
    end
    hWaitBar.setValue(100);

    h.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));
    h.show;


