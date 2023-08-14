classdef ParameterPanel<handle





    properties(GetAccess=?uitest.factory.Tester)
Icon
    end
    properties
HeaderPanel
BodyPanel
        PanelSelected=true;
        HeaderVisible=false;
        BodyVisible=false;
PanelHeight
HeaderPosition
BodyPosition
        FontName='Helvetica';
        FontSize=12;
    end

    events
ExpandedDropDown
UpdatedSettings
    end

    methods

        function self=ParameterPanel()

        end

        function setupParameterPanel(self,hParent,titleString,tag)

            pos=get(hParent,'Position');
            containerWidth=pos(3);
            containerHeight=pos(4)+1;
            headerHeight=30;

            self.HeaderPanel=uipanel('Parent',hParent,...
            'Units','pixels',...
            'Position',[0,containerHeight-headerHeight,containerWidth,headerHeight],...
            'Visible','off',...
            'BorderType','none',...
            'Tag',tag,...
            'AutoResizeChildren','off',...
            'ButtonDownFcn',@(~,~)self.panelSelectedCallback());

            uilabel('Parent',self.HeaderPanel,...
            'Text',titleString,...
            'Position',[20,5,containerWidth-30,20],...
            'Visible','on',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize+2,...
            'HandleVisibility','off');

            self.Icon=uiimage('Parent',self.HeaderPanel,...
            'Position',[5,10,10,10],...
            'ScaleMethod','fill',...
            'Tag',[tag,'_ExpandIcon'],...
            'ImageSource',fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_NextArrow_10.png'));

            addlistener(self.Icon,'ImageClicked',@(src,evt)panelSelectedCallback(self));

            self.BodyPanel=uipanel('Parent',hParent,...
            'Units','pixels',...
            'Position',[0,containerHeight-headerHeight-self.PanelHeight,containerWidth,self.PanelHeight],...
            'Visible','off',...
            'HitTest','off',...
            'AutoResizeChildren','off',...
            'BorderType','none');

        end

        function updateSettings(self)
            notify(self,'UpdatedSettings');
        end

        function panelSelectedCallback(self)
            if self.PanelSelected
                self.contractPanel();
            else
                self.expandPanel();
            end
            notify(self,'ExpandedDropDown');
        end

        function hidePanel(self)
            self.HeaderVisible=false;
            self.BodyVisible=false;
        end

        function showPanel(self)
            self.HeaderVisible=true;
            self.BodyVisible=self.PanelSelected;
            if self.PanelSelected
                set(self.Icon,'ImageSource',fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_DownArrow_10.png'))
            else
                set(self.Icon,'ImageSource',fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_NextArrow_10.png'))
            end
        end

        function expandPanel(self)
            self.HeaderVisible=true;
            self.BodyVisible=true;
            self.PanelSelected=true;
            set(self.Icon,'ImageSource',fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_DownArrow_10.png'))
        end

        function contractPanel(self)
            self.HeaderVisible=true;
            self.BodyVisible=false;
            self.PanelSelected=false;
            set(self.Icon,'ImageSource',fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_NextArrow_10.png'))
        end
    end

    methods

        function set.HeaderVisible(self,TF)
            if TF
                set(self.HeaderPanel,'Visible','on');%#ok<MCSUP>
            else
                set(self.HeaderPanel,'Visible','off');%#ok<MCSUP>
            end
            self.HeaderVisible=TF;
        end

        function set.BodyVisible(self,TF)
            if TF
                set(self.BodyPanel,'Visible','on');%#ok<MCSUP>
            else
                set(self.BodyPanel,'Visible','off');%#ok<MCSUP>
            end
            self.BodyVisible=TF;
        end

        function set.HeaderPosition(self,inputVal)
            set(self.HeaderPanel,'Position',inputVal);%#ok<MCSUP>
            self.HeaderPosition=inputVal;
        end

        function set.BodyPosition(self,inputVal)
            set(self.BodyPanel,'Position',inputVal);%#ok<MCSUP>
            self.BodyPosition=inputVal;
        end

    end

    methods(Static)

        function TF=validateSettings(inputVal)
            TF=false;
            if isscalar(inputVal)&&isreal(inputVal)&&isfinite(inputVal)
                TF=true;
            end
        end

    end

end



