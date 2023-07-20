classdef LoadFromWorkspace<images.internal.app.utilities.OkCancelDialog





    properties

loadImagesPanel
movingImagePathBox
movingImageBrowseButton

fixedImagePathBox
fixedImageBrowseButton

movingImageDetailPanel
movingDefaultReferencingButton
movingSpatialReferencingWKSpaceButton
movingSpatialReferencingDropdownButton
movingTransformationObjectDropdownButton

fixedImageDetailPanel
fixedDefaultReferencingButton
fixedSpatialReferencingWKSpaceButton
fixedSpatialReferencingDropdownButton

statusText

images
movingImage
fixedImage
fixedReferenceObjects
fixedReferenceObject
movingReferenceObjects
movingReferenceObject
movingTransform
wkspaceTforms

        userLoadedTransform=false;
        userLoadedFixedRefObj=false;
        userLoadedMovingRefObj=false;

isFixedRGB
isMovingRGB
isFixedNormalized
isMovingNormalized

preloadCheckbox
        preloadTechniques=true;

RGBImage

        titleString='';
movingFileName
fixedFileName

AppFigure
    end

    properties(Constant)

        smallestDim=16;
    end

    methods

        function self=LoadFromWorkspace(loc,hfig)

            self=self@images.internal.app.utilities.OkCancelDialog(loc,...
            images.internal.app.registration.ui.getMessageString('loadDialog'));

            self.AppFigure=hfig;

            self.Size=[500,420];

            create(self);

        end

        function create(self)

            create@images.internal.app.utilities.OkCancelDialog(self);

            import images.internal.app.registration.ui.*;

            self.loadImagesPanel=uipanel('Parent',self.FigureHandle,...
            'Title',getMessageString('loadImages'),...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Units','pixels',...
            'Position',[6,310,490,105]);

            self.setupLoadImagesPanel();

            self.movingImageDetailPanel=uipanel('Parent',self.FigureHandle,...
            'Title',getMessageString('movingImage'),...
            'Units','pixels',...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Position',[6,70,242,235]);

            self.setupMovingImageDetailPanel();

            self.fixedImageDetailPanel=uipanel('Parent',self.FigureHandle,...
            'Title',getMessageString('fixedImage'),...
            'Units','pixels',...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Position',[253,70,243,235]);

            self.setupFixedImageDetailPanel();

            self.statusText=uilabel('Parent',self.FigureHandle,...
            'Position',[6,10,330,20],...
            'HorizontalAlignment','left',...
            'VerticalAlignment','bottom',...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Tag','statusText',...
            'Text',getMessageString('specifyGrayOrColor'));

            self.preloadCheckbox=uicheckbox('Parent',self.FigureHandle,...
            'Position',[6,40,330,20],...
            'Value',1,...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Tag','preloadCheckBoxWS',...
            'Text',getMessageString('preload'));

            set(self.Ok,'Position',[350,10,60,20]);
            set(self.Cancel,'Position',[430,10,60,20]);

            set(self.statusText,'FontColor','red');
            set(self.Ok,'Enable','Off');

        end

    end

    methods(Access=protected)

        function okClicked(self)

            if strcmp(get(self.Ok,'Enable'),'off')
                return;
            end

            import images.internal.app.registration.ui.*;

            set(self.FigureHandle,'Visible','off');

            fixedIdx=get(self.fixedImagePathBox,'Value');
            movingIdx=get(self.movingImagePathBox,'Value');
            self.fixedImage=evalin('base',fixedIdx);
            self.movingImage=evalin('base',movingIdx);


            if strcmp(fixedIdx,movingIdx)
                sameImageFlag=true;
            else
                sameImageFlag=false;
            end


            [self.fixedImage,self.movingImage,self.isFixedRGB,self.isMovingRGB,self.isFixedNormalized,self.isMovingNormalized,self.RGBImage]=...
            preprocessImageDialog(self.fixedImage,self.movingImage,sameImageFlag,self.AppFigure);

            if(get(self.fixedSpatialReferencingWKSpaceButton,'Value'))&&(~strcmp(get(self.fixedSpatialReferencingDropdownButton,'Value'),self.fixedReferenceObjects{1}))
                fixedReferenceName=get(self.fixedSpatialReferencingDropdownButton,'Value');
                self.fixedReferenceObject=evalin('base',fixedReferenceName);
                self.userLoadedFixedRefObj=true;
            else
                self.fixedReferenceObject=imref2d(size(self.fixedImage));
                self.userLoadedFixedRefObj=false;
            end

            if(get(self.movingSpatialReferencingWKSpaceButton,'Value'))&&(~strcmp(get(self.movingSpatialReferencingDropdownButton,'Value'),self.movingReferenceObjects{1}))
                movingReferenceName=get(self.movingSpatialReferencingDropdownButton,'Value');
                self.movingReferenceObject=evalin('base',movingReferenceName);
                self.userLoadedMovingRefObj=true;
            else
                self.movingReferenceObject=imref2d(size(self.movingImage));
                self.userLoadedMovingRefObj=false;
            end

            movingTformName=get(self.movingTransformationObjectDropdownButton,'Value');
            if strcmp(movingTformName,self.wkspaceTforms{1})
                self.movingTransform=affine2d();
                self.userLoadedTransform=false;
            else
                self.movingTransform=evalin('base',movingTformName);
                self.userLoadedTransform=true;
            end

            self.preloadTechniques=self.preloadCheckbox.Value;

            self.Canceled=false;
            close(self);

        end


        function keyPress(self,evt)

            switch(evt.Key)
            case 'escape'
                cancelClicked(self);
            end

        end

        function setupLoadImagesPanel(self)

            import images.internal.app.registration.ui.*;


            uilabel('Parent',self.loadImagesPanel,...
            'Position',[10,50,100,20],...
            'HorizontalAlignment','right',...
            'Tag','tagmovingImageLabel',...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Text',getMessageString('movingImage'));


            wkspaceVars=evalin('base','whos');
            self.images={''};

            for idx=1:numel(wkspaceVars)
                if self.isImageValid(wkspaceVars(idx).name)
                    self.images{end+1}=wkspaceVars(idx).name;
                end
            end

            self.movingImagePathBox=uidropdown('Parent',self.loadImagesPanel,...
            'Position',[120,50,100,20],...
            'Items',self.images,...
            'FontName','Helvetica',...
            'FontSize',12,...
            'ValueChangedFcn',@(~,~)self.approveUserInputs(),...
            'Tag','tagmovingImagePathBox');


            uilabel('Parent',self.loadImagesPanel,...
            'Position',[10,15,100,20],...
            'HorizontalAlignment','right',...
            'Tag','tagfixedImageLabel',...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Text',getMessageString('fixedImage'));


            self.fixedImagePathBox=uidropdown('Parent',self.loadImagesPanel,...
            'Position',[120,15,100,20],...
            'Items',self.images,...
            'FontName','Helvetica',...
            'FontSize',12,...
            'ValueChangedFcn',@(~,~)self.approveUserInputs(),...
            'Tag','tagfixedImagePathBox');

            set(self.movingImagePathBox,'Enable','on');
            set(self.fixedImagePathBox,'Enable','on');
        end

        function setupMovingImageDetailPanel(self)

            import images.internal.app.registration.ui.*;


            uilabel('Parent',self.movingImageDetailPanel,...
            'Position',[5,195,225,20],...
            'HorizontalAlignment','left',...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Tag','tagmovingImageSpatialRefTextBox',...
            'Text',getMessageString('spatialRefInfo'));

            movingImageDetailButtonGroup=uibuttongroup('Parent',self.movingImageDetailPanel,...
            'Visible','off',...
            'Units','pixels',...
            'Position',[5,80,232,115],...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Tag','tagmovingImageDetailButtonGroup',...
            'SelectionChangedFcn',@self.bselectionMoving);

            self.movingDefaultReferencingButton=uiradiobutton(movingImageDetailButtonGroup,...
            'Text',getMessageString('defaultSpatialRefInfo'),...
            'Position',[5,80,225,20],...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Tag','tagmovingDefaultReferencingButton',...
            'HandleVisibility','off');

            self.movingSpatialReferencingWKSpaceButton=uiradiobutton(movingImageDetailButtonGroup,...
            'Text',getMessageString('spatialRefObject'),...
            'Position',[5,45,225,20],...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Tag','tagmovingSpatialReferencingWKSpaceButton',...
            'HandleVisibility','off');

            noRefObjs=false;
            self.movingReferenceObjects=getVariableList({'imref2d'});

            if(numel(self.movingReferenceObjects)==1)
                self.movingReferenceObjects={''};
                noRefObjs=true;
            end

            self.movingSpatialReferencingDropdownButton=uidropdown('Parent',movingImageDetailButtonGroup,...
            'Items',self.movingReferenceObjects,...
            'Tag','tagmovingSpatialReferencingDropdownButton',...
            'Position',[100,15,100,20],...
            'FontName','Helvetica',...
            'FontSize',12,...
            'ValueChangedFcn',@(~,~)self.approveUserInputs());
            set(self.movingSpatialReferencingDropdownButton,'Enable','off');


            if noRefObjs
                set(self.movingSpatialReferencingWKSpaceButton,'Enable','off');
            end

            movingImageDetailButtonGroup.Visible='on';


            uilabel('Parent',self.movingImageDetailPanel,...
            'Position',[5,45,225,20],...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Tag','tagmovingTransformationObjectTextBox',...
            'HorizontalAlignment','left',...
            'Text',getMessageString('initialTForm'));


            noTforms=false;
            self.wkspaceTforms=getVariableList({'affine2d','projective2d'});

            if(numel(self.wkspaceTforms)==1)
                noTforms=true;
            end

            self.movingTransformationObjectDropdownButton=uidropdown('Parent',self.movingImageDetailPanel,...
            'Items',self.wkspaceTforms,...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Tag','tagmovingTransformationObjectDropdownButton',...
            'Position',[100,15,100,20]);


            if(noTforms)
                set(self.movingTransformationObjectDropdownButton,'Enable','Off');
            else
                set(self.movingTransformationObjectDropdownButton,'Value',self.wkspaceTforms{1});
            end

        end

        function setupFixedImageDetailPanel(self)

            import images.internal.app.registration.ui.*;


            uilabel('Parent',self.fixedImageDetailPanel,...
            'Position',[5,195,232,20],...
            'HorizontalAlignment','left',...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Tag','tagfixedImageSpatialRefTextBox',...
            'Text',getMessageString('spatialRefInfo'));

            fixedImageDetailButtonGroup=uibuttongroup('Parent',self.fixedImageDetailPanel,...
            'Visible','off',...
            'Units','pixels',...
            'Position',[5,80,233,115],...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Tag','tagfixedImageDetailButtonGroup',...
            'SelectionChangedFcn',@self.bselectionFixed);

            self.fixedDefaultReferencingButton=uiradiobutton(fixedImageDetailButtonGroup,...
            'Text',getMessageString('defaultSpatialRefInfo'),...
            'Position',[5,80,225,20],...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Tag','tagfixedDefaultReferencingButton',...
            'HandleVisibility','off');

            self.fixedSpatialReferencingWKSpaceButton=uiradiobutton(fixedImageDetailButtonGroup,...
            'Text',getMessageString('spatialRefObject'),...
            'Position',[5,45,225,20],...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Tag','tagfixedSpatialReferencingWKSpaceButton',...
            'HandleVisibility','off');

            noRefObjs=false;
            self.fixedReferenceObjects=getVariableList({'imref2d'});

            if(numel(self.fixedReferenceObjects)==1)
                self.fixedReferenceObjects={''};
                noRefObjs=true;
            end

            self.fixedSpatialReferencingDropdownButton=uidropdown('Parent',fixedImageDetailButtonGroup,...
            'Items',self.fixedReferenceObjects,...
            'Tag','tagfixedSpatialReferencingDropdownButton',...
            'Position',[100,15,100,20],...
            'FontName','Helvetica',...
            'FontSize',12,...
            'ValueChangedFcn',@(~,~)self.approveUserInputs());
            set(self.fixedSpatialReferencingDropdownButton,'Enable','off');


            if noRefObjs
                set(self.fixedSpatialReferencingWKSpaceButton,'Enable','off');
            end

            fixedImageDetailButtonGroup.Visible='on';
        end

        function bselectionFixed(self,~,~)
            if(get(self.fixedSpatialReferencingWKSpaceButton,'Value')==1)&&~isempty(self.fixedReferenceObjects{1})
                set(self.fixedSpatialReferencingDropdownButton,'Enable','on');
            else
                set(self.fixedSpatialReferencingDropdownButton,'Enable','off');
            end
            self.approveUserInputs();
        end

        function bselectionMoving(self,~,~)
            if(get(self.movingSpatialReferencingWKSpaceButton,'Value')==1)&&~isempty(self.movingReferenceObjects{1})
                set(self.movingSpatialReferencingDropdownButton,'Enable','on');
            else
                set(self.movingSpatialReferencingDropdownButton,'Enable','off');
            end
            self.approveUserInputs();
        end

        function TF=validateFixedRefObj(self)
            if get(self.fixedSpatialReferencingWKSpaceButton,'Value')&&(~isempty(get(self.fixedImagePathBox,'Value')))
                fixImage=evalin('base',get(self.fixedImagePathBox,'Value'));
                fixRefObjIndex=get(self.fixedSpatialReferencingDropdownButton,'Value');
                if~strcmp(fixRefObjIndex,self.fixedReferenceObjects{1})
                    fixRefObject=evalin('base',fixRefObjIndex);
                    TF=(~isempty(fixRefObject)&&isequal(size(fixImage),fixRefObject.ImageSize));
                else
                    TF=true;
                end
            else
                TF=true;
            end
        end

        function TF=validateMovingRefObj(self)
            if get(self.movingSpatialReferencingWKSpaceButton,'Value')&&(~isempty(get(self.movingImagePathBox,'Value')))
                movImage=evalin('base',get(self.movingImagePathBox,'Value'));
                movRefObjIndex=get(self.movingSpatialReferencingDropdownButton,'Value');
                if~strcmp(movRefObjIndex,self.movingReferenceObjects{1})
                    movRefObject=evalin('base',movRefObjIndex);
                    TF=(~isempty(movRefObject)&&isequal(size(movImage),movRefObject.ImageSize));
                else
                    TF=true;
                end
            else
                TF=true;
            end
        end

        function approveUserInputs(self)
            fixedIdx=get(self.fixedImagePathBox,'Value');
            movingIdx=get(self.movingImagePathBox,'Value');
            if self.isImageValid(fixedIdx)&&self.isImageValid(movingIdx)
                self.movingFileName=movingIdx;
                self.fixedFileName=fixedIdx;
                if self.validateFixedRefObj()&&self.validateMovingRefObj()
                    self.createTitleString();
                    set(self.Ok,'Enable','on');
                    set(self.statusText,'Text','');
                else
                    set(self.Ok,'Enable','off');
                    set(self.statusText,'Text',images.internal.app.registration.ui.getMessageString('RefObjsMustMatch'));%#ok<PROP>
                end
            else
                set(self.Ok,'Enable','Off');
                set(self.statusText,'Text',images.internal.app.registration.ui.getMessageString('specifyGrayOrColor'));%#ok<PROP>
            end

        end


        function createTitleString(self)
            import images.internal.app.registration.ui.getMessageString
            if~isempty(self.movingFileName)&&~isempty(self.fixedFileName)
                self.titleString=[self.movingFileName,' (',getMessageString('movingImage'),') & ',...
                self.fixedFileName,' (',getMessageString('fixedImage'),')'];
            end
        end

        function TF=isImageValid(self,objName)
            try
                entry=evalin('base',objName);

                isSizeOK=(ndims(entry)<4&&(size(entry,1)>=self.smallestDim)&&(size(entry,2)>=self.smallestDim)&&(size(entry,3)==1||size(entry,3)==3));
                isTypeOK=(isa(entry,'uint8')||isa(entry,'uint16')||isa(entry,'int16')||isa(entry,'single')||isa(entry,'double')||islogical(entry))&&isreal(entry);
                if isSizeOK&&isTypeOK
                    TF=true;
                else
                    TF=false;
                end
            catch
                TF=false;
            end
        end

    end

end
