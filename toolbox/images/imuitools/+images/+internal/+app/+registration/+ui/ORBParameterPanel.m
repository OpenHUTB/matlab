classdef ORBParameterPanel<images.internal.app.registration.ui.ParameterPanel





    properties(GetAccess={?uitest.factory.Tester,...
        ?images.internal.app.registration.ui.DocumentArea})
hTransformType
        TformList={'Rigid','Similarity','Affine','Projective'};

hNumLevels
hScaleFactor

hFeatureQualitySlider
    end

    properties
        Tform='similarity';
        HasRotation=false;
        ScaleFactor=1.2;
        NumLevels=4;
        MinSize=31;
    end

    methods

        function self=ORBParameterPanel(hParent)

            import images.internal.app.registration.ui.*;

            self.PanelHeight=114;

            self.setupParameterPanel(hParent,getMessageString('featureParameters'),'featureParameters')

            self.setupFeatureComponents();

        end

        function setMinImageSize(self,sz)

            self.MinSize=sz;

            MaxNumLevels=uint8(floor((log(self.MinSize)-log(31*2+1))/log(double(self.ScaleFactor)))+1);

            if self.NumLevels>MaxNumLevels
                self.NumLevels=MaxNumLevels;
                self.hNumLevels.Value=double(MaxNumLevels);
            end

            if MaxNumLevels==1
                self.hNumLevels.Enable='off';
            else
                self.hNumLevels.Limits=double([1,MaxNumLevels]);
                self.hNumLevels.Enable='on';
            end

        end

        function setupFeatureComponents(self)

            import images.internal.app.registration.ui.*;

            pos=get(self.BodyPanel,'Position');
            border=2;
            height=20;

            newpos=[10,pos(4)-height,5*height,height];
            labelpos=[10+(5*height)+border,pos(4)-height,pos(3)-(5*height)-border-10,height-3];


            self.hTransformType=uidropdown(...
            'Parent',self.BodyPanel,...
            'Position',newpos,...
            'Items',self.TformList,...
            'ItemsData',1:numel(self.TformList),...
            'Value',2,...
            'Tag','FeatureTransformTypeORB',...
            'Tooltip',getMessageString('tformTypeTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.tformCallback(hobj,evt));

            uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('tformType'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

            newpos(2)=pos(4)-(2*height)-(2*border);
            newpos(3)=3*height;
            labelpos=[10+(3*height)+border,newpos(2),pos(3)-10,height-3];

            self.hScaleFactor=uieditfield('numeric',...
            'Parent',self.BodyPanel,...
            'Position',newpos,...
            'Value',self.ScaleFactor,...
            'Tag','ScaleFactor',...
            'Tooltip',getMessageString('scaleFactorTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.scaleFactorCallback(hobj,evt));

            uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('scaleFactor'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

            newpos(2)=pos(4)-(3*height)-(3*border);
            labelpos=[10+(3*height)+border,newpos(2),pos(3)-10,height-3];

            self.hNumLevels=uieditfield('numeric',...
            'Parent',self.BodyPanel,...
            'Position',newpos,...
            'Value',self.NumLevels,...
            'RoundFractionalValues','on',...
            'Tag','NumLevels',...
            'Tooltip',getMessageString('numLevelsTooltip'),...
            'ValueChangedFcn',@(hobj,evt)self.numLevelsCallback(hobj,evt));

            uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('numLevels'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','top',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

            newpos(2)=pos(4)-(4*height)-(4*border);
            labelpos=[10,newpos(2),pos(3)-10,height-3];

            uilabel('Parent',self.BodyPanel,...
            'Text',getMessageString('qualityFeatures'),...
            'Position',labelpos,...
            'Visible','on',...
            'VerticalAlignment','bottom',...
            'FontName',self.FontName,...
            'FontSize',self.FontSize);

            newpos(2)=pos(4)-(4.5*height)-(5*border);
            newpos(3)=8*height;

            self.hFeatureQualitySlider=uislider('Parent',self.BodyPanel,...
            'Tag','FeatureQualitySliderORB',...
            'Value',0.5,...
            'Position',[newpos(1:3),3],...
            'Visible','on',...
            'Limits',[0,1],...
            'MajorTicks',[],...
            'MinorTicks',[],...
            'ValueChangedFcn',@(~,~)updateSettings(self));

        end

        function tformCallback(self,~,evt)
            self.Tform=evt.Source.Items{evt.Source.Value};
            self.updateSettings();
        end

        function numLevelsCallback(self,~,evt)
            if evt.Value>=1
                self.NumLevels=evt.Value;
                validateNumLevels(self);
            else
                evt.Source.Value=evt.PreviousValue;
            end
        end

        function scaleFactorCallback(self,~,evt)
            if evt.Value>1&&isfinite(evt.Value)
                self.ScaleFactor=evt.Value;
                validateNumLevels(self);
            else
                evt.Source.Value=evt.PreviousValue;
            end
        end

        function validateNumLevels(self)

            MaxNumLevels=uint8(floor((log(self.MinSize)-log(31*2+1))/log(double(self.ScaleFactor)))+1);

            if self.NumLevels>MaxNumLevels
                self.NumLevels=MaxNumLevels;
                self.hNumLevels.Value=double(MaxNumLevels);
            end

            if MaxNumLevels==1
                self.hNumLevels.Enable='off';
            else
                self.hNumLevels.Limits=double([1,MaxNumLevels]);
                self.hNumLevels.Enable='on';
            end

            updateSettings(self);

        end

    end

    methods

        function set.Tform(self,inputString)
            idx=find(strcmpi(self.TformList,inputString));%#ok<MCSUP>
            set(self.hTransformType,'Value',idx);%#ok<MCSUP>
            self.Tform=lower(inputString);
        end

    end

end

