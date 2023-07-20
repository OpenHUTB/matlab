classdef LoadImagesDialog<images.internal.app.utilities.OkCancelDialog





    properties

loadImagesPanel
movingImagePathBox
movingImageBrowseButton

fixedImagePathBox
fixedImageBrowseButton

movingImageDetailPanel
movingDefaultReferencingButton
movingIncludeDICOMRadioButton
movingSpatialReferencingWKSpaceButton
movingSpatialReferencingDropdownButton
movingTransformationObjectDropdownButton

fixedImageDetailPanel
fixedDefaultReferencingButton
fixedIncludeDICOMRadioButton
fixedSpatialReferencingWKSpaceButton
fixedSpatialReferencingDropdownButton

statusText

        isFixedValid=false;
        isMovingValid=false;
        isFixedDICOM=false;
        isMovingDICOM=false;

movingImage
fixedImage
fixedReferenceObjects
fixedReferenceObject
movingReferenceObjects
movingReferenceObject
movingTransform
wkspaceTforms

preloadCheckbox
        preloadTechniques=true;

        userLoadedTransform=false;
        userLoadedFixedRefObj=false;
        userLoadedMovingRefObj=false;

isFixedRGB
isMovingRGB
isFixedNormalized
isMovingNormalized

RGBImage

        titleString='';
movingFileName
fixedFileName

AppFigure
App
    end

    properties(Constant)

        allowedExtensions='*.bmp;*.jpg;*.jpeg;*.tif;*.tiff;*.png;*.dcm*.BMP*.JPG*.JPEG*.TIF*.TIFF*.PNG*.DCM';

        smallestDim=16;
    end

    methods

        function self=LoadImagesDialog(loc,hfig,app)

            self=self@images.internal.app.utilities.OkCancelDialog(loc,...
            images.internal.app.registration.ui.getMessageString('loadDialog'));

            self.AppFigure=hfig;
            self.App=app;

            self.Size=[500,420];

            create(self);

        end

        function create(self)

            create@images.internal.app.utilities.OkCancelDialog(self);

            import images.internal.app.registration.ui.*;

            self.loadImagesPanel=uipanel('Parent',self.FigureHandle,...
            'Title',getMessageString('loadImages'),...
            'Units','pixels',...
            'FontName','Helvetica',...
            'FontSize',12,...
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
            'Tag','preloadCheckBoxFile',...
            'Text',getMessageString('preload'));

            set(self.statusText,'FontColor','red');
            set(self.Ok,'Enable','Off');

            set(self.Ok,'Position',[350,10,60,20]);
            set(self.Cancel,'Position',[430,10,60,20]);

            set(self.movingImagePathBox,'Value','');
            set(self.fixedImagePathBox,'Value','');

        end

    end

    methods(Access=protected)

        function okClicked(self)

            if strcmp(get(self.Ok,'Enable'),'off')
                return;
            end

            import images.internal.app.registration.ui.*;

            set(self.FigureHandle,'Visible','off');

            fixedImagePath=get(self.fixedImagePathBox,'Value');
            movingImagePath=get(self.movingImagePathBox,'Value');


            if(strcmp(fixedImagePath,movingImagePath))
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
            elseif(get(self.fixedIncludeDICOMRadioButton,'Value'))
                m=dicominfo(fixedImagePath);

                if isfield(m,'ImagePositionPatient')&&isfield(m,'PixelSpacing')
                    xStart=m.ImagePositionPatient(1);
                    yStart=m.ImagePositionPatient(2);
                    xSpacing=m.PixelSpacing(1);
                    ySpacing=m.PixelSpacing(2);

                    self.fixedReferenceObject=imref2d([m.Rows,m.Columns],...
                    double([xStart,xStart+xSpacing*m.Columns]),...
                    double([yStart,yStart+ySpacing*m.Rows]));
                else
                    self.fixedReferenceObject=imref2d([m.Rows,m.Columns]);
                end

                self.userLoadedFixedRefObj=true;
            else
                self.fixedReferenceObject=imref2d(size(self.fixedImage));
                self.userLoadedFixedRefObj=false;
            end

            if(get(self.movingSpatialReferencingWKSpaceButton,'Value'))&&(~strcmp(get(self.movingSpatialReferencingDropdownButton,'Value'),self.movingReferenceObjects{1}))
                movingReferenceName=get(self.movingSpatialReferencingDropdownButton,'Value');
                self.movingReferenceObject=evalin('base',movingReferenceName);
                self.userLoadedMovingRefObj=true;
            elseif(get(self.movingIncludeDICOMRadioButton,'Value'))
                m=dicominfo(movingImagePath);

                if isfield(m,'ImagePositionPatient')&&isfield(m,'PixelSpacing')
                    xStart=m.ImagePositionPatient(1);
                    yStart=m.ImagePositionPatient(2);
                    xSpacing=m.PixelSpacing(1);
                    ySpacing=m.PixelSpacing(2);

                    self.movingReferenceObject=imref2d([m.Rows,m.Columns],...
                    double([xStart,xStart+xSpacing*m.Columns]),...
                    double([yStart,yStart+ySpacing*m.Rows]));
                else
                    self.movingReferenceObject=imref2d([m.Rows,m.Columns]);
                end

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

        function browseFixedImage(self,~)

            import images.internal.app.registration.ui.*;

            [pathstr,~,~]=fileparts(get(self.fixedImagePathBox,'Value'));
            s=settings;
            if isempty(pathstr)
                pathstr=s.images.imageregistrationtool.fixedFileLocation.ActiveValue;
                if isempty(pathstr)
                    pathstr=pwd;
                end
            end

            imageFileTypes=[pathstr,filesep,self.allowedExtensions];
            [fixedImageFileName,fixedPathName]=uigetfile(imageFileTypes,getMessageString('chooseFixed'));
            if fixedImageFileName~=0
                fixedImagePath=[fixedPathName,fixedImageFileName];
                set(self.fixedImagePathBox,'Value',fixedImagePath);
                s.images.imageregistrationtool.fixedFileLocation.PersonalValue=fixedPathName;

                self.validateFixed(fixedImagePath);
                self.fixedFileName=fixedImageFileName;

                if self.isFixedDICOM

                    set(self.fixedIncludeDICOMRadioButton,'Enable','on');
                    set(self.fixedSpatialReferencingDropdownButton,'Enable','off');
                    set(self.fixedIncludeDICOMRadioButton,'Value',1);
                else
                    set(self.fixedIncludeDICOMRadioButton,'Enable','off');
                    if get(self.fixedIncludeDICOMRadioButton,'Value')
                        set(self.fixedDefaultReferencingButton,'Value',1);
                    end
                end



                if~self.isMovingValid
                    set(self.movingImagePathBox,'Value',fixedPathName);
                end

                self.approveUserInputs();
            end

            if ispc||ismac
                bringToFront(self.App);
                figure(self.FigureHandle);
            end

        end

        function browseMovingImage(self,~)

            import images.internal.app.registration.ui.*;

            [pathstr,~,~]=fileparts(get(self.movingImagePathBox,'Value'));
            s=settings;
            if isempty(pathstr)
                pathstr=s.images.imageregistrationtool.movingFileLocation.ActiveValue;
                if isempty(pathstr)
                    pathstr=pwd;
                end
            end

            imageFileTypes=[pathstr,filesep,self.allowedExtensions];
            [movingImageFileName,movingPathName]=uigetfile(imageFileTypes,getMessageString('chooseMoving'));

            if movingImageFileName~=0
                movingImagePath=[movingPathName,movingImageFileName];
                set(self.movingImagePathBox,'Value',movingImagePath);
                s.images.imageregistrationtool.movingFileLocation.PersonalValue=movingPathName;

                self.validateMoving(movingImagePath);
                self.movingFileName=movingImageFileName;

                if self.isMovingDICOM

                    set(self.movingIncludeDICOMRadioButton,'Enable','on');
                    set(self.movingSpatialReferencingDropdownButton,'Enable','off');
                    set(self.movingIncludeDICOMRadioButton,'Value',1);
                else
                    set(self.movingIncludeDICOMRadioButton,'Enable','off');
                    if get(self.movingIncludeDICOMRadioButton,'Value')
                        set(self.movingDefaultReferencingButton,'Value',1);
                    end
                end



                if~self.isFixedValid
                    set(self.fixedImagePathBox,'Value',movingPathName);
                end

                self.approveUserInputs();
            end

            if ispc||ismac
                bringToFront(self.App);
                figure(self.FigureHandle);
            end

        end



        function setupLoadImagesPanel(self)

            import images.internal.app.registration.ui.*;


            uilabel('Parent',self.loadImagesPanel,...
            'Position',[5,65,100,20],...
            'HorizontalAlignment','left',...
            'Tag','tagmovingImageLabel',...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Text',getMessageString('movingImage'));


            self.movingImagePathBox=uieditfield('Parent',self.loadImagesPanel,...
            'Position',[5,45,390,20],...
            'Value','',...
            'FontName','Helvetica',...
            'FontSize',12,...
            'HorizontalAlignment','left',...
            'ValueChangedFcn',@(~,~)self.movingPathBoxCB,...
            'Tag','tagmovingImagePathBox');


            self.movingImageBrowseButton=uibutton('Parent',self.loadImagesPanel,...
            'Position',[400,45,85,20],...
            'ButtonPushedFcn',@(~,~)self.browseMovingImage,...
            'Text',getMessageString('browse'),...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Icon',fullfile(matlabroot,'toolbox','shared','controllib','general','resources','toolstrip_icons','Open_16.png'),...
            'Tag','tagmovingImageBrowseButton');


            uilabel('Parent',self.loadImagesPanel,...
            'Position',[5,25,100,20],...
            'HorizontalAlignment','left',...
            'Tag','tagfixedImageLabel',...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Text',getMessageString('fixedImage'));


            self.fixedImagePathBox=uieditfield('Parent',self.loadImagesPanel,...
            'Position',[5,5,390,20],...
            'Value','',...
            'HorizontalAlignment','left',...
            'FontName','Helvetica',...
            'FontSize',12,...
            'ValueChangedFcn',@(~,~)self.fixedPathBoxCB,...
            'Tag','tagfixedImagePathBox');


            self.fixedImageBrowseButton=uibutton('Parent',self.loadImagesPanel,...
            'Position',[400,5,85,20],...
            'ButtonPushedFcn',@(~,~)self.browseFixedImage,...
            'Text',getMessageString('browse'),...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Icon',fullfile(matlabroot,'toolbox','shared','controllib','general','resources','toolstrip_icons','Open_16.png'),...
            'Tag','tagfixedImageBrowseButton');
        end

        function movingPathBoxCB(self,~)

            import images.internal.app.registration.ui.*;

            imagePath=get(self.movingImagePathBox,'Value');

            self.validateMoving(imagePath);

            if self.isMovingDICOM

                set(self.movingIncludeDICOMRadioButton,'Enable','on');
                set(self.movingSpatialReferencingDropdownButton,'Enable','off');
                set(self.movingIncludeDICOMRadioButton,'Value',1);
            else
                set(self.movingIncludeDICOMRadioButton,'Enable','off');
                if get(self.movingIncludeDICOMRadioButton,'Value')
                    set(self.movingDefaultReferencingButton,'Value',1);
                end
            end

            self.approveUserInputs();
        end

        function fixedPathBoxCB(self,~)

            import images.internal.app.registration.ui.*;

            imagePath=get(self.fixedImagePathBox,'Value');

            self.validateFixed(imagePath);

            if self.isFixedDICOM

                set(self.fixedIncludeDICOMRadioButton,'Enable','on');
                set(self.movingSpatialReferencingDropdownButton,'Enable','off');
                set(self.fixedIncludeDICOMRadioButton,'Value',1);
            else
                set(self.fixedIncludeDICOMRadioButton,'Enable','off');
                if get(self.fixedIncludeDICOMRadioButton,'Value')
                    set(self.fixedDefaultReferencingButton,'Value',1);
                end
            end

            self.approveUserInputs();
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
            'Position',[5,90,225,20],...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Tag','tagmovingDefaultReferencingButton',...
            'HandleVisibility','off');

            self.movingIncludeDICOMRadioButton=uiradiobutton(movingImageDetailButtonGroup,...
            'Text',getMessageString('dicomMeta'),...
            'Position',[5,65,225,20],...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Tag','tagmovingIncludeDICOMRadioButton',...
            'HandleVisibility','off');

            set(self.movingIncludeDICOMRadioButton,'Enable','off');

            self.movingSpatialReferencingWKSpaceButton=uiradiobutton(movingImageDetailButtonGroup,...
            'Text',getMessageString('spatialRefObject'),...
            'Position',[5,40,225,20],...
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
            'Position',[5,90,225,20],...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Tag','tagfixedDefaultReferencingButton',...
            'HandleVisibility','off');

            self.fixedIncludeDICOMRadioButton=uiradiobutton(fixedImageDetailButtonGroup,...
            'Text',getMessageString('dicomMeta'),...
            'Position',[5,65,225,20],...
            'FontName','Helvetica',...
            'FontSize',12,...
            'Tag','tagfixedIncludeDICOMRadioButton',...
            'HandleVisibility','off');

            set(self.fixedIncludeDICOMRadioButton,'Enable','off');

            self.fixedSpatialReferencingWKSpaceButton=uiradiobutton(fixedImageDetailButtonGroup,...
            'Text',getMessageString('spatialRefObject'),...
            'Position',[5,40,225,20],...
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

        function validateFixed(self,imagePath)
            TF=exist(imagePath,'file')==2;
            if TF
                try
                    self.fixedImage=imread(imagePath);
                catch
                    [TF,self.fixedImage]=isDICOM(imagePath);
                    self.isFixedDICOM=TF;
                end
            else
                TF=false;
            end
            isLargeEnough=((size(self.fixedImage,1)>=self.smallestDim)&&(size(self.fixedImage,2)>=self.smallestDim));
            self.isFixedValid=TF&&isLargeEnough;
        end

        function validateMoving(self,imagePath)
            TF=exist(imagePath,'file')==2;
            if TF
                try
                    self.movingImage=imread(imagePath);
                catch
                    [TF,self.movingImage]=isDICOM(imagePath);
                    self.isMovingDICOM=TF;
                end
            else
                TF=false;
            end
            isLargeEnough=((size(self.movingImage,1)>self.smallestDim)&&(size(self.movingImage,2)>self.smallestDim));
            self.isMovingValid=TF&&isLargeEnough;
        end

        function TF=validateFixedRefObj(self)
            if get(self.fixedSpatialReferencingWKSpaceButton,'Value')&&(~isempty(get(self.fixedImagePathBox,'Value')))
                fixRefObjIndex=get(self.fixedSpatialReferencingDropdownButton,'Value');
                if~strcmp(fixRefObjIndex,self.fixedReferenceObjects{1})
                    fixRefObject=evalin('base',fixRefObjIndex);
                    TF=(~isempty(fixRefObject)&&isequal(size(self.fixedImage),fixRefObject.ImageSize));
                else
                    TF=true;
                end
            else
                TF=true;
            end
        end

        function TF=validateMovingRefObj(self)
            if get(self.movingSpatialReferencingWKSpaceButton,'Value')&&(~isempty(get(self.movingImagePathBox,'Value')))
                movRefObjIndex=get(self.movingSpatialReferencingDropdownButton,'Value');
                if~strcmp(movRefObjIndex,self.movingReferenceObjects{1})
                    movRefObject=evalin('base',movRefObjIndex);
                    TF=(~isempty(movRefObject)&&isequal(size(self.movingImage),movRefObject.ImageSize));
                else
                    TF=true;
                end
            else
                TF=true;
            end
        end

        function approveUserInputs(self)
            if self.isMovingValid&&self.isFixedValid
                if self.validateFixedRefObj()&&self.validateMovingRefObj()
                    self.createTitleString();
                    set(self.Ok,'Enable','on');
                    set(self.statusText,'Text','');
                else
                    set(self.Ok,'Enable','off');
                    set(self.statusText,'Text',images.internal.app.registration.ui.getMessageString('RefObjsMustMatch'));
                end
            else
                set(self.Ok,'Enable','Off');
                set(self.statusText,'Text',images.internal.app.registration.ui.getMessageString('specifyGrayOrColor'));
            end

        end

        function createTitleString(self)

            import images.internal.app.registration.ui.getMessageString
            if~isempty(self.movingFileName)&&~isempty(self.fixedFileName)
                self.titleString=[self.movingFileName,' (',getMessageString('movingImage'),') & ',...
                self.fixedFileName,' (',getMessageString('fixedImage'),')'];
            end

        end

    end

end

function[TF,im]=isDICOM(imagePath)
    im=[];
    if~isempty(imagePath)
        TF=strcmp(imagePath(end-3:end),'.dcm')||strcmp(imagePath(end-3:end),'.DCM');
        if TF
            try
                im=dicomread(imagePath);
                TF=ismatrix(im);
            catch
                TF=false;
            end
        end
    else
        TF=false;
    end
end

