classdef(StrictDefaults)ROISelector<matlab.System



























































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)



        VerticalReuse(1,1)logical=false;




        RegionsSource='Property';





        NumberOfRegions=1;





        Regions=[100,100,50,50];
    end

    properties(Constant,Hidden)
        RegionsSourceSet=matlab.system.StringSet({...
        'Property',...
        'Input port'});
    end

    properties(Access=private)
        InputDataReg;
        InputDataPreReg;
        InputControlReg;
        InputControlPreReg;
        HCount;
        VCount;
        InFrame;
        InLine;
        InFramePrev;
        InLinePrev;
        ValidPrev;

        VstartBuf;
        VstartBufPrev;


        VendFinal;
        VendPrev;
        RegionRegs;
        OutputDataRegs;
        OutputControlRegs;

        VIndex;


        SortedRegions;
    end

    properties(Access=private,Nontunable)
        PrivNRegions;

        NumVTiles;

        NumPix;
    end

    methods
        function obj=ROISelector(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Vision_HDL_Toolbox'))
                    error(message('visionhdl:visionhdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Vision_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:});
        end

        function set.NumberOfRegions(obj,val)
            validateattributes(val,...
            {'numeric'},{'scalar','integer','real','>=',1,'<=',16},'ROISelector','NumberOfRegions');
            obj.NumberOfRegions=val;
        end

        function set.Regions(obj,val)
            validateattributes(val,...
            {'numeric'},{'ncols',4},'ROISelector','Regions');
            validateattributes(val,...
            {'numeric'},{'real','integer','>=',1},'ROISelector','Regions');
            obj.Regions=val;
        end

        function set.VerticalReuse(obj,val)
            validateattributes(val,...
            {'logical'},{},'ROISelector','VerticalReuse');

            obj.VerticalReuse=val;
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('visionhdl.ROISelector',...
            'ShowSourceLink',false,...
            'Title','ROI Selector');
        end

        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop

            case 'RegionsSource'
                if obj.VerticalReuse
                    flag=true;
                end


            case 'Regions'
                if strcmp(obj.RegionsSource,'Input port')
                    if obj.VerticalReuse
                        flag=false;
                    else
                        flag=true;
                    end
                end


            case 'NumberOfRegions'
                if strcmp(obj.RegionsSource,'Property')
                    flag=true;
                end
                if obj.VerticalReuse
                    flag=true;
                end

            case 'VerticalReuse'
                if strcmp(obj.RegionsSource,'Input port')
                    flag=true;
                end
            end
        end

        function validateInputsImpl(~,pixelIn,ctrlIn,varargin)

            if isempty(coder.target)||~eml_ambiguous_types



                validateattributes(pixelIn,{'numeric','embedded.fi','logical'},...
                {'real','nonnan','finite'},'ROISelector','pixel input');

                if~ismember(size(pixelIn,1),[1,4,8])
                    coder.internal.error('visionhdl:ROISelector:InputDimensions');
                end

                if~ismember(size(pixelIn,2),[1,3,4])
                    coder.internal.error('visionhdl:ROISelector:UnsupportedComps');
                end

                validatecontrolsignals(ctrlIn);
            end

        end

        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                if~isempty(findprop(obj,fn{ii}))
                    obj.(fn{ii})=s.(fn{ii});
                end
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);
            if obj.isLocked
                s.InputDataReg=obj.InputDataReg;
                s.InputDataPreReg=obj.InputDataPreReg;
                s.InputControlReg=obj.InputControlReg;
                s.InputControlPreReg=obj.InputControlPreReg;
                s.HCount=obj.HCount;
                s.VCount=obj.VCount;
                s.InFrame=obj.InFrame;
                s.InLine=obj.InLine;
                s.InFramePrev=obj.InFramePrev;
                s.InLinePrev=obj.InLinePrev;
                s.ValidPrev=obj.ValidPrev;
                s.VstartBuf=obj.VstartBuf;
                s.VstartBufPrev=obj.VstartBufPrev;
                s.VendFinal=obj.VendFinal;
                s.VendPrev=obj.VendPrev;
                s.RegionRegs=obj.RegionRegs;
                s.OutputDataRegs=obj.OutputDataRegs;
                s.OutputControlRegs=obj.OutputControlRegs;
                s.VIndex=obj.VIndex;
                s.PrivNRegions=obj.PrivNRegions;
                s.NumVTiles=obj.NumVTiles;
                s.SortedRegions=obj.SortedRegions;
                s.NumPix=obj.NumPix;
            end
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end



        function setupImpl(obj,dataIn,~,varargin)
            if~coder.target('hdl')

                nPix=size(dataIn,1);
                if isempty(coder.target)


                    if obj.VerticalReuse
                        nRegs=sum(obj.Regions(:,2)==min(obj.Regions(:,2)));
                    else
                        if strcmp(obj.RegionsSource,'Property')
                            nRegs=size(obj.Regions,1);
                        else
                            nRegs=obj.NumberOfRegions;
                        end
                    end
                else
                    if obj.VerticalReuse
                        nRegs=coder.internal.const(sum(obj.Regions(:,2)==min(obj.Regions(:,2))));
                    else
                        if strcmp(obj.RegionsSource,'Property')
                            nRegs=coder.internal.const(size(obj.Regions,1));
                        else
                            nRegs=coder.internal.const(obj.NumberOfRegions);
                        end
                    end
                end
                obj.PrivNRegions=nRegs;
                obj.NumPix=nPix;

                if isempty(coder.target)
                    if obj.VerticalReuse
                        nVerTiles=(size(obj.Regions,1)/obj.PrivNRegions);
                    else
                        nVerTiles=0;
                    end
                else
                    if obj.VerticalReuse
                        nVerTiles=coder.internal.const((size(obj.Regions,1)/obj.PrivNRegions));
                    else
                        nVerTiles=coder.internal.const(0);
                    end
                end
                obj.NumVTiles=nVerTiles;

                if obj.VerticalReuse
                    sortedReg=uint32(sortRegions(obj));
                else
                    sortedReg=uint32(zeros(size(obj.Regions,1),size(obj.Regions,2)));
                end
                obj.SortedRegions=sortedReg;

                resetImpl(obj);
                if islogical(dataIn)
                    obj.InputDataPreReg=false(obj.NumPix,size(dataIn,2));
                    obj.InputDataReg=false(obj.NumPix,size(dataIn,2));
                    obj.OutputDataRegs=false(obj.NumPix,size(dataIn,2),obj.PrivNRegions);
                else
                    obj.InputDataPreReg=cast(zeros(obj.NumPix,size(dataIn,2)),'like',dataIn);
                    obj.InputDataReg=cast(zeros(obj.NumPix,size(dataIn,2)),'like',dataIn);
                    obj.OutputDataRegs=cast(zeros(obj.NumPix,size(dataIn,2),obj.PrivNRegions),'like',dataIn);
                end
                obj.InputControlPreReg=pixelcontrolstruct(false,false,false,false,false);
                obj.InputControlReg=pixelcontrolstruct(false,false,false,false,false);
                obj.OutputControlRegs=false(obj.PrivNRegions,5);
                obj.RegionRegs=zeros(obj.PrivNRegions,4,'uint32');


                if obj.NumPix>1&&(strcmp(obj.RegionsSource,'Property')||obj.VerticalReuse)
                    regInValid=true;
                    for regIndex=1:size(obj.Regions,1)
                        if~(mod(obj.Regions(regIndex,1),obj.NumPix)==1&&mod(obj.Regions(regIndex,3),obj.NumPix)==0)
                            regInValid=false;
                            break;
                        end
                    end
                    coder.internal.errorIf(~regInValid,'visionhdl:ROISelector:InvalidRegionsMP');
                end


                if strcmp(obj.RegionsSource,'Property')&&~obj.VerticalReuse


                    minhSizevSize=true;
                    for ii=1:size(obj.Regions,1)
                        obj.RegionRegs(ii,:)=uint32(obj.Regions(ii,:));
                        if(obj.RegionRegs(ii,3)<2||obj.RegionRegs(ii,4)<2)&&obj.NumPix==1
                            minhSizevSize=false;
                        end
                        coder.internal.errorIf(~minhSizevSize,'visionhdl:ROISelector:MinhSizevSize');
                        if obj.NumPix>1
                            minhSizevSizeMP=true;
                            if obj.RegionRegs(ii,3)<2*obj.NumPix||obj.RegionRegs(ii,4)<2
                                minhSizevSizeMP=false;
                            end
                            coder.internal.errorIf(~minhSizevSizeMP,'visionhdl:ROISelector:MinhSizevSize');


                            ScaledRegions=[max(1,(floor(obj.RegionRegs(ii,1)/obj.NumPix)+1)),obj.RegionRegs(ii,2),obj.RegionRegs(ii,3)/obj.NumPix,obj.RegionRegs(ii,4)];
                            obj.RegionRegs(ii,:)=ScaledRegions;
                        end
                    end
                end
            else


                nPix=size(dataIn,1);
                if isempty(coder.target)


                    nRegs=size(obj.Regions,1);
                else
                    nRegs=coder.internal.const(size(obj.Regions,1));
                end
                obj.PrivNRegions=nRegs;
                obj.NumPix=nPix;

                nVerTiles=0;

                obj.NumVTiles=nVerTiles;
                resetImpl(obj);
                if islogical(dataIn)
                    obj.InputDataPreReg=false(obj.NumPix,size(dataIn,2));
                    obj.InputDataReg=false(obj.NumPix,size(dataIn,2));
                    obj.OutputDataRegs=false(obj.NumPix,size(dataIn,2),obj.PrivNRegions);
                else
                    obj.InputDataPreReg=cast(zeros(obj.NumPix,size(dataIn,2)),'like',dataIn);
                    obj.InputDataReg=cast(zeros(obj.NumPix,size(dataIn,2)),'like',dataIn);
                    obj.OutputDataRegs=cast(zeros(obj.NumPix,size(dataIn,2),obj.PrivNRegions),'like',dataIn);
                end
                obj.InputControlPreReg=pixelcontrolstruct(false,false,false,false,false);
                obj.InputControlReg=pixelcontrolstruct(false,false,false,false,false);
                obj.OutputControlRegs=false(obj.PrivNRegions,5);
                obj.RegionRegs=zeros(obj.PrivNRegions,4,'uint32');

                if strcmp(obj.RegionsSource,'Property')


                    for ii=1:size(obj.Regions,1)
                        obj.RegionRegs(ii,:)=uint32(obj.Regions(ii,:));
                        if obj.NumPix>1


                            ScaledRegions=[max(1,(floor(obj.RegionRegs(ii,1)/obj.NumPix)+1)),obj.RegionRegs(ii,2),obj.RegionRegs(ii,3)/obj.NumPix,obj.RegionRegs(ii,4)];
                            obj.RegionRegs(ii,:)=ScaledRegions;
                        end
                    end
                end
            end
        end

        function resetImpl(obj)
            obj.HCount=uint32(0);
            obj.VCount=uint32(0);
            obj.VIndex=uint32(1);
            obj.InFrame=false;
            obj.InLine=false;
            obj.InFramePrev=false;
            obj.InLinePrev=false;
            obj.ValidPrev=false(obj.PrivNRegions,1);
            obj.VstartBuf=false(obj.PrivNRegions,1);
            obj.VstartBufPrev=false(obj.PrivNRegions,1);
            obj.VendFinal=false(obj.PrivNRegions,1);
            obj.VendPrev=false(obj.PrivNRegions,1);

        end

        function varargout=outputImpl(obj,~,~,varargin)

            if~coder.target('hdl')
                jj=1;
                for ii=1:2:(obj.PrivNRegions*2)
                    varargout{ii}=obj.OutputDataRegs(:,:,jj);
                    varargout{ii+1}=pixelcontrolstruct(obj.OutputControlRegs(jj,1),...
                    obj.OutputControlRegs(jj,2),...
                    obj.OutputControlRegs(jj,3),...
                    obj.OutputControlRegs(jj,4),...
                    obj.OutputControlRegs(jj,5));
                    jj=jj+1;
                end
            else

                jj=1;
                for ii=1:2:(obj.PrivNRegions*2)
                    varargout{ii}=obj.OutputDataRegs(:,:,jj);
                    varargout{ii+1}=pixelcontrolstruct(obj.OutputControlRegs(jj,1),...
                    obj.OutputControlRegs(jj,2),...
                    obj.OutputControlRegs(jj,3),...
                    obj.OutputControlRegs(jj,4),...
                    obj.OutputControlRegs(jj,5));
                    jj=jj+1;
                end
            end

        end


        function updateImpl(obj,dataIn,ctrlIn,varargin)

            lineFrameFSM(obj,varargin{:});
            for ii=1:obj.PrivNRegions
                [hStart,hEnd,vStart,vEnd,valid]=setROIOutputs(obj,ii);
                obj.OutputControlRegs(ii,1)=hStart;
                obj.OutputControlRegs(ii,2)=hEnd;
                obj.OutputControlRegs(ii,3)=vStart;
                obj.OutputControlRegs(ii,4)=vEnd;
                obj.OutputControlRegs(ii,5)=valid;
                if(valid==true)
                    obj.OutputDataRegs(:,:,ii)=obj.InputDataReg;
                else
                    if islogical(dataIn)
                        obj.OutputDataRegs(:,:,ii)=false(size(dataIn,1),size(dataIn,2),1);
                    else
                        obj.OutputDataRegs(:,:,ii)=cast(zeros(size(dataIn,1),size(dataIn,2),1),'like',dataIn);
                    end
                end
            end

            obj.InputDataReg=obj.InputDataPreReg;
            obj.InputControlReg=obj.InputControlPreReg;
            obj.InputDataPreReg=dataIn;
            obj.InputControlPreReg=ctrlIn;
            obj.VstartBuf=obj.VstartBufPrev;
            obj.VendFinal=obj.VendPrev;
        end


        function[hStart,hEnd,vStart,vEnd,valid]=setROIOutputs(obj,ii)

            regionX=obj.RegionRegs(ii,1);
            regionY=obj.RegionRegs(ii,2);
            regionXend=obj.RegionRegs(ii,1)+obj.RegionRegs(ii,3)-1;
            regionYend=obj.RegionRegs(ii,2)+obj.RegionRegs(ii,4)-1;

            valid=obj.InputControlReg.valid&&...
            obj.InFrame&&obj.InLine&&...
            (obj.HCount>=regionX)&&(obj.HCount<=regionXend)&&...
            (obj.VCount>=regionY)&&(obj.VCount<=regionYend);

            validEdge=obj.InputControlReg.valid&&...
            obj.InFramePrev&&obj.InLinePrev&&...
            (obj.HCount>=regionX)&&(obj.HCount<=regionXend)&&...
            (obj.VCount>=regionY)&&(obj.VCount<=regionYend+1);



            lastEdge=obj.InputControlReg.vEnd&&...
            (obj.VCount>=regionY)&&(obj.VCount<=regionYend+1);

            hStart=valid&&(obj.InputControlReg.hStart||(obj.HCount==regionX));
            hEnd=(obj.ValidPrev(ii)&&validEdge&&obj.InputControlReg.hEnd)||...
            (valid&&(obj.HCount==regionXend));
            vStart=valid&&(obj.InputControlReg.vStart||((obj.VCount==regionY)&&(obj.HCount==regionX)));


            vEndTerm=(obj.ValidPrev(ii)&&validEdge&&obj.InputControlReg.vEnd)||...
            (obj.ValidPrev(ii)&&validEdge&&hEnd&&obj.VCount==regionYend+1)||...
            (valid&&((obj.VCount==regionYend)&&(obj.HCount==regionXend)));


            obj.VstartBufPrev(ii)=vStart||(~obj.VendFinal(ii)&&obj.VstartBuf(ii));



            if~valid&&(hEnd||vEndTerm)
                valid=true;
            end


            obj.VendPrev(ii)=vEndTerm||(obj.VstartBuf(ii)&&lastEdge);
            obj.ValidPrev(ii)=valid;
            vEnd=obj.VendPrev(ii);
        end

        function updateRegionRegs(obj,varargin)
            if~coder.target('hdl')
                if obj.VerticalReuse
                    for ii=1:obj.PrivNRegions
                        obj.RegionRegs(ii,:)=uint32(obj.SortedRegions(ii,:));
                    end

                    if obj.VIndex>1


                        regionYend=obj.SortedRegions((obj.VIndex*obj.PrivNRegions)-obj.PrivNRegions,4)+obj.SortedRegions((obj.VIndex*obj.PrivNRegions)-obj.PrivNRegions,2)-1;
                        offset=obj.SortedRegions((obj.VIndex*obj.PrivNRegions),2)-regionYend;
                        for ii=1:obj.PrivNRegions
                            obj.RegionRegs(ii,2)=uint32(offset);
                            obj.RegionRegs(ii,4)=uint32(obj.SortedRegions((obj.VIndex*obj.PrivNRegions),4));
                        end
                    end
                else
                    if strcmp(obj.RegionsSource,'Input port')
                        minhSizevSize=true;
                        for ii=1:obj.PrivNRegions
                            inputregionSize=size(uint32(varargin{ii}));
                            if(inputregionSize(1)==4||inputregionSize(2)==4)&&(inputregionSize(1)==1||inputregionSize(2)==1)
                                validInputRegion=true;
                            else
                                validInputRegion=false;
                            end


                            coder.internal.errorIf(~validInputRegion,'visionhdl:ROISelector:InvalidRegionsProperty');
                            obj.RegionRegs(ii,:)=uint32(varargin{ii});

                            if(obj.RegionRegs(ii,3)<2||obj.RegionRegs(ii,4)<2)&&obj.NumPix==1
                                minhSizevSize=false;
                            end
                            coder.internal.errorIf(~minhSizevSize,'visionhdl:ROISelector:MinhSizevSize');
                        end


                        validateattributes(obj.RegionRegs,...
                        {'numeric'},{'real','integer','>=',1},'ROISelector','Regions');


                        if obj.NumPix>1
                            regInValid=true;
                            for regIndex=1:obj.PrivNRegions
                                if~(mod(obj.RegionRegs(regIndex,1),obj.NumPix)==1&&mod(obj.RegionRegs(regIndex,3),obj.NumPix)==0)
                                    regInValid=false;
                                    break;
                                end
                            end
                            coder.internal.errorIf(~regInValid,'visionhdl:ROISelector:InvalidRegionsMP');
                        end
                        if obj.NumPix>1
                            minhSizevSize=true;


                            for ii=1:obj.PrivNRegions

                                if(obj.RegionRegs(ii,3)<2*obj.NumPix||obj.RegionRegs(ii,4)<2)
                                    minhSizevSize=false;
                                end
                                coder.internal.errorIf(~minhSizevSize,'visionhdl:ROISelector:MinhSizevSize');
                                ScaledRegions=[max(1,(floor(obj.RegionRegs(ii,1)/obj.NumPix)+1)),obj.RegionRegs(ii,2),obj.RegionRegs(ii,3)/obj.NumPix,obj.RegionRegs(ii,4)];
                                obj.RegionRegs(ii,:)=ScaledRegions;
                            end
                        end
                    end
                end
            else

                if strcmp(obj.RegionsSource,'Input port')
                    for ii=1:obj.PrivNRegions
                        obj.RegionRegs(ii,:)=uint32(varargin{ii});
                    end
                end
            end
        end

        function sRegions=sortRegions(obj)



            regionsdimension=size(obj.Regions);
            regions=zeros(regionsdimension(1),regionsdimension(2));
            Regs=zeros(regionsdimension(1),regionsdimension(2));
            if obj.NumPix>1
                minhSizevSize=true;


                for ii=1:size(obj.Regions,1)

                    if(obj.Regions(ii,3)<2*obj.NumPix||obj.Regions(ii,4)<2)
                        minhSizevSize=false;
                    end
                    coder.internal.errorIf(~minhSizevSize,'visionhdl:ROISelector:MinhSizevSize');
                    ScaledRegions=[max(1,(floor(obj.Regions(ii,1)/obj.NumPix)+1)),obj.Regions(ii,2),obj.Regions(ii,3)/obj.NumPix,obj.Regions(ii,4)];
                    Regs(ii,:)=ScaledRegions;
                end
            else
                minhSizevSize=true;
                for ii=1:size(obj.Regions,1)

                    if(obj.Regions(ii,3)<2||obj.Regions(ii,4)<2)
                        minhSizevSize=false;
                    end
                    coder.internal.errorIf(~minhSizevSize,'visionhdl:ROISelector:MinhSizevSize');
                end
                Regs=obj.Regions;
            end


            sortedVerRegions=sortrows(Regs,2);

            minVPos=min(sortedVerRegions(:,2));

            numHtiles=sum(sortedVerRegions(:,2)==minVPos);
            for regIdx=1:numHtiles:regionsdimension(1)
                if regIdx+numHtiles-1<=regionsdimension(1)

                    regions(regIdx:regIdx+numHtiles-1,:)=sortrows(sortedVerRegions(regIdx:regIdx+numHtiles-1,:),1);
                end
            end

            sRegions=regions;
        end

        function lineFrameFSM(obj,varargin)


            obj.InFramePrev=obj.InFrame;
            obj.InLinePrev=obj.InLine;

            if obj.InputControlReg.valid
                if obj.InFrame&&obj.InLine
                    obj.HCount(:)=obj.HCount+1;
                end
                if obj.InputControlReg.vStart
                    obj.InFrame=true;
                    obj.VCount=uint32(1);

                    updateRegionRegs(obj,varargin{:});
                    if obj.InputControlReg.hStart
                        obj.InLine=true;
                        obj.HCount=uint32(1);
                    else

                    end
                elseif obj.InFrame&&obj.InputControlReg.vEnd
                    obj.InFrame=false;
                    if obj.InputControlReg.hEnd
                        obj.InLine=false;
                    else

                    end
                elseif obj.InFrame&&obj.InLine&&obj.InputControlReg.hEnd
                    obj.VCount(:)=obj.VCount+1;
                    obj.InLine=false;
                elseif obj.InFrame&&obj.InputControlReg.hStart
                    obj.InLine=true;
                    obj.HCount=uint32(1);
                elseif obj.InFrame&&~obj.InLine&&obj.InputControlReg.hEnd
                    obj.InLine=false;

                elseif~obj.InFrame&&(obj.InputControlReg.hStart||obj.InputControlReg.hEnd)

                end
                if obj.VerticalReuse


                    vSize=obj.RegionRegs(1,2)+obj.RegionRegs(1,4)-1;
                end
                if obj.VerticalReuse&&obj.VCount==(vSize+1)&&...
                    obj.InputControlReg.hStart&&obj.VIndex<obj.NumVTiles


                    obj.VCount=uint32(1);

                    obj.VIndex(:)=obj.VIndex+1;


                    updateRegionRegs(obj,varargin{:});
                end

                if obj.VerticalReuse&&obj.InputControlReg.vEnd

                    obj.VIndex=uint32(1);
                end

            end
        end

        function num=getNumInputsImpl(obj)
            num=2;
            if strcmp(obj.RegionsSource,'Input port')
                num=num+obj.NumberOfRegions;
            end
        end

        function num=getNumOutputsImpl(obj)
            if~coder.target('hdl')
                if obj.VerticalReuse

                    coder.internal.errorIf(size(obj.Regions,1)~=size(unique(obj.Regions,'rows'),1),'visionhdl:ROISelector:InvalidRegions');
                    regionsdimension=size(obj.Regions);
                    regions=zeros(regionsdimension(1),regionsdimension(2));

                    if(isempty(coder.target))
                        sortedVerRegions=sortrows(obj.Regions,2);
                    else
                        sortedVerRegions=coder.const(@sortrows,obj.Regions,2);
                    end

                    minVPos=min(sortedVerRegions(:,2));
                    minHPos=min(sortedVerRegions(:,1));

                    numHorTiles=sum(sortedVerRegions(:,2)==minVPos);
                    numVerTiles=sum(sortedVerRegions(:,1)==minHPos);
                    coder.internal.errorIf((numVerTiles>1024),'visionhdl:ROISelector:InvalidRegions');
                    for regIdx=1:numHorTiles:regionsdimension(1)
                        if regIdx+numHorTiles-1<=regionsdimension(1)

                            regions(regIdx:regIdx+numHorTiles-1,:)=sortrows(sortedVerRegions(regIdx:regIdx+numHorTiles-1,:),1);
                        end
                    end


                    vAlign=true;
                    vOverlap=true;
                    for regIdx=1:size(obj.Regions,1)
                        if regIdx+numHorTiles<=size(obj.Regions,1)

                            if~(regions(regIdx,1)==regions(regIdx+numHorTiles,1)&&regions(regIdx,3)==regions(regIdx+numHorTiles,3))
                                vAlign=false;
                            end





                            if~(regions(regIdx,2)+regions(regIdx,4)<=regions(regIdx+numHorTiles,2))
                                vOverlap=false;
                            end
                        end
                    end

                    if numVerTiles==1
                        if numHorTiles==1
                            vAlign=true;
                        else
                            for regIdx=1:size(obj.Regions,1)-1
                                if~(regions(regIdx,3)==regions(regIdx+1,3))
                                    vAlign=false;
                                end
                            end
                        end
                    end
                    coder.internal.errorIf(~vAlign,'visionhdl:ROISelector:InvalidRegions');
                    coder.internal.errorIf(~vOverlap,'visionhdl:ROISelector:InvalidRegions');

                    num=numHorTiles*2;

                    validateattributes(num,...
                    {'numeric'},{'>=',1,'<=',32},'ROISelector','NumberOfOutputPorts');
                else
                    if strcmp(obj.RegionsSource,'Input port')
                        num=obj.NumberOfRegions*2;
                    else
                        num=size(obj.Regions,1)*2;

                        validateattributes(size(obj.Regions,1),...
                        {'numeric'},{'>=',1,'<=',16},'ROISelector','Regions');
                    end
                end
            else

                if strcmp(obj.RegionsSource,'Input port')
                    num=obj.NumberOfRegions*2;
                else
                    num=size(obj.Regions,1)*2;

                    validateattributes(size(obj.Regions,1),...
                    {'numeric'},{'>=',1,'<=',16},'ROISelector','Regions');
                end
            end
        end

        function icon=getIconImpl(~)
            icon=sprintf('ROI Selector');
        end


        function varargout=getInputNamesImpl(obj)
            numInputs=getNumInputs(obj);
            varargout=cell(1,numInputs);
            varargout{1}='pixel';
            varargout{2}='ctrl';
            if numInputs==3
                varargout{3}='region';
            else
                for ii=3:numInputs
                    varargout{ii}=sprintf('region%d',ii-2);
                end
            end
        end


        function varargout=getOutputNamesImpl(obj)
            numOutputs=getNumOutputs(obj);
            varargout=cell(1,numOutputs);
            if numOutputs==2
                varargout{1}='pixel';
                varargout{2}='ctrl';
            else
                for ii=0:numOutputs-1
                    varargout{ii*2+1}=sprintf('pixel%d',ii+1);
                    varargout{ii*2+2}=sprintf('ctrl%d',ii+1);
                end
            end
        end


        function varargout=getOutputSizeImpl(obj)
            for ii=1:2:getNumOutputs(obj)
                varargout{ii}=propagatedInputSize(obj,1);
                varargout{ii+1}=propagatedInputSize(obj,2);
            end
        end

        function varargout=isOutputComplexImpl(obj)
            for ii=1:2:getNumOutputs(obj)
                varargout{ii}=propagatedInputComplexity(obj,1);
                varargout{ii+1}=propagatedInputComplexity(obj,2);
            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            intype=propagatedInputDataType(obj,1);
            for ii=1:2:getNumOutputs(obj)
                varargout{ii}=intype;
                varargout{ii+1}=pixelcontrolbustype;
            end
        end

        function varargout=isOutputFixedSizeImpl(obj)
            for ii=1:2:getNumOutputs(obj)
                varargout{ii}=propagatedInputFixedSize(obj,1);
                varargout{ii+1}=propagatedInputFixedSize(obj,2);
            end
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

    end

end
