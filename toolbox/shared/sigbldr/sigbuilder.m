function varargout=sigbuilder(method,varargin)









































    extra_args={};
    switch(nargin)
    case 0
        DAStudio.message('Sigbldr:sigbldr:CopyFromLibrary');
    case 1

        if any(method=='.')
            fileName=method;
            method='open_existing_file';
            dialog=[];
            UD=[];
        else
            dialog=gcbf;
            UD=get(dialog,'UserData');
        end
    case 2
        dialog=varargin{1};
        UD=get(dialog,'UserData');
    otherwise
        dialog=varargin{1};
        UD=varargin{2};
        extra_args=varargin(3:end);
    end



    method_tab={'tuVar',@()sigBuilderTuVar();...
    'cmdApi',@()sigBuilderCmdApi(varargin{1},nargout,varargin{2:end});...
    'assertApi',@()sigBuilderAssertApi(dialog,UD,nargout,varargin{3:end});...
    'SlBlockOpen',@()sigBuilderBlockOpen();...
    'close',@()sigBuilderClose();...
    'DSChange',@()sigBuilderDSChange();...
    'ButtonDown',@()sigBuilderMouseHandler();...
    'ButtonUp',@()sigBuilderMouseHandler();...
    'ButtonMotion',@()sigBuilderMouseHandler();...
    'KeyPress',@()sigBuilderMouseHandler();...
    'chContext',@()sigBuilderChannelContext();...
    'chanUi',@()sigBuilderChannelUi();...
    'tdisprange',@()sigBuilderSetRange();...
    'setYrange',@()sigBuilderSetRange();...
    'Resize',@()sigBuilderResize();...
    'Scrollbar',@()sigBuilderScrollBar();...
    'PrntMenu',@()printCmd([],dialog,[],extra_args{:});...
    'print',@()printCmd(varargin{1},get_param(varargin{1},'UserData'),varargin{3:end});...
    'ChanListbox',@()sigBuilderListbox();...
    'addConstantSignal',@()addConstantSignal(dialog,extra_args{1});...
    'addStepSignal',@()addStepSignal(dialog,extra_args{1});...
    'addPulseSignal',@()addPulseSignal(dialog,extra_args{1});...
    'addSquareSignal',@()sigBuilderAddSquareSignal();...
    'addTriangleSignal',@()sigBuilderAddTriangleSignal();...
    'addSampledSineSignal',@()sigBuilderAddSampledSineSignal();...
    'addGaussianNoiseSignal',@()sigBuilderAddGaussianNoiseSignal();...
    'addBinaryNoiseSignal',@()sigBuilderAddBinaryNoiseSignal();...
    'addPoissonNoiseSignal',@()sigBuilderAddPoissonNoiseSignal();...
    'addCustomSignal',@()sigBuilderAddCustomSignal();...
    'solid',@()sigBuilderLineStyle();...
    'dashed',@()sigBuilderLineStyle();...
    'dotted',@()sigBuilderLineStyle();...
    'dash-dott',@()sigBuilderLineStyle();...
    'chanLineWidth',@()sigBuilderLineWidth();...
    'setTrange',@()sigBuilderSetTRange();...
    'chanIndex',@()sigBuilderSignalIndex();...
    'delete',@()sigBuilderSignalDelete();...
    'copy',@()sigBuilderSignalCopy();...
    'cut',@()sigBuilderSignalCut();...
    'paste',@()sigBuilderSignalPaste();...
    'start',@()sigBuilderStart();...
    'stop',@()sigBuilderStop();...
    'pause',@()sigBuilderPause();...
    'up',@()sigBuilderUp();...
    'snapGrid',@()sigBuilderSnapGrid();...
    'zoomX',@()sigBuilderZoomXY(9);...
    'zoomY',@()sigBuilderZoomXY(10);...
    'zoomXY',@()sigBuilderZoomXY(11);...
    'fullview',@()fullView(dialog,UD);...
    'verifyView',@()sigBuilderVerifyView();...
    'playAll',@()playAll(dialog);...
    'undo',@()sigBuilderUndoRedo();...
    'redo',@()sigBuilderUndoRedo();...
    'open',@()sigBuilderOpen();...
    'import_file',@()sigBuilderImportFile(dialog,'open');...
    'saveas',@()sigBuilderSaveAs();...
    'save',@()sigBuilderSave();...
    'export_ws',@()sigBuilderExportWS();...
    'export_mat',@()exportMatFileUI(UD);...
    'simOpts',@()sigBuilderSimOpts();...
    'dataSetCopy',@()sigBuilderDataSetCopy();...
    'dataSetDelete',@()sigBuilderDataSetDelete();...
    'dataSetRename',@()sigBuilderDataSetRename();...
    'dataSetRight',@()sigBuilderDataSetMove('right');...
    'dataSetLeft',@()sigBuilderDataSetMove('left');...
    'showTab',@()sigBuilderShowGroup();...
    'show',@()sigBuilderShowSignal();...
    'outputPorts',@()sigBuilderoutputPorts();...
    'outputFlatBus',@()sigBuilderoutputFlatBus();...
    'convert2SE',@()convertToSignalEditor(gcb);};



    k=strmatch(method,method_tab(:,1),'exact');%#ok<MATCH3>

    if isempty(k)
        DAStudio.message('Sigbldr:sigbldr:UnknownMethod');
    else
        if nargout>0
            varargout=cell(1,nargout);
            [varargout{:}]=method_tab{k,2}();
        else
            method_tab{k,2}();
        end
    end





    function varargout=sigBuilderTuVar()



        blockH=dialog;
        dialogH=get_param(blockH,'UserData');
        if~isempty(dialogH)&&ishghandle(dialogH,'figure')
            UD=get(dialogH,'UserData');
            UD=mouse_handler('ForceMode',UD.dialog,UD,1);
            ActiveGroup=UD.sbobj.ActiveGroup;
            if isempty(ActiveGroup)
                ActiveGroup=UD.dataSetIdx;
                UD.sbobj.ActiveGroup=UD.dataSetIdx;
            end
            signalCnt=length(UD.channels);
            [X,Y]=match_end_points(UD,ActiveGroup);
            varargout{1}=create_sl_input_variable(X,Y,signalCnt);
        else
            varargout{1}=init_tu_var(blockH);
        end
    end

    function sigBuilderCmdApi(subMethod,varargin)



        switch(subMethod)
        case 'requiopen'
            blockH=varargin{2};
            value=varargin{3};
            blockUD=get_param(blockH,'UserData');


            if isempty(blockUD)||~ishandle(blockUD)
                return;
            end
            UD=get(blockUD,'UserData');
            UD.common.reqUIOpen=value;
            set(UD.dialog,'UserData',UD)
        otherwise
            DAStudio.message('Sigbldr:sigbldr:UnknownMethod');
        end

    end

    function varargout=sigBuilderAssertApi(blockH,subMethod,argout,varargin)

        varargout=cell(1,argout);
        [varargout{:}]=assert_api(subMethod,blockH,varargin);
    end

    function varargout=sigBuilderBlockOpen()




        handleStruct=dialog;

        dialog=create(1);

        UD=get(dialog,'UserData');



        UD=load_session(UD,handleStruct.subsysH);
        UD.simulink=handleStruct;
        update_titleStr(UD);
        if(~isfield(UD,'axes'))
            UD.axes=[];
        end

        set(dialog,'UserData',UD);
        enable_mouse_callback(dialog);
        varargout{1}=dialog;

        if is_simulating_l(UD)
            enter_iced_state_l(UD);
        end

        if get_param(UD.simulink.modelH,'InteractiveSimInterfaceExecutionStatus')==2

            UD=enter_iced_state_fastRestart(UD);
        end
    end

    function sigBuilderClose()
        if isempty(UD)
            UD=get(dialog,'UserData');
        end
        close_internal(UD);
    end


    function sigBuilderDSChange()
        if isempty(UD)
            UD=get(dialog,'UserData');
        end
        UD=dataSet_activate(UD,extra_args{:});
        set(dialog,'UserData',UD);
    end

    function sigBuilderMouseHandler()
        [UD,modified]=mouse_handler(method,dialog,UD,extra_args{:});
        if modified
            set(dialog,'UserData',UD);
        end
    end







    function sigBuilderChannelContext()
        if isempty(UD)
            UD=get(dialog,'UserData');
        end
        [UD,modified]=channel_handler(extra_args{1},dialog,UD,extra_args{2:end});
        if modified
            set(dialog,'UserData',UD);
        end
    end





    function sigBuilderChannelUi()
        if isempty(UD)
            UD=get(dialog,'UserData');
        end
        if~in_iced_state_l(UD)
            [UD,modified]=channel_ui_handler(extra_args{1},UD,extra_args{2:end});
            if modified
                set(dialog,'UserData',UD);
            end
        end
    end





    function sigBuilderSetRange()

        axesUD=get(UD.current.axes,'UserData');
        if isempty(axesUD)
            return;
        end
        axesInd=axesUD.index;
        switch(method)
        case 'tdisprange'
            title=getString(message('Sigbldr:sigbldr:SetTRange'));
            strtVals={num2str(UD.common.dispTime(1)),num2str(UD.common.dispTime(2))};
            dlgTag='SetTDispRangeforAxesDlg';
        case 'setYrange'
            yLims=get(UD.axes(axesInd).handle,'YLim');
            dispNum=UD.numAxes+1-axesInd;
            title=getString(message('Sigbldr:sigbldr:SetYRange',dispNum));
            strtVals={num2str(yLims(1)),num2str(yLims(2))};
            dlgTag='SetYRangeforAxesDlg';
        end

        labels={getString(message('Sigbldr:sigbldr:MinimumColon')),getString(message('Sigbldr:sigbldr:MaximumColon'))};
        vals=sigbuilder_modal_edit_dialog(dlgTag,...
        title,labels,strtVals);

        if~iscell(vals)
            return;
        end

        minVal=eval_to_real_scalar(vals{1},...
        ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:MinimumColon'))),'"']);
        maxVal=eval_to_real_scalar(vals{2},...
        ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:MaximumColon'))),'"']);

        if isempty(minVal)||isempty(maxVal)
            return;
        end

        if maxVal<=minVal
            errordlg(getString(message('Sigbldr:sigbldr:MinLessThanMax')));
            return;
        end

        newValues=[minVal,maxVal];

        switch(method)
        case 'tdisprange'
            UD=set_new_time_range(UD,newValues,0);
        case 'setYrange'
            set(UD.axes(axesInd).handle,'YLim',newValues);
            UD.axes(axesInd).yLim=newValues;
            update_axes_label(UD.axes(axesInd));
        end
        UD=set_dirty_flag(UD);
        set(dialog,'UserData',UD);
    end

    function sigBuilderResize()
        if isempty(UD)
            UD=get(dialog,'UserData');
        end
        UD=resize(UD);
        set(dialog,'UserData',UD);
    end

    function sigBuilderScrollBar()
        if isempty(UD)
            UD=get(dialog,'UserData');
        end

        startTime=get(UD.tlegend.scrollbar,'Value');
        trange=UD.common.dispTime+(startTime-UD.common.dispTime(1));




        if trange(2)>UD.common.maxTime
            trange(2)=UD.common.maxTime;
        end

        if trange(1)<UD.common.minTime
            trange(1)=UD.common.minTime;
        end

        UD=set_new_time_range(UD,trange,1);
        set(dialog,'UserData',UD);
    end

    function sigBuilderListbox()
        if isempty(UD)
            UD=get(dialog,'UserData');
        end
        UD=chan_listbox_mgr(UD);
        UD=set_dirty_flag(UD);
        set(dialog,'UserData',UD);
    end

    function sigBuilderAddSquareSignal()


        UD=get(dialog,'UserData');
        title=getString(message('Sigbldr:sigbldr:SquareWave'));
        labels={getString(message('Sigbldr:sigbldr:FrequencyHz')),getString(message('Sigbldr:sigbldr:AmplitudeColon')),...
        getString(message('Sigbldr:sigbldr:OffsetColon')),getString(message('Sigbldr:sigbldr:DutyCycleColon'))};
        startVals={'1.0','1.0','1.0','50.0'};
        vals=sigbuilder_modal_edit_dialog('SquareWaveDlg',title,labels,startVals);

        if iscell(vals)
            freq=eval_to_real_scalar(vals{1},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:FrequencyHz'))),'"']);
            amp=eval_to_real_scalar(vals{2},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:AmplitudeColon'))),'"']);
            off=eval_to_real_scalar(vals{3},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:OffsetColon'))),'"']);
            duty=eval_to_real_scalar(vals{4},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:DutyCycleColon'))),'"']);
            if isempty(freq)||isempty(amp)||isempty(off)||isempty(duty)
                return;
            end

            if freq<=0
                errordlg(getString(message('Sigbldr:sigbldr:PositiveFrequency')));
                return;
            end

            if(duty<0||duty>100)
                errordlg(getString(message('Sigbldr:sigbldr:DutyCycleLimit')));
                return;
            end





            xNorm=[0,0,1,1]*(duty/100);
            yNorm=off+[-1,1,1,-1]*amp;




            if(1/freq)>abs(UD.common.maxTime-UD.common.minTime)



                if(UD.common.minTime/(1/freq))<(duty/100)
                    yMinToAdd=off+1*amp;

                    xNorm=[xNorm,UD.common.minTime/(1/freq)];
                    [xNorm,idxSort]=sort(xNorm);

                    yNorm=[yNorm,yMinToAdd];
                    yNorm=yNorm(idxSort);

                elseif(UD.common.minTime/(1/freq))>(duty/100)


                    xNorm=[xNorm,(UD.common.minTime/(1/freq))];
                    yNorm=[yNorm,(off+(-1)*amp)];
                end



                if(UD.common.maxTime/(1/freq))<(duty/100)
                    yMaxToAdd=off+1*amp;

                    xNorm=[xNorm,UD.common.maxTime/(1/freq)];
                    [xNorm,idxSort]=sort(xNorm);

                    yNorm=[yNorm,yMaxToAdd];
                    yNorm=yNorm(idxSort);
                elseif(UD.common.maxTime/(1/freq))>(duty/100)


                    xNorm=[xNorm,(UD.common.maxTime/(1/freq))];
                    yNorm=[yNorm,(off+(-1)*amp)];
                end

            end


            negativexNorm=fliplr(1-xNorm);

            if mod(UD.common.maxTime,1/freq)<duty/(100*freq)
                lastY=off+amp;
            else
                lastY=off-amp;
            end

            if mod(UD.common.minTime,1/freq)<duty/(100*freq)
                firstY=off+amp;
            else
                firstY=off-amp;
            end

            UD=add_repeat_normalized_signal(UD,xNorm,yNorm,freq,extra_args{1},lastY,firstY,negativexNorm,yNorm);
            set(dialog,'UserData',UD);
        end
    end

    function sigBuilderAddTriangleSignal()


        UD=get(dialog,'UserData');
        title=getString(message('Sigbldr:sigbldr:TriangleWave'));
        labels={getString(message('Sigbldr:sigbldr:FrequencyHz')),getString(message('Sigbldr:sigbldr:AmplitudeColon')),...
        getString(message('Sigbldr:sigbldr:OffsetColon'))};
        startVals={'1.0','1.0','1.0'};
        vals=sigbuilder_modal_edit_dialog('TriangleWaveDlg',title,...
        labels,startVals);
        if iscell(vals)
            freq=eval_to_real_scalar(vals{1},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:FrequencyHz'))),'"']);
            amp=eval_to_real_scalar(vals{2},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:AmplitudeColon'))),'"']);
            off=eval_to_real_scalar(vals{3},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:OffsetColon'))),'"']);
            if isempty(freq)||isempty(amp)||isempty(off)
                return;
            end
            if freq<=0
                errordlg(getString(message('Sigbldr:sigbldr:PositiveFrequency')));
                return;
            end
            xNorm=[0,1];
            yNorm=off+[-1,1]*amp;




            if(1/freq)>abs(UD.common.maxTime-UD.common.minTime)

                minNorm=UD.common.minTime/(1/freq);
                maxNorm=UD.common.maxTime/(1/freq);


                yI=interp1(xNorm,yNorm,[minNorm,maxNorm]);
                xNorm=[xNorm,minNorm,maxNorm];
                yNorm=[yNorm,yI];
                [xNorm,sortIdx]=sort(xNorm);
                yNorm=yNorm(sortIdx);

            end

            negativeyNorm=off+[1,-1]*amp;
            relativeX=mod(UD.common.maxTime,1/freq);
            lastY=2*freq*amp*relativeX+off-amp;
            relativeX=mod(UD.common.minTime,1/freq);
            firstY=2*freq*amp*relativeX+off-amp;
            UD=add_repeat_normalized_signal(UD,xNorm,yNorm,freq,extra_args{1},lastY,firstY,xNorm,negativeyNorm);
            set(dialog,'UserData',UD);
        end
    end

    function sigBuilderAddSampledSineSignal()


        UD=get(dialog,'UserData');
        title=getString(message('Sigbldr:sigbldr:SampledSine'));
        labels={getString(message('Sigbldr:sigbldr:FrequencyHz')),getString(message('Sigbldr:sigbldr:AmplitudeColon')),...
        getString(message('Sigbldr:sigbldr:OffsetColon')),getString(message('Sigbldr:sigbldr:SamplesPerPeriod'))};
        startVals={'1.0','1.0','1.0','9'};
        vals=sigbuilder_modal_edit_dialog('SampledSinDlg',title,...
        labels,startVals);

        if iscell(vals)
            freq=eval_to_real_scalar(vals{1},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:FrequencyHz'))),'"']);
            amp=eval_to_real_scalar(vals{2},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:AmplitudeColon'))),'"']);
            off=eval_to_real_scalar(vals{3},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:OffsetColon'))),'"']);
            ns=eval_to_real_scalar(vals{4},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:SamplesPerPeriod'))),'"']);
            if isempty(freq)||isempty(amp)||isempty(off)||isempty(ns)
                return;
            end

            if freq<=0
                errordlg(getString(message('Sigbldr:sigbldr:PositiveFrequency')));
                return;
            end

            if ns<1
                errordlg(getString(message('Sigbldr:sigbldr:IntegerSampleCount')));
                return;
            end




            if ns<2
                ns=2;
            end
            tns=ns-1;
            xNorm=0:(1/tns):1-(1/tns);




            if(1/freq)>abs(UD.common.maxTime-UD.common.minTime)

                minNorm=UD.common.minTime/(1/freq);
                maxNorm=UD.common.maxTime/(1/freq);

                xNorm=[xNorm,minNorm,maxNorm];
                [xNorm,~]=sort(xNorm);
            end

            yNorm=off+amp*sin(2*pi*xNorm);
            negativeyNorm=off+amp*sin(2*pi*(-xNorm));
            lastY=off+amp*sin(2*pi*UD.common.maxTime*freq);
            firstY=off+amp*sin(2*pi*UD.common.minTime*freq);
            UD=add_repeat_normalized_signal(UD,xNorm,yNorm,freq,extra_args{1},lastY,firstY,xNorm,negativeyNorm);
            set(dialog,'UserData',UD);
        end
    end

    function sigBuilderAddGaussianNoiseSignal()


        UD=get(dialog,'UserData');
        title=getString(message('Sigbldr:sigbldr:SampledGaussianNoise'));
        labels={getString(message('Sigbldr:sigbldr:FrequencyHz')),getString(message('Sigbldr:sigbldr:MeanColon')),...
        getString(message('Sigbldr:sigbldr:StandardDeviationColon')),getString(message('Sigbldr:sigbldr:SeedCurrentState'))};
        startVals={'10.0','0.0','1.0',''};
        vals=sigbuilder_modal_edit_dialog('SampledGaussianNoiseDlg',...
        title,labels,startVals);

        if iscell(vals)
            freq=eval_to_real_scalar(vals{1},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:FrequencyHz'))),'"']);
            mean=eval_to_real_scalar(vals{2},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:MeanColon'))),'"']);
            stdev=eval_to_real_scalar(vals{3},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:StandardDeviationColon'))),'"']);

            if~isempty(vals{4})
                seed=eval_to_real_scalar(vals{4},...
                ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:SeedCurrentState'))),'"']);
                if isempty(seed)
                    return;
                end

                try
                    stream=RandStream('shr3cong','seed',seed);
                catch randstreamError
                    errordlg(randstreamError.message);
                    return;
                end
            else
                stream=RandStream.getGlobalStream;
            end

            if isempty(freq)||isempty(mean)||isempty(stdev)
                return;
            end
            if freq<=0
                errordlg(getString(message('Sigbldr:sigbldr:PositiveFrequency')));
                return;
            end
            if stdev<0
                errordlg(getString(message('Sigbldr:sigbldr:NonNegativeStandardDeviation')));
                return;
            end


            dlgAnswer=checkSignalDataPoints(...
            ceil(UD.common.maxTime/(1/freq))+1);

            if~strcmpi(dlgAnswer,'yes')
                return;
            end

            xNorm=UD.common.minTime:(1/freq):UD.common.maxTime;




            if(1/freq)>=abs(UD.common.maxTime-UD.common.minTime)


                xNorm=[UD.common.minTime,UD.common.maxTime];
            end

            yNorm=mean+stdev*randn(stream,1,length(xNorm));
            UD=add_nonrepeat_normalized_signal(UD,xNorm,yNorm,1,extra_args{1});
            set(dialog,'UserData',UD);
        end
    end

    function sigBuilderAddBinaryNoiseSignal()

        UD=get(dialog,'UserData');
        title=getString(message('Sigbldr:sigbldr:PseudorandomNoise'));
        labels={getString(message('Sigbldr:sigbldr:FrequencyHz')),getString(message('Sigbldr:sigbldr:UpperValueColon')),...
        getString(message('Sigbldr:sigbldr:LowerValueColon')),getString(message('Sigbldr:sigbldr:SeedColon'))};
        startVals={'10.0','1.0','0.0',''};
        vals=sigbuilder_modal_edit_dialog('PseudorandomNoiseDlg',title,...
        labels,startVals);

        if iscell(vals)
            freq=eval_to_real_scalar(vals{1},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:FrequencyHz'))),'"']);
            uval=eval_to_real_scalar(vals{2},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:UpperValueColon'))),'"']);
            lval=eval_to_real_scalar(vals{3},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:LowerValueColon'))),'"']);

            if~isempty(vals{4})
                seed=eval_to_real_scalar(vals{4},...
                ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:SeedColon'))),'"']);
                if isempty(seed)
                    return;
                end

                try
                    stream=RandStream('swb2712','seed',seed);
                catch randstreamError
                    errordlg(randstreamError.message);
                    return;
                end

            else
                stream=RandStream.getGlobalStream;
            end

            if isempty(freq)||isempty(uval)||isempty(lval)
                return;
            end

            if freq<=0
                errordlg(getString(message('Sigbldr:sigbldr:PositiveFrequency')));
                return;
            end

            if uval<lval
                errordlg(getString(message('Sigbldr:sigbldr:LowerLessThanUpper')));
                return;
            end


            dlgAnswer=checkSignalDataPoints(ceil(UD.common.maxTime/(1/freq))+1);
            if~strcmpi(dlgAnswer,'yes')
                return;
            end

            xNorm=UD.common.minTime:(1/freq):UD.common.maxTime;




            if(1/freq)>abs(UD.common.maxTime-UD.common.minTime)


                xNorm=[UD.common.minTime,UD.common.maxTime];
            end

            yNorm=lval+(1+sign(rand(stream,1,length(xNorm))-0.5))*(uval-lval)/2;
            [xnew,ynew]=make_piecewise_constant(xNorm,yNorm,1);
            [xnew,ynew]=remove_colinear_points(xnew,ynew);
            UD=add_nonrepeat_normalized_signal(UD,xnew,ynew,1,extra_args{1});
            set(dialog,'UserData',UD);
        end
    end

    function sigBuilderAddPoissonNoiseSignal()

        UD=get(dialog,'UserData');
        title=getString(message('Sigbldr:sigbldr:PoissonNoise'));
        labels={getString(message('Sigbldr:sigbldr:AveRate')),getString(message('Sigbldr:sigbldr:SeedCurrentState'))};
        startVals={'10.0',''};
        vals=sigbuilder_modal_edit_dialog('PoissonNoiseDlg',title,...
        labels,startVals);

        if iscell(vals)
            rate=eval_to_real_scalar(vals{1},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:AveRate'))),'"']);

            if isempty(rate)
                return;
            end

            if rate<=0
                errordlg(getString(message('Sigbldr:sigbldr:PositiveRate')));
                return;
            end

            if~isempty(vals{2})
                seed=eval_to_real_scalar(vals{2},...
                ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:SeedCurrentState'))),'"']);
                if isempty(seed)
                    return;
                end

                try
                    stream=RandStream('swb2712','seed',seed);
                catch randstreamError
                    errordlg(randstreamError.message);
                    return;
                end
            else
                stream=RandStream.getGlobalStream;
            end


            expectedL=floor(rate*(UD.common.maxTime-UD.common.minTime)*1.2);

            if(expectedL<2)
                expectedL=2;
            end


            dlgAnswer=checkSignalDataPoints(expectedL);
            if~strcmpi(dlgAnswer,'yes')
                return;
            end

            x=rand(stream,1,expectedL);
            t=-log(x)/rate;
            xNorm=UD.common.minTime+[0,cumsum(t)];
            xNorm=xNorm(xNorm<=UD.common.maxTime);
            xx=[xNorm(1:(end-1));xNorm(2:end)];
            xNorm=xx(:)';
            quartL=ceil(length(xNorm)/4);
            yNorm=repmat([0,0,1,1],1,quartL);
            yNorm=yNorm(1:length(xNorm));

            if isempty(xNorm)
                UD=add_nonrepeat_normalized_signal(UD,[UD.common.minTime,UD.common.maxTime],[0,0],1,extra_args{1});
            else
                UD=add_nonrepeat_normalized_signal(UD,xNorm,yNorm,1,extra_args{1});
            end

            set(dialog,'UserData',UD);
        end
    end

    function sigBuilderAddCustomSignal()

        UD=get(dialog,'UserData');
        prompts={getString(message('Sigbldr:sigbldr:TValuesColon')),getString(message('Sigbldr:sigbldr:YValuesColon'))};
        startVals={'',''};
        vals=sigbuilder_modal_edit_dialog('CustomWaveformDataDlg',...
        getString(message('Sigbldr:sigbldr:CustomData')),prompts,startVals);

        if iscell(vals)
            try
                rawX=evalin('base',vals{1});
            catch evalXError
                errordlg(getString(message('Sigbldr:sigbldr:NoEvalX',vals{1},evalXError.message)));
                return;
            end
            try
                rawY=evalin('base',vals{2});
            catch evalYError
                errordlg(getString(message('Sigbldr:sigbldr:NoEvalY',vals{1},evalYError.message)));
                return;
            end
            rawX=rawX(:)';
            rawY=rawY(:)';



            errMsg='';
            if any(~isfinite(rawX))
                errMsg=getString(message('Sigbldr:sigbldr:InvalidX',vals{1}));
            end

            if any(~isfinite(rawY))
                errMsg=[errMsg,getString(message('Sigbldr:sigbldr:InvalidY',vals{2}))];
            end




            if~isreal(rawX)||~isreal(rawY)
                errMsg=getString(message('Sigbldr:sigbldr:RealData'));
            end

            if length(rawX)~=length(rawY)
                errMsg=getString(message('Sigbldr:sigbldr:LengthXY'));
            end

            if any(diff(rawX)<0)
                errMsg=getString(message('Sigbldr:sigbldr:MonotonicX'));
            end

            if length(rawX)<2||rawX(1)>=UD.common.maxTime||rawX(end)<=UD.common.minTime
                errMsg=getString(message('Sigbldr:sigbldr:ValidSignalData'));
            end

            if~isempty(errMsg)
                errordlg(errMsg);
                x=[];
                y=[];
            else

                [x,y]=update_time_data(rawX(1),rawX(end),...
                UD.common.minTime,UD.common.maxTime,rawX,rawY);
            end

            if~isempty(x)

                [x,y]=remove_unneeded_points(x,y);
                if extra_args{1}
                    SBSigSuite=UD.sbobj;
                    groupSignalAppend(SBSigSuite,x,y);
                    sigName=SBSigSuite.Groups(1).Signals(end).Name;
                    UD=signal_new(UD,0,0,sigName);
                    UD=new_axes(UD,1,[]);
                    UD=new_plot_channel(UD,UD.numChannels,1);
                else
                    chInd=UD.current.channel;
                    UD=apply_new_channel_data(UD,chInd,x,y);
                    UD=rescale_axes_to_fit_data(UD,UD.channels(chInd).axesInd,1);
                end
                set(dialog,'UserData',UD);
            end
        end
    end


    function sigBuilderLineStyle()

        UD=channel_handler('setLineStyle',dialog,UD,method);
        set(dialog,'UserData',UD);
    end


    function sigBuilderLineWidth()

        UD=channel_handler('setWidth',dialog,UD);
        set(dialog,'UserData',UD);
    end


    function sigBuilderSetTRange()

        prompts={getString(message('Sigbldr:sigbldr:MinTimeColon')),getString(message('Sigbldr:sigbldr:MaxTimeColon'))};
        startVals={num2str(UD.common.minTime),num2str(UD.common.maxTime)};
        vals=sigbuilder_modal_edit_dialog('SettheTotalTimeRangeDlg',...
        getString(message('Sigbldr:sigbldr:TotalTimeRange')),prompts,startVals);
        if iscell(vals)
            minTime=eval_to_real_scalar(vals{1},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:MinTimeColon'))),'"']);
            maxTime=eval_to_real_scalar(vals{2},...
            ['"',checkAndRemoveEndColon(getString(message('Sigbldr:sigbldr:MaxTimeColon'))),'"']);
            if isempty(minTime)||isempty(maxTime)
                return;
            end
            if maxTime<=minTime
                errordlg(getString(message('Sigbldr:sigbldr:MinLessThanMax')));
                return;
            end
            UD=set_new_total_time_range(UD,minTime,maxTime);
            SBSigSuite=UD.sbobj;
            ActiveGroup=SBSigSuite.ActiveGroup;

            groupTRangeSet(SBSigSuite,{[minTime,maxTime]},ActiveGroup);
            UD=set_dirty_flag(UD);
            set(dialog,'UserData',UD);
        end
    end

    function sigBuilderSignalIndex()

        oldIdx=UD.current.channel;
        if oldIdx==0
            return;
        end

        title=getString(message('Sigbldr:sigbldr:ChangeIndex',UD.channels(oldIdx).label));
        labels={[getString(message('sigbldr_ui:create:IndexColon')),' ']};
        chanCount=length(UD.channels);
        choices={cellstr(num2str((1:chanCount)'))};
        startvals={oldIdx};

        vals=sigbuilder_modal_edit_dialog('ChangeIndexDlg',title,...
        labels,startvals,[],choices);
        if ischar(vals)
            newIdx=round(str2double(vals));
            if newIdx<1
                newIdx=1;
            elseif newIdx>length(UD.channels)
                newIdx=length(UD.channels);
            end

            UD=changeIndexSignal(UD,newIdx,oldIdx);
            set(dialog,'UserData',UD);
        end
    end

    function sigBuilderSignalDelete()


        UD=channel_handler(method,dialog,UD);



        UD=update_show_menu(UD);
        set(dialog,'UserData',UD);
    end

    function sigBuilderSignalCopy()


        UD=channel_handler(method,dialog,UD);
        set(dialog,'UserData',UD);
    end

    function sigBuilderSignalCut()


        UD=channel_handler(method,dialog,UD);
        set(dialog,'UserData',UD);
    end

    function sigBuilderSignalPaste()


        if UD.current.mode==3||UD.current.mode==7



            UD=channel_handler(method,dialog,UD);
            set(dialog,'UserData',UD);
        else
            if strcmp(UD.clipboard.type,'channel')

                SBSigSuite=UD.sbobj;
                groupSignalAppend(SBSigSuite,...
                UD.clipboard.content.xData,...
                UD.clipboard.content.yData,...
                UD.clipboard.content.label);


                sigName=SBSigSuite.Groups(1).Signals(end).Name;
                UD=signal_new(UD,...
                UD.clipboard.content.stepX,...
                UD.clipboard.content.stepY,...
                sigName,...
                UD.clipboard.content.color,...
                UD.clipboard.content.lineStyle,...
                UD.clipboard.content.lineWidth);
                UD=new_axes(UD,1,[]);
                UD=new_plot_channel(UD,UD.numChannels,1);
                UD.current.mode=3;
                UD.current.channel=UD.numChannels;
                UD.current.bdPoint=[0,0];
                UD.current.bdObj=UD.channels(UD.numChannels).lineH;
                UD=update_channel_select(UD);
                set(dialog,'UserData',UD);
            end
        end
    end

    function sigBuilderStart()

        UD.current.simWasStopped=0;
        set(UD.dialog,'Pointer','watch');
        UD=sl_command(UD,'start');
        set(dialog,'UserData',UD);
    end


    function sigBuilderStop()





        UD.current.simWasStopped=1;
        UD=sl_command(UD,'stop');
        set(dialog,'UserData',UD);
    end

    function sigBuilderPause()

        UD=sl_command(UD,'pause');
        set(dialog,'UserData',UD);
    end

    function sigBuilderUp()

        UD=sl_command(UD,'open');
        set(dialog,'UserData',UD);
    end


    function sigBuilderSnapGrid()

        if strcmp(UD.current.gridSetting,'off')
            UD.current.gridSetting='on';
        else
            UD.current.gridSetting='off';
        end

        for indx=1:UD.numAxes
            set(UD.axes(indx).handle,...
            'XGrid',UD.current.gridSetting,...
            'YGrid',UD.current.gridSetting);
        end
        sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
        set(dialog,'UserData',UD);
    end

    function sigBuilderZoomXY(modenumber)



        if UD.current.mode==modenumber
            UD=mouse_handler('ForceMode',dialog,UD,1);
        else
            UD=mouse_handler('ForceMode',dialog,UD,modenumber);
        end
        set(dialog,'UserData',UD);

    end

    function sigBuilderVerifyView()

        UD=get(dialog,'UserData');
        UD=verifyView(UD);
        set(dialog,'UserData',UD);
    end

    function sigBuilderUndoRedo()

        UD=perform_undo_or_redo(UD,method);
        set(dialog,'UserData',UD);
    end

    function sigBuilderOpen()

        uiopen('Simulink');
    end

    function sigBuilderSaveAs()


        if isempty(UD.simulink.modelH)
            return;
        end


        modelH=UD.simulink.modelH;





        harnessOwner=Simulink.harness.internal.getHarnessOwnerBD(modelH);
        if~isempty(harnessOwner)&&~Simulink.harness.internal.isSavedIndependently(harnessOwner)
            modelH=get_param(harnessOwner,'Handle');
        end

        modelSaveAs(modelH);
    end

    function sigBuilderSave()


        if isempty(UD.simulink.modelH)
            return;
        end


        modelH=UD.simulink.modelH;
        fileName=get_param(modelH,'FileName');





        harnessOwner=Simulink.harness.internal.getHarnessOwnerBD(modelH);
        if~isempty(harnessOwner)&&~Simulink.harness.internal.isSavedIndependently(harnessOwner)
            modelH=get_param(harnessOwner,'Handle');
            fileName=char(get_param(harnessOwner,'FileName'));
        end

        if isempty(fileName)
            modelSaveAs(modelH);
            return;
        end

        UD=sl_command(UD,'save');
        set(dialog,'UserData',UD);
    end

    function sigBuilderExportWS()


        name=sigbuilder_modal_edit_dialog('ExporttoWorkspaceDlg',...
        getString(message('Sigbldr:sigbldr:ExportToWS')),getString(message('Sigbldr:sigbldr:VariableNameColon')),'channels');


        ActiveGroup=UD.sbobj.ActiveGroup;
        sigCnt=UD.sbobj.Groups(ActiveGroup).NumSignals;
        for i=1:sigCnt
            UD.channels(i).xData=UD.sbobj.Groups(ActiveGroup).Signals(i).XData;
            UD.channels(i).yData=UD.sbobj.Groups(ActiveGroup).Signals(i).YData;
        end

        if ischar(name)
            try
                assignin('base',name,UD.channels);
            catch exportError
                errordlg(getString(message('Sigbldr:sigbldr:ExportError',exportError.message)));
            end
        end
        UD.channels=rmfield(UD.channels,{'xData','yData'});
    end

    function sigBuilderSimOpts()


        prompts={getString(message('Sigbldr:sigbldr:AfterFinalTime')),getString(message('Sigbldr:sigbldr:SampleTimeColon')),getString(message('Sigbldr:sigbldr:EnableZeroCross'))};

        afterFinalStrs={'Hold final value','Extrapolate','Set to zero'};
        onOffStrs={'off','on'};

        StringsTable={
        afterFinalStrs{1},getString(message('Sigbldr:sigbldr:HoldFinalValue'));...
        afterFinalStrs{2},getString(message('Sigbldr:sigbldr:Extrapolate'));...
        afterFinalStrs{3},getString(message('Sigbldr:sigbldr:SetToZero'));...
        onOffStrs{1},getString(message('Sigbldr:sigbldr:Off'));...
        onOffStrs{2},getString(message('Sigbldr:sigbldr:On'))};

        if~isfield(UD.common,'afterFinalStr')||isempty(UD.common.afterFinalStr)
            UD.common.afterFinalStr=afterFinalStrs{2};
        end
        if~isfield(UD.common,'sampleTime')||isempty(UD.common.sampleTime)
            UD.common.sampleTime='0';
        else
            if~ischar(UD.common.sampleTime)
                UD.common.sampleTime=num2str(UD.common.sampleTime);
            end
        end

        if~isfield(UD.common,'zeroCross')||isempty(UD.common.zeroCross)
            UD.common.zeroCross='off';
        end

        currentIdx=find(strcmp({UD.common.afterFinalStr},afterFinalStrs));
        zerocrossIdx=1+strcmp(UD.common.zeroCross,'on');
        startVals={currentIdx,UD.common.sampleTime,zerocrossIdx};
        vals=sigbuilder_modal_edit_dialog('SimulationOptionsDlg',...
        getString(message('Sigbldr:sigbldr:SimulationOptions')),prompts,startVals,[],{StringsTable(1:3,2),[],StringsTable(4:5,2)});
        if iscell(vals)
            UD.common.sampleTime=vals{2};
            [~,ID]=ismember(vals{1},StringsTable(:,2));
            UD.common.afterFinalStr=StringsTable{ID,1};
            [~,ID]=ismember(vals{3},StringsTable(:,2));
            UD.common.zeroCross=StringsTable{ID,1};




            if isfield(UD.simulink,'fromWsH')
                fromWsH=UD.simulink.fromWsH;
            else
                fromWsH=[];
            end


            if~isempty(fromWsH)&&ishandle(fromWsH)
                if~isfield(UD.common,'afterFinalStr')||isempty(UD.common.afterFinalStr)
                    UD.common.afterFinalStr='Hold final value';
                end
                if~isfield(UD.common,'sampleTime')||isempty(UD.common.sampleTime)
                    UD.common.sampleTime='0';
                end

                if~isfield(UD.common,'zeroCross')||isempty(UD.common.zeroCross)
                    UD.common.zeroCross='off';
                end

                switch(UD.common.afterFinalStr)
                case 'Hold final value'
                    set_param(fromWsH,'OutputAfterFinalValue','HoldingFinalValue')
                case 'Set to zero'
                    set_param(fromWsH,'OutputAfterFinalValue','SettingToZero')
                case 'Extrapolate'
                    set_param(fromWsH,'OutputAfterFinalValue','Extrapolation')
                end
                set_param(fromWsH,'SampleTime',UD.common.sampleTime);
                set_param(fromWsH,'ZeroCross',UD.common.zeroCross);
            end

            UD=set_dirty_flag(UD);
            set(dialog,'UserData',UD);
        end
    end


    function sigBuilderDataSetCopy()


        copyIdx=UD.current.dataSetIdx;
        UD.sbobj.groupAppend(UD.sbobj.Groups(copyIdx));
        newname=UD.sbobj.Groups(end).Name;

        UD=group_store(UD);
        UD.dataSet(end+1)=UD.dataSet(copyIdx);

        UD.dataSet(end).name=newname;
        newIdx=length(UD.dataSet);

        sigbuilder_tabselector('addentry',UD.hgCtrls.tabselect.axesH,newname);
        UD=dataSet_sync_menu_state(UD);

        UD=set_dirty_flag(UD);

        set(UD.dialog,'UserData',UD)
        vnv_notify('sbBlkGroupAdd',UD.simulink.subsysH,newIdx);
        UD=update_undo(UD,'add','dataSet',length(UD.dataSet),[]);
        set(dialog,'UserData',UD);
    end


    function sigBuilderDataSetDelete()


        if is_req_dialog_open(UD.common)
            need_to_close_rmi;
        else
            dsIdx=UD.current.dataSetIdx;
            undoData.dataSet=UD.dataSet(dsIdx);
            for chanIdx=1:length(UD.channels)
                undoData.chXData{chanIdx}=UD.sbobj.Groups(dsIdx).Signals(chanIdx).XData;
                undoData.chYData{chanIdx}=UD.sbobj.Groups(dsIdx).Signals(chanIdx).YData;
            end
            UD=update_undo(UD,'delete','dataSet',dsIdx,undoData);
            groupRemove(UD.sbobj,dsIdx);
            UD=group_delete(UD,dsIdx);
            set(dialog,'UserData',UD);

            refreshGroupAnnotation(UD.simulink.subsysH);
        end
    end


    function sigBuilderDataSetRename()


        dsIdx=UD.current.dataSetIdx;
        currLabel=UD.dataSet(dsIdx).name;
        newLabel=sigbuilder_modal_edit_dialog('GroupTabNameDlg',...
        getString((message('Sigbldr:sigbldr:GroupTabName'))),...
        {getString(message('Sigbldr:sigbldr:NameColon',dsIdx))},{currLabel});
        if ischar(newLabel)
            if isempty(newLabel)
                errordlg(getString((message('Sigbldr:sigbldr:NoEmptyGroupName'))));
                return;
            end

            UD.sbobj.groupRename(dsIdx,{newLabel});
            newName=UD.sbobj.Groups(dsIdx).Name;
            UD.dataSet(dsIdx).name=newName;
            sigbuilder_tabselector('rename',UD.hgCtrls.tabselect.axesH,...
            dsIdx,newName);

            UD=update_undo(UD,'rename','dataSet',dsIdx,currLabel);
            UD=set_dirty_flag(UD);
            set(dialog,'UserData',UD);

            refreshGroupAnnotation(UD.simulink.subsysH)
        end
    end

    function sigBuilderDataSetMove(direction)

        if is_req_dialog_open(UD.common)
            need_to_close_rmi;
        else
            dsIdx=UD.current.dataSetIdx;
            dsCnt=length(UD.dataSet);

            switch(direction)
            case 'left'
                if dsIdx==1
                    return;
                end

                old2NewIdx=[1:(dsIdx-2),dsIdx-[0,1],(dsIdx+1):dsCnt];
                newDsIdx=dsIdx-1;

            case 'right'
                if dsIdx==dsCnt
                    return;
                end

                old2NewIdx=[1:(dsIdx-1),dsIdx+[1,0],(dsIdx+2):dsCnt];
                newDsIdx=dsIdx+1;
            end
            UD=dataSet_reorder(UD,old2NewIdx,newDsIdx);
            UD=update_undo(UD,'move','dataSet',dsIdx,newDsIdx);
            set(dialog,'UserData',UD);
        end
    end

    function sigBuilderShowGroup()

        UD=get(dialog,'UserData');
        UD=showTab(UD,extra_args{1});
        set(dialog,'UserData',UD);
    end

    function sigBuilderShowSignal()

        UD=get(dialog,'UserData');

        chanIdx=extra_args{1};
        dsIdx=UD.current.dataSetIdx;
        axesIdx=find(UD.dataSet(dsIdx).activeDispIdx==chanIdx,1);

        if isempty(axesIdx)
            UD=signal_show(UD,chanIdx,dsIdx);
            set(dialog,'UserData',UD);
        end
    end


    function sigBuilderoutputFlatBus()
        UD=get(dialog,'UserData');

        UD=outputFlatBus(UD);
        set(dialog,'UserData',UD);
    end


    function sigBuilderoutputPorts()
        UD=get(dialog,'UserData');

        UD=outputPorts(UD);
        set(dialog,'UserData',UD);
    end






    function[xnew,ynew]=make_piecewise_constant(x,y,hold_forward)




        if nargin==2||isempty(hold_forward)
            hold_forward=1;
        end

        xnew=x;
        ynew=y;


        ImustChange=find(abs(diff(y))>0&diff(x)~=0);
        if isempty(ImustChange)
            return;
        end

        Iout=ImustChange+(1:length(ImustChange));

        for ind=Iout
            if hold_forward
                xinsert=xnew(ind);
                yinsert=ynew(ind-1);
            else
                xinsert=xnew(ind-1);
                yinsert=ynew(ind);
            end

            xnew=[xnew(1:(ind-1)),xinsert,xnew(ind:end)];
            ynew=[ynew(1:(ind-1)),yinsert,ynew(ind:end)];
        end
    end

    function UD=add_repeat_normalized_signal(UD,xNorm,yNorm,freq,...
        add_new,lastY,firstY,negativexNorm,negativeyNorm)

        chIdx=UD.current.channel;


        UD=mouse_handler('ForceMode',UD.dialog,UD,1);

        if isempty(UD.current.axes)||UD.current.axes==0
            if~isempty(UD.axes)
                UD.current.axes=UD.axes(1).handle;
            end
        end


        T=1/freq;


        dlgAnswer=checkSignalDataPoints(ceil(UD.common.maxTime/(1/freq))+1);
        if~strcmpi(dlgAnswer,'yes')
            return;
        end


        positivexData=[];
        positiveyData=[];
        if(UD.common.maxTime>=0)
            startTime=max(UD.common.minTime,0);
            [positivexData,positiveyData]=generate_repeating_data(startTime,UD.common.maxTime,T,xNorm,yNorm,firstY,lastY);
        end


        negativexData=[];
        negativeyData=[];
        if(UD.common.minTime<0)
            startTime=max(-UD.common.maxTime,0);
            [negativexData,negativeyData]=generate_repeating_data(startTime,-UD.common.minTime,T,negativexNorm,negativeyNorm,lastY,firstY);
            negativexData=fliplr(-negativexData);
            negativeyData=fliplr(negativeyData);


            repeatingData=positiveyData(positivexData==0);
            ind=(negativexData==0)&ismember(negativeyData,repeatingData);
            negativeyData(ind)=[];
            negativexData(ind)=[];
        end

        xData=[negativexData,positivexData];
        yData=[negativeyData,positiveyData];


        if add_new==0&&chIdx>0
            UD=apply_new_channel_data(UD,chIdx,xData,yData);
            UD=rescale_axes_to_fit_data(UD,UD.channels(chIdx).axesInd,1);
            UD=set_dirty_flag(UD);
        else

            SBSigSuite=UD.sbobj;
            groupSignalAppend(SBSigSuite,xData,yData);
            sigName=SBSigSuite.Groups(1).Signals(end).Name;
            UD=signal_new(UD,0,0,sigName);
            if is_space_for_new_axes(UD.current.axesExtent,UD.geomConst,UD.numAxes)
                UD=new_axes(UD,1,[]);
                UD=new_plot_channel(UD,UD.numChannels,1);
                UD.current.mode=3;
                UD.current.channel=UD.numChannels;
                UD.current.bdPoint=[0,0];
                UD.current.bdObj=UD.channels(UD.numChannels).lineH;
            end
            UD=update_channel_select(UD);
        end
    end

    function[xnew,ynew]=remove_colinear_points(x,y)


        xnew=x;
        ynew=y;



        if length(x)>2

            sameY=diff(y)==0;
            I_eliminate=find(sameY(1:(end-1))&diff(sameY)==0)+1;
            xnew(I_eliminate)=[];
            ynew(I_eliminate)=[];
        end


    end

    function UD=perform_undo_or_redo(UD,method)


        if~strcmp(UD.undo.command,method)
            return;
        end

        dataStruct.view=UD.undo.view;
        dataStruct.model=UD.undo.model;
        undoIdx=UD.undo.index;

        switch(UD.undo.contents)
        case 'channel'


            switch(UD.undo.action)

            case 'edit'
                ActiveGroup=UD.sbobj.ActiveGroup;

                UD.undo.view=UD.channels(undoIdx);
                UD.undo.model.XData=UD.sbobj.Groups(ActiveGroup).Signals(undoIdx).XData;
                UD.undo.model.YData=UD.sbobj.Groups(ActiveGroup).Signals(undoIdx).YData;

                UD.channels(undoIdx)=dataStruct.view;
                UD.sbobj.Groups(ActiveGroup).Signals(undoIdx).XData=dataStruct.model.XData;
                UD.sbobj.Groups(ActiveGroup).Signals(undoIdx).YData=dataStruct.model.YData;
                UD=rescale_axes_to_fit_data(UD,dataStruct.view.axesInd);
                axIdx=dataStruct.view.axesInd;
                set(dataStruct.view.lineH...
                ,'XData',UD.sbobj.Groups(ActiveGroup).Signals(undoIdx).XData...
                ,'YData',UD.sbobj.Groups(ActiveGroup).Signals(undoIdx).YData...
                ,'Color',dataStruct.view.color...
                ,'LineWidth',dataStruct.view.lineWidth...
                ,'LineStyle',dataStruct.view.lineStyle...
                );
                if axIdx>0
                    set(UD.axes(axIdx).labelH,'Color',dataStruct.view.color);
                end
                UD=update_channel_select(UD);

            case 'move'
                prevIdx=dataStruct.view;
                UD.undo.view=undoIdx;
                UD.undo.index=prevIdx;
                UD=change_channel_index(UD,prevIdx,undoIdx);

            case 'delete'



                origDataStruct=dataStruct;
                dataStruct.view=dataStruct.view.channel;
                grpCnt=length(UD.dataSet);
                if(grpCnt>1)
                    xData=cell(1,grpCnt);
                    yData=cell(1,grpCnt);
                    for m=1:grpCnt
                        xData{1,m}=UD.undo.view.allSignals{m}.XData;
                        yData{1,m}=UD.undo.view.allSignals{m}.YData;
                    end
                else
                    xData=dataStruct.model.XData;
                    yData=dataStruct.model.YData;
                end
                SBSigSuite=UD.sbobj;
                groupSignalAppend(SBSigSuite,...
                xData,...
                yData,...
                dataStruct.view.label);
                UD=signal_new(UD,...
                dataStruct.view.stepX,...
                dataStruct.view.stepY,...
                dataStruct.view.label,...
                dataStruct.view.color,...
                dataStruct.view.lineStyle,...
                dataStruct.view.lineWidth);
                UD=new_axes(UD,1,[]);
                UD=new_plot_channel(UD,UD.numChannels,1);
                UD=change_channel_index(UD,undoIdx,UD.numChannels);

                for idx=1:length(UD.dataSet)
                    oai=origDataStruct.view.dataSet(idx).activeDispIdx;
                    cai=UD.dataSet(idx).activeDispIdx;
                    if~isempty(find(oai==undoIdx,1))&&...
                        isempty(find(cai==undoIdx,1))
                        UD.dataSet(idx).activeDispIdx=sort([cai,undoIdx],'descend');
                    end
                end

                UD.current.mode=3;
                UD.current.channel=undoIdx;
                UD.current.bdPoint=[0,0];
                UD.current.bdObj=UD.channels(UD.numChannels).lineH;
                UD=update_channel_select(UD);
                UD.undo.action='add';
                UD.undo.view=[];
                UD.undo.model=[];
                UD.undo.index=undoIdx;
                UD=update_show_menu(UD);

            case 'add'
                ActiveGroup=UD.sbobj.ActiveGroup;
                UD.undo.view.channel=UD.channels(undoIdx);
                UD.undo.model=struct;
                UD.undo.model.XData=UD.sbobj.Groups(ActiveGroup).Signals(undoIdx).XData;
                UD.undo.model.YData=UD.sbobj.Groups(ActiveGroup).Signals(undoIdx).YData;
                for i=1:length(UD.dataSet)
                    UD.undo.view.allSignals{i}.XData=UD.sbobj.Groups(i).Signals(undoIdx).XData;
                    UD.undo.view.allSignals{i}.YData=UD.sbobj.Groups(i).Signals(undoIdx).YData;
                end
                for ind=1:length(UD.dataSet)
                    UD.undo.view.dataSet(ind).activeDispIdx=UD.dataSet(ind).activeDispIdx;
                end

                UD.undo.action='delete';

                for m=1:UD.sbobj.NumGroups
                    UD.sbobj.Groups(m).signalRemove(undoIdx);
                end
                UD=remove_channel(UD,undoIdx);
                UD.current.channel=0;
                UD=update_channel_select(UD);
                UD=update_show_menu(UD);

            case 'rename'
                UD=signal_rename(UD,dataStruct.view,UD.channels(undoIdx).label,undoIdx);

            case 'hide'
                UD=signal_show(UD,undoIdx,dataStruct.view);

            case 'show'
                axesIdx=UD.channels(undoIdx).axesInd;
                UD=signal_hide(UD,undoIdx,dataStruct.view,axesIdx);

            case 'outputFlatBus'
                UD=outputPorts(UD);

            case 'outputPorts'
                UD=outputFlatBus(UD);

            otherwise
            end

        case 'dataSet'
            switch(UD.undo.action)
            case 'delete'

                UD=dataSet_store(UD);
                oldActiveDsIdx=UD.current.dataSetIdx;
                if~isfield(UD.undo.view.dataSet,'displayRange')
                    UD.undo.view.dataSet.displayRange=UD.undo.view.dataSet.timeRange;
                end

                UD.dataSet(end+1)=UD.undo.view.dataSet;


                sigCnt=length(UD.channels);
                time=cell(sigCnt,1);
                data=cell(sigCnt,1);
                for i=1:sigCnt
                    time{i,1}=UD.undo.model{i}.XData;
                    data{i,1}=UD.undo.model{i}.YData;
                end
                sigLabels={UD.sbobj.Groups(1).Signals.Name};

                UD.sbobj.groupAppend(time,data,sigLabels,...
                UD.undo.view.dataSet.name);

                sigbuilder_tabselector('addentry',...
                UD.hgCtrls.tabselect.axesH,...
                UD.undo.view.dataSet.name);
                dsCnt=length(UD.dataSet);

                if dsCnt~=undoIdx
                    old2NewIdx=[1:(undoIdx-1),dsCnt,undoIdx:(dsCnt-1)];

                    if undoIdx>1
                        UD=dataSet_reorder(UD,old2NewIdx,old2NewIdx(oldActiveDsIdx));
                    else
                        UD=dataSet_reorder(UD,old2NewIdx,2);
                    end
                end
                UD.undo.action='add';
                UD.undo.view=[];
                UD.undo.model=[];
                UD=dataSet_sync_menu_state(UD);


            case 'add'
                UD.undo.view.dataSet=UD.dataSet(undoIdx);
                for i=1:length(UD.channels)
                    UD.undo.model{i}.XData=UD.sbobj.Groups(undoIdx).Signals(i).XData;
                    UD.undo.model{i}.YData=UD.sbobj.Groups(undoIdx).Signals(i).YData;
                end
                UD.undo.action='delete';
                groupRemove(UD.sbobj,undoIdx);
                UD=group_delete(UD,undoIdx);

            case 'move'
                newIdx=undoIdx;
                oldIdx=UD.undo.view;
                dsCnt=length(UD.dataSet);
                if(oldIdx>newIdx)
                    old2newIdx=[1:(newIdx-1),oldIdx,newIdx:(oldIdx-1),(oldIdx+1):dsCnt];
                else
                    old2newIdx=[1:(oldIdx-1),(oldIdx+1):newIdx,oldIdx,(newIdx+1):dsCnt];
                end
                UD=dataSet_reorder(UD,old2newIdx,old2newIdx(UD.current.dataSetIdx));
                UD.undo.view=newIdx;
                UD.undo.index=oldIdx;
                UD=dataSet_sync_menu_state(UD);


            case 'rename'
                tempName=UD.undo.view;
                UD.undo.view=UD.dataSet(undoIdx).name;
                UD.dataSet(undoIdx).name=tempName;
                UD.sbobj.Groups(undoIdx).Name=tempName;
                sigbuilder_tabselector('rename',...
                UD.hgCtrls.tabselect.axesH,undoIdx,tempName);


                set(UD.dialog,'UserData',UD);
                refreshGroupAnnotation(UD.simulink.subsysH);

            case 'timeRange'
                ActiveGroup=UD.sbobj.ActiveGroup;
                tempViews=dataStruct.view.channels;
                timeRange=dataStruct.view.timeRange;
                tempModel=dataStruct.model;
                UD.undo.view.channels=UD.channels;
                for i=1:length(UD.channels)
                    UD.undo.model{i}.XData=UD.sbobj.Groups(ActiveGroup).Signals(i).XData;
                    UD.undo.model{i}.YData=UD.sbobj.Groups(ActiveGroup).Signals(i).YData;
                end
                UD.undo.view.timeRange=UD.common.dispTime;


                UD.channels=tempViews;
                for i=1:length(UD.channels)
                    UD.sbobj.Groups(ActiveGroup).Signals(i).XData=tempModel{i}.XData;
                    UD.sbobj.Groups(ActiveGroup).Signals(i).YData=tempModel{i}.YData;
                end
                UD.common.dispTime=timeRange;
                UD.common.minTime=timeRange(1);
                UD.common.maxTime=timeRange(2);
                set_new_time_range(UD,timeRange);


                dsIdx=UD.current.dataSetIdx;
                dispChans=UD.dataSet(dsIdx).activeDispIdx;

                for i=1:length(dispChans)
                    chIdx=dispChans(i);
                    set(UD.channels(chIdx).lineH,...
                    'Xdata',UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData,...
                    'Ydata',UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData);
                end

            otherwise
            end
        otherwise
        end

        if strcmp(method,'undo')
            UD.undo.command='redo';
            set([UD.menus.figmenu.EditMenuUndo,UD.toolbar.undo],'Enable','off');
            set([UD.menus.figmenu.EditMenuRedo,UD.toolbar.redo],'Enable','on');
        else
            UD.undo.command='undo';
            set([UD.menus.figmenu.EditMenuUndo,UD.toolbar.undo],'Enable','on');
            set([UD.menus.figmenu.EditMenuRedo,UD.toolbar.redo],'Enable','off');
        end
    end

    function modelSaveAs(modelH)
        modelName=get_param(modelH,'Name');
        fail=true;





        while fail
            [file,~]=Simulink.SaveDialog(modelName,false);

            if file
                [pathname,filename,ext]=fileparts(file);





                pwDir=pwd;
                cd(pathname);
                try
                    save_system(modelH,[filename,ext]);
                    fail=false;
                catch Exception
                    title=DAStudio.message('Sigbldr:sigbldr:SaveMDLFileDialogTitle');
                    h=errordlg(Exception.message,title,'modal');
                    uiwait(h);
                end
                cd(pwDir);
            else
                fail=false;
            end
        end
    end

    function UD=set_new_total_time_range(UD,minTime,maxTime)

        moveMax=(maxTime~=UD.common.maxTime);
        moveMin=(minTime~=UD.common.minTime);

        if(~moveMax&&~moveMin)
            return;
        end


        undoData.timeRange=UD.common.dispTime;
        undoData.channels=UD.channels;
        ActiveGroup=UD.sbobj.ActiveGroup;
        UD=update_undo(UD,'timeRange','dataSet',ActiveGroup,undoData);


        theGroup=UD.sbobj.Groups(ActiveGroup);
        for i=1:UD.numChannels
            X=theGroup.Signals(i).XData;
            Y=theGroup.Signals(i).YData;
            [X,Y]=update_time_data(X(1),X(end),...
            minTime,maxTime,X,Y);

            UD=apply_new_channel_data(UD,i,X,Y,1);
        end

        UD.common.maxTime=maxTime;
        UD.common.minTime=minTime;
        UD=set_new_time_range(UD,[minTime,maxTime]);

    end



    function dlgAnswer=checkSignalDataPoints(numDataPoints)
        dlgAnswer='Yes';

        threshold=100000000;



        if numDataPoints>=threshold
            dlgAnswer=questdlg(...
            DAStudio.message('Sigbldr:sigbldr:LargeNumberOfDataPoints'),...
            DAStudio.message('Sigbldr:sigbldr:LargeNumberOfDataPointsTitle'));
        end

    end


    function str=checkAndRemoveEndColon(str)



        if~ischar(str)
            return;
        else
            if isequal(str(end),':')
                str=str(1:end-1);
            else
                return;
            end
        end
    end

end

