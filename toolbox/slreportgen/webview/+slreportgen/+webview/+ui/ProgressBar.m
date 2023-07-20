classdef(Hidden)ProgressBar<slreportgen.webview.ProgressMonitor















































    properties

        ShowMessagePriority=slreportgen.webview.ProgressMonitor.ImportantMessagePriority;
    end

    properties(SetAccess=private)

        Title='';


        Visible=false;
    end

    properties(Access=private)

        WaitBar=[];


        CancelMsgBox=[];
        CancelTextWidget=[];
        CancelTitleWidget=[];


        AlreadyCanceled=false;


WaitBarCancelCacheValue
WaitBarMinCacheValue
WaitBarMaxCacheValue
WaitBarLabelCacheValue
WaitBarPercentCacheValue


LastCheckedForCancelInWaitBar
    end

    properties(Constant,Access=private)

        CheckCancelInterval=0.5;


        WaitBarIcon=fullfile(slreportgen.webview.IconsDir,'SimulinkRoot.png');
    end

    methods
        function this=ProgressBar(varargin)
            this=this@slreportgen.webview.ProgressMonitor(varargin{:});
        end

        function setTitle(this,title)



            this.Title=title;
            this.update();
        end

        function cancel(this)



            if~this.AlreadyCanceled
                this.AlreadyCanceled=true;
                if this.Visible
                    this.WaitBar.hide();
                    this.createCancelMsgBox();
                    this.setMessage(...
                    message('slreportgen_webview:exporter:Canceling').getString(),...
                    this.ImportantMessagePriority);
                end
                this.cancel@slreportgen.webview.ProgressMonitor();
            end
        end

        function tf=isCanceled(this)



            tf=this.AlreadyCanceled||this.isWaitBarCanceled();
        end

        function done(this)



            this.hide();
            this.done@slreportgen.webview.ProgressMonitor();
        end

        function show(this)


            if~this.Visible
                if this.isCanceled()
                    if isempty(this.CancelMsgBox)
                        this.createCancelMsgBox();
                    end
                    this.CancelMsgBox.Visible=false;
                else
                    if isempty(this.WaitBar)
                        this.createWaitBar();
                    end
                    this.WaitBar.show();
                end
                this.Visible=true;
            end
            this.update();
        end

        function hide(this)


            if this.Visible
                if~isempty(this.WaitBar)
                    this.WaitBar.hide();
                end
                if~isempty(this.CancelMsgBox)
                    this.CancelMsgBox.Visible=false;
                end
                this.Visible=false;
            end
            this.update();
        end

        function delete(this)

            delete(this.CancelMsgBox)
        end
    end

    methods(Access=protected)
        function update(this)
            if this.isCanceled()
                if~this.AlreadyCanceled
                    this.cancel();
                end
                this.updateCancelWidget();
            else
                this.updateWaitBar();
            end
            this.update@slreportgen.webview.ProgressMonitor();
        end
    end

    methods(Access=private)
        function createWaitBar(this)
            this.WaitBar=DAStudio.WaitBar;
            waitbar=this.WaitBar;
            waitbar.setWindowIcon(this.WaitBarIcon);
            if~isempty(this.Title)
                title=this.Title;
            else
                title=' ';
            end
            waitbar.setWindowTitle(title);
            this.LastCheckedForCancelInWaitBar=tic();


        end

        function createCancelMsgBox(this)

            emptyText='[                                                            ]';
            this.CancelMsgBox=msgbox(emptyText,this.Title);
            this.CancelTextWidget=findobj(this.CancelMsgBox,'Tag','MessageBox');
        end

        function tf=isWaitBarCanceled(this)



            if~isempty(this.WaitBar)
                if isempty(this.WaitBarCancelCacheValue)...
                    ||(toc(this.LastCheckedForCancelInWaitBar)>this.CheckCancelInterval)
                    tf=this.WaitBar.wasCanceled();
                    this.LastCheckedForCancelInWaitBar=tic();
                    this.WaitBarCancelCacheValue=tf;
                end
                tf=this.WaitBarCancelCacheValue;
            else
                tf=false;
            end
        end

        function updateWaitBar(this)
            if~isempty(this.WaitBar)&&this.Visible

                minValue=0;
                maxValue=0;
                value=0;

                percent=this.getPercent();
                if((percent>=0)&&(percent<=1))

                    minValue=0;
                    maxValue=100;
                    value=percent*100;
                end


                this.setWaitBarMinValue(minValue);
                this.setWaitBarMaxValue(maxValue);
                this.setWaitBarPercentValue(round(value));


                if(this.ShowMessagePriority>=this.MessagePriority)
                    this.setWaitBarLabel(this.Message);
                end
            end
        end

        function setWaitBarMinValue(this,minValue)

            if isempty(this.WaitBarMinCacheValue)||(this.WaitBarMinCacheValue~=minValue)
                this.WaitBar.setMinimum(minValue);
                this.WaitBarMinCacheValue=minValue;
            end
        end

        function setWaitBarMaxValue(this,maxValue)

            if isempty(this.WaitBarMaxCacheValue)||(this.WaitBarMaxCacheValue~=maxValue)
                this.WaitBar.setMaximum(maxValue);
                this.WaitBarMaxCacheValue=maxValue;
            end
        end

        function setWaitBarPercentValue(this,percentValue)

            if isempty(this.WaitBarPercentCacheValue)||(this.WaitBarPercentCacheValue~=percentValue)
                this.WaitBar.setValue(percentValue);
                this.WaitBarPercentCacheValue=percentValue;
            end
        end

        function setWaitBarLabel(this,label)

            if isempty(this.WaitBarLabelCacheValue)||strcmp(this.WaitBarLabelCacheValue,label)
                this.WaitBar.setLabelText(label);
                this.WaitBarLabelCacheValue=label;
            end
        end

        function updateCancelWidget(this)
            if~isempty(this.CancelMsgBox)&&this.Visible
                needToDrawNow=false;

                if(this.ShowMessagePriority>=this.MessagePriority)
                    set(this.CancelTextWidget,'String',this.Message);
                    needToDrawNow=true;
                end

                if~strcmp(this.CancelMsgBox.Name,this.Title)
                    this.CancelMsgBox.Name=this.Title;
                    needToDrawNow=true;
                end

                if needToDrawNow
                    drawnow();
                end
            end
        end
    end
end

