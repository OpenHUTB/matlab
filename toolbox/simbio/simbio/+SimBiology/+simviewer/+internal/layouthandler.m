function varargout=layouthandler(action,varargin)













    switch action
    case 'sizeTextLabel'
        sizeTextLabel(varargin{:});
    case 'sizeButton'
        sizeButton(varargin{:});
    case 'sizeCheckBox'
        sizeCheckBox(varargin{:});
    case 'makeComponentsSameWidth'
        makeComponentsSameWidth(varargin{:});
    case 'sizeComponentWidth'
        sizeComponentWidth(varargin{:});
    case 'readIcon'
        varargout{1}=readIcon(varargin{:});
    case 'configureTitle'
        configureTitle(varargin{:});
    case 'configureXLabel'
        configureXLabel(varargin{:})
    case 'configureYLabel'
        configureYLabel(varargin{:});
    case 'getBorderColor'
        varargout{1}=[132,140,149]/255;
    case 'configureButtonColor'
        configureButtonColor(varargin{:});
    case 'getUIPlot'
        [uiplot,ax]=getUIPlot(varargin{:});
        varargout{1}=uiplot;
        varargout{2}=ax;
    case 'centerDialog'
        centerDialog(varargin{:});
    case 'convertToString'
        varargout{1}=convertToString(varargin{:});
    case 'isValidOutputTimesArray'
        varargout{1}=isValidOutputTimesArray(varargin{:});
    case 'getValidColor'
        varargout{1}=[0.9400,0.9400,0.9400];
    case 'getInvalidColor'
        varargout{1}=[236/255,214/255,214/255];
    end


    function sizeTextLabel(h)

        hPos=get(h,'Position');
        hExt=get(h,'Extent');
        hPos(3)=hExt(3);
        set(h,'Position',hPos);


        function sizeButton(h)

            hPos=get(h,'Position');
            hExt=get(h,'Extent');
            hPos(3)=hExt(3)+8;
            set(h,'Position',hPos);


            function sizeCheckBox(h)

                spi=get(0,'ScreenPixelsPerInch');
                pad=(SimBiology.simviewer.UIPanel.getFieldPadding()*spi)/96;



                hPos=get(h,'Position');
                hExt=get(h,'Extent');
                hPos(3)=hExt(3)+pad;
                set(h,'Position',hPos);


                function makeComponentsSameWidth(h)

                    width=0;
                    for i=1:length(h)
                        hPos=get(h(i),'Position');
                        width=max(width,hPos(3));
                    end

                    for i=1:length(h)
                        sizeComponentWidth(h(i),width);
                    end


                    function sizeComponentWidth(h,width)

                        hPos=get(h,'Position');
                        hPos(3)=width;
                        set(h,'Position',hPos);


                        function cdata=readIcon(filename)

                            if isdeployed
                                filename=fullfile('toolbox','simbio','simbio','+SimBiology','+simviewer','+resources',filename);
                            else
                                filename=fullfile(matlabroot,'toolbox','simbio','simbio','+SimBiology','+simviewer','+resources',filename);
                            end

                            [cdata,map,alpha]=imread(filename);
                            if isempty(cdata)
                                return;
                            end

                            if isempty(map)

                                cdata=double(cdata);
                                cdata=cdata/255;
                            else
                                cdata=ind2rgb(cdata,map);
                            end


                            r=cdata(:,:,1);
                            r(alpha==0)=NaN;
                            g=cdata(:,:,2);
                            g(alpha==0)=NaN;
                            b=cdata(:,:,3);
                            b(alpha==0)=NaN;
                            cdata=cat(3,r,g,b);


                            function configureTitle(h)

                                set(h,'VerticalAlignment','bottom','FontSize',10,'FontWeight','normal','Interpreter','none');


                                function configureXLabel(h)

                                    set(h,'FontSize',10,'FontWeight','normal','Interpreter','none');


                                    function configureYLabel(h)

                                        set(h,'FontSize',10,'FontWeight','normal','Interpreter','none');


                                        function configureButtonColor(handle,color)

                                            set(handle,'UserData',color);

                                            if ischar(color)

                                                color=handle.BackgroundColor;
                                            end

                                            length=12;


                                            r=0.6*ones(length,length);
                                            g=0.6*ones(length,length);
                                            b=0.6*ones(length,length);


                                            r(2:end-1,2:end-1)=color(1)*ones(length-2,length-2);
                                            g(2:end-1,2:end-1)=color(2)*ones(length-2,length-2);
                                            b(2:end-1,2:end-1)=color(3)*ones(length-2,length-2);


                                            c(:,:,1)=r;
                                            c(:,:,2)=g;
                                            c(:,:,3)=b;


                                            set(handle,'CData',c);


                                            function[uiplot,ax]=getUIPlot(appUI)

                                                index=appUI.Handles.PlotSetup.PlotComboBox.Value;
                                                uiplot=appUI.Plots(index);
                                                ax=appUI.axesHandles(index);


                                                function centerDialog(outerFrame,dialogFrame)

                                                    figurePos=outerFrame.Position;
                                                    pos=dialogFrame.Position;
                                                    pos(1)=figurePos(1)+(figurePos(3)/2-pos(3)/2);
                                                    pos(2)=figurePos(2)+(figurePos(4)/2-pos(4)/2);

                                                    dialogFrame.Position=pos;


                                                    function out=convertToString(value)

                                                        if isempty(value)
                                                            out='[]';
                                                        elseif length(value)==1
                                                            out=num2str(value);
                                                        elseif length(value)==2
                                                            out=['[',num2str(value(1)),' ',num2str(value(2)),']'];
                                                        else
                                                            min=value(1);
                                                            max=value(end);
                                                            step=value(2)-value(1);

                                                            temp=min:step:max;
                                                            if isequal(value,temp)
                                                                out=[num2str(min),':',num2str(step),':',num2str(max)];
                                                            else
                                                                temp=sprintf(repmat('%g ',1,length(value)),value);
                                                                out=['[',temp(1:end-1),']'];
                                                            end
                                                        end


                                                        function valid=isValidOutputTimesArray(value)

                                                            valid=isnumeric(value)&&all(value>=0)&&all(isreal(value))&&isDataMonotonicallyIncreasing(value)&&all(isfinite(value));


                                                            function out=isDataMonotonicallyIncreasing(value)

                                                                out=(all(value(2:end)>value(1:end-1)));
